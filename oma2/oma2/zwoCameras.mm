//
//  zwoCameras.cpp
//  oma2cam
//
//  Created by Marshall Long on 3/29/22.
//  Copyright © 2022 Yale University. All rights reserved.
//

#include "zwoCameras.hpp"

extern char lastname[];
extern Image iBuffer;
extern int printMax;
extern Variable user_variables[];


/*
 ZWO command arguments
    Command to control ZWO camera
    Available commands are as follows:
        EXPosure    exposureTime (in msec)
        TEMperature setTemperature
        ACQuire
        STAtus
        GAIn    gainSetting
        BIN     binSetting
 
    Notes:
    Only the first theree characters of a command are matched in decoding the command.
    
 */

int bDisplay = 0;
int bMain = 1;
int bChangeFormat = 0;
enum CHANGE{
    change_imagetype = 0,
    change_bin,
    change_size_bigger,
    change_size_smaller
};
CHANGE change;

int camNum=0;
int numDevices=0;
int zWidth;
int zHeight;
ASI_CAMERA_INFO ASICameraInfo;
bool connected=false;
int iMaxWidth, iMaxHeight;
const char* bayerPattern[] = {"RG","BG","GR","GB"};
int iNumOfCtrl = 0;
long ltemp = 0;
ASI_BOOL bAuto = ASI_FALSE;
int bin = 1, Image_type;
ASI_CONTROL_CAPS ControlCaps;
ASI_EXPOSURE_STATUS status;
int exp_ms;
int gain=0, temp=20;
int imageType=2;


int zwo(int n,char* args){

    long i;
    int nargs;
    char dummy[256];

    if(!connected)
        if( connectCamera() <= 0) return HARD_ERR;
    
    for( i=0; i<3; i++) args[i] = toupper(args[i]);
    if( strncmp(args,"EXP",3) == 0){
        sscanf(args,"%s %d",dummy, &exp_ms);
        ASISetControlValue(camNum, ASI_EXPOSURE, exp_ms*1000, ASI_FALSE);
        ASISetControlValue(camNum, ASI_BANDWIDTHOVERLOAD, 40, ASI_FALSE);

    } else if ( strncmp(args,"GAI",3) == 0){
        sscanf(args,"%s %d",dummy, &gain);
        ASISetControlValue(camNum, ASI_GAIN, gain, ASI_FALSE);
        
    } else if ( strncmp(args,"DIS",3) == 0){
        ASICloseCamera(camNum);
        connected=false;
        
    } else if ( strncmp(args,"TEM",3) == 0){
        long coolerPercent,coolerOn;
        ASIGetControlValue(camNum, ASI_COOLER_ON, &coolerOn, &bAuto);
        ASIGetControlValue(camNum, ASI_TEMPERATURE, &ltemp, &bAuto);
        ASIGetControlValue(camNum, ASI_COOLER_POWER_PERC, &coolerPercent, &bAuto);
        if(coolerOn)
            printf("Cooler is ON.\n");
        else
            printf("Cooler is OFF.\n");
        printf("Sensor Temperature: %02f\n", (float)ltemp/10.0);
        printf("Cooler Percent: %d\n", coolerPercent);

    } else if ( strncmp(args,"SET",3) == 0){
        nargs = sscanf(args,"%s %d",dummy, &temp);
        if(nargs == 2){
            if(temp >= -15 && temp <= 20){
                ltemp=temp;
                ASISetControlValue(camNum, ASI_COOLER_ON, 1, bAuto);
                ASISetControlValue(camNum, ASI_TARGET_TEMP, ltemp, bAuto);
            }
            long coolerPercent;
            ASIGetControlValue(camNum, ASI_TEMPERATURE, &ltemp, &bAuto);
            ASIGetControlValue(camNum, ASI_COOLER_POWER_PERC, &coolerPercent, &bAuto);
            printf("Sensor Temperature: %02f\n", (float)ltemp/10.0);
            printf("Cooler Percent: %d\n", coolerPercent);
        } else {
            ASISetControlValue(camNum, ASI_COOLER_ON, 0, bAuto);
            printf("Cooler is OFF.\n");
        }

    } else if ( strncmp(args,"CRO",3) == 0){
        printf("crop\n");

    } else if ( strncmp(args,"BIN",3) == 0){
        sscanf(args,"%s %d",dummy, &bin);
        int w = iMaxWidth/bin;
        int h= iMaxHeight/bin;
        sprintf(dummy,"%d %d", h,w);
        size_c(0,dummy);
        int* specs = iBuffer.getspecs();
        specs[DX] = specs[DY] = bin;
        iBuffer.setspecs(specs);
        free(specs);
        update_UI();
    } else if ( strncmp(args,"ACQ",3) == 0){
        int* specs = iBuffer.getspecs();
        int modified=0;
        if(specs[COLS] % (8/specs[DX])) {
            specs[COLS] -= specs[COLS] % (8/specs[DX]);
            modified=1;
        }
        if(specs[ROWS] & 1) {
            specs[ROWS]--;
            modified=1;
        }
        if(specs[X0] & 1) {
            specs[X0]--;
            modified=1;
        }
        if(specs[Y0] & 1) {
            specs[Y0]--;
            modified=1;
        }
        if(modified){
            printf("Image specs modified.\n");
            iBuffer.setspecs(specs);
        }

        // check to see if the parameters are OK for this camera
        // specs[COLS]%8 !=0 -- doesn't seem to be needed for bin=2
        if( specs[DX]*specs[COLS]+specs[X0] > iMaxWidth ||
           specs[DY]*specs[ROWS]+specs[Y0] > iMaxHeight || specs[DX] != specs[DY] ||
           specs[ROWS]%2 != 0) {
            beep();
            printf("Incompatible readout parameters. (Row/Column/X0/Y0/DX/DY)\n");
            printf("Possible binning  is 1x1, 2x2, 3x3.\n");
            free(specs);
            return HARD_ERR;
        }
        
        int err = ASISetROIFormat(camNum, specs[COLS], specs[ROWS], specs[DX], (ASI_IMG_TYPE)2);
        if(err != ASI_SUCCESS){
            beep();
            printf("Error setting format: %d\n",err);
            free(specs);
            return HARD_ERR;
        }
        ASISetStartPos(camNum,specs[X0]/specs[DX],specs[Y0]/specs[DY]);

        long imgSize = specs[COLS]* specs[ROWS]; //width*height*(1 + (imageType==ASI_IMG_RAW16));
        unsigned short* imgBuf = new unsigned short[imgSize];
        
        ASIStartExposure(camNum, ASI_FALSE);
        usleep(10000);//10ms
        status = ASI_EXP_WORKING;
        while(status == ASI_EXP_WORKING)
        {
            ASIGetExpStatus(camNum, &status);
            usleep(1000);//1 ms
        }
        if(status == ASI_EXP_SUCCESS){
            ASIGetDataAfterExp(camNum, (unsigned char*)imgBuf, imgSize*2);
        }
        DATAWORD* datptr= iBuffer.getImageData();
        unsigned short* bufptr= imgBuf;
        for(i=0; i< imgSize; i++){
            *datptr++ = *bufptr++;
        }
        ASIStopExposure(camNum);
        iBuffer.getmaxx(printMax);
        display(0,(char*)"ZWO");
        
        //setReturnValues();
        
        update_UI();
        delete[] imgBuf;
        free(specs);
        return err;


            
    } else {
        beep();
        printf("Unknown ZWO Command\nValid Commands are: \nEXPosure \nTEMperature\nGAIn \nACQuire \nBINning \nSTAtus\n DISconnect\n");
        return CMND_ERR;
    }
    return NO_ERR;
}

