#import <Foundation/Foundation.h>


@interface PeripheralDetailsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property(nonatomic, strong) CBPeripheral *peripheral;
@end