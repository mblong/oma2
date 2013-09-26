//
//  UI.h
//  oma2
//
//  Created by Marshall Long on 3/26/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#ifndef oma2_UI_h
#define oma2_UI_h

#include "StatusController.h"
#include "AppController.h"
#include "ImageBitmap.h"
#include "Image.h"
#include "commands_1.h"
#include "comdec.h"

// In this exceptional case, define external variable in this header file
extern AppController *appController;
extern StatusController *statusController;

enum {CROSS,RECT,CALCRECT,RULER,LINEPLOT};


#define printf omaprintf

#define display_data [appController showDataWindow:(char*) args];
#define erase_window [appController eraseWindow:(int) n];


void dropped_file(char*,char*);
void update_UI();

int omaprintf(const char* format, ...);

#endif
