//
//  labjack.mm
//  oma2
//
//  Created by Marshall B. Long on 4/14/14.
//  Copyright (c) 2014 Yale University. All rights reserved.
//

#ifdef LJU3


#include "oma2.h"
#include "UI.h"


#include "u3.h"
#include <unistd.h>

int u3_connected = 0;	// Global flag. No matter ain or aout is called first, u3 is set to connected mode.
                        // This elimates a possible error when switching from ain to aout or vice versa.
HANDLE hDevice;
u3CalibrationInfo caliInfo;
int no_u3=1;


/* ********** */
// WAITHI bit_number
//	Waits until the specified digital I/O bit is aserted high on a LabJack U12. Don't use bit_number = 2, as that is reserved for outbut using the DOUT command


int waithi(int n, char* args)
{
    
	long	idnum = -1;
	long	errorCode;
	long 	channel;
	//char	errorString[255];
    long    ConfigIO = 1;
    
	long	state;
    
	channel = n;
    

    errorCode = eDI(hDevice,ConfigIO,channel,&state);
	if (errorCode != 0) {
		//GetErrorString	(errorCode, (char *)&errorString);
		//printf("Error: %s\n", (char *)&errorString);
        printf("Error: %ld\n", errorCode);
	}
	while(state == 0 ){
		errorCode = eDI(hDevice,ConfigIO,channel,&state);
		if (errorCode != 0) {
			//GetErrorString	(errorCode, (char *)&errorString);
			//printf("Error: %s\n", (char *)&errorString);
            printf("Error: %ld\n", errorCode);
			return -1;
		}
	}
	printf("%d %d \n",idnum,state);
	return 0;
}
/* ********** */

// DOUT state
//	Sets digital I/O bit 2 to low (state = 0) or high (state = 1) on a LabJack U12

int dout(int n, char* args)
{
	long	idnum = -1;
	long	errorCode;
	long 	channel;
	//char	errorString[255];
    
	long	state;
    
    long    ConfigIO = 1;
    
	channel = 4;	//
	state = n;
    

    errorCode = eDO(hDevice,ConfigIO,channel,state);
	if (errorCode != 0) {
		//GetErrorString	(errorCode, (char *)&errorString);
		//printf("Error: %s\n", (char *)&errorString);
        printf("Error: %ld\n", errorCode);
	}
	printf("%d %d \n",idnum,state);
	return 0;
}

/* ********** */

// AIN channel
//	Read Analog input on a LabJack U3

int ain(int n, char* args)
{
	extern Variable user_variables[];

    static long DAC1Enable;
    long errorCode=0;
    
    double dblVoltage=0.;
    
	//Open first found U3 over USB
    if(connectU3())
	{
        if( (errorCode = eAIN(hDevice, &caliInfo, 1, &DAC1Enable, n, 31, &dblVoltage, 0, 0, 0, 0, 0, 0)) != 0 )goto close;
        printf("Labjack U3 AIN%d value = %.3f\n", n,dblVoltage);
	}
    else {
        beep();
        printf("No Labjack U3 recognized\n");
        return HARD_ERR;
    }
    user_variables[0].fvalue = dblVoltage;
	user_variables[0].is_float = 1;

close:
    if(errorCode) {	//errorCode>0 for low-level errors
        closeUSBConnection(hDevice);
        u3_connected=0;
    }
	
	if(errorCode) return HARD_ERR;
    return NO_ERR;
}


/*  // only U3 implemented so far
 AOUTPUT v1 v2 [v3 v4]
 Sends voltages to D/A converters 0 and 1 on a Labjack USB analog/digital I/O device.
 If a Labjack U3 is present, v1 and v2 are sent to it.
 If there is no U3 but there is a Labjack U12, v1 and v2 are sent to the U12.
 If both U3 and U12 Labjacks are present and all 4 voltages are given, v1 and v2 are sent to the U3 and v3 and v4 are sent to the U12.
 */

int aout(int n, char* args)
{
	float v1=0.,v2=0.,v3=0.,v4=0.;
	long	errorCode=0;
	
	extern Variable user_variables[];
	extern char cmnd[];
    
	int j=0;

    j = sscanf(args,"%f %f %f %f",&v1,&v2,&v3,&v4);
	    
    if (connectU3()) {
        if((errorCode = eDAC(hDevice, &caliInfo, 0, 0,v1, 0, 0, 0)) != 0){
            printf("eDAC error %ld\n", errorCode);
            goto close;
        }
        if((errorCode = eDAC(hDevice, &caliInfo, 1, 1,v2, 0, 0, 0)) != 0)
            printf("eDAC error %ld\n", errorCode);
    } else {
        beep();
        printf("No Labjack U3 recognized\n");
        return HARD_ERR;
    }
close:
    if(errorCode) {	//errorCode>0 for low-level errors
         closeUSBConnection(hDevice);
         u3_connected=0;
     }
	
	if(errorCode) return HARD_ERR;
    return NO_ERR;
}

// return if everything is OK, 0 otherwise
int connectU3(){
    if (u3_connected) return u3_connected;
    
    long errorCode = 0;
    //Open first found U3 over USB
    int localID = -1;
    hDevice = openUSBConnection(localID);
    if(hDevice == NULL) {
        no_u3=1;
        return 0;
    } else {
        no_u3=0;
        u3_connected=1;
        if((errorCode = getCalibrationInfo(hDevice, &caliInfo)) != 0) {
            //getCalib sometimes needs to be called twice to work
            printf("getCalibInfo error %ld, try again\n",errorCode);
            closeUSBConnection(hDevice);
            u3_connected=0;
            return 0;
        }
        return 1;
    }
}



#endif