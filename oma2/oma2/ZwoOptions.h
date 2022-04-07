//
//  ZwoOptions.h
//  oma2cam
//
//  Created by Marshall Long on 4/1/22.
//  Copyright © 2022 Yale University. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "zwoCameras.hpp"

NS_ASSUME_NONNULL_BEGIN

@interface ZwoOptions : NSWindowController{
    NSTimer *myTimer;
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

- (void)updateZwoWindow;
- (void)updateTimer:(int)secondsRemaining;
- (void)closeWindow;
@end

NS_ASSUME_NONNULL_END
