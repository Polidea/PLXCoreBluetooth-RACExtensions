@import Foundation;
@import CoreBluetooth;
@import ReactiveCocoa;

extern NSInteger PLXCBCentralManagerScanInfiniteCount;

@interface CBCentralManager (PLXRACExtensions)

/*!
 *  @method rac_isPoweredOn
 *
 *  @discussion         This method returns stream of nexts (<code>@YES</code> or <code>@NO</code>) over the time.
 *
 *  @see                state
 */
- (RACSignal *)rac_isPoweredOn;

/*!
 *  @method rac_scanForPeripheralsWithServices:count:options:
 *
 *  @param serviceUUIDs A list of <code>CBUUID</code> objects representing the service(s) to scan for.
 *  @param count        Count of peripherals that will be scanned.
 *  @param options      An optional dictionary specifying options for the scan.
 *
 *  @discussion         This method will provide first <code>count</code> discovered peripherals, then will stop scan.
 *                      If <code>count</code> is PLXCBCentralManagerScanInfiniteCount, it will never stop scan.
 *
 *                      This method returns signal with <code>count</code> (or infinite) discovered peripherals, or error when scan fails.
 *
 *  @see                scanForPeripheralsWithServices:options:
 */
- (RACSignal *)rac_scanForPeripheralsWithServices:(nullable NSArray<CBUUID *> *)serviceUUIDs count:(NSInteger)count options:(nullable NSDictionary<NSString *, id> *)options;

/*!
 *  @method rac_connectPeripheral:options:
 *
 *  @param peripheral   The <code>CBPeripheral</code> to be connected.
 *  @param options      An optional dictionary specifying connection behavior options.
 *
 *  @discussion         This method returns signal with <code>@YES</code> and completes if connect succeeds, error otherwise.
 *
 *  @see                connectPeripheral:options:
 */
- (RACSignal *)rac_connectPeripheral:(CBPeripheral *)peripheral options:(nullable NSDictionary<NSString *, id> *)options;

/*!
 *  @method rac_disconnectPeripheralConnection:
 *
 *  @param peripheral   A <code>CBPeripheral</code>.
 *
 *  @discussion         This method returns signal with <code>@YES</code> and completed if disconnect succeeds, error otherwise.
 *
 *  @see                cancelPeripheralConnection:
 */
- (RACSignal *)rac_disconnectPeripheralConnection:(CBPeripheral *)peripheral;

@end
