//
//  macImageSupport.h
//  oma2
//
//  Created by Marshall Long on 4/5/14.
//  Copyright (c) 2014 Yale University. All rights reserved.
//

#ifndef oma2_macImageSupport_h
#define oma2_macImageSupport_h

#include    "oma2.h"
#include    "UI.h"
#include    "image.h"


int read_jpegXXX(char* filename,int thecolor,Image* im);
int saveJpeg(char* filename);
int savePdf(char* filename);


#endif
