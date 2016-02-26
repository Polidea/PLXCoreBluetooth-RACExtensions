#import <Foundation/Foundation.h>


@interface ServiceTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UILabel *isPrimaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *includedServicesCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *characteristicsCountLabel;

@end