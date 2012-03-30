//
//  UI.h
//  oma2
//
//  Created by Marshall Long on 3/26/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#ifndef oma2_UI_h
#define oma2_UI_h

#include "AppController.h"
extern AppController *appController;

#define send_reply [appController appendCText: reply];
#define display_data [appController showDataWindow:(char*) args];
#define erase_window [appController eraseWindow:(int) n];


#endif
