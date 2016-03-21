/*
 | ==============================================================================
 | Copyright (C) 2005-2007 Prosilica.  All Rights Reserved.
 |
 | Redistribution of this header file, in original or modified form, without
 | prior written consent of Prosilica is prohibited.
 |
 |==============================================================================
 |
 | This sample code, open the first camera found on the host computer and set it
 | for capturing. It then wait for the user to press a key before enqueuing a
 | frame and saving it to a TIFF file if the capture was successful
 |
 |==============================================================================
 |
 | THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
 | WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF TITLE,
 | NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR  PURPOSE ARE
 | DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 | INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 | LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
 | OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED  AND ON ANY THEORY OF
 | LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 | NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 | EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 |
 |==============================================================================
 */

#ifdef GIGE_

#define _OSX
#define _x86

//#include "gluedCommands.h"

//#define tPvUint32 unsigned int

#if defined(_LINUX) || defined(_QNX) || defined(_OSX)
#include <unistd.h>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include <ctime>
#endif

#include "PvApi.h"
#include "ImageLib.h"

//#include "oma2.h"
#include "UI.h"


// camera's data
typedef struct
{
    unsigned long   UID;
    tPvHandle       Handle;
    tPvFrame        Frame[100];
    
} tCamera;

void Sleep(unsigned int time);
void WaitForCamera();
bool CameraGet(tCamera* Camera);
bool CameraSetup(tCamera* Camera);
bool CameraStartContinuous(tCamera* Camera, int exptime, int frate, int gain, int trigger, int triggerDelay, int binx, int biny);
bool CameraStart_preview(tCamera* Camera, int* time);
bool CameraStart(tCamera* Camera, int* time, int* fcount, int* frate, int* gain, int* trigger, int *triggerDelay, int *binx, int* biny);
void CameraSnap(tCamera* Camera, int time, int fcount, int frate, int label, int trigger, int sav, char* savestr);
void CameraSnapOneFrame(tCamera* Camera,DATAWORD*);
void CameraStop(tCamera* Camera);
void CameraUnsetup(tCamera* Camera, int fcount);

enum {FREERUN,FIXED,SYNCIN};

#if defined(_LINUX) || defined(_QNX) || defined(_OSX)
void Sleep(unsigned int time)
{
    struct timespec t,r;
    
    t.tv_sec    = time / 1000;
    t.tv_nsec   = (time % 1000) * 1000000;    
    
    while(nanosleep(&t,&r)==-1)
        t = r;
}
#endif

int GigEinitialized = 0;
extern Image iBuffer;
char labelBuffer[100];
tCamera Camera;
unsigned long sbyte=0;

// wait for a camera to be plugged
void WaitForCamera()
{   
    int i=0;
    
    printf("waiting for a camera ");
    while(!PvCameraCount() && i++<20)
    {
        printf(".");
        Sleep(250);
    }
    printf("\n");
}

// get the first camera found
bool CameraGet(tCamera* Camera)
{
    tPvUint32 count,connected;
    tPvCameraInfo list;
    
    count = PvCameraList(&list,1,&connected);
    if(count == 1)
    {
        Camera->UID = list.UniqueId;
        printf("got camera %s\n",list.SerialString);
        return true;
    }
    else
        return false;
}

// open the camera
bool CameraSetup(tCamera* Camera)
{
    bool result;
    result = PvCameraOpen(Camera->UID,ePvAccessMaster,&(Camera->Handle));
    return !result; 
}

// setup and start streaming continuous mode
// use FREERUN for trigger
bool CameraStart_preview(tCamera* Camera, int* time)
{
    unsigned long FrameSize = 0;
    char pixelformat[256];
    
    // Auto adjust the packet size to max supported by the network, up to a max of 8228.
    // NOTE: In Vista, if the packet size on the network card is set lower than 8228,
    //       this call may break the network card's driver. See release notes.
    //
    PvCaptureAdjustPacketSize(Camera->Handle,8228); //-mbl added this in (was commented out) -- seems OK
    
    // set the camera in capture mode
	if(PvCaptureStart(Camera->Handle)){
		printf("Couldn't start capture.\n");
		return false;
	}
    
    PvAttrEnumGet(Camera->Handle,"SensorType",pixelformat,sizeof(pixelformat),NULL);
    //sprintf(type,"Sensor type: %s\n",pixelformat);
    // set the camera pixel format
    if(strncmp(pixelformat,"Bayer",3) == 0){
        if(PvAttrEnumSet(Camera->Handle,"PixelFormat","Bayer16")){
            printf("Couldn't set format.\n");
            return false;
        }
    } else if (strncmp(pixelformat,"Mono",3) == 0){
        if(PvAttrEnumSet(Camera->Handle,"PixelFormat","Mono16")){
            printf("Couldn't set format.\n");
            return false;
        }  
    }
    
    // set the camera exposure mode
    if(PvAttrEnumSet(Camera->Handle, "ExposureMode","Manual")){
		printf("Couldn't set exposure mode.\n");
		return false;
	}
    
    int* specs = iBuffer.getspecs();
    
	// Need checking for valid values here
	if(PvAttrUint32Set(Camera->Handle, "Width", specs[COLS])){
		printf("Couldn't set width.\n");
        free(specs);
		return false;
	}
	if(PvAttrUint32Set(Camera->Handle, "Height", specs[ROWS])){
		printf("Couldn't set height.\n");
        free(specs);
		return false;
	}
	specs[X0] = specs[X0] & 0xfffe;
	if(PvAttrUint32Set(Camera->Handle, "RegionX", specs[X0])){
		printf("Couldn't set X0.\n");
        free(specs);
		return false;
	}
	specs[Y0] = specs[Y0] & 0xfffe;
	if(PvAttrUint32Set(Camera->Handle, "RegionY", specs[Y0])){
		printf("Couldn't set Y0.\n");
        free(specs);
		return false;
	}
    
    if(PvAttrUint32Set(Camera->Handle, "ExposureValue", *time)){
        printf("Couldn't set exposure.\n");
        free(specs);
        return false;
    }
    
    // how big should the frame buffers be?
    if(PvAttrUint32Get(Camera->Handle,"TotalBytesPerFrame",&FrameSize)) {   // this is affected by width and height
		printf("Couldn't get size.\n");
        free(specs);
		return false;
	}
    
    // set the streambyte/second value
    if(PvAttrUint32Set(Camera->Handle,"StreamBytesPerSecond",sbyte)){
        printf("Couldn't set stream rate.\n");
        free(specs);
        return false;
    }
    
    // set the camera in continuous acquisition mode
	if(PvAttrEnumSet(Camera->Handle,"AcquisitionMode","Continuous")){
		printf("Couldn't set continuous acquisition mode.\n");
        free(specs);
		return false;
	}
    
    // set the trigger mode
    if(PvAttrEnumSet(Camera->Handle,"FrameStartTriggerMode","Freerun")){
        printf("Couldn't set free run mode.\n");
        free(specs);
        return false;
    }
    
	// allocate the buffer for one frame
    Camera->Frame->Context[0]  = Camera;
    Camera->Frame->ImageBuffer = malloc(FrameSize);
    if(Camera->Frame->ImageBuffer){
        Camera->Frame->ImageBufferSize = FrameSize;
    } else {
        printf("Couldn't allocate space.\n");
        free(specs);
        return false;
    }
    
    // IMAGE ACQUISITION
	if(PvCommandRun(Camera->Handle,"AcquisitionStart"))
	{
		// if that fails, we reset the camera to non capture mode
		PvCaptureEnd(Camera->Handle) ;
		printf("Couldn't start acqusition.\n");
        free(specs);
		return false;
	}
    free(specs);
	return true;    
}


