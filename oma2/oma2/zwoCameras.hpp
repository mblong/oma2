//
//  zwoCameras.hpp
//  oma2cam
//
//  Created by Marshall Long on 3/29/22.
//  Copyright © 2022 Yale University. All rights reserved.
//

#ifndef zwoCameras_hpp
#define zwoCameras_hpp

#define _MAC
#define _LIN

#include <stdio.h>
#include <iostream>
#include "ASICamera2.h"
#include <sys/time.h>
#include <time.h>
#include <unistd.h>
#include "pthread.h"

#include "oma2.h"
#include "UI.h"
#include "ImageBitmap.h"
#import "AppController.h"


int connectCamera();
ASI_ERROR_CODE zwoGetTempInfo();
ASI_ERROR_CODE zwoSetTemp(int);
ASI_ERROR_CODE zwoSetAntiDew(bool);
ASI_ERROR_CODE zwoSetCoolerState(bool);
ASI_ERROR_CODE zwoSetGain();
void zwoDisconnect();


#endif /* zwoCameras_hpp */
