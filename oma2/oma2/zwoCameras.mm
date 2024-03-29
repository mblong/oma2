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
extern ImageBitmap iBitmap;
extern oma2UIData UIData;

extern float fwhmRatio;
extern float fwhmMinIncreaseFraction;
extern int fwhmRadius;
extern int fwhmAverageOver;

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
        DISconnect
        WBAlance whiteBalanceRed whiteBalanceBlue (values are from 1-99)
        FOCus (using the current settings, presumably a cropped window, continuously acquire
         and display 8-bit grey-scale images. To stop, type cmnd')
 
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
long setTemp = 20;
long sensorTemp=200;
ASI_BOOL bAuto = ASI_FALSE;
int bin = 1, Image_type;
ASI_CONTROL_CAPS ControlCaps;
ASI_EXPOSURE_STATUS status;
int exp_ms=10;
int gain=0;
int imageType=2;
long wbR,wbB;
bool coolerEnabled=false;
bool antiDewEnabled=false;
bool autoDisplayEnabled=true;
bool clearBadEnabled=false;
int stopExposure;
long maxGain;
float fwhmValue;
float circDevValue;

long coolerPercent=0;
ASI_ERROR_CODE asiErr;

// information about the ZWO focuser is included in the extra data
extern bool focuserConnected;
extern int currentPos;
extern float fTemp;


int zwo(int n,char* args){

    long i;
    int nargs;
    char dummy[CHPERLN];
    
    

    if(!connected)
        if( connectCamera() <= 0) return HARD_ERR;
    
    zwoWindow
    zwoGetTempInfo();
    
    if(strlen(args) == 0)
        strcpy(args,"ACQ");
    for( i=0; i<3; i++) args[i] = toupper(args[i]);
    if( strncmp(args,"EXP",3) == 0){
        sscanf(args,"%s %d",dummy, &exp_ms);
        ASISetControlValue(camNum, ASI_EXPOSURE, exp_ms*1000, ASI_FALSE);
        ASISetControlValue(camNum, ASI_BANDWIDTHOVERLOAD, 50, ASI_FALSE);
        zwoUpdate

    } else if ( strncmp(args,"GAI",3) == 0){
        sscanf(args,"%s %d",dummy, &gain);
        if(gain > maxGain){
            beep();
            printf("Maximum gain is set to %d\n",maxGain);
            gain = (int)maxGain;
        }
        zwoSetGain();
        zwoUpdate
        
    } else if ( strncmp(args,"DIS",3) == 0){
        zwoWindowClose
        
    } else if ( strncmp(args,"WBA",3) == 0){
        sscanf(args,"%s %ld %ld",dummy, &wbR,&wbB);
        ASISetControlValue(camNum, ASI_WB_R, wbR, ASI_FALSE);
        ASISetControlValue(camNum, ASI_WB_B, wbB, ASI_FALSE);
        
    } else if ( strncmp(args,"TEM",3) == 0){
        nargs = sscanf(args,"%s %ld",dummy, &setTemp);
        if(nargs == 2){
            if(setTemp >= -15 && setTemp <= 20){
                ASISetControlValue(camNum, ASI_COOLER_ON, 1, bAuto);
                coolerEnabled=true;
                ASISetControlValue(camNum, ASI_TARGET_TEMP, setTemp, bAuto);
            }
            long coolerPercent;
            ASIGetControlValue(camNum, ASI_TEMPERATURE, &sensorTemp, &bAuto);
            ASIGetControlValue(camNum, ASI_COOLER_POWER_PERC, &coolerPercent, &bAuto);
            printf("Sensor Temperature: %.1f\n", (float)sensorTemp/10.0);
            printf("Cooler Percent: %d\n", coolerPercent);
            
        } else {
            ASISetControlValue(camNum, ASI_COOLER_ON, 0, bAuto);
            coolerEnabled=false;
            printf("Cooler is OFF.\n");
        }
        zwoUpdate

    } else if ( strncmp(args,"BIN",3) == 0){
        sscanf(args,"%s %d",dummy, &bin);
        int w = iMaxWidth/bin;
        int h= iMaxHeight/bin;
        snprintf(dummy,CHPERLN,"%d %d", h,w);
        size_c(0,dummy);
        int* specs = iBuffer.getspecs();
        specs[DX] = specs[DY] = bin;
        specs[CAMERA] = ZWO+0;
        iBuffer.setspecs(specs);
        free(specs);
        update_UI();
    } else if ( strncmp(args,"ACQ",3) == 0){
        int* specs = iBuffer.getspecs();
        float* extra;
        int exSize = iBuffer.getExtraSize();
        if(exSize == ZWO_EXTRA_SIZE){                // assume this extra is valid for camera info
            extra = iBuffer.getextra();
        }else{
            extra = new float[ZWO_EXTRA_SIZE];      // if no extra exists, we'll make new extra
            for(i=0; i<ZWO_EXTRA_SIZE; i++) extra[i]=0.0;
        }
        specs[CAMERA] = ZWO+0;
        int modified=0;
        stopExposure=0;
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
        
        DATAWORD* values = iBuffer.getvalues();

        values[EXPOSURE] = exp_ms/1000.;
        values[RED_MULT] = wbR/100.;
        values[GREEN_MULT] = 1.;
        values[BLUE_MULT] = wbB/100.;
        values[APERTURE] = 0.;
        values[ISO] = gain;
        
        
        // check to see if the parameters are OK for this camera
        // specs[COLS]%8 !=0 -- doesn't seem to be needed for bin=2
        if( specs[DX]*specs[COLS]+specs[X0] > iMaxWidth ||
           specs[DY]*specs[ROWS]+specs[Y0] > iMaxHeight || specs[DX] != specs[DY] ||
           specs[ROWS]%2 != 0) {
            beep();
            printf("Incompatible readout parameters. (Row/Column/X0/Y0/DX/DY)\n");
            printf("Possible binning  is 1x1, 2x2, 3x3.\n");
            free(specs);
            free(values);
            return HARD_ERR;
        }
        
        asiErr = ASISetROIFormat(camNum, specs[COLS], specs[ROWS], specs[DX], (ASI_IMG_TYPE)2);
        if(asiErr != ASI_SUCCESS){
            beep();
            printf("Error setting format: %d\n",asiErr);
            free(specs);
            free(values);
            return HARD_ERR;
        }
        ASISetStartPos(camNum,specs[X0]/specs[DX],specs[Y0]/specs[DY]);

        long imgSize = specs[COLS]* specs[ROWS]; //width*height*(1 + (imageType==ASI_IMG_RAW16));
        unsigned short* imgBuf = new unsigned short[imgSize];
        int countdown= exp_ms/1000; //seconds of exposure
        ASIStartExposure(camNum, ASI_FALSE);
        usleep(10000);//10ms
        status = ASI_EXP_WORKING;
        while(status == ASI_EXP_WORKING){
            ASIGetExpStatus(camNum, &status);
            if(exp_ms/1000 >= 5){
                zwoUpdateTimer
                if(stopExposure){
                    asiErr=ASIStopExposure(0);
                    values[EXPOSURE]=exp_ms/1000-countdown;
                    beep();
                    printf("Exposure terminated early.\nExposure was ~ %d seconds.\n",exp_ms/1000-countdown);
                    countdown=0;
                    stopExposure=0;
                    zwoUpdateTimer
                } else {
                    if(countdown) usleep(1000000);  //1 second
                    countdown--;
                }
            }
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
        iBuffer.setvalues(values);
        free(values);
        
        // add comments
        snprintf(dummy,CHPERLN,"%s\nCooler On: %d\nAnti-Dew On: %d\nSet Temperature: %ld\nSensor Temperature: %f\nGain: %d\n",ASICameraInfo.Name,coolerEnabled,antiDewEnabled,setTemp,sensorTemp/10.0,gain);
        int logLength=(int)strlen(dummy);
        for(i=0;i<logLength;i++) if(dummy[i]=='\n') dummy[i]=0;
        dummy[logLength]=0;
        iBuffer.setComment(dummy, logLength+1);
        
        // add extra data
        extra[SET_TEMP] = setTemp;
        extra[CAM_TEMP] = sensorTemp/10.0;
        extra[COOLER_ON] = coolerEnabled;
        extra[ANTI_DEW_ON] = antiDewEnabled;
        if(focuserConnected){
            extra[FOCUSER_CONNECTED] = 1.0;
            extra[FOCUSER_POSITION] = currentPos;
            extra[FOCUSER_TEMP] = fTemp;
        } else {
            extra[FOCUSER_CONNECTED] = 0.0;
            extra[FOCUSER_POSITION] = -1.0;
            extra[FOCUSER_TEMP] = 100.0;
        }
        if(strncmp("ZWO ASI2600MC Pro",ASICameraInfo.Name,17) == 0){
            extra[ZWO_CAMERA_TYPE] = ASI2600MC;
            extra[XPIXSZ] = 3.76;
            extra[YPIXSZ] = 3.76;
        } else {
            extra[ZWO_CAMERA_TYPE] = ASI174MM;
            extra[XPIXSZ] = 5.86;
            extra[YPIXSZ] = 5.86;
        }

        if(clearBadEnabled) {
            extern oma2UIData UIData;
            extern int bayer,ccd_height;
            printMax=0;
            //bayer = 1;
            if(UIData.clearBad != 0.0){
                if(UIData.clearBad != 1.0){
                    // take the clearBad value as counts and find bad pixels in the current image
                    n=UIData.clearBad;
                    snprintf(dummy,CHPERLN,"%d",n);
                    findbad_c(n,dummy);
                }
                if(ccd_height > 0){        // means bad pixels have already been found;
                    clearbad_c(0, dummy);
                } else {
                    beep();
                    printf("Bad pixels have not been located -- run FINDBAD first or specify number of counts.\n");
                }
            }
            if(UIData.demosaic){
                snprintf(dummy,CHPERLN,"0 0 0");
                demosaic_c(0,dummy);
            }
            long black;
            asiErr = ASIGetControlValue(camNum, ASI_OFFSET, &black, &bAuto);
            switch (UIData.subtractBlack) {
                    
                case 0:
                    break;
                case 1:
                    snprintf(dummy,CHPERLN,"%ld",black);
                    minus_c(0,dummy);
                    break;
                case 2:
                    snprintf(dummy,CHPERLN,"%ld",black);
                    minus_c(0,dummy);
                    snprintf(dummy,CHPERLN,"0");
                    clipbottom_c(0, dummy);
                    break;
                default:
                    break;
            }
            
            if(UIData.applyWhiteBalance){
                printf("White balance correction not implemented here.\n");
                //im->rgbMult(redMult, greenMult, blueMult);
                //im->clip(C.maximum-black);
            }
            if(UIData.applyGamma!= 1.0){
                snprintf(dummy,CHPERLN,"%f",1.0/UIData.applyGamma);
                power_c(0,dummy);
            }
        }
        printMax=1;
        iBuffer.setExtra(extra, ZWO_EXTRA_SIZE);
        delete[] extra;
 
        iBuffer.getmaxx(printMax);
        if(autoDisplayEnabled) display(0,(char*)"ZWO");
                
        update_UI();
        delete[] imgBuf;
        free(specs);
        return asiErr;

    } else if ( strncmp(args,"FOC",3) == 0){
        int* specs = iBuffer.getspecs();
        specs[CAMERA] = ZWO+0;
        int modified=0,count=0;
        int numInArray=0;
        float fwhmArray[MAX_FWHM_AVERAGE_SIZE];
        stopExposure=0;
        
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
        
        DATAWORD* values = iBuffer.getvalues();
        values[EXPOSURE] = exp_ms/1000.;
        values[RED_MULT] = wbR/100.;
        values[GREEN_MULT] = 1.;
        values[BLUE_MULT] = wbB/100.;
        iBuffer.setvalues(values);
        free(values);

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

        asiErr = ASISetROIFormat(camNum, specs[COLS], specs[ROWS], specs[DX], ASI_IMG_Y8);
        if(asiErr != ASI_SUCCESS){
            beep();
            printf("Error setting format: %d\n",asiErr);
            free(specs);
            return HARD_ERR;
        }
        ASISetStartPos(camNum,specs[X0]/specs[DX],specs[Y0]/specs[DY]);
        
        long imgSize = specs[COLS]* specs[ROWS];
        unsigned char* imgBuf = new unsigned char[imgSize];
        DATAWORD* datptr;
        unsigned char* bufptr;
        int currentWindowFlag = UIData.newwindowflag;
        UIData.newwindowflag = 0;
        
        while (!stopExposure){
            ASIStartExposure(camNum, ASI_FALSE);
            usleep(10000);//10ms
            status = ASI_EXP_WORKING;
            while(status == ASI_EXP_WORKING){
                ASIGetExpStatus(camNum, &status);
            }
            if(status == ASI_EXP_SUCCESS){
                ASIGetDataAfterExp(camNum, imgBuf, imgSize);
            } else {
                stopExposure=0;
                beep();
                printf("Exposure error.\n");
            }
            datptr= iBuffer.getImageData();
            bufptr= imgBuf;
            for(i=0; i< imgSize; i++){      // copy the 8-bit data into iBuffer
                *datptr++ = *bufptr++;
            }
            ASIStopExposure(camNum);
            iBuffer.getmaxx(0);
            if(UIData.toolselected == CALCRECT){
                display(0,(char*)"ZWO");
                update_UI();
                //printf("%d ave over\n",fwhmAverageOver);
                point substart,subend;
                substart = UIData.iRect.ul;
                subend = UIData.iRect.lr;
                //float* distribution = new float[distSize];
                
                if (subend.h < iBuffer.width() && subend.v < iBuffer.height() &&
                    substart.h >= 0 && substart.v >= 0){
                    fwhmValue=fwhm(substart,subend,fwhmRadius,fwhmRatio,fwhmMinIncreaseFraction);
                    fwhmArray[count%fwhmAverageOver]=fwhmValue; // save this latest value
                    count++;
                    if( numInArray < fwhmAverageOver){
                        numInArray++;
                    } else {
                        numInArray=fwhmAverageOver;
                    }
                    float sum=0.0;
                    for(i=0; i < numInArray; i++){
                        sum += fwhmArray[i];
                    }
                    fwhmValue=sum/numInArray;
                    //printf("%f %d %f\n",sum,numInArray,fwhmValue);
                    zwoUpdateFwhm
                }
            } else if (UIData.toolselected == CROSS){
                float size,ellipticity;
                starFocus(&size,&ellipticity);
                display(0,(char*)"ZWO");
                update_UI();
                zwoUpdateSize
            } else {
                display(0,(char*)"ZWO");
                update_UI();
            }
        }
        if(UIData.toolselected == CALCRECT || UIData.toolselected == CROSS){
            fwhmValue=-1.0;
            zwoUpdateFwhm
        }
        
        UIData.newwindowflag = currentWindowFlag;
        delete[] imgBuf;
        free(specs);
        return asiErr;

    } else {
        beep();
        printf("Unknown ZWO Command\nValid Commands are:\n\tEXPosure exposureTimeInMsec\n\tTEMperature targetTemperature (degrees C)\n\tGAIn gainValue (0-700)\n\tACQuire (acquire an image; if connected this will be done with no arguments)\n\tBINning binValue (sets format for binValue = 1 or 2)\n\tDISconnect\n\tWBAlance whiteBalanceRed whiteBalanceBlue (values are from 1-99)\n\tFOCus (using the current settings, presumably a cropped window, continuously acquire and display 8-bit grey-scale images. To stop, type cmnd')\n");
        return CMND_ERR;
    }
    return NO_ERR;
}

int connectCamera(){
    extern int bayer;
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
    if(ASICameraInfo.IsColorCam){
        printf("Color Camera: bayer pattern:%s\n",bayerPattern[ASICameraInfo.BayerPattern]);
        bayer=1;
    }else{
        printf("Mono camera\n");
        bayer=0;
    }
    ASIGetNumOfControls(camNum, &iNumOfCtrl);
    for( i = 0; i < iNumOfCtrl; i++) {
        ASIGetControlCaps(camNum, i, &ControlCaps);
        printf("%s\n", ControlCaps.Name);
        printf("\t%s\n", ControlCaps.Description);
        printf("\tMax Value: %ld\n", ControlCaps.MaxValue);
        if(strncmp(ControlCaps.Name,"Gain",4) == 0){
            maxGain = ControlCaps.MaxValue;
        }
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
    connected=true;
    return numDevices;
}


ASI_ERROR_CODE zwoGetTempInfo(){
    long getBool;
    ASIGetControlValue(camNum, ASI_TEMPERATURE, &sensorTemp, &bAuto);
    ASIGetControlValue(camNum, ASI_COOLER_POWER_PERC, &coolerPercent, &bAuto);
    ASIGetControlValue(camNum, ASI_ANTI_DEW_HEATER, &getBool, &bAuto);
    ASIGetControlValue(camNum, ASI_TARGET_TEMP, &setTemp, &bAuto);
    antiDewEnabled = getBool;
    asiErr = ASIGetControlValue(camNum, ASI_COOLER_ON, &getBool, &bAuto);
    coolerEnabled = getBool;
    asiErr = ASIGetControlValue(camNum, ASI_WB_R, &wbR, &bAuto);
    asiErr = ASIGetControlValue(camNum, ASI_WB_B, &wbB, &bAuto);
    return asiErr;
}
ASI_ERROR_CODE zwoSetTemp(int newTemp){
    setTemp=newTemp;
    ASISetControlValue(camNum, ASI_TARGET_TEMP, setTemp, bAuto);
    return asiErr;
}
ASI_ERROR_CODE zwoSetAntiDew(bool state){
    asiErr = ASISetControlValue(camNum, ASI_ANTI_DEW_HEATER, state, bAuto);
    return asiErr;
}
ASI_ERROR_CODE zwoSetGain(){
    asiErr = ASISetControlValue(camNum, ASI_GAIN, gain, ASI_FALSE);
    return asiErr;
}
ASI_ERROR_CODE zwoSetCoolerState(bool state){
    asiErr = ASISetControlValue(camNum, ASI_COOLER_ON, state, bAuto);
    return asiErr;
}

void zwoDisconnect(){
    ASICloseCamera(camNum);
    connected=false;
}