// setup and start streaming CONTINUOUS mode
// uses fixed rate or triggered framing
bool CameraStartContinuous(tCamera* Camera, int exptime, int frate, int gain, int trigger, int triggerDelay, int binx, int biny)
{
    unsigned long FrameSize = 0;
    char pixelformat[256];
    tPvErr err;
    
    // Auto adjust the packet size to max supported by the network, up to a max of 8228.
    // NOTE: In Vista, if the packet size on the network card is set lower than 8228,
    //       this call may break the network card's driver. See release notes.
    //
    PvCaptureAdjustPacketSize(Camera->Handle,8228); //-mbl added this in (was commented out) -- seems OK
    
    // set the camera in capture mode
	if(PvCaptureStart(Camera->Handle)){
		printf("Couldn't start capture.\n");
		return false;
	}
    
    PvAttrEnumGet(Camera->Handle,"SensorType",pixelformat,sizeof(pixelformat),NULL);
    //sprintf(type,"Sensor type: %s\n",pixelformat);
    // set the camera pixel format
    if(strncmp(pixelformat,"Bayer",3) == 0){
        if(PvAttrEnumSet(Camera->Handle,"PixelFormat","Bayer16")){
            printf("Couldn't set format.\n");
            return false;
        }
    } else if (strncmp(pixelformat,"Mono",3) == 0){
        if(PvAttrEnumSet(Camera->Handle,"PixelFormat","Mono16")){
            printf("Couldn't set format.\n");
            return false;
        }
    }
    
    // set the camera exposure mode
    if(PvAttrEnumSet(Camera->Handle, "ExposureMode","Manual")){
		printf("Couldn't set exposure mode.\n");
		return false;
	}
    // set the camera gain mode
    if(PvAttrEnumSet(Camera->Handle, "GainMode","Manual")){
		printf("Couldn't set gain mode.\n");
		return false;
	}
    
    // set the camera gain value (decibel)
    if(PvAttrUint32Set(Camera->Handle, "GainValue", gain)){
        printf("Couldn't set gain.\n");
        return false;
    }
    
    // set the binning factor
    if(PvAttrUint32Set(Camera->Handle, "BinningX", binx)){
        printf("Couldn't set horizontal binning.\n");
        return false;
    }
    if(PvAttrUint32Set(Camera->Handle, "BinningY", biny)){
        printf("Couldn't set vertical binning.\n");
        return false;
    }
    
    int* specs = iBuffer.getspecs();
    
	// Need checking for valid values here
	if(PvAttrUint32Set(Camera->Handle, "Width", specs[COLS])){
		printf("Couldn't set width.\n");
        free(specs);
		return false;
	}
	if(PvAttrUint32Set(Camera->Handle, "Height", specs[ROWS])){
		printf("Couldn't set height.\n");
        free(specs);
		return false;
	}
	specs[X0] = specs[X0] & 0xfffe;
	if(PvAttrUint32Set(Camera->Handle, "RegionX", specs[X0])){
		printf("Couldn't set X0.\n");
        free(specs);
		return false;
	}
	specs[Y0] = specs[Y0] & 0xfffe;
	if(PvAttrUint32Set(Camera->Handle, "RegionY", specs[Y0])){
		printf("Couldn't set Y0.\n");
        free(specs);
		return false;
	}
    
    
    if(PvAttrUint32Set(Camera->Handle, "ExposureValue", exptime)){
        printf("Couldn't set exposure.\n");
        free(specs);
        return false;
    }
    
    // how big should the frame buffers be?
    if(PvAttrUint32Get(Camera->Handle,"TotalBytesPerFrame",&FrameSize)) {   // this is affected by width and height
		printf("Couldn't get size.\n");
        free(specs);
		return false;
	}
    
    // set the streambyte/second value
    if(PvAttrUint32Set(Camera->Handle,"StreamBytesPerSecond",sbyte)){
        printf("Couldn't set streamhold capacity.\n");
        free(specs);
        return false;
    }
    
    // set the camera in continuous acquisition mode
	if(PvAttrEnumSet(Camera->Handle,"AcquisitionMode","Continuous")){
		printf("Couldn't set continuous acquisition mode.\n");
        free(specs);
		return false;
	}
    /*
     // set the trigger mode
     */
    
	// allocate the buffer for one frame
    Camera->Frame->Context[0]  = Camera;
    Camera->Frame->ImageBuffer = malloc(FrameSize);
    if(Camera->Frame->ImageBuffer){
        Camera->Frame->ImageBufferSize = FrameSize;
    } else {
        printf("Couldn't allocate space.\n");
        free(specs);
        return false;
    }
    
    
    // **** INTERNAL TRIGGER **** //
    if (trigger == FIXED) {
        
        // set the frame rate value
        if((err = PvAttrFloat32Set(Camera->Handle, "FrameRate",frate))){
            printf("Couldn't set frame rate. Return %d\n",err);
            free(specs);
            return false;
        }
        
        // set the trigger mode
        if(PvAttrEnumSet(Camera->Handle,"FrameStartTriggerMode","FixedRate")){
            printf("Couldn't set fixed-rate mode.\n");
            free(specs);
            return false;
        }
        // IMAGE ACQUISITION
        if(PvCommandRun(Camera->Handle,"AcquisitionStart"))
        {
            // if that fails, we reset the camera to non capture mode
            PvCaptureEnd(Camera->Handle) ;
            printf("Couldn't start acqusition.\n");
            free(specs);
            return false;
        }
        
        
    } else if (trigger == SYNCIN){
        
        // FrameStartTriggerMode,"SyncIn2"
        if(PvAttrEnumSet(Camera->Handle,"FrameStartTriggerMode","SyncIn2")){
            printf("Couldn't set trigger mode.\n");
            free(specs);
            return false;
        }
        
        // FrameStartTriggerEvent,"EdgeRising"
        if(PvAttrEnumSet(Camera->Handle,"FrameStartTriggerEvent","EdgeRising")){
            printf("Couldn't set edge rising event.\n");
            free(specs);
            return false;
        }
        // FrameStartTriggerDelay
        if(PvAttrUint32Set(Camera->Handle,"FrameStartTriggerDelay",triggerDelay)){
            printf("Couldn't set trigger delay.\n");
            free(specs);
            return false;
        }
        
        // AcqStartTriggerMode,"SyncIn2"
        if(PvAttrEnumSet(Camera->Handle,"AcqStartTriggerMode","SyncIn2")){
            printf("Couldn't set acquisition trigger mode.\n");
            free(specs);
            return false;
        }
        
        // AcqStartTriggerEvent,"EdgeRising"
        if(PvAttrEnumSet(Camera->Handle,"AcqStartTriggerEvent","LevelHigh")){
            printf("Couldn't set acquisition edgerising event.\n");
            free(specs);
            return false;
        }
        
    } else if( trigger == FREERUN){
        if(PvAttrEnumSet(Camera->Handle,"FrameStartTriggerMode","Freerun")){
            printf("Couldn't set free run mode.\n");
            return false;
        }
        if(PvCommandRun(Camera->Handle,"AcquisitionStart")){
            // if that fails, we reset the camera to non capture mode
            PvCaptureEnd(Camera->Handle) ;
            printf("Couldn't start acqusition.\n");
            free(specs);
            return false;
        }
    }
    free(specs);
	return true;
}


