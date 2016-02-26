#import <Foundation/Foundation.h>


@interface ServiceDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {}
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UILabel *isPrimaryLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic, strong) CBService *service;
@end