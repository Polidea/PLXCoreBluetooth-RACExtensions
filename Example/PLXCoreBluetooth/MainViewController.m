#import "MainViewController.h"
#import "ScanningListViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"StartScanningSegue"]) {
        ScanningListViewController *scanningListViewController = segue.destinationViewController;

        scanningListViewController.shouldScanInfiniteDevices = self.scanInfiniteItemsSwitch.isOn;
        scanningListViewController.scanItemsCount = [self.scanItemsCountTextField.text intValue];
        scanningListViewController.UUIDToScan = self.scanUUIDTextField.text;
    }
}

- (IBAction)unwindToMain:(UIStoryboardSegue *)unwindSegue {
}

@end
