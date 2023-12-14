//
//  ZwoOptions.m
//  oma2cam
//
//  Created by Marshall Long on 4/1/22.
//  Copyright © 2022 Yale University. All rights reserved.
//

#import "ZwoOptions.h"


extern bool connected;
extern long sensorTemp;
extern long setTemp;
extern long coolerPercent;
extern int bin;
extern int exp_ms;
extern int gain;
extern bool coolerEnabled;
extern bool antiDewEnabled;
extern bool autoDisplayEnabled;
extern bool clearBadEnabled;
extern int stopExposure;
extern long wbB,wbR;
extern ASI_CAMERA_INFO ASICameraInfo;
extern int maxGain;
extern int iSelectedID;

// For EAF Focuser
extern bool focuserConnected;
extern int currentPos;
extern int maxPos;
extern int steps;
extern float fTemp;

@interface ZwoOptions ()

@end



@implementation ZwoOptions

@synthesize temperatureSetPoint;
@synthesize changeSetControl;
@synthesize changeGainControl;
@synthesize enableCooler;
@synthesize enableAntiDew;
@synthesize temperatureStatus;
@synthesize coolerPercentValue;
@synthesize exposureValue;
@synthesize gainValue;
@synthesize timerText;
@synthesize enableAutoDisplay;
@synthesize enableClearBad;
@synthesize balanceValues;


@synthesize focuserCurrentPosition;
@synthesize focuserTemperature;
@synthesize focuserMaxPosition;
@synthesize focuserGotoPosition;
@synthesize focuserStepSize;
@synthesize rightButton;
@synthesize leftButton;
@synthesize modifyMaxPosButton;
@synthesize modifyGotoButton;
@synthesize modifyStepSizeButton;
@synthesize modifyCurrentPositionButton;

@synthesize countdownFWHM;

- (void)windowDidLoad {
    [super windowDidLoad];
    modifyingMaxPos=false;
    modifyingGoto=false;
    modifyingStepSize=false;
    modifyingCurrentPosition=false;
    zwoGetTempInfo();
    [self updateZwoWindow];
    // update temperature every 5 seconds
    myTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                     target:self
                                   selector:@selector(updateCoolingInfo)
                                   userInfo:nil
                                    repeats:YES];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
- (void) windowWillClose:(NSNotification *) notification
{
    zwoDisconnect();
    //[myTimer invalidate];
    
}

-(BOOL) acceptsFirstResponder{
    return YES;
}

- (IBAction)changeSetPoint:(id)sender {
    setTemp = [changeSetControl intValue];
    [temperatureSetPoint setStringValue:[NSString stringWithFormat:@"%ld",setTemp]];
    if(coolerEnabled) zwoSetTemp(setTemp);
}
- (IBAction)changeGain:(id)sender {
    gain = [changeGainControl intValue];
    if(gain > maxGain){
        [changeGainControl setIntValue:maxGain];
        gain = (int)maxGain;
    }

    zwoSetGain();
    [self updateZwoWindow];
}
- (IBAction)coolerStateChanged:(id)sender {
    coolerEnabled=[enableCooler state];
    zwoSetCoolerState(coolerEnabled);
}
- (IBAction)antiDewStateChanged:(id)sender {
    antiDewEnabled = [enableAntiDew state];
    zwoSetAntiDew(antiDewEnabled);
}
- (IBAction)autoDisplayChanged:(id)sender {
    autoDisplayEnabled = [enableAutoDisplay state];
}
- (IBAction)clearBadChanged:(id)sender {
    clearBadEnabled = [enableClearBad state];
}

/* ----------- FOCUSER ---------------- */

- (IBAction)moveRight:(id)sender {
    focuserMoveSteps(steps);
    [self updateZwoWindow];
}
- (IBAction)moveLeft:(id)sender {
    focuserMoveSteps(-steps);
    [self updateZwoWindow];
}
- (IBAction)stepSizeChange:(id)sender {
    [focuserStepSize setEditable:false];
    [modifyStepSizeButton setTitle:@"Modify"];
    steps = [focuserStepSize intValue];
    
    [self updateZwoWindow];
    modifyingStepSize=false;
}

- (IBAction)gotoPosition:(id)sender {
    [focuserGotoPosition setEditable:false];
    [modifyGotoButton setTitle:@"Modify"];
    int target = [focuserGotoPosition intValue];
    //[self focuserGoto:target];
    //focuserGoto(target);
    
    EAF_ERROR_CODE err;
    if(target < 0 || target > maxPos){
        beep();
    }
    err = EAFMove(iSelectedID, target);
    bool isMoving = false;
    while(1)
    {
        bool pbHandControl;
        err = EAFIsMoving(iSelectedID, &isMoving, &pbHandControl);
        if(err != EAF_SUCCESS || !isMoving)
            break;
        //[NSThread sleepForTimeInterval:0.7f];
        usleep(700000);
        EAFGetPosition(iSelectedID, &currentPos);
        [focuserCurrentPosition setStringValue:[NSString stringWithFormat:@"%d",currentPos]];
        [focuserCurrentPosition setNeedsDisplay];
        //zwoUpdate
    }
    EAFGetPosition(iSelectedID, &currentPos);

    
    [self updateZwoWindow];
    modifyingGoto=false;
}
- (IBAction)resetCurrentPosition:(id)sender {
    [focuserCurrentPosition setEditable:false];
    [modifyCurrentPositionButton setTitle:@"Modify"];
    int newPos = [focuserCurrentPosition intValue];
    focuserResetPosition(newPos);
    modifyingCurrentPosition=false;
}

