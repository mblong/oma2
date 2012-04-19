//
//  UI.mm
//  oma2
//
//  Created by Marshall Long on 4/17/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#include <iostream>
#include "UI.h"
extern char    reply[1024];   // buffer for sending messages to be typed out by the user interface
extern Image   iBuffer;       // the image buffer
extern ImageBitmap iBitmap;   // the bitmap buffer
extern oma2UIData UIData; 


// update the User Interface
// 
// This is a way to update user interface values after a command

void update_UI(){
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

    free(specs);
    free(values);
    
    
}

void dropped_file(char* extension, char* name){
    
    printf2("File ext is: %s\n",extension);
    printf2("File name is: %s\n",name);
    if(strcmp(extension, "dat")==0){
        getfile_c(0,name);
        display(0,(char*)"Data");
        [appController appendText: @"OMA2>"];
    }
}



