//
//  canonCamera.mm
//  oma2cam
//
//  Created by Marshall Long on 7/31/21.
//  Copyright © 2021 Yale University. All rights reserved.
//

#include "canonCamera.h"


bool _isSDKLoaded=false;
bool pictureReceived=false;
int loadResult=true;
int displayResult=true;
EdsCameraRef _camera;
EdsCameraListRef  cameraList = NULL;
EdsUInt32 count = 0;
EdsDeviceInfo deviceInfo;
EdsUInt32 saveTo = kEdsSaveTo_Host;
char filename[CHPERLN];
extern char lastname[];
extern Image iBuffer;
extern int printMax;
extern Variable user_variables[];


/*
 CANON command arguments
    Command to control Canon camera
    Available commands are as follows:
    SHOOt filename -- take a picture and save the result to the specified file
    LOADResult loadResultFlag -- if the flag is nonzero, the file read from the camera is opened (default is true)
    DISPlayResult displayResultFlag -- if the flag is nonzero, the current image is displayed (default is true)
    Notes:
    Only the first four characters of a command are matched in decoding the command.
    If a single argument is given, that is interpreted as the filename for the SHOOT command.
 */

int canon(int n,char* args){
    EdsError error = EDS_ERR_OK;
    int i,nargs;
    char dummy[256];
    
    // check to see if there was more than one argument
    nargs=sscanf(args, "%s %s",dummy,dummy);
    switch(nargs){
        case 2:
            // there was more than one argument, so decode the command
            for( i=0; i<4; i++) args[i] = toupper(args[i]); // only the first four characters are matched
            /*
             LOADRESULT command
             LOADResult loadResultFlag -- if the flag is nonzero, the file read from the camera is opened (default is true)
             */
            if(strncmp(args,"LOAD",4) == 0){
                sscanf(args, "%s %d",dummy,&loadResult);
                if(loadResult)
                    printf("New shots will be saved to file and loaded.\n");
                else
                    printf("New shots will be saved to file but not loaded.\n");
                return NO_ERR;
                /*
                 DISPLAYRESULT command
                 DISPlayResult displayResultFlag -- if the flag is nonzero, the current image is displayed (default is true)
                 */
            } else if(strncmp(args,"DISP",4) == 0){
                sscanf(args, "%s %d",dummy,&displayResult);
                if(displayResult)
                    printf("After shot, image will be displayed.\n");
                else
                    printf("After shot, image will not be displayed.\n");
                return NO_ERR;
            } else if(strncmp(args,"SHOO",4) == 0){
                sscanf(args, "%s %s",dummy,filename);
                break;
            } else {
                beep();
                printf("Unrecognized CANON command.\n");
                return CMND_ERR;
            }
        case 1:
            if(strncmp(args,"OPEN",4) == 0){
                error=setupCamera();
                //error = EdsOpenSession(_camera);
                if(error){
                    beep();
                    printf("Error on setup: %x\n",error);
                    closeCamera();
                }
                return error;
            } else if(strncmp(args,"CLOS",4) == 0){
                return closeCamera();
            } else {
                strcpy(filename, args); // arguments as typed
                break;
            }
    }
    
    if(!_isSDKLoaded)
        error=setupCamera();
    if(error){
        beep();
        printf("Error on setup: %x\n",error);
        closeCamera();
        return error;
    }
    // from OpenSessionCommand ****************
    
    //The communication with the _camera begins
    error = EdsOpenSession(_camera);

    //Preservation ahead is set to PC
    //if(error == EDS_ERR_OK){
        error = EdsSetPropertyData(_camera, kEdsPropID_SaveTo, 0, sizeof(saveTo) , &saveTo);
    printf("Error setProp: %x\n",error);
    //}
    
    if(error == EDS_ERR_OK){
        EdsCapacity capacity = {0x7FFFFFFF, 0x1000, 1};
        error = EdsSetCapacity(_camera, capacity);
    }
    
    //Notification of error
    if(error != EDS_ERR_OK){
        /*
         number = [[NSNumber alloc] initWithInt: error];
         event = [[CameraEvent alloc] init:@"error" withArg: number];
         [_model notifyObservers:event];
         [event release];
         [number release];
         */
        beep();
        printf("error: %x\n",error);
        return error;
    }
    


        
    // from TakePictureCommand ****************

    error = EdsSendCommand( _camera , kEdsCameraCommand_PressShutterButton, kEdsCameraCommand_ShutterButton_Completely);
    EdsSendCommand( _camera , kEdsCameraCommand_PressShutterButton, kEdsCameraCommand_ShutterButton_OFF);
    pictureReceived=false;
    
    //Notification of error
    if(error != EDS_ERR_OK){
        // Retry it at device busy?
        if(error == EDS_ERR_DEVICE_BUSY){
            beep();
            printf("EDS_ERR_DEVICE_BUSY\n");
            closeCamera();
            return error;
        }
        beep();
        printf("Error after shutter press: %x\n",error);
        closeCamera();
        return error;
        
    }
    
    // wait for the image to be saved to a file
    //CFRunLoopRunInMode(kCFRunLoopDefaultMode, 30, false);
    while(!pictureReceived){
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, false);
        [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    }
    error = EdsCloseSession(_camera);
    closeCamera();

    if(loadResult){
        // read in the image
        Image new_im(filename,LONG_NAME);
        if(new_im.err()){
            beep();
            printf("Could not load %s\n",filename);
            return new_im.err();
        }
        iBuffer.free();     // release the old data
        iBuffer = new_im;   // this is the new data
        iBuffer.getmaxx(printMax);
        update_UI();
    }
    // and display
    if(displayResult) display(0,args);
    
    return NO_ERR;
}