// setup and start streaming MULTIFRAME MODE
// frames are stored in the camera and then made available to the computer
bool CameraStart(tCamera* Camera, int* time, int* fcount, int* frate, int* gain, int* trigger, int *triggerDelay, int *binx, int* biny)
{
    unsigned long FrameSize = 0;
    unsigned long strcap = 0;
    unsigned long strbyte = 0;
    char pixelformat[256];
    tPvErr err;
    
    // Auto adjust the packet size to max supported by the network, up to a max of 8228.
    // NOTE: In Vista, if the packet size on the network card is set lower than 8228,
    //       this call may break the network card's driver. See release notes.
    //
    PvCaptureAdjustPacketSize(Camera->Handle,8228); //-mbl added this in (was commented out) -- seems OK
    
    // set the camera in capture mode
	if(PvCaptureStart(Camera->Handle)){
		printf("Couldn't start capture.\n");
		return false;
	}
    
    PvAttrEnumGet(Camera->Handle,"SensorType",pixelformat,sizeof(pixelformat),NULL);
    //sprintf(type,"Sensor type: %s\n",pixelformat);
    // set the camera pixel format
    if(strncmp(pixelformat,"Bayer",3) == 0){
        if(PvAttrEnumSet(Camera->Handle,"PixelFormat","Bayer16")){
            printf("Couldn't set format.\n");
            return false;
        }
    } else if (strncmp(pixelformat,"Mono",3) == 0){
        if(PvAttrEnumSet(Camera->Handle,"PixelFormat","Mono16")){
            printf("Couldn't set format.\n");
            return false;
        }  
    }
    
    // set the camera exposure mode
    if(PvAttrEnumSet(Camera->Handle, "ExposureMode","Manual")){
		printf("Couldn't set exposure mode.\n");
		return false;
	}
    
    // set the camera exposure mode
    if(PvAttrEnumSet(Camera->Handle, "GainMode","Manual")){
		printf("Couldn't set gain mode.\n");
		return false;
	}
    
    // set the camera gain value (decibel)
    if(PvAttrUint32Set(Camera->Handle, "GainValue", *gain)){
        printf("Couldn't set gain.\n");
        return false;
    }
    
    // set the binning factor 
    if(PvAttrUint32Set(Camera->Handle, "BinningX", *binx)){
        printf("Couldn't set horizontal binning.\n");
        return false;
    }
    if(PvAttrUint32Set(Camera->Handle, "BinningY", *biny)){
        printf("Couldn't set vertical binning.\n");
        return false;
    }

    // this looks problematic to me  -mbl
    // setting this is up to the user
    // this will mess up the buffer size
    
    //header[NCHAN] = header[NCHAN] / *binx;
    //header[NTRAK] = header[NTRAK] / *biny;
    
    int* specs = iBuffer.getspecs();
    
	// Need checking for valid values here
	if(PvAttrUint32Set(Camera->Handle, "Width", specs[COLS])){
		printf("Couldn't set width.\n");
        free(specs);
		return false;
	}
	if(PvAttrUint32Set(Camera->Handle, "Height", specs[ROWS])){
		printf("Couldn't set height.\n");
        free(specs);
		return false;
	}
	specs[X0] = specs[X0] & 0xfffe;
	if(PvAttrUint32Set(Camera->Handle, "RegionX", specs[X0])){
		printf("Couldn't set X0.\n");
        free(specs);
		return false;
	}
	specs[Y0] = specs[Y0] & 0xfffe;
	if(PvAttrUint32Set(Camera->Handle, "RegionY", specs[Y0])){
		printf("Couldn't set Y0.\n");
        free(specs);
		return false;
	}
    /*
    // adjust the framerate if the one selected is too high for the camera
    if(strncmp(pixelformat,"Bayer",3) == 0){
        if(*frate > (-0.0000001572 * pow(header[NTRAK],3) + 0.0003954* pow(header[NTRAK],2) - 0.3615*header[NTRAK] + 153.6)){
            *frate = (-0.0000001572 * pow(header[NTRAK],3) + 0.0003954* pow(header[NTRAK],2) - 0.3615*header[NTRAK] +  153.6)-1; 
            if (header[NTRAK] <= 180){
                if ( *frate >= 99) *frate = 100;
            }
            if (header[NTRAK] == 1024){
                if ( *frate >= 28) *frate = 30;
            }
            printf("Fps set to %d (maximum value given the frame size)\n\n", *frate);
        } 
    } else if (strncmp(pixelformat,"Mono",3) == 0){
        if(*frate > (0.0000000002296 * pow(header[NTRAK],4) - 0.0000006682 * pow(header[NTRAK],3) + 0.0007413 * pow(header[NTRAK],2) - 0.4031 *header[NTRAK] + 120.7)){
            *frate = (0.0000000002296 * pow(header[NTRAK],4) - 0.0000006682 * pow(header[NTRAK],3) + 0.0007413 * pow(header[NTRAK],2) - 0.4031 *header[NTRAK] + 120.7)-1;
            if (header[NTRAK] == 1024){
                if ( *frate >= 19) *frate = 20;
            }
            printf("Fps set to %d (maximum value given the frame size)\n\n", *frate);
        }
    }
    
    if(*time * *frate > 1000000){ 
        *time = 1000000 / *frate;
        printf("The selected exposure is not compatible with the framerate\n");
        printf("Exposure time decreased to %d us\n", *time);
    }
    */
    if(PvAttrUint32Set(Camera->Handle, "ExposureValue", *time)){
        printf("Couldn't set exposure.\n");
        free(specs);
        return false;
    }
    
    // how big should the frame buffers be?
    if(PvAttrUint32Get(Camera->Handle,"TotalBytesPerFrame",&FrameSize)) {   // this is affected by width and height
		printf("Couldn't get size.\n");
        free(specs);
		return false;
	}
    
    // get the streamhold capacity of the camera
    if(PvAttrUint32Get(Camera->Handle,"StreamHoldCapacity",&strcap)){
        printf("Couldn't set streamhold capacity.\n");
        free(specs);
        return false;
    }
    
    // set the streambyte/second value
    if(PvAttrUint32Set(Camera->Handle,"StreamBytesPerSecond",sbyte)){
        printf("Couldn't set stream rate.\n");
        free(specs);
        return false;
    }
    
    if(PvAttrUint32Get(Camera->Handle,"StreamBytesPerSecond",&strbyte)){
        printf("Couldn't get streamhold capacity.\n");
        free(specs);
        return false;
    }
    
    // set the number of frame to acquire
    if(PvAttrUint32Set(Camera->Handle,"AcquisitionFrameCount",*fcount)){
		printf("Couldn't set acquisition frame count.\n");
        free(specs);
		return false;
	}
    
	// allocate the buffer for the frames we need
    for(int i=0; i< *fcount; i++){
        Camera->Frame[i].Context[0]  = Camera;
        Camera->Frame[i].ImageBuffer = malloc(FrameSize);
        if(Camera->Frame[i].ImageBuffer){
            Camera->Frame[i].ImageBufferSize = FrameSize;
        } else {
            printf("Couldn't allocate space.\n");
            free(specs);
            return false;
        }
        // queue frames
        PvCaptureQueueFrame(Camera->Handle,&(Camera->Frame[i]),NULL);
    }
    
    // **** INTERNAL TRIGGER **** //
    if (*trigger == FIXED) {
        
        // set the frame rate value
        if((err = PvAttrFloat32Set(Camera->Handle, "FrameRate",*frate))){
            printf("Couldn't set frame rate. Return %d\n",err);
            free(specs);
            return false;
        }
        
        // set the trigger mode
        if(PvAttrEnumSet(Camera->Handle,"FrameStartTriggerMode","FixedRate")){
            printf("Couldn't set fixed-rate mode.\n");
            free(specs);
            return false;
        }
        
        // set the camera in multiframe acquisition mode
        if(PvAttrEnumSet(Camera->Handle,"AcquisitionMode","MultiFrame")){
            printf("Couldn't set multiframe acquisition mode.\n");
            free(specs);
            return false;
        }
        
        // enable the camera to store the images in its memory
        if(PvAttrEnumSet(Camera->Handle,"StreamHoldEnable","On")){
            printf("Couldn't set stream hold.\n");
            free(specs);
            return false;
        }
        
        // IMAGE ACQUISITION
        if(PvCommandRun(Camera->Handle,"AcquisitionStart"))
        {
            // if that fails, we reset the camera to non capture mode
            PvCaptureEnd(Camera->Handle) ;
            printf("Couldn't start acqusition.\n");
            free(specs);
            return false;
        }
        
        // release the images to the host computer
        if(PvAttrEnumSet(Camera->Handle,"StreamHoldEnable","Off")){
            printf("Couldn't set stream hold.\n");
            free(specs);
            return false;
        }
        
    // **** EXTERNAL TRIGGER **** //
    } else if (*trigger == SYNCIN){
        
        // FrameStartTriggerMode,"SyncIn2"
        if(PvAttrEnumSet(Camera->Handle,"FrameStartTriggerMode","SyncIn2")){
            printf("Couldn't set trigger mode.\n");
            free(specs);
            return false;
        }
        
        // FrameStartTriggerEvent,"EdgeRising"
        if(PvAttrEnumSet(Camera->Handle,"FrameStartTriggerEvent","EdgeRising")){
            printf("Couldn't set edge rising event.\n");
            free(specs);
            return false;
        }
        
        // set the camera in multiframe acquisition mode
        if(PvAttrEnumSet(Camera->Handle,"AcquisitionMode","MultiFrame")){
            printf("Couldn't set multiframe acquisition mode.\n");
            free(specs);
            return false;
        }
        
        // FrameStartTriggerDelay
        if(PvAttrUint32Set(Camera->Handle,"FrameStartTriggerDelay",*triggerDelay)){
            printf("Couldn't set trigger delay.\n");
            free(specs);
            return false;
        }
        
        // AcqStartTriggerMode,"SyncIn2"
        if(PvAttrEnumSet(Camera->Handle,"AcqStartTriggerMode","SyncIn2")){
            printf("Couldn't set acquisition trigger mode.\n");
            free(specs);
            return false;
        }
        
        // AcqStartTriggerEvent,"EdgeRising"
        if(PvAttrEnumSet(Camera->Handle,"AcqStartTriggerEvent","LevelHigh")){
            printf("Couldn't set acquisition edgerising event.\n");
            free(specs);
            return false;
        }
        
    }
    
    PvCaptureEnd(Camera->Handle); //should be here, before CameraSnap, otherwise it doesn't work properly
    free(specs);
	return true;    
}

