//
//  File.swift
//  NeblinaCtrlPanel
//
//  Created by Hoan Hoang on 2015-10-07.
//  Copyright © 2015 Hoan Hoang. All rights reserved.
//

import Foundation
import CoreBluetooth


/*struct FusionPacket {
	//var cmd : uint8
	var TimeStamp : UInt32
	var Data = [Int16?](count:6, repeatedValue:0)
	init() {
		TimeStamp = 0
		Data = [0,0,0,0,0,0]
	}
}*/
/*
enum FusionId : UInt8 {
	case
	Downsample = 1,			// Downsampling factor definition
	MotionState = 2,		// streaming Motion State
	SixAxisIMU = 3,			// streaming the 6-axis IMU data
	Quaternion = 4,			// streaming the quaternion data
	EulerAngle = 5,			// streaming the Euler angles
	ExtrnForce = 6,			// streaming the external force
	SetFusionType = 7,		// setting the Fusion type to either 6-axis or 9-axis
	TrajectoryRecStartStop = 8,	// start recording orientation trajectory
//	TrajectRecStop = 9,		// stop recording orientation trajectory
	TrajectInfo = 9,		// calculating the distance from a pre-recorded orientation trajectory
	Pedometer = 10,			// streaming pedometer data
	Mag = 11,				// streaming magnetometer data
	SittingStanding = 12,	// Stting & Standing data
	LockHeadingRef = 13,
	SetAccRange = 14,
	DisableAllStreaming = 15,
	ResetTimeStamp = 16
//	FlashEraseAll = 0x0E,
//	FlashRecordStartStop = 0x0F,
//	FlashPlaybackStartStop = 0x10
}

struct FusionCmdItem {
	let	CmdId : FusionId
	let Name : String
}
*/

struct NebCmdItem {
	let SubSysId : Int32
	let	CmdId : Int32
	let Name : String
}


let NebCmdList = [NebCmdItem] (arrayLiteral:
	NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_DEBUG, CmdId: DEBUG_CMD_SET_INTERFACE, Name: "Set Interface (BLE/UART)"),
	NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_MOTION_ENG, CmdId: Quaternion, Name: "Quaternion Stream"),
	NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_MOTION_ENG, CmdId: MAG_Data, Name: "Mag Stream"),
	NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_MOTION_ENG, CmdId: LockHeadingRef, Name: "Lock Heading Ref."),
	NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_STORAGE, CmdId: FlashEraseAll, Name: "Flash Erase All"),
	NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_STORAGE, CmdId: FlashRecordStartStop, Name: "Flash Record"),
	NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_STORAGE, CmdId: FlashPlaybackStartStop, Name: "Flash Playback"),
	NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_LED, CmdId: LED_CMD_SET_VALUE, Name: "Set LED0"),
	NebCmdItem(SubSysId: NEB_CTRL_SUBSYS_LED, CmdId: LED_CMD_SET_VALUE, Name: "Set LED1")
)

// BLE custom UUID
let NEB_SERVICE_UUID = CBUUID (string:"0df9f021-1532-11e5-8960-0002a5d5c51b")
let NEB_DATACHAR_UUID = CBUUID (string:"0df9f022-1532-11e5-8960-0002a5d5c51b")
let NEB_CTRLCHAR_UUID = CBUUID (string:"0df9f023-1532-11e5-8960-0002a5d5c51b")

class Neblina : NSObject, CBPeripheralDelegate {
	var device : CBPeripheral!
	var dataChar : CBCharacteristic!
	var ctrlChar : CBCharacteristic!
	var NebPkt = NEB_PKT()//(SubSys: 0, Len: 0, Crc: 0, Data: [UInt8](count:17, repeatedValue:0)
	var fp = Fusion_DataPacket_t()
	var delegate : NeblinaDelegate!
	
	func getCmdIdx(subsysId : Int32, cmdId : Int32) -> Int {
		for (idx, item) in NebCmdList.enumerate() {
			if (item.SubSysId == subsysId && item.CmdId == cmdId) {
				return idx
			}
		}
		
		return -1
	}
	
	func setPeripheral(peripheral : CBPeripheral) {
		device = peripheral;
		device!.delegate = self;
		while (device.state != CBPeripheralState.Connected) {}
		if (device.state == CBPeripheralState.Connected)
		{
			device!.discoverServices([NEB_SERVICE_UUID])
		}
		//print("Device : \(device)")
	}
	
