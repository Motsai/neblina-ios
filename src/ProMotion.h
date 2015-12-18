/*
 * ProMotion.h
 *
 *  Created on: Dec 10, 2015
 *      Author: Omid Sarbishei
 *      Project: Neblina
 *      Company: Motsai
 *      Description: Certain components and features that do not exist on Neblina, but they do on the ProMotion board
 */

#ifndef PROMOTION_H_
#define PROMOTION_H_

#pragma pack(push, 1)

//Additional subsystems on the ProMotion board
#define NEB_CTRL_SUBSYS_STORAGE				0x0B		//NOR flash memory recorder
#define NEB_CTRL_SUBSYS_EEPROM				0x0C		//small EEPROM storage
/////////////////////////////////////////////////////////////////////////////////////


//Flash Recorder subsystem commands
#define FlashEraseAll 0x01 //erases the whole NOR flash
#define FlashRecordStartStop 0x02 //start or stop recording in a new session
#define FlashPlaybackStartStop 0x03 //playing back a pre-recorded session: either start or stop
//////////////////////////////////////////////////////////


//EEPROM subsystem commands and other defines
#define EEPROM_Read		0x01 //reads 8-byte chunks of data
#define EEPROM_Write	0x02 //write 8-bytes of data to the EEPROM
#define NEB_EEPROM_MAXSIZE			2048 //total number of bytes reserved for the user
#define NEB_EEPROM_USER_BASE_ADDR 	2048 //the base address in the EEPROM where users can start recording
#define NEB_EEPROM_PAGE_SIZE		8 //in bytes
#define NEB_EEPROM_DATA_RESERVED	6 //number of reserved bytes in the data section of the EEPROM packet
//////////////////////////////////////////////////////////////////////////////

typedef struct EEPROM_DataPacket_t
{
	uint16_t page_nb; //the page_nb is limited to 256 pages, where each page is 8 bytes. Hence, only 1 byte will be used, while the second byte should be zero
	uint8_t data[NEB_EEPROM_PAGE_SIZE+NEB_EEPROM_DATA_RESERVED]; //the first 8 bytes are used to represent data, and the rest are reserved
}EEPROM_DataPacket_t;


#pragma pack(pop)



#endif /* PROMOTION_H_ */