// snap and save a frame from the camera
void CameraSnap(tCamera* Camera, int exptime, int fcount, int frate, int label, int trigger, int sav, char* savestr)
{
    int i,j;
    short *ptr;
    
    unsigned long Tfreq;
    unsigned long T_hi;
    unsigned long T_lo;
    double tempo;
    int nt,nc;
    FILE *fp;
   /*
    GetTime(&datetime);
    int month = datetime.month;
    int day = datetime.day;
    int year = datetime.year%100;
    int hour = datetime.hour;
    int minute = datetime.minute;
    float second = datetime.second;
    int secondo = second;
    */
    time_t rawtime;
    struct tm * timeinfo;
    time (&rawtime);
    timeinfo = localtime (&rawtime);
    //printf ("Current local time and date: %s", asctime(timeinfo));

    double tempo_pr = 0;
    
    char strin[256];
    char ora[256];
    
    PvCommandRun(Camera->Handle,"TimeStampReset");
    PvAttrUint32Get(Camera->Handle,"TimeStampFrequency",&Tfreq);
    
    for(j=0; j< fcount; j++){
        
        if(PvCaptureQueueFrame(Camera->Handle,&(Camera->Frame[j]),NULL)){
            
            while(PvCaptureWaitForFrameDone(Camera->Handle,&(Camera->Frame[j]),PVINFINITE) == ePvErrTimeout)
                printf("still waiting ...\n");
            
            if(Camera->Frame[j].Status == ePvErrSuccess){
                
                ptr = (short*)Camera->Frame[j].ImageBuffer;
                int* specs = iBuffer.getspecs();
                // move the data
                for(i=0; i< specs[ROWS];i++){
                    for(int k=0;k<specs[COLS]; k++)
                        iBuffer.setpix(i,k,*(ptr++));
                }
                free(specs);
                //display(0,(char*)"GigE");
                
                //If the camera crashes, try to remove the timestamp calculation.
                
                PvCommandRun(Camera->Handle,"TimeStampValueLatch");
                PvAttrUint32Get(Camera->Handle,"TimeStampValueHi",&T_hi);
                PvAttrUint32Get(Camera->Handle,"TimeStampValueLo",&T_lo);
                
                tempo = (T_hi*4294967296. + T_lo) / Tfreq;  
                float fratec = 1./(tempo - tempo_pr);
                tempo_pr = tempo;
                
                if(label == 1){
                    if (trigger == FIXED){
                        sprintf(labelBuffer,"%2d:%2d:%.4f (Frame %d/%d - %d fps - exp. %d us) ",
                            timeinfo->tm_hour,timeinfo->tm_min,timeinfo->tm_sec+tempo, j+1, fcount, frate, exptime);
                    } else if (trigger == SYNCIN){
                        sprintf(labelBuffer,"%2d:%2d:%.4f (Frame %d/%d - %.1f fps - exp. %d us) ",
                                timeinfo->tm_hour,timeinfo->tm_min,timeinfo->tm_sec+tempo, j+1, fcount, fratec, exptime);
                    }
                    
                 }
                
                if(sav == 1){
                    
                    strcpy(strin,savestr);
                    sprintf(ora,"%s",asctime(timeinfo));
                    strcat(strin,ora);
                    
                    fp = fopen(fullname(strin,SAVE_DATA),"w");
                    if( fp != NULL) {
                        i=0;
                        for(nt=0; nt<iBuffer.height(); nt++){
                            for(nc=0; nc<iBuffer.width(); nc++){

                                fprintf(fp,"%g\t",iBuffer.getpix(nt,nc));
                            }
                            fprintf(fp,"\n");
                        }
                        fclose(fp);
                    }
                }
            }
			//pattern on the GC1380CH is Red Green Green Blue
            else{
                printf("the frame failed to be captured. Status: %d\n",Camera->Frame[j].Status);			
            }
        }
        else{
            printf("failed to queue the frame\n");
        }
    } 
}

