#import "CharacteristicDetailsViewController.h"


@implementation CharacteristicDetailsViewController {

}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = [NSString stringWithFormat:@"Characteristic: %@", self.characteristic.UUID.UUIDString];
}


@end