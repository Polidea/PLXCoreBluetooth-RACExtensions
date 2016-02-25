#import <PLXCoreBluetooth/CBCentralManager+PLXRACExtensions.h>
#import <objc/objc.h>
#import "ScanningListViewController.h"
#import "ScanningPeripheralCell.h"

@interface ScanningListViewController ()
@property(nonatomic, strong) CBCentralManager *centralManager;
@property(nonatomic, strong) NSMutableDictionary<CBPeripheral *, RACTuple *> *peripheralsDict;

@end

@implementation ScanningListViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.peripheralsDict = [NSMutableDictionary dictionary];
    }

    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupBluetoothCentral];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.centralManager stopScan];
}

- (void)setupBluetoothCentral {
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:nil queue:nil];
    self.centralManager.shouldWaitUntilPoweredOn = YES;
    NSInteger itemsCount = self.shouldScanInfiniteDevices ? PLXCBCentralManagerScanInfiniteCount : self.scanItemsCount;
    NSArray *serviceUUIDs = self.UUIDToScan.length != 0 ? @[self.UUIDToScan] : nil;

    @weakify(self)
    [[[self.centralManager
            rac_scanForPeripheralsWithServices:serviceUUIDs
                                         count:itemsCount
                                       options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES}]
            filter:^BOOL(id __) {
                @strongify(self)
                return !self.scanningEnabledSwitch.on;
            }]
            subscribeNext:^(RACTuple *tuple) {
                @strongify(self)
                self.peripheralsDict[tuple.first] = tuple;

                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self)
                    [self.tableView reloadData];
                });
            }
                    error:^(NSError *error) {
                        NSLog(@"scan error = %@", error);
                    }];
}

- (RACTuple *)peripheralDataForIndexPath:(NSIndexPath *)indexPath {
    NSArray *sortedPeripherals = [self.peripheralsDict.allKeys sortedArrayUsingComparator:^NSComparisonResult(CBPeripheral *obj1, CBPeripheral *obj2) {
        return [obj1.identifier.UUIDString compare:obj2.identifier.UUIDString];
    }];

    return self.peripheralsDict[sortedPeripherals[(NSUInteger) indexPath.row]];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.peripheralsDict.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ScanningPeripheralCell *cell = [tableView dequeueReusableCellWithIdentifier:@"peripheralCell" forIndexPath:indexPath];

    RACTupleUnpack(CBPeripheral *peripheral, NSDictionary *advDataDict, NSNumber *RSSI) = [self peripheralDataForIndexPath:indexPath];

    cell.advDataLabel.text = [[NSString stringWithFormat:@"%@", advDataDict] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    cell.RSSILabel.text = [NSString stringWithFormat:@"RSSI: %@", RSSI];
    cell.nameLabel.text = peripheral.identifier.UUIDString;

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    @weakify(self)
    UITableViewRowAction *showAdvDictAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Show Adv Details" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath2) {
        @strongify(self)
        NSDictionary *advDataDict = [self peripheralDataForIndexPath:indexPath2].second;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Adv Data"
                                                                                 message:[NSString stringWithFormat:@"%@", advDataDict]
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alertController addAction:actionOk];
        [self presentViewController:alertController animated:YES completion:nil];
    }];

    return @[showAdvDictAction];
}


@end
