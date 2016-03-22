# PLXCoreBluetooth

`PLXCoreBluetooth` is a thin abstraction layer over `CBCentralManager` and `CBPeripheral` that enables programming using Reactive Cocoa.

## Usage

### Sample App

Take a look at example app, it illustrates all common usage cases pretty straightforward.
To run it, clone the repo, and run `pod install` from the Example directory first or run `pod try PLXCoreBluetooth`.

### Example

Let's try to scan for some peripherals, connect to them, discover characteristics for given services and read them. Easy.

```objc

@weakify(self)
[[[[self.centralManager rac_scanForPeripheralsWithServices:@[mySpecialService]
                                                     count:PLXCBCentralManagerScanInfiniteCount
                                                   options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @NO}]
        reduceEach:^id(CBPeripheral *peripheral, NSDictionary<NSString *, id> *advertisementData, NSNumber *RSSI) {
            return peripheral;
        }]
        flattenMap:^RACSignal *(CBPeripheral *peripheral) {
            @strongify(self)
            return [[[self.centralManager
                    rac_connectPeripheral:peripheral options:nil]
                    flattenMap:^RACSignal *(CBPeripheral *_) {
                        return [peripheral rac_discoverCharacteristics:nil forService:mySpecialService];
                    }]
                    flattenMap:^RACSignal *(NSArray<CBCharacteristic *> *characteristics) {
                        return [[[characteristics.rac_sequence signal]
                                flattenMap:^RACSignal *(CBCharacteristic *characteristic) {
                                    return [peripheral rac_readValueForCharacteristic:characteristic];
                                }]
                                collect];
                    }];
        }]
```

### API

There are two sets of extensions, first for `CBCentralManager`, second for `CBPeripheral`.

#### `CBCentralManager`

This is a property that determines whether all methods below should continue only if `CBCentralManager` is in powered on state. If it's set to YES each of them will be blocking and will wait for powered on state. Otherwise, default behavior is to finish immediately with error.

By default set to NO.

```objc
@property(nonatomic, assign) BOOL plx_shouldWaitUntilPoweredOn;
```

##### Scanning

Scan method returns signal with first `count` scanned peripherals info tuples (peripheral, advertisementData, RSSI) for given services.
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

#### `CBPeripheral`

This is a property that determines whether all methods below should continue only if `CBPeripheral` is in connected state. If it's set to YES each of them will be blocking and will wait for connected state. Otherwise, default behavior is to finish immediately with error.

By default set to NO.

```objc
@property(nonatomic, assign) BOOL plx_shouldWaitUntilConnected;
```

This property returns most recent name and subscribes for peripheral name changes.

```objc
@property(nonatomic, strong, readonly) RACSignal *rac_name;
```

This method returns signal subscribed for peripheral name changes.

```objc
- (RACSignal *)rac_peripheralDidUpdateName;
```

This method returns signal containing services peripheral that have been changed over time.

```objc
- (RACSignal *)rac_peripheralDidModifyServices;
```

##### Discovery

Returns an array of discovered services.

```objc
- (RACSignal *)rac_discoverServices:(nullable NSArray<CBUUID *> *)serviceUUIDs;
```

Returns an array of discovered included services for given service.

```objc
- (RACSignal *)rac_discoverIncludedServices:(nullable NSArray<CBUUID *> *)includedServiceUUIDs
                                 forService:(CBService *)service;
```

Returns an array of discovered characteristics for given service.

```objc
- (RACSignal *)rac_discoverCharacteristics:(nullable NSArray<CBUUID *> *)characteristicUUIDs
                                forService:(CBService *)service;
```

Returns an array of discovered descriptors for given characteristic.

```objc
- (RACSignal *)rac_discoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic;
```

##### Reading

This method returns RSSI and completes, error signal otherwise.

```objc
- (RACSignal *)rac_readRSSI;
```

Those methods return read value and complete on successful read, error otherwise.

```objc
- (RACSignal *)rac_readValueForCharacteristic:(CBCharacteristic *)characteristic;

- (RACSignal *)rac_readValueForDescriptor:(CBDescriptor *)descriptor;
```

##### Writing

Those methods return boolean YES and complete on successful write, error otherwise.

```objc
- (RACSignal *)rac_writeValue:(NSData *)data
            forCharacteristic:(CBCharacteristic *)characteristic
                    writeType:(CBCharacteristicWriteType)writeType;

- (RACSignal *)rac_writeValue:(NSData *)data
                forDescriptor:(CBDescriptor *)descriptor;
```

##### Updating

This method returns boolean YES and completes if change succeeds, or error otherwise.

```objc
- (RACSignal *)rac_setNotifyValue:(BOOL)enabled
       forChangesInCharacteristic:(CBCharacteristic *)characteristic;
```

This method returns updated values (from `peripheral:didUpdateValueForCharacteristic:error:` callback), or error if update fails.

```objc
- (RACSignal *)rac_setNotifyValue:(BOOL)enabled
andGetUpdatesForChangesInCharacteristic:(CBCharacteristic *)characteristic;
```

This method returns stream of signals with value or error (taken from `peripheral:didUpdateValueForCharacteristic:error:` callback).

```objc
- (RACSignal *)rac_listenForUpdatesForCharacteristic:(nullable CBCharacteristic *)characteristic;
```

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
