#import <Foundation/Foundation.h>


@interface CharacteristicDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *isNotifyingLabel;
@property (weak, nonatomic) IBOutlet UILabel *propertiesLabel;
@property (weak, nonatomic) IBOutlet UITextField *characteristicNewValueTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISwitch *writeResponseSwitch;

@property(nonatomic, strong) CBCharacteristic *characteristic;
@property(nonatomic, strong) CBPeripheral *peripheral;
@end