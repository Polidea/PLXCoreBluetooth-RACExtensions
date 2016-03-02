#import <PLXCoreBluetooth/CBPeripheral+PLXRACExtensions.h>
#import "CharacteristicDetailsViewController.h"
#import "DescriptorTableViewCell.h"


@implementation CharacteristicDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.title = [NSString stringWithFormat:@"Characteristic: %@", self.characteristic.UUID.UUIDString];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.uuidLabel.text = [NSString stringWithFormat:@"UUID: %@", self.characteristic.UUID.UUIDString];
    self.isNotifyingLabel.text = [NSString stringWithFormat:@"Is Notifying: %@", @(self.characteristic.isNotifying)];
    self.propertiesLabel.text = [NSString stringWithFormat:@"Properties: %@", @(self.characteristic.properties)];

    if (self.characteristic.value) {
        self.valueLabel.text = [NSString stringWithFormat:@"Value: %@", self.characteristic.value];
    }

    @weakify(self)
    [[[[[self.peripheral rac_discoverDescriptorsForCharacteristic:self.characteristic]
            doNext:^(id x) {
                NSLog(@"Successfully read descriptors for %@", self.characteristic);

                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self)
                    [self.tableView reloadData];
                });
            }]
            flattenMap:^RACStream *(id _) {
                NSMutableArray *readDescriptorValuesSignals = [NSMutableArray array];
                for (CBDescriptor *descriptor in self.characteristic.descriptors) {
                    [readDescriptorValuesSignals addObject:[self.peripheral rac_readValueForDescriptor:descriptor]];
                }

                return [RACSignal zip:readDescriptorValuesSignals];
            }]
            deliverOnMainThread]
            subscribeNext:^(id _) {
                NSLog(@"Successfully read all descriptor values");
                @strongify(self)
                [self.tableView reloadData];
            }
                    error:^(NSError *error) {
                        NSLog(@"Error while reading descriptors= %@", error);
                    }];
}

#pragma mark - Actions


- (IBAction)didTapReadButton:(id)sender {
    @weakify(self)
    [[[self.peripheral rac_readValueForCharacteristic:self.characteristic]
            deliverOnMainThread]
            subscribeNext:^(id _) {
                @strongify(self)
                NSLog(@"Successfully read value for characteristic %@", self.characteristic);

                self.valueLabel.text = [NSString stringWithFormat:@"Value: %@", self.characteristic.value];

            } error:^(NSError *error) {
        NSLog(@"Error while reading value for characteristic %@ = %@", self.characteristic, error);
    }];
}


- (IBAction)didTapReadyAndNotifyButton:(id)sender {
    @weakify(self)

    [[[self.peripheral rac_setNotifyValue:YES andGetUpdatesForChangesInCharacteristic:self.characteristic]
            deliverOnMainThread]
            subscribeNext:^(id x) {
                @strongify(self)
                NSLog(@"Successfully read value for characteristic %@", self.characteristic);
                self.valueLabel.text = [NSString stringWithFormat:@"Value: %@", self.characteristic.value];
            } error:^(NSError *error) {
        NSLog(@"Error while registering for notifications for characteristic %@ = %@", self.characteristic, error);
    }];
}

- (IBAction)didTapWriteButton:(id)sender {
    NSInteger *dataToWrite;
    NSMutableData *mutableDataToWrite = [NSMutableData data];
    [mutableDataToWrite appendBytes:&dataToWrite length:sizeof(dataToWrite)];
    CBCharacteristicWriteType writeType = self.writeResponseSwitch.on ? CBCharacteristicWriteWithResponse : CBCharacteristicWriteWithoutResponse;
    [[self.peripheral rac_writeValue:mutableDataToWrite forCharacteristic:self.characteristic writeType:writeType]
            subscribeNext:^(id _) {
                NSLog(@"Successfully written data to characteristic");
            } error:^(NSError *error) {
        NSLog(@"Error while writing to characteristic= %@", error);
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