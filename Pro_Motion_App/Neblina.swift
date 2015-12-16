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

enum FusionId : UInt8 {
	case
	Downsample = 1,			// Downsampling factor definition
	MotionState = 2,		// streaming Motion State
	SixAxisIMU = 3,			// streaming the 6-axis IMU data
	Quaternion = 4,			// streaming the quaternion data
	EulerAngle = 5,			// streaming the Euler angles
	ExtrnForce = 6,			// streaming the external force
	SetFusionType = 7,		// setting the Fusion type to either 6-axis or 9-axis
	TrajectRecStart = 8,	// start recording orientation trajectory
	TrajectRecStop = 9,		// stop recording orientation trajectory
	TrajectDistance = 10,	// calculating the distance from a pre-recorded orientation trajectory
	Pedometer = 11,			// streaming pedometer data
	Mag = 12,				// streaming magnetometer data
	RecorderErase = 13,
	RecorderStart = 14,
	RecorderStop = 15
}

struct FusionCmdItem {
	let	CmdId : FusionId
	let Name : String
}

let FusionCmdList = [FusionCmdItem](arrayLiteral:
	FusionCmdItem(CmdId: FusionId.SixAxisIMU, Name:"6 Axis IMU Stream"),
	FusionCmdItem(CmdId: FusionId.Quaternion, Name: "Quaternion Stream"),
	FusionCmdItem(CmdId: FusionId.EulerAngle, Name: "Euler Angle Stream"),
	FusionCmdItem(CmdId: FusionId.ExtrnForce, Name: "External Force Stream"),
	FusionCmdItem(CmdId: FusionId.Pedometer, Name:"Pedometer Stream"),
	FusionCmdItem(CmdId: FusionId.TrajectRecStart, Name: "Trajectory Record"),
	FusionCmdItem(CmdId: FusionId.TrajectDistance, Name: "Trajectory Distance Stream"),
	FusionCmdItem(CmdId: FusionId.Mag, Name: "MAG Stream"),
	FusionCmdItem(CmdId: FusionId.MotionState, Name: "Motion Data"),
	FusionCmdItem(CmdId: FusionId.RecorderStart, Name: "Record")
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
	
	func setPeripheral(peripheral : CBPeripheral) {
		device = peripheral;
		device!.delegate = self;
		//while (device.state != CBPeripheralState.Connected) {}
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
//		NebPeripheral.discoverCharacteristics([NEB_CHAR_UUID], forService: <#T##CBService#>)
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
		var hdr = NEB_PKTHDR(SubSys: 0, Len: 0, Crc: 0, Cmd: 0)
		if (characteristic.UUID .isEqual(NEB_DATACHAR_UUID))
		{
			characteristic.value?.getBytes(&hdr, length: sizeof(NEB_PKTHDR))
			characteristic.value?.getBytes(&NebPkt, length: sizeof(NEB_PKTHDR) + 1)
			switch (hdr.SubSys)
			{
				case 1:	// Motion Engine
					//print("\(characteristic.value)")
					characteristic.value?.getBytes(&fp, range: NSMakeRange(sizeof(NEB_PKTHDR), sizeof(Fusion_DataPacket_t)))
					//print("\(characteristic.value)")
					//print("\(fp)")
					////print("\(fdata)")
					//characteristic.value?.getBytes(&fdata, range: NSMakeRange(sizeof(NEB_PKTHDR), sizeof(Fusion_DataPacket_t)))
					//characteristic.value?.getBytes(&fdata.Data[0], range: NSMakeRange(sizeof(NEB_PKTHDR) + 4, 12))
					
					//print("\(fdata)")
					let id = FusionId(rawValue: hdr.Cmd)
					delegate.didReceiveFusionData(id!, data: fp)
					//delegate.didReceiveFusionData(hdr.Cmd, data: fdata)
//					characteristic.value?.getBytes(&ppk, range: NSMakeRange(sizeof(NEB_PKTHDR), 16))
					break;
				default:
					break;
			}
			
		//	NebPkt!.Data = data;
	//		delegate.didReceiveData(NebPkt)
			//print("FusionPacket : \(fp)")
		}
	}
	
	func MotionStream(Enable:Bool)
	{
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = 1
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = FusionId.MotionState.rawValue	// Cmd
		
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

	func SixAxisIMU_Stream(Enable:Bool)
	{
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = 1
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = FusionId.SixAxisIMU.rawValue	// Cmd
		
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
	
	func QuaternionStream(Enable:Bool)
	{
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = 1
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = FusionId.Quaternion.rawValue	// Cmd
		
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
	
	func EulerAngleStream(Enable:Bool)
	{
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = 1
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = FusionId.EulerAngle.rawValue	// Cmd
		
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
	
	func ExternalForceStream(Enable:Bool)
	{
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = 1
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = FusionId.ExtrnForce.rawValue	// Cmd
		
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
	
	func PedometerStream(Enable:Bool)
	{
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = 1
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = FusionId.Pedometer.rawValue	// Cmd
		
		if Enable == true
		{
			pkbuf[8] = 11
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
	
	func TrajectoryRecord(Enable:Bool)
	{
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = 1
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = FusionId.TrajectRecStart.rawValue	// Cmd
		
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
	
	func TrajectoryDistanceData(Enable:Bool)
	{
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = 1
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = FusionId.TrajectDistance.rawValue	// Cmd
		
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
	
	func MagStream(Enable:Bool)
	{
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = 1
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = FusionId.Mag.rawValue	// Cmd
		
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
	
	func RecorderErase(Enable:Bool) {
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = 1
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = FusionId.RecorderErase.rawValue	// Cmd
		
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
	
	func Recorder(Enable:Bool) {
		var pkbuf = [UInt8](count:20, repeatedValue:0)
		
		pkbuf[0] = 1
		pkbuf[1] = UInt8(sizeof(Fusion_DataPacket_t))
		pkbuf[2] = 0
		pkbuf[3] = FusionId.RecorderStart.rawValue	// Cmd
		
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
	
	func UpdateMotionFeatures() {
		
	}
}

protocol NeblinaDelegate {
	
	func didReceiveFusionData(type : FusionId, data : Fusion_DataPacket_t)
	//func didReceiveFusionData(type : UInt8, data : FusionPacket)
}
