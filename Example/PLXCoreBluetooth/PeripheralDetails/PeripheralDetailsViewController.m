#import <PLXCoreBluetooth/CBPeripheral+PLXRACExtensions.h>
#import <BlocksKit/BlocksKit+UIKit.h>
#import <PLXCoreBluetooth/CBCentralManager+PLXRACExtensions.h>
#import "PeripheralDetailsViewController.h"


@implementation PeripheralDetailsViewController {

}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.peripheral.identifier.UUIDString;
    self.uuidLabel.text = [NSString stringWithFormat:@"UUID: %@", self.peripheral.identifier.UUIDString];

    @weakify(self)
    [[[self.peripheral rac_name]
            deliverOnMainThread]
            subscribeNext:
                    ^(NSString *name) {
                        @strongify(self)
                        self.title = name;
                        self.nameLabel.text = [NSString stringWithFormat:@"Name: %@", name];
                    }];

    [[RACObserve(self.peripheral, state)
            deliverOnMainThread]
            subscribeNext:^(NSNumber *state) {
                @strongify(self)

                CBPeripheralState stateValue = (CBPeripheralState) state.integerValue;
                NSString *stateString = @"Unknown";

                switch (stateValue) {
                    case CBPeripheralStateDisconnected:
                        stateString = @"Disconnected";
                        break;
                    case CBPeripheralStateConnecting:
                        stateString = @"Connecting";
                        break;
                    case CBPeripheralStateConnected:
                        stateString = @"Connected";
                        break;
                    case CBPeripheralStateDisconnecting:
                        stateString = @"Disconnecting";
                        break;
                }
                self.statusLabel.text = [NSString stringWithFormat:@"State: %@", stateString];
            }];

    [self.centralManager rac_disconnectPeripheralConnection:<#(CBPeripheral *)peripheral#>]
}

- (IBAction)actionsButtonTapped:(id)sender {

    @weakify(self)
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *connectAction = [UIAlertAction actionWithTitle:@"Connect"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *_) {
                                                              @strongify(self)

                                                              [[self.centralManager rac_connectPeripheral:self.peripheral options:nil]
                                                                      subscribeNext:^(CBPeripheral *peripheral) {
                                                                          NSLog(@"Connected to %@", peripheral);
                                                                      }
                                                                              error:^(NSError *error) {
                                                                                  NSLog(@"Error while connecting to peripheral %@", error);
                                                                              }];
                                                          }];
    UIAlertAction *disconnectAction = [UIAlertAction actionWithTitle:@"Disconnect"
                                                               style:UIAlertActionStyleDestructive
                                                             handler:^(UIAlertAction *_) {
                                                                 @strongify(self)
                                                                 [[self.centralManager rac_disconnectPeripheralConnection:self.peripheral]
                                                                         subscribeNext:^(CBPeripheral *peripheral) {
                                                                             NSLog(@"Disconnected from %@", peripheral);
                                                                         }
                                                                                 error:^(NSError *error) {
                                                                                     NSLog(@"Error while disconnecting from peripheral %@", error);
                                                                                 }];
                                                             }];
    [alertController addAction:connectAction];
    [alertController addAction:disconnectAction];

    alertController.popoverPresentationController.barButtonItem = self.actionsBarButton;
    [self presentViewController:alertController animated:YES completion:nil];
}

@end