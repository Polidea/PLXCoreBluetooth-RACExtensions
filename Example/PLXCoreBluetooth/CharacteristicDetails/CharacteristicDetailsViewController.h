#import <Foundation/Foundation.h>


@interface CharacteristicDetailsViewController : UIViewController{}

@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UIButton *isNotifyingLabel;
@property (weak, nonatomic) IBOutlet UILabel *propertiesLabel;
@property (weak, nonatomic) IBOutlet UITextField *characteristicNewValueTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic, strong) CBCharacteristic *characteristic;
@end