// use when the camera has been started in continuous mode
// return one frame
void CameraSnapOneFrame(tCamera* Camera,DATAWORD* dataBuffer)
{
    int i;
    short *ptr;
    
    
    if(!PvCaptureQueueFrame(Camera->Handle,&(Camera->Frame[0]),NULL))
    {
        //printf("waiting for the frame to be done ...\n");
        int* specs = iBuffer.getspecs();
        while(PvCaptureWaitForFrameDone(Camera->Handle,&(Camera->Frame[0]),100) == ePvErrTimeout)
            printf("still waiting ...\n");
        if(Camera->Frame[0].Status == ePvErrSuccess)
        {
			ptr = (short*)Camera->Frame[0].ImageBuffer;
            // move the data
            //for(i=0; i< specs[ROWS];i++){
                //for(int k=0;k<specs[COLS]; k++)
                    //iBuffer.setpix(i,k,*(ptr++));
            //}
            for(i=0; i< specs[ROWS]*specs[COLS];i++)
                *(dataBuffer++) = *(ptr++);
            

			//pattern on the GC1380CH is Red Green Green Blue
        } else {
            printf("the frame failed to be captured. Status: %d\n",Camera->Frame[0].Status);			
		}
        free(specs);
    } 
    else
        printf("failed to queue the frame\n");
}

// stop streaming
void CameraStop(tCamera* Camera)
{
    unsigned long stat_pack_miss = 0;
    unsigned long stat_frame_drop = 0;
    
    if(PvAttrUint32Get(Camera->Handle,"StatPacketsMissed",&stat_pack_miss)){
        printf("Couldn't get stat frame rate.\n");
        return;
    }
	printf("Packets missed: %d.\n",stat_pack_miss);
    
    if(PvAttrUint32Get(Camera->Handle,"StatFramesDropped",&stat_frame_drop)){
        printf("Couldn't get stat frame rate.\n");
        return;
    }
	printf("Frames dropped: %d.\n\n",stat_frame_drop);
    
    PvCaptureQueueClear(Camera->Handle);
    PvCommandRun(Camera->Handle,"AcquisitionStop");
    //PvCaptureEnd(Camera->Handle);  
}

// unsetup the camera

void CameraUnsetup(tCamera* Camera, int fcount)
{
    //PvCameraClose(Camera->Handle);
    // and free the image buffer of the frame
    for(int i=0;i< fcount;i++){
        if (Camera->Frame[i].ImageBuffer)
            free( (char*)Camera->Frame[i].ImageBuffer);     // occasional errors: pointer being freed was not allocated
        Camera->Frame[i].ImageBuffer = 0;
    }
}

/* ************************************************************************************ */
/*
 GIGE
 OMA command for the Prosilica GigE camera.
 */

