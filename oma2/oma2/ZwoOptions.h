//
//  ZwoOptions.h
//  oma2cam
//
//  Created by Marshall Long on 4/1/22.
//  Copyright © 2022 Yale University. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "zwoCameras.hpp"
#include "EAF_focuser.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZwoOptions : NSWindowController{
    NSTimer *myTimer;
    bool modifyingMaxPos;
    bool modifyingGoto;
    bool modifyingStepSize;
    bool modifyingCurrentPosition;

}
@property (weak) IBOutlet NSTextField *temperatureSetPoint;
@property (weak) IBOutlet NSTextField *temperatureStatus;
@property (weak) IBOutlet NSTextField *timerText;
@property (weak) IBOutlet NSStepperCell *changeSetControl;
@property (weak) IBOutlet NSButton *enableCooler;
@property (weak) IBOutlet NSButton *enableAntiDew;
@property (weak) IBOutlet NSTextField *coolerPercentValue;
@property (weak) IBOutlet NSTextField *exposureValue;
@property (weak) IBOutlet NSTextField *gainValue;
@property (weak) IBOutlet NSButton *enableAutoDisplay;
@property (weak) IBOutlet NSButton *enableClearBad;
@property (weak) IBOutlet NSTextField *balanceValues;
@property (weak) IBOutlet NSStepper *changeGainControl;


@property (weak) IBOutlet NSTextField *focuserCurrentPosition;
@property (weak) IBOutlet NSTextField *focuserTemperature;
@property (weak) IBOutlet NSTextField *focuserMaxPosition;
@property (weak) IBOutlet NSTextField *focuserGotoPosition;
@property (weak) IBOutlet NSTextField *focuserStepSize;
@property (weak) IBOutlet NSButtonCell *rightButton;
@property (weak) IBOutlet NSButtonCell *leftButton;

@property (weak) IBOutlet NSButton *modifyMaxPosButton;
@property (weak) IBOutlet NSButton *modifyGotoButton;
@property (weak) IBOutlet NSButton *modifyStepSizeButton;
@property (weak) IBOutlet NSButton *modifyCurrentPositionButton;

@property (weak) IBOutlet NSTextField *countdownFWHM;


- (void)updateZwoWindow;
- (void)updateTimer:(int)secondsRemaining;
- (void)updateFwhm:(float)fwhm;
- (void)closeWindow;
- (void)focuserGoto:(int) target;
@end

NS_ASSUME_NONNULL_END
