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
typedef enum {
	BLE = (uint8_t)0x00, //default value
	Serial = (uint8_t)0x01,
}Intrfc_Protocol;
*/

typedef struct {
	uint8_t major;
	uint8_t minor;
	uint8_t build;
}FWVersion_t;

typedef struct {
	uint8_t API_Release;
	FWVersion_t KL26;
	FWVersion_t Nordic;
	uint64_t devid;
}Neblina_FWVersions_t;


//Firmware Versions: Define here
#define API_RELEASE_VERSION	0x01
//Freescale
static const FWVersion_t KL26_fw = {
		0x00, //major "v1"
		0x0D, //minor "v2"
		1 ///build number 1
};
//Nordic
static const FWVersion_t Nordic_fw = {
		0x00, //major "v1"
		0x0D, //minor "v2"
		1 ///build number 1
};
///////////////////////////////////


/*
 * Neblina communication interface definitions
 */
#define NEB_COMM_INTRF_BLE				0		// Neblina comm over BLE
#define NEB_COMM_INTRF_UART				1		// Neblina comm over UART

/*
 * Neblina Control Byte definitions
 *
 * 0-4 : Subsystem
 * 5-7 : Packet Type
 *
 */
#define NEB_CTRL_PKTYPE_MASK			0xE0		// Packet type mask
#define NEB_CTRL_SUBSYS_MASK			0x1F		// Subsystem mask

// Packet types
#define NEB_CTRL_PKTYPE_DATA				0		// Data/Response
#define NEB_CTRL_PKTYPE_ACK					1		// Ack
#define NEB_CTRL_PKTYPE_CMD					2		// Command
#define NEB_CTRL_PKTYPE_RESERVE1			3
#define NEB_CTRL_PKTYPE_ERR					4		// Error response
#define NEB_CTRL_PKTYPE_RESERVE2			5		//
#define NEB_CTRL_PKTYPE_RQSTLOG				6		// Request status/error log
#define NEB_CTRL_PKTYPE_RESERVE3			7

// Subsystem values
#define NEB_CTRL_SUBSYS_DEBUG				0		// Status & logging
#define NEB_CTRL_SUBSYS_MOTION_ENG			1		// Motion Engine
#define NEB_CTRL_SUBSYS_POWERMGMT			2		// Power management
#define NEB_CTRL_SUBSYS_GPIO				3		// GPIO control
#define NEB_CTRL_SUBSYS_LED					4		// LED control
#define NEB_CTRL_SUBSYS_ADC					5		// ADC control
#define NEB_CTRL_SUBSYS_DAC					6		// DAC control
#define NEB_CTRL_SUBSYS_I2C					7		// I2C control
#define NEB_CTRL_SUBSYS_SPI					8		// SPI control


//Status Check MASK for SUBSYS
//#define NEB_SUBSYS_STATUS_MASK				0x80
//#define NEB_SUBSYS_COMMAND_RESPONSE_MASK	0x40
//#define NEB_SUBSYS_ACKNOWLEDGE_MASK			0x20

// Power management command code
#define POWERMGMT_CMD_GET_BAT_LEVEL			0	// Get battery level
#define POWERMGMT_CMD_GET_TEMPERATURE		1	// Get temperature

// Debug command code
#define DEBUG_CMD_SET_INTERFACE						1	//sets the protocol interface
#define DEBUG_CMD_MOTENGINE_RECORDER_STATUS			2	//asks for the streaming status of the motion engine, as well as the flash recorder state
#define DEBUG_CMD_MOTION_ENG_UNIT_TEST_START_STOP	3	//starts/stops the motion engine unit-test mode
#define DEBUG_CMD_MOTION_ENG_UNIT_TEST_DATA			4	//data being transferred between the host and Neblina for motion engine's unit testing
#define DEBUG_CMD_GET_FW_VERSION					5

// LED control command codes
#define LED_CMD_SET_VALUE							1	// Set LED value
#define LED_CMD_GET_VALUE							2	// Get LED value
#define LED_CMD_SET_CFG								3	// Set config
#define LED_CMD_GET_CFG								4	// Get config

typedef struct _LedCtrl_Data {
	uint8_t NbLed;						// Number of LED to control
	struct {
		uint8_t	No;						// LED number
		uint8_t	Value;					// data - value depending on command code
	} Led[8];
} NEB_LEDCTRL_DATA;

typedef struct Fusion_DataPacket_t
{
	uint32_t TimeStamp;
	uint8_t data[MAX_NB_BYTES];
}Fusion_DataPacket_t;

typedef struct {
	uint8_t SubSys:5; 	// subsystem code
	uint8_t PkType:3; 	// packet type: command, response, error packet, acknowledge
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
bool ProcessLedCtrlCmd(NEB_PKT *pPkt);

#ifdef __cplusplus
}
#endif


#endif // __NEBLINA_H__
