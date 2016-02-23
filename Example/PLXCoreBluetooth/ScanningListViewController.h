#import <UIKit/UIKit.h>
@import CoreBluetooth;

@interface ScanningListViewController : UIViewController

@property(nonatomic, assign) NSInteger scanItemsCount;
@property(nonatomic, assign) BOOL scanInfiniteDevices;
@property(nonatomic, copy) NSString *UUIDToScan;

@end
