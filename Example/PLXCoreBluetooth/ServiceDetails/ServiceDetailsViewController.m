#import "ServiceDetailsViewController.h"
#import "CharacteristicDetailsViewController.h"
#import "ServiceTableViewCell.h"
#import "CharacteristicTableViewCell.h"
#import <PLXCoreBluetooth/CBCentralManager+PLXRACExtensions.h>
#import <PLXCoreBluetooth/CBPeripheral+PLXRACExtensions.h>

@implementation ServiceDetailsViewController {
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = [NSString stringWithFormat:@"Service: %@", self.service.UUID.UUIDString];
    self.uuidLabel.text = [NSString stringWithFormat:@"UUID: %@", self.service.UUID.UUIDString];
    self.isPrimaryLabel.text = [NSString stringWithFormat:@"Is Primary: %@", self.service.isPrimary ? @"YES" : @"NO"];

    self.tableView.estimatedRowHeight = 88;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showService"]) {
        ServiceDetailsViewController *serviceDetailsViewController = segue.destinationViewController;

        CBService *service = self.service.includedServices[(NSUInteger) [self.tableView indexPathForCell:sender].row];
        serviceDetailsViewController.service = service;
    } else if ([segue.identifier isEqualToString:@"showCharacteristic"]) {
        CharacteristicDetailsViewController *characteristicDetailsViewController = segue.destinationViewController;

        CBCharacteristic *characteristic = self.service.characteristics[(NSUInteger) [self.tableView indexPathForCell:sender].row];
        characteristicDetailsViewController.characteristic = characteristic;
        characteristicDetailsViewController.peripheral = self.service.peripheral;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    @weakify(self)
    [[[self.service.peripheral rac_discoverIncludedServices:nil forService:self.service]
            deliverOnMainThread]
            subscribeNext:^(id _) {
                NSLog(@"Discovered included services for %@", self.service);
                @strongify(self)
                [self.tableView reloadData];

            }
                    error:^(NSError *error) {
                        NSLog(@"Error while discovering included services = %@", error);
                    }];

    [[[self.service.peripheral rac_discoverCharacteristics:nil forService:self.service]
            deliverOnMainThread]
            subscribeNext:^(id _) {
                @strongify(self)
                NSLog(@"Discovered characteristics for service %@", self.service);
                [self.tableView reloadData];
            }
                    error:^(NSError *error) {
                        NSLog(@"Error while discovering characteristics = %@", error);
                    }];
}


#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? self.service.includedServices.count : self.service.characteristics.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [tableView dequeueReusableCellWithIdentifier:@"servicesHeader"];
    } else if (section == 1) {
        return [tableView dequeueReusableCellWithIdentifier:@"characteristicsHeader"];
    }

    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        ServiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"serviceCell"];
        CBService *service = self.service.includedServices[(NSUInteger) indexPath.row];

        cell.uuidLabel.text = [NSString stringWithFormat:@"UUID: %@", service.UUID.UUIDString];
        cell.isPrimaryLabel.text = [NSString stringWithFormat:@"Is Primary: %@", service.isPrimary ? @"YES" : @"NO"];
        cell.includedServicesCountLabel.text = [NSString stringWithFormat:@"Included services count: %@", @(service.includedServices.count)];
        cell.characteristicsCountLabel.text = [NSString stringWithFormat:@"Characteristics count: %@", @(service.characteristics.count)];

        return cell;
    } else if (indexPath.section == 1) {
        CharacteristicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"characteristicCell"];
        CBCharacteristic *characteristic = self.service.characteristics[(NSUInteger) indexPath.row];

        cell.uuidLabel.text = [NSString stringWithFormat:@"UUID: %@", characteristic.UUID.UUIDString];
        cell.valueLabel.text = [NSString stringWithFormat:@"Value : %@", characteristic.value];
        cell.propertiesLabel.text = [NSString stringWithFormat:@"Properties : %@", @(characteristic.properties)];
        cell.isNotifyingLabel.text = [NSString stringWithFormat:@"Is Notifying: %@", characteristic.isNotifying ? @"YES" : @"NO"];
        cell.descriptorsCountLabel.text = [NSString stringWithFormat:@"Descriptors count: %@", @(characteristic.descriptors.count)];

        NSMutableArray *descriptorValues = [NSMutableArray array];

        for (CBDescriptor *cbDescriptor in characteristic.descriptors) {
            if (cbDescriptor.value) {
                [descriptorValues addObject:cbDescriptor.value];
            }
        }

        cell.descriptorsSummaryLabel.text = [NSString stringWithFormat:@"Descriptors summary: %@", [descriptorValues componentsJoinedByString:@","]];

        return cell;
    }

    return nil;
}


@end