- (IBAction)resetMaxPosition:(id)sender {
    [focuserMaxPosition setEditable:false];
    [modifyMaxPosButton setTitle:@"Modify"];
    int newMax = [focuserMaxPosition intValue];
    focuserSetMaxPosition(newMax);
    modifyingMaxPos=false;
}
- (IBAction)modifyMaxPos:(id)sender {
    if(!modifyingMaxPos){
        modifyingMaxPos=true;
        [focuserMaxPosition setEditable:true];
        [modifyMaxPosButton setTitle:@"Reset"];
    } else {
        int target = [focuserMaxPosition intValue];
        focuserSetMaxPosition(target);
        [focuserMaxPosition setEnabled:false];
        [focuserMaxPosition setEditable:false];
        [modifyMaxPosButton setTitle:@"Modify"];
        modifyingMaxPos=false;
        [focuserMaxPosition setEnabled:true];
    }
}
- (IBAction)modifyGoto:(id)sender {
    if(!modifyingGoto){
        modifyingGoto=true;
        [focuserGotoPosition setEditable:true];
        [modifyGotoButton setTitle:@"Go"];
    } else {
        int target = [focuserGotoPosition intValue];
        //[self focuserGoto:target];
        //focuserGoto(target);
        
        EAF_ERROR_CODE err;
        if(target < 0 || target > maxPos){
            beep();
        }
        err = EAFMove(iSelectedID, target);
        bool isMoving = false;
        while(1)
        {
            bool pbHandControl;
            err = EAFIsMoving(iSelectedID, &isMoving, &pbHandControl);
            if(err != EAF_SUCCESS || !isMoving)
                break;
            //[NSThread sleepForTimeInterval:0.7f];
            usleep(700000);
            EAFGetPosition(iSelectedID, &currentPos);
            [focuserCurrentPosition setStringValue:[NSString stringWithFormat:@"%d",currentPos]];
            [focuserCurrentPosition setNeedsDisplay];
        }
        EAFGetPosition(iSelectedID, &currentPos);

        [focuserGotoPosition setEnabled:false];
        [focuserGotoPosition setEditable:false];
        [modifyGotoButton setTitle:@"Modify"];
        [self updateZwoWindow];
        modifyingGoto=false;
        [focuserGotoPosition setEnabled:true];
    }
}
- (IBAction)modifyStepSize:(id)sender {
    if(!modifyingStepSize){
        modifyingStepSize=true;
        [focuserStepSize setEditable:true];
        [modifyStepSizeButton setTitle:@"Reset"];
    } else {
        steps = [focuserStepSize intValue];
        [focuserStepSize setEnabled:false];
        [focuserStepSize setEditable:false];
        [modifyStepSizeButton setTitle:@"Modify"];
        [self updateZwoWindow];
        modifyingStepSize=false;
        [focuserStepSize setEnabled:true];
    }
}
- (IBAction)modifyCurrentPosition:(id)sender {
    if(!modifyingCurrentPosition){
        modifyingCurrentPosition=true;
        [focuserCurrentPosition setEditable:true];
        [modifyCurrentPositionButton setTitle:@"Reset"];
    } else {
        currentPos = [focuserCurrentPosition intValue];
        [focuserCurrentPosition setEnabled:false];
        [focuserCurrentPosition setEditable:false];
        [modifyCurrentPositionButton setTitle:@"Modify"];
        [self updateZwoWindow];
        modifyingCurrentPosition=false;
        [focuserCurrentPosition setEnabled:true];
    }

}

