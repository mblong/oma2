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

BOOL dropped_file(char* extension, char* name){
    extern int windowNameMemory;
    extern char windowName[];
    
    //printf("File ext is: %s\n",extension);
    printf("File name is: %s\n",name);
    for(int i=0; i<strlen(extension); i++)
        extension[i] = toupper(extension[i]);
    if(strcmp(extension, "DAT")==0 || strcmp(extension, "NEF")==0 || strcmp(extension, "JPG")==0
       || strcmp(extension, "TIF")==0 || strcmp(extension, "TIFF")==0 || strcmp(extension, "HDR")==0
       || strcmp(extension, "O2D")==0){
        Image new_im(name,LONG_NAME);
        if(new_im.err()){
            beep();
            printf("Could not load %s\n",name);
            [appController appendText: @"OMA2>"];
            return NO;
        }
        iBuffer.free();     // release the old data
        iBuffer = new_im;   // this is the new data
        iBuffer.getmaxx(PRINT_RESULT);
        update_UI();

        display(0,(char*)"");
        [appController appendText: @"OMA2>"];
        //[[appController theWindow] makeKeyAndOrderFront:NULL];
        [[NSApplication sharedApplication] activateIgnoringOtherApps : YES];    // make oma active
        return YES;
    }
    if(strcmp(extension, "MAC")==0 || strcmp(extension, "O2M")==0){
        extern char	macbuf[];
        int fd,nread,i;
        fd = open(name,READMODE);
        if(fd == -1) {
            beep();
            printf("Macro File '%s' Not Found.\n",name);
            return NO;
        }
        for(i=0; i<MBUFLEN; i++) *(macbuf+i) = 0;	// clear the buffer
        nread = (int)read(fd,macbuf,MBUFLEN);		/* read the largest buffer  */
        printf("%d Bytes Read.\n",nread);
        
        
        /* the format of macro files has changed -- now they are formatted text files */
        /* previously, they were constant length files containing C strings */
        /* this code should read both formats */
        
        for(i=0; i<nread ; i++) {
            if( *(macbuf+i) == 0x0D || *(macbuf+i) == 0x0A)
                *(macbuf+i) = 0x00;	/* change CR or LF to null */
        }
        *(macbuf+nread) = 0;				/* one extra to signify end of buffer */
        *(macbuf+nread+1) = 0;
        
        close(fd);
        clear_buffer_to_end(macbuf);		/* insert trailing zeros after the macro */
        [appController appendText: @"OMA2>"];
        [[NSApplication sharedApplication] activateIgnoringOtherApps : YES];    // make oma active
        return YES;
    }
    if(strcmp(extension, "O2S")==0){
        printf("Loading Settings...\n");
        int err = loadprefs(name);
        [appController appendText: @"OMA2>"];
        [[NSApplication sharedApplication] activateIgnoringOtherApps : YES];    // make oma active
        if (err == NO_ERR) return YES;
    }
    
    return NO;
}

// these C++ functions are called by C functions

int cprintf(const char* format, ...)
{
    
    va_list args;
    va_start(args,format);
    extern unsigned char printall,no_print;
    
    if(!printall) return NO_ERR;
	if(no_print) return NO_ERR;
    
    
    int return_status = NO_ERR;
    
    return_status = vsprintf(reply,format, args);
    //[appController appendCText: reply];
    dispatch_queue_t theQueue = dispatch_get_current_queue();
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    if (theQueue == mainQueue) {
        [appController appendCText: reply];
    } else {
        dispatch_sync(mainQueue,^{[appController appendCText: reply];});
    }
    
    va_end(args);
    return return_status;
}

void cbeep(){
    beep();
}

int cpprintf(const char* format, ...)		/* priority printing! */
{
    va_list args;
    va_start(args,format);
    extern unsigned char no_print;
    
    //if(!printall) return NO_ERR;
	if(no_print) return NO_ERR;
    
    
    int return_status = NO_ERR;
    
    return_status = vsprintf(reply,format, args);
    //[appController appendCText: reply];
    dispatch_queue_t theQueue = dispatch_get_current_queue();
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    if (theQueue == mainQueue) {
        [appController appendCText: reply];
    } else {
        dispatch_sync(mainQueue,^{[appController appendCText: reply];});
    }
    
    va_end(args);
    return return_status;
	
}


// end of UI functions to be called by C functions


int omaprintf(const char* format, ...)
{
    
    va_list args;
    va_start(args,format);
    extern unsigned char printall,no_print;
    
    if(!printall) return NO_ERR;
	if(no_print) return NO_ERR;

    
    int return_status = NO_ERR;
    
    return_status = vsprintf(reply,format, args);
    //[appController appendCText: reply];
    dispatch_queue_t theQueue = dispatch_get_current_queue();
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    if (theQueue == mainQueue) {
        [appController appendCText: reply];
    } else {
        dispatch_sync(mainQueue,^{[appController appendCText: reply];});
    }
    
    va_end(args);
    return return_status;
}

int pprintf(const char* format, ...)		/* priority printing! */
{
    va_list args;
    va_start(args,format);
    extern unsigned char no_print;
    
    //if(!printall) return NO_ERR;
	if(no_print) return NO_ERR;
    
    
    int return_status = NO_ERR;
    
    return_status = vsprintf(reply,format, args);
    //[appController appendCText: reply];
    dispatch_queue_t theQueue = dispatch_get_current_queue();
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    if (theQueue == mainQueue) {
        [appController appendCText: reply];
    } else {
        dispatch_sync(mainQueue,^{[appController appendCText: reply];});
    }
    
    va_end(args);
    return return_status;
	
}


void beep(){
    extern int stop_on_error,macflag,exflag,isErrorText;
    
    isErrorText = 1;
    NSBeep();
    
    if(stop_on_error && (macflag || exflag))
        //stopMacroNow = 1;
        stopmacro();

}

void alertSound(char* sayString){

    NSSpeechSynthesizer* talker = [[NSSpeechSynthesizer alloc] init];
    [talker startSpeakingString: [NSString stringWithCString:sayString encoding:NSASCIIStringEncoding]];
    
    //NSBeep();
    
    
}
