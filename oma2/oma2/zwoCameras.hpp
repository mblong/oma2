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
#include "opencv2/highgui/highgui_c.h"
#include <opencv2/imgproc.hpp>
#include <opencv2/core/types_c.h>
#include "ASICamera2.h"
#include <sys/time.h>
#include <time.h>
#include <unistd.h>
#include "pthread.h"

#include "oma2.h"
#include "UI.h"

int connectCamera();

// routines from SDK
static unsigned long GetTickCount();


#endif /* zwoCameras_hpp */
