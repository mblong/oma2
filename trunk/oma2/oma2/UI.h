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

extern AppController *appController;
extern StatusController *statusController;

#define printf1(s) {sprintf(reply,s); send_reply}
#define printf2(s,a) {sprintf(reply,s,a); send_reply}
#define printf3(s,a,b) {sprintf(reply,s,a,b); send_reply}
#define printf4(s,a,b,c) {sprintf(reply,s,a,b,c); send_reply}
#define printf5(s,a,b,c,d) {sprintf(reply,s,a,b,c,d); send_reply}
#define printf6(s,a,b,c,d,e) {sprintf(reply,s,a,b,c,d,e); send_reply}


#define send_reply [appController appendCText: reply];
#define display_data [appController showDataWindow:(char*) args];
#define erase_window [appController eraseWindow:(int) n];


void dropped_file(char*,char*);
void update_UI();

#endif
