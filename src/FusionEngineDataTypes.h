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

#define FUSION_ENABLE 1
#define FUSION_DISABLE 0


#define QUAT Quaternion_t
#define command_t uint8_t
#define Euler_fxp Euler_fxp_t
#define MOTION_FEATURE Motion_Feature_t

//all fusion engine commands
#define Downsample 				0x01
#define MotionState 			0x02
#define IMU_Data 				0x03
#define Quaternion 				0x04
#define EulerAngle 				0x05
#define ExtForce 				0x06
#define SetFusionType 			0x07
#define TrajectoryRecStartStop 	0x08
#define TrajectoryInfo 			0x09
#define Pedometer 				0x0A
#define MAG_Data 				0x0B
#define SittingStanding			0x0C
#define LockHeadingRef			0x0D
#define SetAccRange				0x0E
#define DisableAllStreaming		0x0F
#define ResetTimeStamp 			0x10
///////////////////////////////////////////////

//Accelerometer full scale modes
#define ACC_FS_MODE_2G		0x00
#define ACC_FS_MODE_4G		0x01
#define ACC_FS_MODE_8G		0x02
#define ACC_FS_MODE_16G		0x03

#define TrajectoryDistance TrajectoryInfo

#pragma pack(push, 1)

typedef struct Quaternion_t //quaternion
{
	int16_t q[4]; //fixed-point quaternion
}Quaternion_t;

typedef enum{ //filter type: 6-axis IMU (no magnetometer), or 9-axis MARG
	IMU_Filter = (uint8_t)0x00,
	MARG_Filter = (uint8_t)0x01,
}Filter_Type;

typedef struct Euler_fxp_t //fixed-point Euler angles, i.e., round(angle*10)
{
	int16_t yaw; //first rotation, around z-axis
	int16_t pitch; //second rotation, around y-axis
	int16_t roll; //third rotation, around x-axis
}Euler_fxp_t;

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

typedef struct wheels_t { //wheel rotation data type
	uint8_t rot_detect; //detection of a full 360 degrees rotation gives 1. It also returns 1, if no rotation has been detected for 5 seconds
	uint32_t wheel_rot_cnt; //number of wheel rotations done so far
	uint16_t rpm; //rounds per minute
}wheels_t;

typedef struct sit_stand_t {
	uint8_t sit_stand_mode; //0: sitting, 1: standing, 2: no change
	uint32_t sit_time; //in seconds
	uint32_t stand_time; //in seconds
}sit_stand_t;

typedef enum{
	No_Change = (uint8_t)0x00, //holds its previous state
	Stop_Motion = (uint8_t)0x01, //the device stops moving
	Start_Motion = (uint8_t)0x02, //the device starts moving
}motionstatus_t;

typedef struct Motion_Feature_t{ //all features
	uint8_t motion; //0: no change in motion, 1: stops moving, 2: starts moving
	IMURaw_t IMUData; //18 bytes
	Quaternion_t quatrn; //8 bytes
	Euler_fxp_t angles; //6 bytes
	Fext_Vec16_t force; //6 bytes
	Euler_fxp_t angles_err; //6 bytes: error in Euler angles compared to a reference trajectory
	uint16_t motiontrack_cntr; //shows how many times the pre-recorded track has been repeated
	uint8_t motiontrack_progress; //the percentage showing how much of a pre-recorded track has been covered
	uint32_t TimeStamp; //4 bytes: in microseconds
	steps_t steps;
	int16_t direction;
	sit_stand_t sit_stand;
}Motion_Feature_t;





#pragma pack(pop)



#endif /* FUSIONENGINEDATATYPES_H_ */
