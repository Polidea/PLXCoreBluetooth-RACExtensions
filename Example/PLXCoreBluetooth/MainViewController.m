#import "MainViewController.h"
#import "ScanningListViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"StartScanningSegue"]) {
        ScanningListViewController *scanningListViewController = segue.destinationViewController;

        scanningListViewController.scanInfiniteDevices = self.scanInfiniteItemsSwitch.isOn;
        scanningListViewController.scanItemsCount = [self.scanItemsCountTextField.text intValue];
        scanningListViewController.UUIDToScan = self.scanUUIDTextField.text;
    }
}

@end
