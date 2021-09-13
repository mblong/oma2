//
//  canonCamera.h
//  oma2cam
//
//  Created by Marshall Long on 7/31/21.
//  Copyright © 2021 Yale University. All rights reserved.
//

#ifndef canonCamera_h
#define canonCamera_h

#define __MACOS__

#import <Foundation/Foundation.h>
#import "EDSDK.h"

//#import "cameraModel.h"
//#import "cameraEventListener.h"
//#import "PressingShutterButtomCommand.h"

#include "oma2.h"
#include "UI.h"
#include "stdio.h"

int canon( int,char*);
EdsError downloadImage(EdsDirectoryItemRef directoryItem);
static EdsError EDSCALLBACK handleStateEvent (EdsStateEvent event,EdsUInt32 parameter,EdsVoid * context);
static EdsError EDSCALLBACK handleObjectEvent( EdsObjectEvent event,EdsBaseRef object,EdsVoid * context);
static EdsError EDSCALLBACK handlePropertyEvent (EdsPropertyEvent event,EdsPropertyID property,EdsUInt32 inParam, EdsVoid * context);
EdsError setupCamera();
EdsError closeCamera();
EdsError  takePicture();
EdsError  KeepOpen();

#endif /* canonCamera_h */
