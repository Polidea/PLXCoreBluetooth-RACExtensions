#import <PLXCoreBluetooth/CBPeripheral+PLXRACExtensions.h>
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
}

@end