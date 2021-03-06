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
extern int printMax;


// update the User Interface
// 
// This is a way to update user interface values after a command

void update_UI(){
        
    if([NSThread isMainThread]) \
        [appController updateStatusWindow]; \
    else \
        dispatch_sync(dispatch_get_main_queue(),^{[appController updateStatusWindow];});

    if([NSThread isMainThread]) \
        [appController updateVariablesWindow]; \
    else \
        dispatch_sync(dispatch_get_main_queue(),^{[appController updateVariablesWindow];});

    [[appController preferenceController] fillInUIData];
    

}

BOOL dropped_file(char* extension, char* name){
    extern int windowNameMemory;
    extern char windowName[];
    extern char binaryExtension[];
    //char upperCaseBinExt[256];
    extern FileDecoderExtensions fileDecoderExtensions[];
    
    //printf("File ext is: %s\n",extension);
    
    if( strlen(extension) == 0){
        char nameCopy[NEW_PREFIX_CHPERLN];
        strlcpy(nameCopy,name,NEW_PREFIX_CHPERLN);
        // assume this is a directory and reset the preferences accordingly.
        strlcat(nameCopy,"/",NEW_PREFIX_CHPERLN);
        printf("File prefixes set to: %s\n",nameCopy);
        strlcpy(UIData.saveprefixbuf,nameCopy,NEW_PREFIX_CHPERLN);
        strlcpy(UIData.getprefixbuf,nameCopy,NEW_PREFIX_CHPERLN);
        strlcpy(UIData.graphicsprefixbuf,nameCopy,NEW_PREFIX_CHPERLN);
        strlcat(nameCopy,"macros/",NEW_PREFIX_CHPERLN);
        strlcpy(UIData.macroprefixbuf,nameCopy,NEW_PREFIX_CHPERLN);
        //printf("OMA2>",name); -- this causes trouble here -- thread related I assume
        [appController appendText: @"OMA2>"];
        return NO;
    }
    printf("File name is: %s\n",name);
    int i;
    for(i=0; i<strlen(extension); i++){
        extension[i] = toupper(extension[i]);
        //upperCaseBinExt[i] = toupper(binaryExtension[i]);
    }
    //upperCaseBinExt[i]=0;
    
    for(i=0; fileDecoderExtensions[i].ext[0]; i++ ){
        int extLength = (int)strlen(fileDecoderExtensions[i].ext) - 1 ;
        if(strncmp(extension,&fileDecoderExtensions[i].ext[1],extLength) == 0){
            Image new_im(name,LONG_NAME);
            if(new_im.err()){
                beep();
                printf("Could not load %s\n",name);
                [appController appendText: @"OMA2>"];
                return NO;
            }
            iBuffer.free();     // release the old data
            iBuffer = new_im;   // this is the new data
            iBuffer.getmaxx(printMax);
            update_UI();
            
            display(0,(char*)"");
            [appController appendText: @"OMA2>"];
            //[[appController theWindow] makeKeyAndOrderFront:NULL];
            [[NSApplication sharedApplication] activateIgnoringOtherApps : YES];    // make oma active
            return YES;
        }
    }

    /*
    if(strcmp(extension, "DAT")==0 || strcmp(extension, "NEF")==0 || strcmp(extension, "JPG")==0
       || strcmp(extension, "TIF")==0 || strcmp(extension, "TIFF")==0 || strcmp(extension, "HDR")==0
       || strcmp(extension, "O2D")==0 || strcmp(extension, "PNG")==0 || strcmp(extension, "HOBJ")==0
       || strcmp(extension, upperCaseBinExt)==0 || strcmp(extension, "CR2")==0){
    */
    
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
    if(strcmp(extension, "PA1")==0){
        printf("Loading Custom Palette...\n");
        int err = getpalettefile(name);
        update_UI();
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
    if ([NSThread isMainThread]) {
        [appController appendCText: reply];
    } else {
        dispatch_sync(dispatch_get_main_queue(),^{[appController appendCText: reply];});
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
    if ([NSThread isMainThread]) {
        [appController appendCText: reply];
    } else {
        dispatch_sync(dispatch_get_main_queue(),^{[appController appendCText: reply];});
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
    if ([NSThread isMainThread]) {
        [appController appendCText: reply];
    } else {
        dispatch_sync(dispatch_get_main_queue(),^{[appController appendCText: reply];});
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
    if ([NSThread isMainThread]) {
        [appController appendCText: reply];
    } else {
        dispatch_sync(dispatch_get_main_queue(),^{[appController appendCText: reply];});
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

