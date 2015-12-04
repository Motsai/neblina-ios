/*
 * FusionEngineDataTypes.h
 *
 *  Created on: Sep 18, 2015
 *      Author: Omid Sarbishei
 *      Project: Neblina
 *      Company: Motsai
 */

#ifndef FUSIONENGINEDATATYPES_H_
#define FUSIONENGINEDATATYPES_H_

#include "stdint.h"

#define ENABLE 1
#define DISABLE 0


#define Quaternion_t QUAT
#define command_t uint8_t

//all fusion engine commands
#define Downsample 0x01
#define MotionState 0x02
#define IMU_Data 0x03
#define Quaternion 0x04
#define EulerAngle 0x05
#define ExtForce 0x06
#define SetFusionType 0x07
#define TrajectoryRecStart 0x08
#define TrajectoryRecStop 0x09
#define TrajectoryDistance 0x0A
#define Pedometer 0x0B
#define MAG_Data 0x0C
#define Erase_Recorder 0x0D
#define Start_Recorder 0x0E
#define Stop_Recorder 0x0F


#pragma pack(push, 1)

typedef struct QUAT //quaternion
{
	int16_t q[4]; //fixed-point quaternion
}QUAT;

typedef enum{ //filter type: 6-axis IMU (no magnetometer), or 9-axis MARG
	IMU_Filter = (uint8_t)0x00,
	MARG_Filter = (uint8_t)0x01,
}Filter_Type;

typedef struct Euler_fxp //fixed-point Euler angles, i.e., round(angle*10)
{
	int16_t yaw; //first rotation, around z-axis
	int16_t pitch; //second rotation, around y-axis
	int16_t roll; //third rotation, around x-axis
}Euler_fxp;

typedef struct Fext_Vec16_t { //external force vector
	int16_t x;
	int16_t y;
	int16_t z;
}Fext_Vec16_t;

typedef struct { //3-axis raw data type
  int16_t Data[3];
} AxesRaw_t;

typedef struct { //9-axis data type
	AxesRaw_t Acc; //accelerometer
	AxesRaw_t Gyr; //gyroscope
	AxesRaw_t Mag; //magnetometer
} IMURaw_t;

typedef struct { //6-axis IMU data type - no magnetometers
	AxesRaw_t Acc; //accelerometer
	AxesRaw_t Gyr; //gyroscope
} IMU_6Axis_t;


typedef struct steps_t { //steps and pedometer data types
	uint8_t step_detect; //detection of a step gives 1. It also returns 1, if no step has been detected for 5 seconds
	uint16_t step_cnt; //number of steps taken so far.
	uint8_t spm; //cadence: number of steps per minute
}steps_t;

typedef enum{
	No_Change = (uint8_t)0x00, //holds its previous state
	Stop_Motion = (uint8_t)0x01, //the device stops moving
	Start_Motion = (uint8_t)0x02, //the device starts moving
}motionstatus_t;

typedef struct MOTION_FEATURE{ //all features
	uint8_t motion; //0: no change in motion, 1: stops moving, 2: starts moving
	IMURaw_t IMUData; //18 bytes
	Quaternion_t quatrn; //8 bytes
	Euler_fxp angles; //6 bytes
	Fext_Vec16_t force; //6 bytes
	Euler_fxp angles_err; //6 bytes: error in Euler angles compared to a reference trajectory
	uint32_t TimeStamp; //4 bytes: in microseconds
	steps_t steps;
	int16_t direction;
}MOTION_FEATURE;





#pragma pack(pop)



#endif /* FUSIONENGINEDATATYPES_H_ */