	//
	// CBPeripheral stuffs
	//
	func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?)
	{
		for service in peripheral.services ?? []
		{
			if (service.UUID .isEqual(NEB_SERVICE_UUID))
			{
				peripheral.discoverCharacteristics(nil, forService: service)
			}
		}
		//NebPeripheral.discoverCharacteristics([NEB_CHAR_UUID], forService: <#T##CBService#>)
	}
	
	func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?)
	{
		for characteristic in service.characteristics ?? []
		{
			//print("car \(characteristic.UUID)");
			if (characteristic.UUID .isEqual(NEB_DATACHAR_UUID))
			{
				dataChar = characteristic;
				if ((dataChar.properties.rawValue & CBCharacteristicProperties.Notify.rawValue) != 0)
				{
					peripheral.setNotifyValue(true, forCharacteristic: dataChar);
				}
			}
			if (characteristic.UUID .isEqual(NEB_CTRLCHAR_UUID))
			{
				ctrlChar = characteristic;
				delegate.didConnectNeblina()
			}
		}
	}
	
	func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?)
	{
		//var textView : NSTextView
		//print("Value : \(characteristic.value)")
		
		//let pkt = unsafeBitCast(&NebPkt, UnsafePointer<uint8>.self)
		//let NebPktt = unsafeBitCast(characteristic.value, UnsafePointer<NEB_PKT>.self) //
		//let pkk = UnsafePointer<NEB_PKTX>(characteristic.value)
		///var ppk = NebPacket(SubSys: 0, Len: 0, Crc: 0, Cmd:0, TimeStamp: 0)
		var hdr = NEB_PKTHDR()
		//var hdr = NEB_PKTHDR(Ctrl : (SubSys:0, PkType : 0), Len: 0, Crc: 0, Cmd: 0)
		if (characteristic.UUID .isEqual(NEB_DATACHAR_UUID))
		{
			characteristic.value?.getBytes(&hdr, length: sizeof(NEB_PKTHDR))
			characteristic.value?.getBytes(&NebPkt, length: sizeof(NEB_PKTHDR) + 1)

			let id = Int32(hdr.Cmd) //FusionId(rawValue: hdr.Cmd)
			//print("\(characteristic)")
			var errflag = Bool(false)
			if ((hdr.SubSys  & 0x80) == 0x80)
			{
				errflag = true;
				hdr.SubSys &= 0x7F;
			}
			switch (Int32(hdr.SubSys))
			{
				case NEB_CTRL_SUBSYS_MOTION_ENG:	// Motion Engine
					//print("\(characteristic.value)")
					characteristic.value?.getBytes(&fp, range: NSMakeRange(sizeof(NEB_PKTHDR), sizeof(Fusion_DataPacket_t)))
					//print("\(characteristic.value)")
					//print("\(fp)")
					////print("\(fdata)")
					//characteristic.value?.getBytes(&fdata, range: NSMakeRange(sizeof(NEB_PKTHDR), sizeof(Fusion_DataPacket_t)))
					//characteristic.value?.getBytes(&fdata.Data[0], range: NSMakeRange(sizeof(NEB_PKTHDR) + 4, 12))
					
					//print("\(fdata)")
			//		let id = Int32(hdr.Cmd) //FusionId(rawValue: hdr.Cmd)
					delegate.didReceiveFusionData(id, data: fp, errFlag: errflag)
					//delegate.didReceiveFusionData(hdr.Cmd, data: fdata)
//					characteristic.value?.getBytes(&ppk, range: NSMakeRange(sizeof(NEB_PKTHDR), 16))
					break
				case NEB_CTRL_SUBSYS_DEBUG:
					var dd = [UInt8](count:16, repeatedValue:0)
					characteristic.value?.getBytes(&dd, range: NSMakeRange(sizeof(NEB_PKTHDR), Int(hdr.Len)))
					delegate.didReceiveDebugData(id, data: dd, errFlag: errflag)
					break
				default:
					break
			}
			
		//	NebPkt!.Data = data;
	//		delegate.didReceiveData(NebPkt)
			//print("FusionPacket : \(fp)")
		}
	}
	func isDeviceReady()-> Bool {
		if (device == nil) {
			return false
		}
		
		if (device.state != CBPeripheralState.Connected) {
			return false
		}
		
		return true
	}
	
	func SendCmdMotionStream(Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(MotionState)	// Cmd
		
		if Enable == true
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
        if let device = device
        {
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
        }
	}

	func SendCmdSixAxisIMUStream(Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(IMU_Data)	// Cmd
		
		if Enable == true
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
        if let device = device
        {
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
        }
	}
	
	func SendCmdQuaternionStream(Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(Quaternion)	// Cmd
		
		if (Enable == true)
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
        if let device = device
        {
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
        }
	}
	
	func SendCmdEulerAngleStream(Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(EulerAngle)//FusionId.EulerAngle.rawValue	// Cmd
		
		if (Enable == true)
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
        if let device = device
        {
        
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
        }
	}
	
	func SendCmdExternalForceStream(Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(ExtForce)	// Cmd
		
		if (Enable == true)
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
        if let device = device
        {
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
        }
	}
	
	func SendCmdPedometerStream(Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(Pedometer)// Cmd
		
		if Enable == true
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
        if let device = device
        {
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
        }
	}
	
	func SendCmdTrajectoryRecord(Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(TrajectoryRecStartStop)	// Cmd
		
		if Enable == true
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
        if let device = device
        {
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
        }
	}
	
	func SendCmdTrajectoryInfo(Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(TrajectoryInfo)	// Cmd
		
		if Enable == true
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
        if let device = device
        {
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
        }
	}
	
	func SendCmdMagStream(Enable:Bool)
	{
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(MAG_Data)	// Cmd
		
		if Enable == true
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
        if let device = device
        {
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
        }
	}
	
	func SendCmdSittingStanding(Enable:Bool) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(SittingStanding)	// Cmd
		
		if Enable == true
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
        if let device = device
        {
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
        }
	}
	
	func SendCmdFlashErase(Enable:Bool) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_STORAGE) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(FlashEraseAll) // FusionId.FlashEraseAll.rawValue // RecorderErase.rawValue	// Cmd
		
		if Enable == true
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
        if let device = device
        {
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
        }
		
	}
	
	func SendCmdFlashRecord(Enable:Bool) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_STORAGE) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(FlashRecordStartStop)//FusionId.FlashRecordStartStop.rawValue	// Cmd
		
		if Enable == true
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
        if let device = device
        {
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
        }
	}
	
	func SendCmdFlashPlayback(Enable:Bool) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_STORAGE) //0x41
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(FlashPlaybackStartStop) //FusionId.FlashPlaybackStartStop.rawValue	// Cmd
		
		if Enable == true
		{
			pkbuf[8] = 1
		}
		else
		{
			pkbuf[8] = 0
		}
		pkbuf[9] = 0xff
		pkbuf[10] = 0xff
        if let device = device
        {
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
        }
	}
	
	func SendCmdLockHeading(Enable:Bool) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
	
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_MOTION_ENG) //0x41
		pkbuf[1] = 0 //UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(LockHeadingRef)	// Cmd
		
        if let device = device
        {
        device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
        }
	}
	
	func SendCmdControlInterface(Interf : Int) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = 0x40
		pkbuf[1] = 16//UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = 1//FusionId.FlashPlaybackStartStop.rawValue	// Cmd
		
		// Interf = 0 : BLE
		// Interf = 1 : UART
		pkbuf[4] = UInt8(Interf)
		//pkbuf[9] = 0xff
		//pkbuf[10] = 0xff
        if let device = device
        {
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
        }
	}
	
	func SendCmdEngineStatus() {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_DEBUG)
		pkbuf[1] = 16//UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(DEBUG_CMD_MOTENGINE_RECORDER_STATUS)	// Cmd
		
        if let device = device
        {
        device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
        }
	}

	func SendCmdLedSetValue(LedNo : UInt8, Value:UInt8) {
		if (isDeviceReady() == false) {
			return
		}
		
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = UInt8((NEB_CTRL_PKTYPE_CMD << 5) | NEB_CTRL_SUBSYS_LED)
		pkbuf[1] = 16//UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = UInt8(LED_CMD_SET_VALUE)	// Cmd
		
		// Nb of LED to set
		pkbuf[4] = 1
		pkbuf[5] = LedNo
		pkbuf[6] = Value
        if let device = device
        {
		device.writeValue(NSData(bytes: UnsafeMutablePointer<Void>(pkbuf), length: 20), forCharacteristic: ctrlChar, type: CBCharacteristicWriteType.WithoutResponse)
        }
	}
}

@objc protocol NeblinaDelegate {
	
	func didReceiveFusionData(type : Int32, data : Fusion_DataPacket_t, errFlag : Bool)
	func didReceiveDebugData(type : Int32, data : UnsafePointer<UInt8>, errFlag : Bool)
	func didConnectNeblina()
	
	//TODO: add processing functions callback for each packet type
	
	// Process Fusion data
}
