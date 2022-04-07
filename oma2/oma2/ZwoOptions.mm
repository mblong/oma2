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


@interface ZwoOptions ()

@end



@implementation ZwoOptions

@synthesize temperatureSetPoint;
@synthesize changeSetControl;
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

- (void)windowDidLoad {
    [super windowDidLoad];
    zwoGetTempInfo();
    [self updateZwoWindow];
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
    [myTimer invalidate];
    
}

-(BOOL) acceptsFirstResponder{
    return YES;
}

- (IBAction)changeSetPoint:(id)sender {
    setTemp = [changeSetControl intValue];
    [temperatureSetPoint setStringValue:[NSString stringWithFormat:@"%ld",setTemp]];
    if(coolerEnabled) zwoSetTemp(setTemp);
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

- (void)updateZwoWindow{
    [temperatureSetPoint setStringValue:[NSString stringWithFormat:@"%ld",setTemp]];
    [changeSetControl setIntegerValue:setTemp];
    [enableCooler setState:coolerEnabled];
    [enableAntiDew setState:antiDewEnabled];
    [gainValue setStringValue:[NSString stringWithFormat:@"%d",gain]];
    [exposureValue setStringValue:[NSString stringWithFormat:@"%g",exp_ms/1000.]];
    [coolerPercentValue setStringValue:[NSString stringWithFormat:@"%ld",coolerPercent]];
    [temperatureStatus setStringValue:[NSString stringWithFormat:@"%.1f",sensorTemp/10.]];
    [enableClearBad setState:clearBadEnabled];
    [enableAutoDisplay setState:autoDisplayEnabled];
    [balanceValues setStringValue:[NSString stringWithFormat:@"%ld/%ld",wbR,wbB]];
}
- (void)updateCoolingInfo{
    zwoGetTempInfo();
    [self updateZwoWindow];
    
}
- (void)updateTimer:(int)secondsRemaining{
    if(secondsRemaining>=0)
        [timerText setStringValue:[NSString stringWithFormat:@"%d",secondsRemaining]];
    else
        [timerText setStringValue:@"-"];
}
- (void)closeWindow{
    [[self window] close];
}
- (void)keyDown:(NSEvent *)anEvent{
    if([anEvent modifierFlags] & NSEventModifierFlagCommand){
        NSString *theKey = [anEvent charactersIgnoringModifiers];
        if([theKey isEqualToString:@";"]){
            stopExposure=1;
        }
    } else {
        [[appController theWindow] sendEvent: anEvent];
    }
}

@end
