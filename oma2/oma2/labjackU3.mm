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


/* ********** */
// WAITHI bit_number
//	Waits until the specified digital I/O bit is aserted high on a LabJack U12. Don't use bit_number = 2, as that is reserved for outbut using the DOUT command


int waithi(int n, char* args)
{
    
	long	idnum = -1;
	long	errorCode;
	long 	channel;
	char	errorString[255];
    long    ConfigIO = 1;
    
	long	state;
    
	channel = n;
    

    errorCode = eDI(hDevice,ConfigIO,channel,&state);
	if (errorCode != 0) {
		GetErrorString	(errorCode, (char *)&errorString);
		printf("Error: %s\n", (char *)&errorString);
	}
	while(state == 0 ){
		errorCode = eDI(hDevice,ConfigIO,channel,&state);
		if (errorCode != 0) {
			GetErrorString	(errorCode, (char *)&errorString);
			printf("Error: %s\n", (char *)&errorString);
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
	char	errorString[255];
    
	long	state;
    
    long    ConfigIO = 1;
    
	channel = 4;	//
	state = n;
    

    errorCode = eDO(hDevice,ConfigIO,channel,state);
	if (errorCode != 0) {
		GetErrorString	(errorCode, (char *)&errorString);
		printf("Error: %s\n", (char *)&errorString);
	}
	printf("%d %d \n",idnum,state);
	return 0;
}

/* ********** */

// AIN channel
//	Read Analog input on a LabJack U12 or LabJack U3

int ain(int n, char* args)
{
    
	long channel;
    static int no_u3 = 1;
	static int no_u12 = 1;
	extern Variable user_variables[];
	
	channel = n;
    

	int localID;
    static long DAC1Enable;
    long error=0;
    //	static u3CalibrationInfo caliInfo;
    //	static HANDLE hDevice;
    //  static int u3_connected = 0;
    double dblVoltage=0.;
    
	//Open first found U3 over USB
    if(u3_connected == 0)
	{
		if (no_u3&&no_u12 == 1) {
            
			localID = -1;
			hDevice = openUSBConnection(localID);
			
			if(hDevice == NULL) {
				no_u3=1;
				//closeUSBConnection(hDevice);
				printf("No Labjack U3. Continue search Labjack U12.\n");
			} else {
				no_u3=0;
				u3_connected = 1;
				if(getCalibrationInfo(hDevice, &caliInfo) < 0) {
					//getCalib sometimes needs to be called twice to work
					printf("getCalibInfo error, try again\n");
					goto close;
				}
				if( (error = eAIN(hDevice, &caliInfo, 1, &DAC1Enable, n, 31, &dblVoltage, 0, 0, 0, 0, 0, 0)) != 0 )goto close;
				printf("Labjack U3 AIN%d value = %.3f\n", n,dblVoltage);
				
			}
		}
	}
	else {
        
        if(n <0){   // unhook from this
            closeUSBConnection(hDevice);
            u3_connected=0;
            return 0;
        }
        
        no_u3=0;
        
        if( (error = eAIN(hDevice, &caliInfo, 0, &DAC1Enable, n, 31, &dblVoltage, 0, 0, 0, 0, 0, 0)) != 0 )
            goto close;
        printf("Labjack U3 AIN%d value = %.3f\n", n,dblVoltage);
    }
	
close:
    
    if(error != 0 && u3_connected == 1){
        printf("Received an error code of %ld\n", error);
        closeUSBConnection(hDevice);
        u3_connected=0;
    }
    user_variables[0].fvalue = dblVoltage;
	user_variables[0].is_float = 1;
    
    
    /* Note: The eAIN, eDAC, eDI, and eDO "easy" functions have the ConfigIO
     parameter.  If calling, for example, eAIN to read AIN3 in a loop, set the
     ConfigIO parameter to 1 (True) on the first iteration so that the
     ConfigIO low-level function is called to ensure that channel 3 is set to
     an analog input.  For the rest of the iterations in the loop, set the
     ConfigIO parameter to 0 (False) since the channel is already set as
     analog. */
    
    
    /* Note: The eAIN "easy" function has the DAC1Enable parameter that needs to
     be set to calculate the correct voltage.  In addition to the earlier
     note, if running eAIN in a loop, set ConfigIO to 1 (True) on the first
     iteration to also set the output of the DAC1Enable parameter with the
     current setting on the U3.  For the rest of the iterations, set ConfigIO
     to 0 (False) and use the outputted DAC1Enable parameter from the first
     interation from then on.  If DAC1 is enabled/disabled from a later eDAC
     or ConfigIO low-level call, change the DAC1Enable parameter accordingly
     or make another eAIN call with the ConfigIO parameter set to 1. */
    
    if(!no_u3) return (int)error;
    return -1;
    
}

/*
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
	
	static int no_u3=1;
	
	extern Variable user_variables[];
	extern char cmnd[];
    
	int j=0;
	

    j = sscanf(args,"%f %f %f %f",&v1,&v2,&v3,&v4);
	

	int localID;
    //	static u3CalibrationInfo caliInfo;
    //	static HANDLE hDevice;
    //	static int u3_connected=0;
	
	if (u3_connected==0) {
		//Open first found U3 over USB
		localID = -1;
		hDevice = openUSBConnection(localID);
		
		if(hDevice == NULL) {
			no_u3=1;
			//closeUSBConnection(hDevice);
		} else {
			no_u3=0;
			u3_connected=1;
			if((errorCode = getCalibrationInfo(hDevice, &caliInfo)) < 0) {
				//getCalib sometimes needs to be called twice to work
				printf("getCalibInfo error, try again\n");
				goto close;
			}
			if((errorCode = eDAC(hDevice, &caliInfo, 0, 0,v1, 0, 0, 0)) != 0)
				printf("eDAC error\n");
            goto close;
			errorCode = eDAC(hDevice, &caliInfo, 1, 1,v2, 0, 0, 0);
		}
	}
	else { //in case of u3_connected=1;
		no_u3=0;
        /*
         if((errorCode = getCalibrationInfo(hDevice, &caliInfo)) < 0) {
         //getCalib sometimes needs to be called twice to work
         printf("getCalibInfo error, try again\n");
         goto close;
         }
         */
		if((errorCode = eDAC(hDevice, &caliInfo, 0, 0,v1, 0, 0, 0)) != 0) {
			goto close;
		}
		errorCode = eDAC(hDevice, &caliInfo, 1, 1,v2, 0, 0, 0);
	}
    
close:
    /*
     if (u3_connected!=1) {
     if (no_u12==0) {
     printf("no Labjack U3.\n");
     }
     }
     
     else */if(errorCode != 0 && u3_connected==1) {	//errorCode>0 for low-level errors
         printf("Received an error code of %ld\n", errorCode);
         closeUSBConnection(hDevice);
         u3_connected=0;
         
     }
	
	if(!no_u3) return (int)errorCode;
    return -1;
}



#endif