static EdsError EDSCALLBACK handleObjectEvent( EdsObjectEvent event,EdsBaseRef object,EdsVoid * context)
{
    EdsError err=EDS_ERR_OK;
    
    switch(event)
    {
        case kEdsObjectEvent_DirItemRequestTransfer:
            err = downloadImage(object);
            break;
        default:
            break;
    }
    
    // Object must be released
    if(object){
        err = EdsRelease(object);
    }
    return err;
}

static EdsError EDSCALLBACK handlePropertyEvent (EdsPropertyEvent event,EdsPropertyID     property,EdsUInt32 inParam, EdsVoid * context)
{
    return EDS_ERR_OK;
}

static EdsError EDSCALLBACK handleStateEvent (EdsStateEvent event,EdsUInt32 parameter,EdsVoid * context)
{
    return EDS_ERR_OK;
}

EdsError downloadImage(EdsDirectoryItemRef directoryItem)
{
    EdsError err = EDS_ERR_OK;
    EdsStreamRef stream = NULL;
    // Get directory item information
    EdsDirectoryItemInfo dirItemInfo;
    err = EdsGetDirectoryItemInfo(directoryItem, & dirItemInfo);

    int i;
    
    // Create file stream for transfer destination
    if(err == EDS_ERR_OK)
    {
        
        // get the extension of the file to be read in
        for(i=(int)strlen(dirItemInfo.szFileName)-1; dirItemInfo.szFileName[i] != '.'; i--);
        strcat(filename,&dirItemInfo.szFileName[i]);    // append the appropriate extension
        strncpy(lastname, filename, CHPERLN);   // remember the name without the path
        err = EdsCreateFileStream(fullname(filename,RAW_DATA),kEdsFileCreateDisposition_CreateAlways,kEdsAccess_ReadWrite, &stream);
        
    }
    // Download image
    if(err == EDS_ERR_OK)
    {
        err = EdsDownload( directoryItem, dirItemInfo.size, stream);
    }
    // Issue notification that download is complete
    if(err == EDS_ERR_OK)
    {
        err = EdsDownloadComplete(directoryItem);
    }
    // Release stream
    if( stream != NULL)
    {
        EdsRelease(stream);
        stream = NULL;
    }
    // return the file name as the first  return value
    user_variables[0].fvalue = user_variables[0].ivalue = 0;
    user_variables[0].is_float = -1;
    strcpy(user_variables[0].estring,lastname);

    pictureReceived=true;
    return err;
}

EdsError closeCamera(){
    EdsError error=EDS_ERR_OK;
    
    // Release _camera
    if(_camera != NULL){
        EdsRelease(_camera);
    }
    
    // Terminate SDK


    EdsTerminateSDK();
    _isSDKLoaded=false;
    return error;
}

EdsError setupCamera(){
    EdsError error = EDS_ERR_OK;
    // Initialization of SDK
    error = EdsInitializeSDK();
    
    //Acquisition of _camera list
    if(error == EDS_ERR_OK){
        _isSDKLoaded = YES;
        error = EdsGetCameraList(&cameraList);
    }
    
    //Acquisition of number of Cameras
    if(error == EDS_ERR_OK){
        error = EdsGetChildCount(cameraList, &count);
        if(count == 0){
            error = EDS_ERR_DEVICE_NOT_FOUND;
            beep();
            printf("EDS_ERR_DEVICE_NOT_FOUND\n");
            return closeCamera();
        }
    }
    
    //Acquisition of _camera at the head of the list
    if(error == EDS_ERR_OK){
        error = EdsGetChildAtIndex(cameraList, 0, &_camera);
    }
    
    //Acquisition of _camera information
    if(error == EDS_ERR_OK){
        error = EdsGetDeviceInfo(_camera, &deviceInfo);
        if(error == EDS_ERR_OK && _camera == NULL){
            error = EDS_ERR_DEVICE_NOT_FOUND;
            beep();
            printf("EDS_ERR_DEVICE_NOT_FOUND\n");
            return closeCamera();
        }
    }
    
    if(error != EDS_ERR_OK){
        //[self alert];
        EdsRelease(cameraList);
        EdsRelease(_camera);
        return error;
    }
    
    printf("%s connected on port %s\n",deviceInfo.szDeviceDescription,deviceInfo.szPortName);
    
    //Release _camera list
    EdsRelease(cameraList);
    
    // Set event handler
    if(error == EDS_ERR_OK)
        error = EdsSetObjectEventHandler(_camera, kEdsObjectEvent_All,handleObjectEvent, NULL);
    if(error == EDS_ERR_OK)
        error = EdsSetPropertyEventHandler(_camera, kEdsPropertyEvent_All,handlePropertyEvent, NULL);
    if(error == EDS_ERR_OK)
        error = EdsSetCameraStateEventHandler(_camera, kEdsStateEvent_All,handleStateEvent, NULL);

    
    
 
    return error;
}

