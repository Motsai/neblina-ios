/*
 * neblina.h
 *
 *	Neblina
 *
 *  Created on: 2015-06-17
 *      Author: hoan
 */
#include <stdint.h>

#ifndef __NEBLINA_H__
#define __NEBLINA_H__

#pragma pack(push, 1)

#define NEB_PKT_TYPE_DATA_FLAG		0x80
#define MAX_NB_BYTES 12

// Neblina command codes.
typedef enum  {
	NEB_CMD_UART_RATE,
	NEB_CMD_RESET = 0xa5		// Initiate system reset
} NEB_CMD;

// Neblina control packet
typedef struct {
	NEB_CMD		Cmd;			// Command code
	uint8_t		NbParam;		// Number of parameters
	uint8_t 	ParamData[16];	// Parameter data
} NEB_CTRL;

// Neblina data packet
typedef enum {
	NEB_DATA_TYPE_GYRO,
} NEB_DATA_TYPE;

// Data packet header
typedef struct {
	NEB_DATA_TYPE	Type;		// Data type
	uint16_t		DataLen;	// Length of following data
} NEB_DATA_HRD;

/*
 * Neblina subsystem definitions
 */
#define NEB_SUBSYS_DEBUG				0		// Status & logging
#define NEB_SUBSYS_MOTION_ENG			1		// Motion Engine
#define NEB_SUBSYS_POWER_MGMT			2		// Power management

//Status Check MASK for SUBSYS
#define NEB_SUBSYS_STATUS_MASK			0x80
#define NEB_SUBSYS_VALUE_MASK			0x7F

// Power management command code
#define POWERMGMT_GET_BAT_LEVEL			0



typedef enum subsystem_t//:uint8_t
{
	MotionEngine = 0x01,
	PMIC = 0x02,
	CPU_ADC = 0x03,
	CPU_GPIO = 0x04
} subsystem_t;

typedef struct Fusion_DataPacket_t
{
//	subsystem_t subsys;
//	uint8_t cmd;
	uint32_t TimeStamp;
	//uint8_t length;
	uint8_t data[MAX_NB_BYTES];
}Fusion_DataPacket_t;

typedef struct {
	uint8_t SubSys;		// Subsystem type
	uint8_t Len;		// Data len = size in byte of following data
	uint8_t Crc;		// Crc on data
	uint8_t Cmd;
} NEB_PKTHDR;

typedef struct {
	NEB_PKTHDR	Header;
	uint8_t 	Data[1];	// Data buffer follows. i.e. Data array more than one item
} NEB_PKT;



#pragma pack(pop)


#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief Validate the data packet.
 *
 * @param pPkt : Pointer to header of the data packet
 * @param Len	: Total data length. This does not define packet length
 * @return	true - Success
 */
bool ValidatePacket(NEB_PKT *pPkt, int Len);
void ProcessPacket(NEB_PKT *pPkt);

#ifdef __cplusplus
}
#endif


#endif // __NEBLINA_H__
