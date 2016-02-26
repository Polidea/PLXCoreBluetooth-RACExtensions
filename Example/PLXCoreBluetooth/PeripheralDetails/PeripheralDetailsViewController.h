#import <Foundation/Foundation.h>


@interface PeripheralDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property(weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property(weak, nonatomic) IBOutlet UILabel *nameLabel;
@property(weak, nonatomic) IBOutlet UILabel *rssiLabel;
@property(weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionsBarButton;
@property(nonatomic, strong) CBPeripheral *peripheral;
@property(nonatomic, strong) CBCentralManager *centralManager;
@end