#import <PLXCoreBluetooth/CBPeripheral+PLXRACExtensions.h>
#import <PLXCoreBluetooth/CBCentralManager+PLXRACExtensions.h>
#import <objc/objc.h>
#import "PeripheralDetailsViewController.h"
#import "ServiceTableViewCell.h"
#import "ServiceDetailsViewController.h"
#import <Tweaks/FBTweak.h>
#import <Tweaks/FBTweakInline.h>

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

    BOOL autoConnect = FBTweakValue(@"General", @"Helpers", @"Auto connect", YES);
    if (autoConnect) {
        [self connect];
    }
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
                                                              [self connect];
                                                          }];


    UIAlertAction *readRSSIAction = [UIAlertAction actionWithTitle:@"Read RSSI"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *_) {
                                                               @strongify(self)
                                                               [self readRSSI];
                                                           }];


    UIAlertAction *discoverServicesAction = [UIAlertAction actionWithTitle:@"Discover services"
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction *_) {
                                                                       @strongify(self)
                                                                       [self discoverServices];
                                                                   }];
    UIAlertAction *disconnectAction = [UIAlertAction actionWithTitle:@"Disconnect"
                                                               style:UIAlertActionStyleDestructive
                                                             handler:^(UIAlertAction *_) {
                                                                 @strongify(self)
                                                                 [self disconnect];
                                                             }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];

    [alertController addAction:connectAction];
    [alertController addAction:readRSSIAction];
    [alertController addAction:discoverServicesAction];
    [alertController addAction:disconnectAction];
    [alertController addAction:cancelAction];

    alertController.popoverPresentationController.barButtonItem = self.actionsBarButton;
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)connect {
    @weakify(self)
    [[self.centralManager rac_connectPeripheral:self.peripheral options:nil]
            subscribeNext:^(CBPeripheral *peripheral) {
                @strongify(self)
                NSLog(@"Connected to %@", peripheral);
                BOOL autoDiscovery = FBTweakValue(@"General", @"Helpers", @"Auto discovery", YES);
                if (autoDiscovery) {
                    [self autoDiscover];
                }
            }
                    error:^(NSError *error) {
                        NSLog(@"Error while connecting to peripheral %@", error);
                    }];
}

- (void)readRSSI {
    @weakify(self)
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
}

- (void)discoverServices {
    @weakify(self)
    [[[self.peripheral rac_discoverServices:nil]
            deliverOnMainThread]
            subscribeNext:
                    ^(id __) {
                        NSLog(@"Discovered services");
                        @strongify(self)
                        [self.tableView reloadData];
                    }];
}

- (void)disconnect {
    [[self.centralManager rac_disconnectPeripheralConnection:self.peripheral]
            subscribeNext:^(CBPeripheral *peripheral) {
                NSLog(@"Disconnected from %@", peripheral);
            }
                    error:^(NSError *error) {
                        NSLog(@"Error while disconnecting from peripheral %@", error);
                    }];
}

- (void)autoDiscover {
    @weakify(self)
    [[[[[[[self.peripheral rac_readRSSI]
            flattenMap:^RACStream *(NSNumber *rssi) {
                @strongify(self)
                NSLog(@"Read RSSI %@", rssi);

                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self)
                    self.rssiLabel.text = [NSString stringWithFormat:@"RSSI: %@", rssi];
                });

                return [self.peripheral rac_discoverServices:nil];
            }]
            flattenMap:^RACStream *(NSArray *services) {
                @strongify(self)
                NSLog(@"Discovered all 1st level services (%@ found)", @(services.count));
                NSMutableArray *processServicesArray = [NSMutableArray array];

                for (CBService *service in services) {
                    [processServicesArray addObject:[self processService:service]];
                }
                return [RACSignal zip:processServicesArray];
            }]
            materialize]
            deliverOnMainThread]
            doNext:^(id _) {
                @strongify(self)
                [self.tableView reloadData];
            }]
            subscribeError:
                    ^(NSError *error) {
                        NSLog(@"Error during auto discovery = %@", error);
                    }
                 completed:
                         ^{
                             NSLog(@"Auto discovery complete");
                         }];
}

- (RACSignal *)processService:(CBService *)service {
    RACSignal *processServiceWithIncludedServicesSignal = [[service.peripheral rac_discoverIncludedServices:@[] forService:service]
            flattenMap:^RACStream *(NSArray *includedServices) {
                NSMutableArray *processIncludedServices = [NSMutableArray array];

                for (CBService *includedService in includedServices) {
                    [processIncludedServices addObject:[self processService:includedService]];
                }

                NSLog(@"Will process %@ more services", @(includedServices.count));
                return includedServices.count == 0 ? [RACSignal return:@YES] : [RACSignal zip:processIncludedServices];
            }];
    RACSignal *processServiceWithoutIncludedServicesSignal = [self discoverAndReadCharacteristicsForService:service];
    RACSignal *doesServiceIncludeOtherServicesSignal = [RACSignal return:@(service.includedServices.count != 0)];

    return [RACSignal if:doesServiceIncludeOtherServicesSignal
                    then:processServiceWithIncludedServicesSignal
                    else:processServiceWithoutIncludedServicesSignal];
}

- (RACSignal *)discoverAndReadCharacteristicsForService:(CBService *)service {
    @weakify(self)
    return [[[service.peripheral rac_discoverCharacteristics:@[] forService:service]
            flattenMap:^RACStream *(NSArray *characteristics) {
                @strongify(self)
                NSLog(@"Read characteristics for service %@ : %@", service, characteristics);
                NSMutableArray *readCharacteristicsArray = [NSMutableArray array];

                for (CBCharacteristic *characteristic in characteristics) {
                    [readCharacteristicsArray addObject:[self discoverAndReadDescriptorsForCharacteristic:characteristic]];
                }

                return characteristics.count == 0 ? [RACSignal return:@YES] : [RACSignal zip:readCharacteristicsArray];
            }]
            doNext:^(id _) {
                NSLog(@"Read all characteristics for service %@", service);
            }];
}


- (RACSignal *)discoverAndReadDescriptorsForCharacteristic:(CBCharacteristic *)characteristic {
    return [[[[[characteristic.service.peripheral rac_discoverDescriptorsForCharacteristic:characteristic]
            flattenMap:^RACStream *(NSArray *descriptors) {
                NSLog(@"Discovered descriptors for characteristic %@ : %@", characteristic, descriptors);
                NSMutableArray *readDescriptorsArray = [NSMutableArray array];

                for (CBDescriptor *descriptor in descriptors) {
                    [readDescriptorsArray addObject:[characteristic.service.peripheral rac_readValueForDescriptor:descriptor]];
                }

                return descriptors.count == 0 ? [RACSignal return:@YES] : [RACSignal zip:readDescriptorsArray];
            }]
            doNext:^(id _) {
                NSLog(@"Read all descriptors values for characteristic: %@", characteristic);
            }]
            flattenMap:^RACStream *(id _) {
                return [characteristic.service.peripheral rac_readValueForCharacteristic:characteristic];
            }]
            doNext:^(id _) {
                NSLog(@"Read characteristic value %@", characteristic);
            }];
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