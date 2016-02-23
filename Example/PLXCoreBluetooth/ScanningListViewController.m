#import <PLXCoreBluetooth/CBCentralManager+PLXRACExtensions.h>
#import "ScanningListViewController.h"

@interface ScanningListViewController ()
@property(nonatomic, strong) CBCentralManager *centralManager;
@end

@implementation ScanningListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.centralManager = [[CBCentralManager alloc] initWithDelegate:nil queue:nil];
    NSInteger itemsCount = self.scanInfiniteDevices ? PLXCBCentralManagerScanInfiniteCount : self.scanItemsCount;
    NSArray *serviceUUIDs = self.UUIDToScan.length != 0 ? @[self.UUIDToScan] : nil;

    @weakify(self)
    [[[self.centralManager rac_isPoweredOn]
            ignore:@NO]
            subscribeNext:^(id _) {
                @strongify(self)
                [[self.centralManager rac_scanForPeripheralsWithServices:serviceUUIDs
                                                                   count:itemsCount
                                                                 options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES}]
                        subscribeNext:^(id x) {
                            NSLog(@"Peripheral found %@", x);
                        }];
            }];
}


@end
