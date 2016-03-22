#import <UIKit/UIKit.h>
@import CoreBluetooth;
@import Tweaks;

@interface ScanningListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, strong) RACDisposable *scanDisposable;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *scanButton;

@end