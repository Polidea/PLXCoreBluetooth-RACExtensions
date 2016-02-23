#import <UIKit/UIKit.h>
@import CoreBluetooth;

@interface ScanningListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, assign) NSInteger scanItemsCount;
@property(nonatomic, assign) BOOL shouldScanInfiniteDevices;
@property(nonatomic, copy) NSString *UUIDToScan;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISwitch *scanningEnabledSwitch;

@end