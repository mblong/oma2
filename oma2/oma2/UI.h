//
//  UI.h
//  oma2
//
//  Created by Marshall Long on 3/26/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#ifndef oma2_UI_h
#define oma2_UI_h

#include "ImageBitmap.h"
#include "Image.h"
#include "commands_1.h"
#include "comdec.h"


//#define MacOSX_UI
//#define Qt_UI

#ifdef MacOSX_UI

#include "StatusController.h"
#include "AppController.h"

// In this exceptional case, define external variable in this header file
extern AppController *appController;
extern StatusController *statusController;

enum {CROSS,RECT,CALCRECT,RULER,LINEPLOT};


#define printf omaprintf
/*
 #define display_data [appController showDataWindow:(char*) args];
 #define erase_window [appController eraseWindow:(int) n];
 #define label_data [appController labelDataWindow:(char*) args];
 #define label_data_minMax [appController labelMinMax];
 */

// try this so that the command thread doesn't mess with things that need to be in the main thread

#define display_data if(dispatch_get_main_queue() == dispatch_get_current_queue()) \
[appController showDataWindow:(char*) args]; \
else \
dispatch_sync(dispatch_get_main_queue(),^{[appController showDataWindow:(char*) args];});


#define erase_window if(dispatch_get_main_queue() == dispatch_get_current_queue()) \
[appController eraseWindow:(int) n]; \
else \
dispatch_sync(dispatch_get_main_queue(),^{[appController eraseWindow:(int) n];});

#define label_data if(dispatch_get_main_queue() == dispatch_get_current_queue()) \
[appController labelDataWindow:(char*) args]; \
else \
dispatch_sync(dispatch_get_main_queue(),^{[appController labelDataWindow:(char*) args];});

#define label_data_minMax if(dispatch_get_main_queue() == dispatch_get_current_queue()) \
[appController labelMinMax]; \
else \
dispatch_sync(dispatch_get_main_queue(),^{[appController labelMinMax];});



BOOL dropped_file(char*,char*);
void update_UI();
void alertSound(char*);

int omaprintf(const char* format, ...);
int pprintf(const char* format, ...);

#endif

#ifdef Qt_UI

#define display_data ;
#define erase_window ;
#define label_data ;
#define label_data_minMax ;

#define pprintf printf
#define nil 0

typedef struct{
    int red;
    int green;
    int blue;
} RGBColor;

typedef struct{
    int h;
    int v;
} Point;

typedef char* Ptr;

typedef char BOOL;
#define NO 0
#define YES 1


void alertSound(char*);
void beep();

#endif
#endif
