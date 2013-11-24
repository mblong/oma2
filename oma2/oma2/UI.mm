//
//  UI.mm
//  oma2
//
//  Created by Marshall Long on 4/17/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#include <iostream>
#include <stdarg.h>
#include "UI.h"
#include "PreferenceController.h"


extern char    reply[1024];   // buffer for sending messages to be typed out by the user interface
extern Image   iBuffer;       // the image buffer
extern ImageBitmap iBitmap;   // the bitmap buffer
extern oma2UIData UIData; 


// update the User Interface
// 
// This is a way to update user interface values after a command

void update_UI(){
    [[appController preferenceController] fillInUIData];
    
    /*
     
     */
    int* specs = iBuffer.getspecs();
    DATAWORD* values= iBuffer.getvalues();
    
    UIData.max = values[MAX];
    UIData.min = values[MIN];
    UIData.iscolor = specs[IS_COLOR];
    UIData.rows = specs[ROWS];
    UIData.cols = specs[COLS];
    UIData.dx = specs[DX];
    UIData.dy = specs[DY];
    UIData.x0 = specs[X0];
    UIData.y0 = specs[Y0];
    
    [statusController labelColorMinMax]; 
    
    if(UIData.autoscale)
        [[statusController scaleState] setState:NSOnState];
    else
        [[statusController scaleState] setState:NSOffState];

    if(UIData.autoupdate)
        [[statusController updateState] setState:NSOnState];
    else
        [[statusController updateState] setState:NSOffState];

    static int current_pal = -1;
    if (current_pal != UIData.thepalette) {
        [statusController updatePaletteBox];
        current_pal = UIData.thepalette;
    }
    
    free(specs);
    free(values);
    
    
}

void dropped_file(char* extension, char* name){
    
    printf("File ext is: %s\n",extension);
    printf("File name is: %s\n",name);
    if(strcmp(extension, "dat")==0 || strcmp(extension, "nef")==0 || strcmp(extension, "jpg")==0){
        Image new_im(name,LONG_NAME);
        if(new_im.err()){
            beep();
            printf("Could not load %s\n",name);
            [appController appendText: @"OMA2>"];
            return;
        }
        iBuffer.free();     // release the old data
        iBuffer = new_im;   // this is the new data
        iBuffer.getmaxx();
        update_UI();

        display(0,(char*)"Data");
        [appController appendText: @"OMA2>"];
    }
}


int omaprintf(const char* format, ...)
{
    
    va_list args;
    va_start(args,format);
    extern unsigned char printall,no_print;
    
    if(!printall) return 0;
	if(no_print) return 0;

    
    int return_status = 0;
    
    return_status = vsprintf(reply,format, args);
    //[appController appendCText: reply];
    dispatch_sync(dispatch_get_main_queue(),^{[appController appendCText: reply];});
    
    va_end(args);
    return return_status;
}

void beep(){
    NSBeep();
}

