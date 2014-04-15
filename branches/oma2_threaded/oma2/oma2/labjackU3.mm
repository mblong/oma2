//
//  labjack.mm
//  oma2
//
//  Created by Marshall B. Long on 4/14/14.
//  Copyright (c) 2014 Yale University. All rights reserved.
//

#ifdef LJU3

/* Note: For the labjack U3 to work properly in this version, liblabjackusb.dylib must be copied to /usr/local/lib
 
 For example:
 
 sudo cp liblabjackusb.dylib /usr/local/lib
 
 */
 
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
// WAITHI Channel
//	Waits until the specified digital I/O bit is aserted high on a LabJack U3. Channel must be in the range 4-7


int waithi(int n, char* args)
{
	long	errorCode;
	long 	channel;
    long    ConfigIO = 1;
	long	state;
    
	channel = n;
    if( channel < 4 || channel > 7){
        beep();
        printf("Channel must be in the range 4-7\n");
        return CMND_ERR;
    }
    if(connectU3())
	{
        errorCode = eDI(hDevice,ConfigIO,channel,&state);
        if(errorCode) {	//errorCode>0 for low-level errors
            beep();
            printf("eDI error %ld\n", errorCode);
            closeUSBConnection(hDevice);
            u3_connected=0;
            return HARD_ERR;
        }
        while(state == 0 ){
            errorCode = eDI(hDevice,ConfigIO,channel,&state);
            if (errorCode != 0) {
                printf("eDI error %ld\n", errorCode);
                closeUSBConnection(hDevice);
                u3_connected=0;
                return HARD_ERR;
            }
        }
        return NO_ERR;
	}
    else {
        beep();
        printf("No Labjack U3 recognized\n");
        return HARD_ERR;
    }

}
/* ********** */

// DOUTPUT channel state
//    Sets the specified digital output channel on a Labjack U3 to the specified state (0 or 1). Channel must be in the range 4-7.
//

int dout(int n, char* args)
{
	long	errorCode;
	long 	channel;
	long	state;
    long    ConfigIO = 1;
    
    int narg = sscanf(args,"%ld %ld",&channel,&state);
    if( narg !=2 || channel < 4 || channel > 7){
        beep();
        printf("Arguments are: Channel State\nChannel must be in the range 4-7\n");
        return CMND_ERR;
    }
    if (state) state = 1;
    //Open first found U3 over USB
    if(connectU3())
	{
        errorCode = eDO(hDevice,ConfigIO,channel,state);
        if(errorCode) {	//errorCode>0 for low-level errors
            beep();
            printf("eDO error %ld\n", errorCode);
            closeUSBConnection(hDevice);
            u3_connected=0;
            return HARD_ERR;
        }
        return NO_ERR;
	}
    else {
        beep();
        printf("No Labjack U3 recognized\n");
        return HARD_ERR;
    }
    
}


/* ********** */

// AINPUT channel
//	Read Analog input from the specified channel on a LabJack U3. Channel must be in the range 0-3; The voltage is returned in command_return_1.

int ain(int n, char* args)
{
	extern Variable user_variables[];
    static long DAC1Enable;
    long errorCode=0;
    double dblVoltage=0.;
    
    if( n < 0 || n > 3){
        beep();
        printf("Channel must be in the range 0-3\n");
        return CMND_ERR;
    }

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


/*
 AOUTPUT v1 v2
 Sends voltages to D/A converters 0 and 1 on a Labjack USB U3 analog/digital I/O device.

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