int gige(int n, char* args)
{
    char txt[CHPERLN];
    
    extern oma2UIData UIData;
    int save_new_status;
    
    
    static int exptime = 10000;    // default exposure time in us
    static int numFrames = 1;         // default number of frame 
    static int frameRate = 1;           // default framerate in fps
    static int gain = 0;           // default gain in db
    static int bx = 1;          // default horizontal binning factor
    static int by = 1;          // default vertical binning factor
    static int label = 0;
    static int numPreviews = 0;
    static int preview = 0;
    static int trigger = FIXED;
    static int triggerDelay = 0;
    static int sav = 0;
    static int fixBad = 0;
    static int realTimeDisplay = 1;
    unsigned long fsize,scap;
    
    char pixelformat[256];
    char buffer[256];
    static char savestr[256];
    unsigned long pixwidth = 0;
    unsigned long pixheight = 0;
    unsigned long redBalance = 0;
    unsigned long blueBalance = 0;
    
    
    double tempo_pr = 0;
    unsigned long Tfreq;
    unsigned long T_hi;
    unsigned long T_lo;
    double tempo;
    
    time_t rawtime;
    struct tm * timeinfo;
    

    
    
    //int createfile(int n,int index);
    //int closefile();
    //int concatfile();
    if ( strncmp(args,"help",3) == 0){
        printf("Available Commands:\n");
        printf("  ACQuire (gets frames in MULTIFRAME mode)\n");
        printf("  EXPosure <exposureTime> (in microseconds)\n");
        printf("  GAIn <gain> (0 or 33)\n");
        printf("  NUMber <numberOfFrames> (to be acquired by the ACQUIRE command; default is 1)\n");
        printf("  RATe <frameRate> \n");
        printf("  LABON (label frames) \n");
        printf("  LABOFf (don't label frames) \n");
        printf("  PREview <numberFrames> (show preview for specified number of frames) \n");
        printf("  EXTernal (set external triggering) \n");
        printf("  INTernal (set internal triggering) \n");
        printf("  DELay <triggerDelay> (set the trigger delay [microseconds])\n");
        printf("  SAVe <filename> (enable save mode; filename will store all frames)\n");
        printf("  ENDSave (disable save mode)\n");
        printf("  SFRames <numFrames> (save the specified number of frames using the filename specified in the \n    SAVe command. Uses CONTINUOUS mode. Also saves a text file showing frame times.)\n");
        printf("  STAtus (print camera settings)\n");
        printf("  FIXbad <flag> (set flag to 1 to clear bad pixels before display or save --> must use FINDBAD first)\n");
        printf("  DISplay <flag> (set flag to 1 to display during acqusition)\n");
        printf("  HDR <numFrames> <multiplier> (save the specified number of frames using the filename\n    specified in the SAVe command. Subsequent exposure times are multiplied by the multiplier.)\n");
        return NO_ERR;
        
    }

    if ( strncmp(args,"fixbad",3) == 0){
        extern int num_hot;
        if(num_hot == 0){
            beep();
            printf("No bad pixels have been specified. Use FINDBAD first.\n");
            return CMND_ERR;
        }
        sscanf(args,"%s %d",txt, &n);
        if (n) {
            fixBad = 1;
            printf("Will fix bad pixels before display.\n");
        } else{
            fixBad = 0;
            printf("No bad pixel fix before display.\n");
        }
        
        return NO_ERR;
    }

    if ( strncmp(args,"display",3) == 0){
        sscanf(args,"%s %d",txt, &n);
        if (n) {
            realTimeDisplay = 1;
            printf("Will display in capture.\n");
        } else{
            realTimeDisplay = 0;
            printf("No display in capture.\n");
        }
        
        return NO_ERR;
    }

    if(!GigEinitialized){
		
		// initialise the Prosilica API
		if(PvInitialize()){
			printf("failed to initialise the API\n");
			return -1;
		}
		
		memset(&Camera,0,sizeof(tCamera));	// just sets this to zero
		
		// wait for a camera to be plugged
		WaitForCamera();
		
		// get a camera from the list
		if(!CameraGet(&Camera)){
			printf("failed to find a camera\n");
			PvUnInitialize();
			return -1;
		}
		
		// setup the camera
		if(!CameraSetup(&Camera)){
			printf("failed to setup the camera\n");
			return -1;
		}
		GigEinitialized = 1;
        gige(0, (char*)"stat");
        return NO_ERR;
		
    }
    
    if(*args == 0) {
		// after initialized, let GIGE command be used to acquire
		strncpy(args,"acq",3);
	}
    
    if( strncmp(args,"exposure",3) == 0){
		sscanf(args,"%s %d",txt, &exptime);
		if( exptime <= 10) exptime = 10;
        if( exptime > 60000000) exptime = 60000000;
        printf(" Exposure set to %d us\n",exptime);
        return NO_ERR;
    }
    else if ( strncmp(args,"gain",3) == 0){
        sscanf(args,"%s %d",txt, &gain);
        if( gain <= 0) gain = 0;
        if( gain > 33) gain = 33;
        printf(" Gain value set to %d\n",gain);
        return NO_ERR;
    }
    else if ( strncmp(args,"number",3) == 0){
        sscanf(args,"%s %d",txt, &numFrames);
        if( numFrames <= 1) numFrames = 1;
        printf(" Frame number set to %d\n",numFrames);
        return NO_ERR;
    }
    else if ( strncmp(args,"rate",3) == 0){
        sscanf(args,"%s %d",txt, &frameRate);
        if( frameRate <= 1) frameRate = 1;
        printf(" Frame rate set to %d fps\n",frameRate);
        return NO_ERR;
    }
    // enable/disable the printing of the label over the image
    else if ( strncmp(args,"labon",5) == 0){
        label = 1;
        return NO_ERR;
    }
    else if ( strncmp(args,"laboff",5) == 0){
        label = 0;
        return NO_ERR;
    }
    // set the preview mode
    else if ( strncmp(args,"preview",3) == 0){
        sscanf(args,"%s %d",txt, &numPreviews);
        printf(" Number of frame preview set to %d \n",numPreviews);
        //if (trigger == 1){
        //    beep();
        //    printf("Preview not possible in external trigger mode.\n");
        //    return CMND_ERR;
        //} else {
            strncpy(args,"acq",3);
            printf(" Wait... \n");
            preview = 1;
            sav = 0;
        //}
    }
    // set the binning factor
    else if ( strncmp(args,"binx",4) == 0){
        sscanf(args,"%s %d",txt, &bx);
        if( bx < 1) bx = 1;
        if( bx > 8) bx = 8;
        by = bx;
        printf(" Horizontal (and vertical) binning factor set to %d\n",bx);
    }
    else if ( strncmp(args,"biny",4) == 0){
        sscanf(args,"%s %d",txt, &by);
        if( by < 1) by = 1;
        if( by > 8) by = 8;
        printf(" Vertical binning factor set to %d\n",by);
    }
    // set the trigger mode
    else if ( strncmp(args,"external",3) == 0){
        printf("* External trigger enabled * \n");
        trigger = SYNCIN;
        return NO_ERR;
    }
    else if ( strncmp(args,"internal",3) == 0){
        printf("* Internal trigger enabled * \n");
        trigger = FIXED;
        return NO_ERR;
    }
    // set the trigger delay [microseconds]
    else if ( strncmp(args,"delay",3) == 0){
        sscanf(args,"%s %d",txt, &triggerDelay);
        if (triggerDelay < 0) triggerDelay = 0;
        printf(" Trigger delay set to %d us. \n",triggerDelay);
        return NO_ERR;
    }
    else if ( strncmp(args,"red",3) == 0){
        sscanf(args,"%s %ld",txt, &redBalance);
        if(PvAttrUint32Set(Camera.Handle, "WhitebalValueRed", redBalance)){
            printf("Couldn't set red balance.\n");
            return -1;
        }
        printf(" Red balance set to %ld%%. \n",redBalance);
        return NO_ERR;
    }
    else if ( strncmp(args,"blue",3) == 0){
        sscanf(args,"%s %ld",txt, &blueBalance);
        if(PvAttrUint32Set(Camera.Handle, "WhitebalValueBlue", blueBalance)){
            printf("Couldn't set blue balance.\n");
            return -1;
        }
        printf(" Blue balance set to %ld%%. \n",blueBalance);
        return NO_ERR;
    }
    /*
    // enable image saving 
    else if ( strncmp(args,"save",3) == 0){
        sscanf(args,"%s %s",txt, savestr);
        printf("* Image saving enabled * \n -> Set the prefix! \n");
        sav = 1;
        return NO_ERR;
    }
    else if ( strncmp(args,"endsave",4) == 0){
        printf("* Image saving disabled * \n");
        sav = 0;
        return NO_ERR;
    }
     */
    // statistics
    else if ( strncmp(args,"stat",3) == 0){
        int* specs = iBuffer.getspecs();
        printf("\n");
        
        PvAttrEnumGet(Camera.Handle,"SensorType",pixelformat,sizeof(pixelformat),NULL);
        sprintf(buffer,"Sensor type: %s\n",pixelformat);
        printf("\t%s",buffer);
        PvAttrEnumGet(Camera.Handle,"WhitebalMode",pixelformat,sizeof(pixelformat),NULL);
        sprintf(buffer,"White Balance: %s\n",pixelformat);
        printf("\t%s",buffer);
        PvAttrUint32Get(Camera.Handle,"WhitebalValueRed",&redBalance);
        PvAttrUint32Get(Camera.Handle,"WhitebalValueBlue",&blueBalance);
        printf("\tRed Balance: %d%%\n",redBalance);
        printf("\tBlue Balance: %d%%\n",blueBalance);
        PvAttrUint32Get(Camera.Handle,"SensorWidth",&pixwidth);
        PvAttrUint32Get(Camera.Handle,"SensorHeight",&pixheight);
        printf("\tSensor dimension: %d x %d pixels \n",pixwidth,pixheight);
        printf("\tExposure time: %d us\n",exptime);
        printf("\tGain value: %d\n",gain);
        printf("\tFrame number: %d\n",numFrames);
        if (trigger == FIXED)   printf("\tFrame rate: %d fps.\n",frameRate);
        if (trigger == SYNCIN)   printf("\tFrame rate: see external source value.\n");
        printf("\tFrame dimension: %d x %d pixels\n",specs[ROWS],specs[COLS]);
        printf("\tHorizontal binning: %d\n",bx);
        printf("\tVertical binning: %d\n",by);
        PvAttrUint32Get(Camera.Handle,"StreamHoldCapacity",&scap);
        printf("\tStream hold capacity: %d\n",scap);
        PvAttrUint32Get(Camera.Handle,"TotalBytesPerFrame",&fsize);
        printf("\tFramesize: %d\n",fsize);
        PvAttrUint32Get(Camera.Handle,"StreamBytesPerSecond",&sbyte);
        printf("\tStream bytes per second: %d\n",sbyte);
        if (trigger == SYNCIN)   printf("\tTrigger: external\n");
        if (trigger == SYNCIN)   printf("\tTrigger delay: %d us\n\n",triggerDelay);
        if (trigger == FIXED)   printf("\tTrigger: internal\n\n");
        return NO_ERR;
    }
    
    save_new_status = UIData.newwindowflag;
    
    if ( strncmp(args,"acq",3) == 0){
        
        // continuous acquisition mode
        if(preview){
            
            time (&rawtime);
            timeinfo = localtime (&rawtime);
            
            if(CameraStartContinuous(&Camera,exptime,frameRate,gain,FREERUN,triggerDelay,bx,by)){
            //if(CameraStart_preview(&Camera,&exptime)){
                PvCommandRun(Camera.Handle,"TimeStampReset");
                PvAttrUint32Get(Camera.Handle,"TimeStampFrequency",&Tfreq);
                for(int i=0; i< numPreviews; i++){
                    // snap now
                    CameraSnapOneFrame(&Camera,iBuffer.data);
                    
                    if(label ){
                        PvCommandRun(Camera.Handle,"TimeStampValueLatch");
                        PvAttrUint32Get(Camera.Handle,"TimeStampValueHi",&T_hi);
                        PvAttrUint32Get(Camera.Handle,"TimeStampValueLo",&T_lo);
                    
                        tempo = (T_hi*4294967296. + T_lo) / Tfreq;
                        float fratec = 1./(tempo - tempo_pr);
                        tempo_pr = tempo;
                    
                        sprintf(labelBuffer,"%2d:%2d:%.4f (Frame %d/%d - %.1f fps - exp. %d us) ",
                                timeinfo->tm_hour,timeinfo->tm_min,timeinfo->tm_sec+tempo, i+1, numPreviews, fratec, exptime);
                    }
                    
                    if (fixBad) clearbad_c(0,(char*)"NoPrint");
                    if(i==0) iBuffer.getmaxx(PRINT_RESULT);
                    display(0,(char*)"GigE");
                    if(label ) labelData(0,labelBuffer);
                    
                    //checkEvents;
                    UIData.newwindowflag = 0;  // if 0 opens the new image in the old window, if 1 it opens it in a new window
                }
                // stop the streaming
                PvCommandRun(Camera.Handle,"AcquisitionStop");
                PvCaptureEnd(Camera.Handle);            
                CameraUnsetup(&Camera, 1);
                
                //have_max = 0;
                //maxx();
                UIData.newwindowflag = save_new_status;
                
                preview = 0;
                return NO_ERR;
                
            } else
                printf("Failed to start continuous streaming\n");
            
            // unsetup the camera
            CameraUnsetup(&Camera, 1);
            
            return -1;
            
            // multiframe acquisition mode
        } else {
            
            // set the camera attributes
            if(CameraStart(&Camera,&exptime,&numFrames,&frameRate,&gain,&trigger,&triggerDelay,&bx,&by)){
                
                // snap now
                CameraSnap(&Camera,exptime,numFrames,frameRate,label,trigger,sav,savestr);
                //checkevents();
                
                // stop the streaming
                CameraStop(&Camera);
                CameraUnsetup(&Camera, numFrames);
                
                if (fixBad) {
                    clearbad_c(0,(char*)"");
                } else {
                    iBuffer.getmaxx(PRINT_RESULT);
                }
                display(0,(char*)"GigE");
                
                if(label == 1){
                    labelData(0,labelBuffer);
                }

               
                UIData.newwindowflag = save_new_status;
                
                // reset the binning settings
                //header[NCHAN] = header[NCHAN] * bx;
                //header[NTRAK] = header[NTRAK] * by;
                
                return NO_ERR;
                
            } else
                printf("Failed to start multiframe streaming\n");
            
            // unsetup the camera
            CameraUnsetup(&Camera, numFrames);
            
            return -1;
        } 
    }
    
    if ( strncmp(args,"sfmemory",3) == 0){
        
        time (&rawtime);
        timeinfo = localtime (&rawtime);
        int sFrames = 1;
        
        //sscanf(args,"%s %d",txt, &sFrames);
        sscanf(args,"%s %d",txt, &sFrames);
        if( sFrames < 1) sFrames = 1;
        iBuffer.extraSize = sFrames;                // extra space will have time stamp
        iBuffer.extra = new float[sFrames];
        iBuffer.values[EXPOSURE] = exptime/1e6;
        
        // put everything in a single image
        // make space for big image
        DATAWORD* buffer = new DATAWORD[iBuffer.rows()*iBuffer.cols()*sFrames];
        if(buffer == 0){
            CameraUnsetup(&Camera, 1);
            return MEM_ERR;
        }
        DATAWORD* next = buffer;
        // continuous acquisition mode
        // use frame rate for internal trigger
        // should work for external trigger as well
        //if(CameraStartContinuous(&Camera,exptime,frameRate,gain,trigger,triggerDelay,bx,by)){
        if(CameraStartContinuous(&Camera,exptime,frameRate,gain,trigger,triggerDelay,bx,by)){
            PvCommandRun(Camera.Handle,"TimeStampReset");
            PvAttrUint32Get(Camera.Handle,"TimeStampFrequency",&Tfreq);
            for(int i=0; i< sFrames; i++){
                // snap now
                CameraSnapOneFrame(&Camera,next);
                next += iBuffer.rows()*iBuffer.cols();
                if(realTimeDisplay) display(0,(char*)"GigE");
                //dquartz(0,0);
                
                PvCommandRun(Camera.Handle,"TimeStampValueLatch");
                PvAttrUint32Get(Camera.Handle,"TimeStampValueHi",&T_hi);
                PvAttrUint32Get(Camera.Handle,"TimeStampValueLo",&T_lo);
                
                tempo = (T_hi*4294967296. + T_lo) / Tfreq;
                //float fratec = 1./(tempo - tempo_pr);
                tempo_pr = tempo;
                /*
                if (trigger == FIXED){
                    //fprintf(timeFile,"%2d:%2d:%.4f\t(Frame %d/%d - %d fps - exp. %d us)\n",
                            //timeinfo->tm_hour,timeinfo->tm_min,timeinfo->tm_sec+tempo, i+1, sFrames, frameRate, exptime);
                } else if (trigger == SYNCIN){
                    //fprintf(timeFile,"%2d:%2d:%.4f\t(Frame %d/%d - %.1f fps - exp. %d us)\n",
                            //timeinfo->tm_hour,timeinfo->tm_min,timeinfo->tm_sec+tempo, i+1, sFrames, fratec, exptime);
                }
                 */
                iBuffer.extra[i] = timeinfo->tm_sec+tempo;
                
                //checkevents();
                
            }
            // stop the streaming
            PvCommandRun(Camera.Handle,"AcquisitionStop");
            PvCaptureEnd(Camera.Handle);
            CameraUnsetup(&Camera, 1);
            
            if(iBuffer.data != NULL){
                delete[] iBuffer.data;
                iBuffer.data = buffer;
                iBuffer.specs[ROWS] *= sFrames;
            }

            
            iBuffer.getmaxx(PRINT_RESULT);
            UIData.newwindowflag = save_new_status;
            
            
            return 0;
            
        } else
            printf("Failed to start continuous streaming\n");
        
        
        
        // unsetup the camera
        CameraUnsetup(&Camera, 1);
        
        return -1;
        
    }

    if ( strncmp(args,"sframes",3) == 0){

        FILE* timeFile = NULL;
        time (&rawtime);
        timeinfo = localtime (&rawtime);
        char timeFileName[256];
        int sFrames = 1;
        
        //sscanf(args,"%s %d",txt, &sFrames);
        sscanf(args,"%s %s %d",txt, savestr, &sFrames);
        if( sFrames < 1) sFrames = 1;
        iBuffer.extraSize = sFrames;                // save exposure times in the extra space
        iBuffer.extra = new float[sFrames];
        iBuffer.extra[0] = exptime/1e6;
        iBuffer.values[EXPOSURE] = exptime/1e6;
        for(int i=1; i< sFrames; i++){
            iBuffer.extra[i] = iBuffer.extra[i-1];
            //printf("%f\n",iBuffer.extra[i]);
        }

        
        strcpy(args, savestr);
        strcpy(timeFileName, savestr);
        strcat(timeFileName, "_times.txt");
        
        timeFile = fopen(fullname(timeFileName,RAW_DATA),"w");

        // continuous acquisition mode
        // use frame rate for internal trigger
        // should work for external trigger as well
        //if(CameraStartContinuous(&Camera,exptime,frameRate,gain,trigger,triggerDelay,bx,by)){
        if(CameraStartContinuous(&Camera,exptime,frameRate,gain,FREERUN,triggerDelay,bx,by)){
            PvCommandRun(Camera.Handle,"TimeStampReset");
            PvAttrUint32Get(Camera.Handle,"TimeStampFrequency",&Tfreq);
            for(int i=0; i< sFrames; i++){
                // snap now
                CameraSnapOneFrame(&Camera,iBuffer.data);
                
                if(realTimeDisplay) display(0,(char*)"GigE");
                //dquartz(0,0);
                if(i == 0)
                    createfile_c(0,args);
                else
                    concatfile_c(0,0);
                
                PvCommandRun(Camera.Handle,"TimeStampValueLatch");
                PvAttrUint32Get(Camera.Handle,"TimeStampValueHi",&T_hi);
                PvAttrUint32Get(Camera.Handle,"TimeStampValueLo",&T_lo);
                
                tempo = (T_hi*4294967296. + T_lo) / Tfreq;
                float fratec = 1./(tempo - tempo_pr);
                tempo_pr = tempo;
                
                if (trigger == FIXED){
                    fprintf(timeFile,"%2d:%2d:%.4f\t(Frame %d/%d - %d fps - exp. %d us)\n",
                            timeinfo->tm_hour,timeinfo->tm_min,timeinfo->tm_sec+tempo, i+1, sFrames, frameRate, exptime);
                } else if (trigger == SYNCIN){
                    fprintf(timeFile,"%2d:%2d:%.4f\t(Frame %d/%d - %.1f fps - exp. %d us)\n",
                            timeinfo->tm_hour,timeinfo->tm_min,timeinfo->tm_sec+tempo, i+1, sFrames, fratec, exptime);
                }
                    
                //checkevents();
                
            }
            // stop the streaming
            PvCommandRun(Camera.Handle,"AcquisitionStop");
            PvCaptureEnd(Camera.Handle);
            CameraUnsetup(&Camera, 1);
            
            iBuffer.getmaxx(PRINT_RESULT);
            UIData.newwindowflag = save_new_status;
            
            closefile_c(0,0);
            fclose(timeFile);
            return 0;
            
        } else
            printf("Failed to start continuous streaming\n");
        
        fclose(timeFile);

        // unsetup the camera
        CameraUnsetup(&Camera, 1);
        
        return -1;

    }
    if ( strncmp(args,"hdr",3) == 0){
        int sFrames = 1;
        int nextExpTime = exptime;
        float multiplier = 2.;
        
        sscanf(args,"%s %s %d %f",txt, savestr, &sFrames,&multiplier);
        printf("%d frames with %f multiplier\n",sFrames,multiplier);
        
        strcpy(args, savestr);
        
        if( sFrames < 2) sFrames = 2;
        iBuffer.extraSize = sFrames;                // save exposure times in the extra space
        iBuffer.extra = new float[sFrames];
        iBuffer.extra[0] = exptime/1e6;
        iBuffer.values[EXPOSURE] = exptime/1e6;
        for(int i=1; i< sFrames; i++){
            iBuffer.extra[i] = iBuffer.extra[i-1]*multiplier;
            //printf("%f\n",iBuffer.extra[i]);
        }
        
        if(CameraStartContinuous(&Camera,exptime,frameRate,gain,trigger,triggerDelay,bx,by)){
            PvCommandRun(Camera.Handle,"TimeStampReset");
            for(int i=0; i< sFrames; i++){
                // snap now
                CameraSnapOneFrame(&Camera,iBuffer.data);
                nextExpTime *= multiplier;
                if(PvAttrUint32Set(Camera.Handle, "ExposureValue", nextExpTime)){
                    printf("Couldn't set exposure.\n");
                }
                if (fixBad) clearbad_c(0,(char*)"NoPrint");
                if(realTimeDisplay) display(0,(char*)"GigE");
                if(i == 0)
                    createfile_c(0,args);
                else
                    concatfile_c(0,0);
                
                //checkevents();
                
            }
            // stop the streaming
            PvCommandRun(Camera.Handle,"AcquisitionStop");
            PvCaptureEnd(Camera.Handle);
            CameraUnsetup(&Camera, 1);
            
            iBuffer.getmaxx(PRINT_RESULT);
            UIData.newwindowflag = save_new_status;
            
            closefile_c(0,0);
            return 0;
            
        } else
            printf("Failed to start continuous streaming\n");
        
        
        
        // unsetup the camera
        CameraUnsetup(&Camera, 1);
        
        return -1;
        
    }
    beep();
    gige(0,(char*) "help");

    return CMND_ERR;
}

#endif
