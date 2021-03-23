//
//  colorImageOptionsController.h
//  oma2
//
//  Created by Marshall Long on 3/16/21.
//  Copyright © 2021 Yale University. All rights reserved.
//
#define CSF 3

#import <Cocoa/Cocoa.h>
#import "ImageBitmap.h"

NS_ASSUME_NONNULL_BEGIN

@interface ColorImageOptionsController : NSWindowController{
@private

    
}

@property (weak) IBOutlet NSSlider *redSlideValue;
@property (weak) IBOutlet NSBox *redMultiplierLabel;
@property (weak) IBOutlet NSBox *greenMultiplierLabel;
@property (weak) IBOutlet NSSlider *blueSlideValue;
@property (weak) IBOutlet NSSlider *greenSlideValue;
@property (weak) IBOutlet NSBox *blueMultiplierLabel;

@property (weak) IBOutlet NSSlider *redGammaSlideValue;
@property (weak) IBOutlet NSBox *redGammaLabel;
@property (weak) IBOutlet NSSlider *greenGammaSlideValue;
@property (weak) IBOutlet NSBox *greenGammaLabel;
@property (weak) IBOutlet NSSlider *blueGammaSlideValue;
@property (weak) IBOutlet NSBox *blueGammaLabel;

@property (weak) IBOutlet NSButton *lockGammaValue;


@end

NS_ASSUME_NONNULL_END