int connectCamera(){
    int i;
    
    numDevices = ASIGetNumOfConnectedCameras();
    if(numDevices <= 0){
        beep();
        printf("No camera connected.\n");
        return -1;
    } else {
        printf("Attached cameras:\n");
    }
    for( i = 0; i < numDevices; i++) {
        ASIGetCameraProperty(&ASICameraInfo, i);
        printf("%d %s\n",i, ASICameraInfo.Name);
    }
    // For now, assume only one camera and that is camNum=0
    if(ASIOpenCamera(camNum) != ASI_SUCCESS) {
        beep();
        printf("Open Camera error.\n");
        return -1;
    }
    ASIInitCamera(camNum);
    
    iMaxWidth = ASICameraInfo.MaxWidth;
    iMaxHeight =  ASICameraInfo.MaxHeight;
    printf("Resolution: %d X %d\n", iMaxWidth, iMaxHeight);
    if(ASICameraInfo.IsColorCam)
        printf("Color Camera: bayer pattern:%s\n",bayerPattern[ASICameraInfo.BayerPattern]);
    else
        printf("Mono camera\n");
    ASIGetNumOfControls(camNum, &iNumOfCtrl);
    for( i = 0; i < iNumOfCtrl; i++) {
        ASIGetControlCaps(camNum, i, &ControlCaps);
        printf("%s\n", ControlCaps.Name);
        printf("\t%s\n", ControlCaps.Description);
        printf("\tMax Value: %ld\n", ControlCaps.MaxValue);
        printf("\tMin Value: %ld\n", ControlCaps.MinValue);
        printf("\tDefault: %ld\n", ControlCaps.DefaultValue);
        if(ControlCaps.IsAutoSupported)
            printf("Auto Adjust IS supported\n");
        else
            printf("Auto Adjust IS NOT supported\n");
        if(ControlCaps.IsWritable)
            printf("Read/Write\n\n");
        else
            printf("Read Only\n\n");

    }
    ASIGetControlValue(camNum, ASI_TEMPERATURE, &ltemp, &bAuto);
    printf("Sensor temperature: %02f\n", (float)ltemp/10.0);
    connected=true;
    return numDevices;
}

// _________________________________ //
static unsigned long GetTickCount()
{

#ifdef _MAC

    struct timeval  now;
    gettimeofday(&now, NULL);
    unsigned long ul_ms = now.tv_usec/1000 + now.tv_sec*1000;
    return ul_ms;

#else
   struct timespec ts;
   clock_gettime(CLOCK_MONOTONIC,&ts);
   return (ts.tv_sec*1000 + ts.tv_nsec/(1000*1000));
#endif

}
