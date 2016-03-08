//
//  ViewController.swift
//  SitStand
//
//  Created by Hoan Hoang on 2015-11-19.
//  Copyright © 2015 Hoan Hoang. All rights reserved.
//

import Cocoa
import CoreBluetooth

import "Neblina-Bridging-Header.h"

#import "neblina.h"
#import "FusionEngineDataTypes.h"


struct NebDevice {
	let id : UInt64
	let peripheral : CBPeripheral
}

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, CBCentralManagerDelegate, NeblinaDelegate {

	var bleCentralManager : CBCentralManager!
	var objects = [NebDevice]()
	let device = Neblina()
	
	@IBOutlet weak var sitLabel : NSTextField!
	@IBOutlet weak var standLabel : NSTextField!
	@IBOutlet weak var tableView : NSTableView!

	
	override func viewDidLoad() {
		if #available(OSX 10.10, *) {
		    super.viewDidLoad()
		} else {
		    // Fallback on earlier versions
		}

		// Do any additional setup after loading the view.
		bleCentralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())
	}

	override var representedObject: AnyObject? {
		didSet {
		// Update the view, if already loaded.
		}
	}

	// MARK: - Table View
	func numberOfRowsInTableView(aTableView: NSTableView) -> Int
	{
		return objects.count;
		
	}
	
	func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView?
	{
		if (row < objects.count)
		{
			let cellView = tableView.makeViewWithIdentifier("CellDevice", owner: self) as! NSTableCellView
			
			cellView.textField!.stringValue = objects[row].peripheral.name! + String(format: "_%lX", objects[row].id) //objects[row].name;// "test"//"self.objects.objectAtIndex(row) as! String
			
			return cellView;
		}
		
		return nil;
	}
	
	/*func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject?
	{
	//        var string:String = "row " + String(row) + ", Col" + String(tableColumn.identifier)
	//        return string
	//let newString = getDataArray().objectAtIndex(row).objectForKey(tableColumn!.identifier)
	if (row < devices.count)
	{
	//let peripheral = devices[row];
	//let newString = peripheral.name;
	
	return devices[row];
	}
	return nil;
	}*/
	
	/*	func getDataArray () -> NSArray{
	let dataArray:[NSDictionary] = [["FirstName": "Debasis", "LastName": "Das"],
	["FirstName": "Nishant", "LastName": "Singh"],
	["FirstName": "John", "LastName": "Doe"],
	["FirstName": "Jane", "LastName": "Doe"],
	["FirstName": "Mary", "LastName": "Jane"]];
	print(dataArray);
	return dataArray;
	}*/
	
	func tableViewSelectionDidChange(notification: NSNotification)
	{
		if (self.tableView.numberOfSelectedRows > 0)
		{
			let peripheral = self.objects[self.tableView.selectedRow].peripheral
			
			
			device.setPeripheral(peripheral)
			device.delegate = self
			//print(peripheral)
			
			bleCentralManager.connectPeripheral(peripheral, options: nil)
			bleCentralManager.stopScan()
			//self.tableView.deselectRow(self.tableView.selectedRow)
		}
		
	}
	
	func centralManager(central: CBCentralManager,
		didDiscoverPeripheral peripheral: CBPeripheral,
		advertisementData : [String : AnyObject],
		RSSI: NSNumber) {
			//NebPeripheral = peripheral
			//central.connectPeripheral(peripheral, options: nil)
			
			// We have to set the discoveredPeripheral var we declared earlier to reference the peripheral, otherwise we won't be able to interact with it in didConnectPeripheral. And you will get state = connecting> is being dealloc'ed while pending connection error.
			
			//self.discoveredPeripheral = peripheral
			
			//var curDevice = UIDevice.currentDevice()
			
			//iPad or iPhone
			// println("VENDOR ID: \(curDevice.identifierForVendor) BATTERY LEVEL: \(curDevice.batteryLevel)\n\n")
			//println("DEVICE DESCRIPTION: \(curDevice.description) MODEL: \(curDevice.model)\n\n")
			
			// Hardware beacon
			print("PERIPHERAL NAME: \(peripheral.name)\n AdvertisementData: \(advertisementData)\n RSSI: \(RSSI)\n")
			
			print("UUID DESCRIPTION: \(peripheral.identifier.UUIDString)\n")
			
			print("IDENTIFIER: \(peripheral.identifier)\n")
			
			//sensorData.text = sensorData.text + "FOUND PERIPHERALS: \(peripheral) AdvertisementData: \(advertisementData) RSSI: \(RSSI)\n"
			
			var id : UInt64 = 0
			advertisementData[CBAdvertisementDataManufacturerDataKey]?.getBytes(&id, range: NSMakeRange(2, 8))
			if (id == 0) {
				return
			}
			let device = NebDevice(id: id, peripheral: peripheral)
			
			//print("Peri : \(device)\n");
			
			for dev in objects
			{
				if (dev.id == id)
				{
					return;
				}
			}
			objects.insert(device, atIndex: 0)

			//objects.addObject(peripheral)
//			print("DEVICES: \(devices)\n")
			tableView.reloadData();
			// stop scanning, saves the battery
			//central.stopScan()
			
	}
	
	func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
		
		//peripheral.delegate = self
		peripheral.discoverServices(nil)
		//gameView.PeripheralConnected(peripheral)
		//		detailView.setPeripheral(NebDevice)
		//		NebDevice.setPeripheral(peripheral)
		print("Connected to peripheral")
		
		
	}
	
	func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
		//        sensorData.text = "FAILED TO CONNECT \(error)"
	}
	
	func scanPeripheral(sender: CBCentralManager)
	{
		print("Scan for peripherals")
		bleCentralManager.scanForPeripheralsWithServices(nil, options: nil)
	}
	
	@objc func centralManagerDidUpdateState(central: CBCentralManager) {
		
		switch central.state {
			
		case .PoweredOff:
			print("CoreBluetooth BLE hardware is powered off")
			//self.sensorData.text = "CoreBluetooth BLE hardware is powered off\n"
			break
		case .PoweredOn:
			print("CoreBluetooth BLE hardware is powered on and ready")
			//self.sensorData.text = "CoreBluetooth BLE hardware is powered on and ready\n"
			// We can now call scanForBeacons
			let lastPeripherals = central.retrieveConnectedPeripheralsWithServices([NEB_SERVICE_UUID])
			
			if lastPeripherals.count > 0 {
				// let device = lastPeripherals.last as CBPeripheral;
				//connectingPeripheral = device;
				//centralManager.connectPeripheral(connectingPeripheral, options: nil)
			}
			//scanPeripheral(central)
			bleCentralManager.scanForPeripheralsWithServices([NEB_SERVICE_UUID], options: nil)
			break
		case .Resetting:
			print("CoreBluetooth BLE hardware is resetting")
			//self.sensorData.text = "CoreBluetooth BLE hardware is resetting\n"
			break
		case .Unauthorized:
			print("CoreBluetooth BLE state is unauthorized")
			//self.sensorData.text = "CoreBluetooth BLE state is unauthorized\n"
			
			break
		case .Unknown:
			print("CoreBluetooth BLE state is unknown")
			//self.sensorData.text = "CoreBluetooth BLE state is unknown\n"
			break
		case .Unsupported:
			print("CoreBluetooth BLE hardware is unsupported on this platform")
			//self.sensorData.text = "CoreBluetooth BLE hardware is unsupported on this platform\n"
			break
			
		default:
			break
		}
	}

	// MARK : Neblina
	
	func didConnectNeblina() {
		device.SittingStanding(true)
	}

	func didReceiveFusionData(type : FusionId, data : Fusion_DataPacket_t) {
	//	let textview = self.view.viewWithTag(3) as! UITextView
		
		switch (type) {
			
		case FusionId.MotionState:
			break
		case FusionId.SixAxisIMU:
			break
		case FusionId.EulerAngle:
			//
			// Process Euler Angle
			//
/*			let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
			let x = (Int16(data.data.0) & 0xff) | (Int16(data.data.1) << 8)
			let xrot = Float(x) / 10.0
			let y = (Int16(data.data.2) & 0xff) | (Int16(data.data.3) << 8)
			let yrot = Float(y) / 10.0
			let z = (Int16(data.data.4) & 0xff) | (Int16(data.data.5) << 8)
			let zrot = Float(z) / 10.0
			
			if (heading) {
				ship.eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(90), 0, GLKMathDegreesToRadians(180) - GLKMathDegreesToRadians(xrot))
			}
			else {
				//				ship.eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(90) - GLKMathDegreesToRadians(yrot), GLKMathDegreesToRadians(zrot), GLKMathDegreesToRadians(180) - GLKMathDegreesToRadians(xrot))
				ship.eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(180) - GLKMathDegreesToRadians(yrot), GLKMathDegreesToRadians(xrot), GLKMathDegreesToRadians(180) - GLKMathDegreesToRadians(zrot))
			}
			
			textview.text = String("Euler - Yaw:\(xrot), Pitch:\(yrot), Roll:\(zrot)")
			*/
			
			break
		case FusionId.Quaternion:
			
			//
			// Process Quaternion
			//
/*			let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
			let x = (Int16(data.data.0) & 0xff) | (Int16(data.data.1) << 8)
			let xq = Float(x) / 32768.0
			let y = (Int16(data.data.2) & 0xff) | (Int16(data.data.3) << 8)
			let yq = Float(y) / 32768.0
			let z = (Int16(data.data.4) & 0xff) | (Int16(data.data.5) << 8)
			let zq = Float(z) / 32768.0
			let w = (Int16(data.data.6) & 0xff) | (Int16(data.data.7) << 8)
			let wq = Float(w) / 32768.0
			ship.orientation = SCNQuaternion(yq, xq, zq, wq)
			textview.text = String("Quat - x:\(xq), y:\(yq), z:\(zq), w:\(wq)")
			
			*/
			break
		case FusionId.ExtrnForce:
			//
			// Process External Force
			//
/*			let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
			let x = (Int16(data.data.0) & 0xff) | (Int16(data.data.1) << 8)
			let xq = x / 1600
			let y = (Int16(data.data.2) & 0xff) | (Int16(data.data.3) << 8)
			let yq = y / 1600
			let z = (Int16(data.data.4) & 0xff) | (Int16(data.data.5) << 8)
			let zq = z / 1600
			
			cnt -= 1
			if (cnt <= 0) {
				cnt = max_count
				//if (xf != xq || yf != yq || zf != zq) {
				let pos = SCNVector3(CGFloat(xf/cnt), CGFloat(yf/cnt), CGFloat(zf/cnt))
				//let pos = SCNVector3(CGFloat(yf), CGFloat(xf), CGFloat(zf))
				//SCNTransaction.flush()
				//SCNTransaction.begin()
				//SCNTransaction.setAnimationDuration(0.1)
				//let action = SCNAction.moveTo(pos, duration: 0.1)
				ship.position = pos
				//SCNTransaction.commit()
				//ship.runAction(action)
				
				xf = xq
				yf = yq
				zf = zq
				//}
			}
			else {
				//if (abs(xf) <= abs(xq)) {
				xf += xq
				//}
				//if (abs(yf) <= abs(yq)) {
				yf += yq
				//}
				//if (abs(xf) <= abs(xq)) {
				zf += zq
				//}
				/*	if (xq == 0 && yq == 0 && zq == 0) {
				//cnt = 1
				xf = 0
				yf = 0
				zf = 0
				//if (cnt <= 1) {
				//ship.removeAllActions()
				//	ship.position = SCNVector3(CGFloat(yf), CGFloat(xf), CGFloat(zf))
				//}
				
				}*/
			}
			
			textview.text = String("Extrn Force - x:\(xq), y:\(yq), z:\(zq)")
			//print("Extrn Force - x:\(xq), y:\(yq), z:\(zq)")*/
			break
		case FusionId.Mag:
			//
			// Mag data
			//
/*			let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
			let x = (Int16(data.data.0) & 0xff) | (Int16(data.data.1) << 8)
			let xq = x / 10
			let y = (Int16(data.data.2) & 0xff) | (Int16(data.data.3) << 8)
			let yq = y / 10
			let z = (Int16(data.data.4) & 0xff) | (Int16(data.data.5) << 8)
			let zq = z / 10
			textview.text = String("Mag - x:\(xq), y:\(yq), z:\(zq)")
			//ship.rotation = SCNVector4(Float(xq), Float(yq), 0, GLKMathDegreesToRadians(90))*/
			break
		case FusionId.SittingStanding:
			let state = data.data.0
			let sitTime = (Int32(data.data.1) & 0xff) | (Int32(data.data.2) << 8)  | (Int32(data.data.3) << 16) | (Int32(data.data.4) << 24)
			let standTime = (Int32(data.data.5) & 0xff) | (Int32(data.data.6) << 8)  | (Int32(data.data.7) << 16) | (Int32(data.data.8) << 24)

			sitLabel.stringValue = "Siting time : \(sitTime)"
			standLabel.stringValue = "Standing time : \(standTime)"
			
			if (state == 0)
			{
				// Stitting
				sitLabel.backgroundColor = NSColor.greenColor()
				standLabel.backgroundColor = NSColor.grayColor()
			}
			else
			{
				// Standing
				sitLabel.backgroundColor = NSColor.grayColor()
				standLabel.backgroundColor = NSColor.greenColor()
			}
			break;
		default: break
		}
		
		
	}

}