- (void)updateZwoWindow{
    static bool first=true;
    if(connected){
        if( ASICameraInfo.IsCoolerCam){
            [temperatureSetPoint setStringValue:[NSString stringWithFormat:@"%ld",setTemp]];
            [changeSetControl setEnabled:true];
            [changeSetControl setIntegerValue:setTemp];
            [enableCooler setEnabled:true];
            [enableCooler setState:coolerEnabled];
            [enableAntiDew setState:antiDewEnabled];
            [coolerPercentValue setStringValue:[NSString stringWithFormat:@"%ld",coolerPercent]];


        } else{
            [temperatureSetPoint setStringValue:@"-"];
            [changeSetControl setEnabled:false];
            [enableCooler setEnabled:false];
            [enableAntiDew setEnabled:false];
            [coolerPercentValue setStringValue:@"-"];

        }
        [changeGainControl setEnabled:true];
        [gainValue setStringValue:[NSString stringWithFormat:@"%d",gain]];
        [exposureValue setStringValue:[NSString stringWithFormat:@"%g",exp_ms/1000.]];
        [temperatureStatus setStringValue:[NSString stringWithFormat:@"%.1f",sensorTemp/10.]];
        [enableClearBad setEnabled:true];
        [enableClearBad setState:clearBadEnabled];
        [enableAutoDisplay setEnabled:true];
        [enableAutoDisplay setState:autoDisplayEnabled];
        if( ASICameraInfo.IsColorCam){
            [balanceValues setStringValue:[NSString stringWithFormat:@"%ld/%ld",wbR,wbB]];
        } else {
            [balanceValues setStringValue:@"-"];
        }
    } else {
        [temperatureSetPoint setStringValue:@"-"];
        [changeSetControl setEnabled:false];
        [changeGainControl setEnabled:false];
        [enableCooler setEnabled:false];
        [enableAntiDew setEnabled:false];
        [gainValue setStringValue:@"-"];
        [exposureValue setStringValue:@"-"];
        [coolerPercentValue setStringValue:@"-"];
        [temperatureStatus setStringValue:@"-"];
        [enableClearBad setEnabled:false];
        [enableAutoDisplay setEnabled:false];
        [balanceValues setStringValue:@"-"];
    }
    if(!focuserConnected){
        [focuserCurrentPosition setStringValue:@"-"];
        [focuserMaxPosition setStringValue:@"-"];
        [focuserTemperature setStringValue:@"-"];
        [focuserGotoPosition setStringValue:@"-"];
        [focuserStepSize setStringValue:@"-"];
        [rightButton setEnabled:false];
        [leftButton setEnabled:false];
        
    } else {
        [focuserCurrentPosition setStringValue:[NSString stringWithFormat:@"%d",currentPos]];
        [focuserMaxPosition setStringValue:[NSString stringWithFormat:@"%d",maxPos]];
        [focuserTemperature setStringValue:[NSString stringWithFormat:@"%g",fTemp]];
        if(first){
            [focuserGotoPosition setStringValue:[NSString stringWithFormat:@"%d",currentPos]];
            first=false;
        }
        [focuserStepSize setStringValue:[NSString stringWithFormat:@"%d",steps]];
        [rightButton setEnabled:true];
        [leftButton setEnabled:true];
    }
    
}
- (void)updateCoolingInfo{
    if(connected){
        zwoGetTempInfo();
        [temperatureStatus setStringValue:[NSString stringWithFormat:@"%g",sensorTemp/10.]];
    }
    if(focuserConnected){
        EAFGetTemp(iSelectedID, &fTemp);
        [focuserTemperature setStringValue:[NSString stringWithFormat:@"%g",fTemp]];
    }
    //[self updateZwoWindow];
}

- (void)updateTimer:(int)secondsRemaining{
    if(secondsRemaining>=0){
        [countdownFWHM setStringValue:@"Countdown"];
        [timerText setStringValue:[NSString stringWithFormat:@"%d",secondsRemaining]];
    }else
        [timerText setStringValue:@"-"];
}

- (void)updateFwhm:(float)fwhm{
    extern Variable user_variables[];
    
    if(fwhm<0.0){
        [countdownFWHM setStringValue:@"Countdown"];
        [timerText setStringValue:@"-"];
    } else {
        [countdownFWHM setStringValue:@"FWHM\t\tDeviation"];
        [timerText setStringValue:[NSString stringWithFormat:@"%.2f\t\t\t%.2f",fwhm,user_variables[1].fvalue]];
    }
}

- (void)closeWindow{
    [[self window] close];
}

- (void)keyDown:(NSEvent *)anEvent{
    if([anEvent modifierFlags] & NSEventModifierFlagCommand){
        NSString *theKey = [anEvent charactersIgnoringModifiers];
        if([theKey isEqualToString:@"'"]){
            stopExposure=1;
            return;
        }
    }
    [[appController theWindow] sendEvent: anEvent];
}

- (void) focuserGoto:(int) target{
    EAF_ERROR_CODE err;
    if(target < 0 || target > maxPos){
        beep();
    }
    err = EAFMove(iSelectedID, target);
    bool isMoving = false;
    
    while(1)
    {
        bool pbHandControl;
        err = EAFIsMoving(iSelectedID, &isMoving, &pbHandControl);
        if(err != EAF_SUCCESS || !isMoving)
            break;
        //[NSThread sleepForTimeInterval:0.7f];
        //usleep(700000);
        EAFGetPosition(iSelectedID, &currentPos);
        [focuserCurrentPosition setStringValue:[NSString stringWithFormat:@"%d",currentPos]];
        [focuserCurrentPosition setNeedsDisplay];
        //zwoUpdate
    }
    EAFGetPosition(iSelectedID, &currentPos);
}


@end
