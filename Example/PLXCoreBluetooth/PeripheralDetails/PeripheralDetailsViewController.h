#import <Foundation/Foundation.h>


@interface PeripheralDetailsViewController : UIViewController
@property(weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property(weak, nonatomic) IBOutlet UILabel *nameLabel;
@property(weak, nonatomic) IBOutlet UILabel *rssiLabel;
@property(weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionsBarButton;
@property(nonatomic, strong) CBPeripheral *peripheral;
@property(nonatomic, strong) CBCentralManager *centralManager;
@end