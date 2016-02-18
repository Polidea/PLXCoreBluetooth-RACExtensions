@import Foundation;
@import CoreBluetooth;
@import ReactiveCocoa;

NS_ASSUME_NONNULL_BEGIN

@interface CBPeripheral (PLXRACExtensions)

/*!
 *  @property rac_name
 *
 *  @discussion			This property returns most recent name and subscribes for <i>peripheral</i> name changes.
 *
 *  @see                rac_peripheralDidUpdateName
 */
@property(nonatomic, strong, readonly) RACSignal *rac_name;

/*!
 *  @method rac_peripheralDidUpdateName
 *
 *  @discussion			This method subscribes for <i>peripheral</i> name changes.
 */
- (RACSignal *)rac_peripheralDidUpdateName NS_AVAILABLE(NA, 6_0);

/*!
 *  @method rac_readRSSI
 *
 *  @discussion This method returns signal with RSSI and completes, error otherwise.
 *
 *  @see        rac_peripheralDidReadRSSI
 */
- (RACSignal *)rac_readRSSI;

/*!
 *  @method rac_discoverServices:
 *
 *  @param serviceUUIDs A list of <code>CBUUID</code> objects representing the service types to be discovered. If <i>nil</i>,
 *						all services will be discovered, which is considerably slower and not recommended.
 *
 *  @discussion			This method returns signal with discovered services.
 */
- (RACSignal *)rac_discoverServices:(nullable NSArray<CBUUID *> *)serviceUUIDs;

/*!
 *  @method rac_discoverIncludedServices:forService:
 *
 *  @param includedServiceUUIDs A list of <code>CBUUID</code> objects representing the included service types to be discovered. If <i>nil</i>,
 *								all of <i>service</i>s included services will be discovered, which is considerably slower and not recommended.
 *  @param service				A GATT service.
 *
 *  @discussion					Discovers the specified included service(s) of <i>service</i>.
 *                              This method returns signal with discovered included servises.
 */
- (RACSignal *)rac_discoverIncludedServices:(nullable NSArray<CBUUID *> *)includedServiceUUIDs forService:(CBService *)service;

/*!
 *  @method rac_peripheralDidModifyServices
 *
 *  @discussion			This method returns signal containing @link services @/link of <i>peripheral</i> that have been changed.
 *
 */
- (RACSignal *)rac_peripheralDidModifyServices NS_AVAILABLE(NA, 7_0);


/*!
 *  @method rac_discoverCharacteristics:forService:
 *
 *  @param characteristicUUIDs	A list of <code>CBUUID</code> objects representing the characteristic types to be discovered. If <i>nil</i>,
 *								all characteristics of <i>service</i> will be discovered, which is considerably slower and not recommended.
 *  @param service				A GATT service.
 *
 *  @discussion					Discovers the specified characteristic(s) of <i>service</i>.
 *                              This method returns signal with discovered characteristics.
 */
- (RACSignal *)rac_discoverCharacteristics:(nullable NSArray<CBUUID *> *)characteristicUUIDs forService:(CBService *)service;

/*!
 *  @method rac_readValueForCharacteristic:
 *
 *  @param characteristic	A GATT characteristic.
 *
 *  @discussion				Reads the characteristic value for <i>characteristic</i>.
 *                          This method returns read value and completes if read succeeds, error otherwise.
 */
- (RACSignal *)rac_readValueForCharacteristic:(CBCharacteristic *)characteristic;

/*!
 *  @method rac_writeValue:forCharacteristic:type:
 *
 *  @param data				The value to write.
 *  @param characteristic	The characteristic whose characteristic value will be written.
 *  @param type				The type of write to be executed.
 *
 *  @discussion				Writes <i>value</i> to <i>characteristic</i>'s characteristic value.
 *							If the <code>CBCharacteristicWriteWithoutResponse</code> type is specified, the delivery of the data is best-effort and not
 *							guaranteed.
 *
 *                          This method returns signal with <code>@YES</code> and completes if read succeeds, error otherwise.
 */
- (RACSignal *)rac_writeValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic writeType:(CBCharacteristicWriteType)writeType;

/*!
 *  @method rac_discoverDescriptorsForCharacteristic:
 *
 *  @param characteristic	A GATT characteristic.
 *
 *  @discussion				Discovers the characteristic descriptor(s) of <i>characteristic</i>.
 *                          This method returns signal with discovered descriptors (NSArray<CBDescriptor *>) for given characteristic.
 */
- (RACSignal *)rac_discoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic;

/*!
 *  @method rac_readValueForDescriptor:
 *
 *  @param descriptor	A GATT characteristic descriptor.
 *
 *  @discussion			Reads the value of <i>descriptor</i>.
 *                      This method returns signal with read value for given descriptor and completes, error otherwise.
 */
- (RACSignal *)rac_readValueForDescriptor:(CBDescriptor *)descriptor;

/*!
 *  @method rac_writeValue:forDescriptor:
 *
 *  @param data			The value to write.
 *  @param descriptor	A GATT characteristic descriptor.
 *
 *  @discussion			Writes <i>data</i> to <i>descriptor</i>'s value.
 *                      This method returns signal with <code>@YES</code> and completes if write succeeds, error otherwise.
 */
- (RACSignal *)rac_writeValue:(NSData *)data forDescriptor:(CBDescriptor *)descriptor;

/*!
 *  @method rac_setNotifyValue:forCharacteristic:
 *
 *  @param enabled			Whether or not notifications/indications should be enabled.
 *  @param characteristic	The characteristic containing the client characteristic configuration descriptor.
 *
 *  @discussion				Enables or disables notifications/indications for the characteristic value of <i>characteristic</i>. If <i>characteristic</i>
 *							allows both, notifications will be used.
 *							This method returns signal with <code>@YES</code> and completes if change succeeds or error otherwise.
 */
- (RACSignal *)rac_setNotifyValue:(BOOL)enabled forChangesInCharacteristic:(CBCharacteristic *)characteristic;


/*!
 *  @method rac_setNotifyValue:andGetUpdatesForChangesInCharacteristic:
 *
 *  @param enabled			Whether or not notifications/indications should be enabled.
 *  @param characteristic	The characteristic containing the client characteristic configuration descriptor.
 *
 *  @discussion				Enables or disables notifications/indications for the characteristic value of <i>characteristic</i>. If <i>characteristic</i>
 *							allows both, notifications will be used.
 *							This method returns signal with updated values (from peripheral:didUpdateValueForCharacteristic:error: callback) or error if update fails.
 */
- (RACSignal *)rac_setNotifyValue:(BOOL)enabled andGetUpdatesForChangesInCharacteristic:(CBCharacteristic *)characteristic;

/*!
 *  @method rac_listenForUpdatesForCharacteristic
 *
 *  @param characteristic	The characteristic to listen for.
 *
 *  @discussion             This method return a stream of signals that contains next values or error for each update for given characteristic.
 */
- (RACSignal *)rac_listenForUpdatesForCharacteristic:(nullable CBCharacteristic *)characteristic;

@end

NS_ASSUME_NONNULL_END
