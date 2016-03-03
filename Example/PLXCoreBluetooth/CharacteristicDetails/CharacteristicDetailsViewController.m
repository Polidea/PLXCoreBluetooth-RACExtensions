#import <PLXCoreBluetooth/CBPeripheral+PLXRACExtensions.h>
#import "CharacteristicDetailsViewController.h"
#import "DescriptorTableViewCell.h"


@implementation CharacteristicDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.title = [NSString stringWithFormat:@"Characteristic: %@", self.characteristic.UUID.UUIDString];

    self.uuidLabel.text = [NSString stringWithFormat:@"UUID: %@", self.characteristic.UUID.UUIDString];
    self.isNotifyingLabel.text = [NSString stringWithFormat:@"Is Notifying: %@", @(self.characteristic.isNotifying)];
    self.propertiesLabel.text = [NSString stringWithFormat:@"Properties: %@", [CharacteristicDetailsViewController characteristicPropertiesString:self.characteristic.properties]];

    if (self.characteristic.value) {
        self.valueLabel.text = [NSString stringWithFormat:@"Value: %@", self.characteristic.value];
    }

    @weakify(self)
    [[[[[self.peripheral rac_discoverDescriptorsForCharacteristic:self.characteristic]
            doNext:^(id _) {
                DDLogDebug(@"Successfully read descriptors for %@", self.characteristic);

                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self)
                    [self.tableView reloadData];
                });
            }]
            flattenMap:^RACStream *(id _) {
                @strongify(self)
                NSMutableArray *readDescriptorValuesSignals = [NSMutableArray array];
                for (CBDescriptor *descriptor in self.characteristic.descriptors) {
                    [readDescriptorValuesSignals addObject:[self.peripheral rac_readValueForDescriptor:descriptor]];
                }

                return [RACSignal zip:readDescriptorValuesSignals];
            }]
            deliverOnMainThread]
            subscribeNext:^(id _) {
                @strongify(self)
                DDLogDebug(@"Successfully read all descriptor values");
                [self.tableView reloadData];
            }
                    error:^(NSError *error) {
                        DDLogError(@"Error while reading descriptors= %@", error);
                    }];
}


+ (NSString *)characteristicPropertiesString:(CBCharacteristicProperties)properties {
    NSMutableArray *propertiesArray = [NSMutableArray array];

    if (properties & CBCharacteristicPropertyBroadcast) {[propertiesArray addObject:@"Broadcast"];}
    if (properties & CBCharacteristicPropertyRead) {[propertiesArray addObject:@"Read"];}
    if (properties & CBCharacteristicPropertyWriteWithoutResponse) {[propertiesArray addObject:@"WriteWithoutResponse"];}
    if (properties & CBCharacteristicPropertyWrite) {[propertiesArray addObject:@"Write"];}
    if (properties & CBCharacteristicPropertyNotify) {[propertiesArray addObject:@"Notify"];}
    if (properties & CBCharacteristicPropertyIndicate) {[propertiesArray addObject:@"Indicate"];}
    if (properties & CBCharacteristicPropertyAuthenticatedSignedWrites) {[propertiesArray addObject:@"AuthenticatedSignedWrites"];}
    if (properties & CBCharacteristicPropertyExtendedProperties) {[propertiesArray addObject:@"ExtendedProperties"];}
    if (properties & CBCharacteristicPropertyNotifyEncryptionRequired) {[propertiesArray addObject:@"NotifyEncryptionRequired"];}
    if (properties & CBCharacteristicPropertyIndicateEncryptionRequired) {[propertiesArray addObject:@"IndicateEncryptionRequired"];}

    return [propertiesArray componentsJoinedByString:@","];
}

#pragma mark - Actions

- (IBAction)didTapReadButton:(id)sender {
    @weakify(self)
    [[[self.peripheral rac_readValueForCharacteristic:self.characteristic]
            deliverOnMainThread]
            subscribeNext:^(id _) {
                @strongify(self)
                DDLogDebug(@"Successfully read value for characteristic %@", self.characteristic);

                self.valueLabel.text = [NSString stringWithFormat:@"Value: %@", self.characteristic.value];

            } error:^(NSError *error) {
        DDLogError(@"Error while reading value for characteristic %@ = %@", self.characteristic, error);
    }];
}


- (IBAction)didTapReadAndNotifyButton:(id)sender {
    @weakify(self)

    DDLogDebug(@"Will register for notifications in characteristic %@", self.characteristic);
    [[[self.peripheral rac_setNotifyValue:YES andGetUpdatesForChangesInCharacteristic:self.characteristic]
            deliverOnMainThread]
            subscribeNext:^(id x) {
                @strongify(self)
                DDLogDebug(@"Successfully read value for characteristic %@", self.characteristic);
                self.valueLabel.text = [NSString stringWithFormat:@"Value: %@", self.characteristic.value];
            } error:^(NSError *error) {
        DDLogError(@"Error while registering for notifications for characteristic %@ = %@", self.characteristic, error);
    }];
}

- (IBAction)didTapWriteButton:(id)sender {
    NSInteger dataToWrite = [self.characteristicNewValueTextField.text integerValue];
    NSMutableData *mutableDataToWrite = [NSMutableData data];
    [mutableDataToWrite appendBytes:&dataToWrite length:(NSUInteger) [self.valueSizeTextField.text integerValue]];

    CBCharacteristicWriteType writeType = self.writeResponseSwitch.on ? CBCharacteristicWriteWithResponse : CBCharacteristicWriteWithoutResponse;
    [[self.peripheral rac_writeValue:mutableDataToWrite forCharacteristic:self.characteristic writeType:writeType]
            subscribeNext:^(id _) {
                DDLogDebug(@"Successfully written data to characteristic %@", self.characteristic);
            } error:^(NSError *error) {
        DDLogError(@"Error while writing to characteristic = %@", error);
    }];
}


#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.characteristic.descriptors.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DescriptorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"descriptorCell"];
    CBDescriptor *descriptor = self.characteristic.descriptors[(NSUInteger) indexPath.row];

    cell.valueLabel.text = [NSString stringWithFormat:@"Value: %@", descriptor.value];
    return cell;
}


@end