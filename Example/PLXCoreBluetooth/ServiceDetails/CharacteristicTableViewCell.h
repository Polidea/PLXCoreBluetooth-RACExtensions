#import <Foundation/Foundation.h>


@interface CharacteristicTableViewCell : UITableViewCell {}

@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *propertiesLabel;
@property (weak, nonatomic) IBOutlet UILabel *isNotifyingLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptorsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptorsSummaryLabel;

@end