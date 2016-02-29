#import <PLXCoreBluetooth/CBPeripheral+PLXRACExtensions.h>
#import <PLXCoreBluetooth/CBCentralManager+PLXRACExtensions.h>
#import "PeripheralDetailsViewController.h"
#import "ServiceTableViewCell.h"
#import "ServiceDetailsViewController.h"


@implementation PeripheralDetailsViewController {

}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = [NSString stringWithFormat:@"Peripheral: %@", self.peripheral.identifier.UUIDString];
    self.uuidLabel.text = [NSString stringWithFormat:@"UUID: %@", self.peripheral.identifier.UUIDString];

    @weakify(self)
    [[[self.peripheral rac_name]
            deliverOnMainThread]
            subscribeNext:
                    ^(NSString *name) {
                        NSLog(@"Received name %@", name);
                        @strongify(self)
                        self.title = [NSString stringWithFormat:@"Peripheral: %@", name];
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

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showService"]) {
        ServiceDetailsViewController *serviceDetailsViewController = segue.destinationViewController;

        CBService *service = self.peripheral.services[(NSUInteger) [self.tableView indexPathForCell:sender].row];
        serviceDetailsViewController.service = service;
    }
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


    UIAlertAction *readRSSIAction = [UIAlertAction actionWithTitle:@"Read RSSI"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *_) {
                                                               @strongify(self)
                                                               [[[self.peripheral rac_readRSSI]
                                                                       deliverOnMainThread]
                                                                       subscribeNext:^(NSNumber *RSSI) {
                                                                           @strongify(self)
                                                                           NSLog(@"RSSI = %@", RSSI);
                                                                           self.rssiLabel.text = [NSString stringWithFormat:@"RSSI: %@", RSSI];
                                                                       }
                                                                               error:^(NSError *error) {
                                                                                   NSLog(@"Error while reading RSSI: %@", error);
                                                                               }];
                                                           }];


    UIAlertAction *discoverServicesAction = [UIAlertAction actionWithTitle:@"Discover services"
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction *_) {
                                                                       @strongify(self)
                                                                       [[[self.peripheral rac_discoverServices:nil]
                                                                               deliverOnMainThread]
                                                                               subscribeNext:
                                                                                       ^(id __) {
                                                                                           NSLog(@"Discovered services");
                                                                                           @strongify(self)
                                                                                           [self.tableView reloadData];
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
    [alertController addAction:readRSSIAction];
    [alertController addAction:discoverServicesAction];
    [alertController addAction:disconnectAction];

    alertController.popoverPresentationController.barButtonItem = self.actionsBarButton;
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.peripheral.services.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ServiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"serviceCell" forIndexPath:indexPath];

    CBService *service = self.peripheral.services[(NSUInteger) indexPath.row];

    cell.uuidLabel.text = [NSString stringWithFormat:@"UUID: %@", service.UUID.UUIDString];
    cell.isPrimaryLabel.text = [NSString stringWithFormat:@"Is Primary: %@", service.isPrimary ? @"YES" : @"NO"];
    cell.includedServicesCountLabel.text = [NSString stringWithFormat:@"Included services count: %@", @(service.includedServices.count)];
    cell.characteristicsCountLabel.text = [NSString stringWithFormat:@"Characteristics count: %@", @(service.characteristics.count)];

    return cell;
}


@end