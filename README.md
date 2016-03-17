# PLXCoreBluetooth

`PLXCoreBluetooth` is a thin abstraction layer over `CBCentralManager` and `CBPeripheral` that enables programming using Reactive Cocoa.

## Usage

### Sample App

Take a look at example app, it illustrates all common usage cases pretty straightforward.
To run it, clone the repo, and run `pod install` from the Example directory first or run `pod try PLXCoreBluetooth`.

### API

There are two sets of extensions, first for `CBCentralManager`, second for `CBPeripheral`.

#### `CBCentralManager`

This is a property that determines whether all methods below should continue only if `CBCentralManager` is in powered on state. If it's set to YES each of them will be blocking and will wait for powered on state. Otherwise, default behavior is to finish immediately with error.

By default set to NO.

```objc
@property(nonatomic, assign) BOOL plx_shouldWaitUntilPoweredOn;
```

##### Scanning

Scan method returns signal with first `count` scanned peripherals for given services.
For infinite scan count there should be passed `PLXCBCentralManagerScanInfiniteCount`.

If scan is limited and all peripherals are discovered `stopScan` will be called automatically.
`stopScan` will be called as well when signal is disposed.

```objc
- (RACSignal *)rac_scanForPeripheralsWithServices:(nullable NSArray<CBUUID *> *)serviceUUIDs
                                            count:(NSInteger)count
                                          options:(nullable NSDictionary<NSString *, id> *)options;
```

Stop scan method is just a wrapper for `stopScan` that returns `@YES` after calling it.

```objc
- (RACSignal *)rac_stopScan;
```

##### Connecting

Connect method connects to the peripheral and returns it on success. On connection failure it returns error signal.

```objc
- (RACSignal *)rac_connectPeripheral:(CBPeripheral *)peripheral
                             options:(nullable NSDictionary<NSString *, id> *)options;
```

Disconnect method disconnects from the peripheral and returns it on success. On disconnection failure it returns error signal.

```objc
- (RACSignal *)rac_disconnectPeripheralConnection:(CBPeripheral *)peripheral;
```

##### Misc

There's a signal that is updated whenever power on property changes.

```objc
- (RACSignal *)rac_isPoweredOn;
```

### Examples


## Requirements

- iOS 8.0+
- Xcode 7.2+

## Installation

PLXCoreBluetooth is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "PLXCoreBluetooth"
```

## Authors

Maciej Oczko, maciek.oczko@polidea.com

Michal Mizera, michal.mizera@polidea.com

## License

PLXCoreBluetooth is available under the MIT license. See the LICENSE file for more info.
