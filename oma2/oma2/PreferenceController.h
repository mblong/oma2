//
//  PreferenceController.h
//  oma2
//
//  Created by Marshall Long on 3/20/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "image_support.h"
#import "oma2.h"

extern RGBColor color[256][8];  // the eight color palttes
extern unsigned char customPalette[];

extern float clevls[MAX_CONTOURS];
extern int nlevls;
extern int colorctrs;
extern int datminmax;


@interface PreferenceController : NSWindowController{
    NSTextField *__weak savePrefix;
    NSTextField *__weak getPrefix;
    NSTextField *__weak macroPrefix;
    NSTextField *__weak settingsPrefix;
    
    NSTextField *__weak saveSuffix;
    NSTextField *__weak getSuffix;
    NSTextField *__weak macroSuffix;
    NSTextField *__weak settingsSuffix;
    
    NSTextField *__weak transparencyValue;
    
    NSString *sometext;
    
    // for the Palette tab
    int colorIndex;
    int lastIndex;
    unsigned char originalPalette[768];
    
    // for the contours tab
    NSArray *theTextFields;
    
    
}

- (IBAction)saveNewSettings:(id)sender;
- (IBAction)forgetNewSettings:(id)sender;

- (IBAction)selectPalette:(id)sender;


@property (weak) IBOutlet NSNumber* transparent;
@property (weak) IBOutlet NSMatrix *paletteSelected;

@property (weak) IBOutlet NSTextField *transparencyValue;

@property (weak) IBOutlet NSTextField *savePrefix;
@property (weak) IBOutlet NSTextField *getPrefix;
@property (weak) IBOutlet NSTextField *macroPrefix;
@property (weak) IBOutlet NSTextField *settingsPrefix;


@property (weak) IBOutlet NSTextField *saveSuffix;
@property (weak) IBOutlet NSTextField *getSuffix;
@property (weak) IBOutlet NSTextField *macroSuffix;
@property (weak) IBOutlet NSTextField *settingsSuffix;

@property (copy) IBOutlet NSString *sometext;

- (IBAction)highlightSaturatedCheckbox:(id)sender;
@property (weak) IBOutlet NSButton *highlightSaturatedState;


@property (weak) IBOutlet NSColorWell *highlightColor;
- (IBAction)highlightColorSet:(id)sender;

- (void) fillInUIData;

// Things in the Pallete tab
@property (weak) IBOutlet NSImageView *prefixPaletteImage;

@property (weak) IBOutlet NSSlider *colorIndexValue;
@property (weak) IBOutlet NSImageView *palleteImage;
@property (weak) IBOutlet NSColorWell *theColor;

@property (weak) IBOutlet NSTextField *pixLabel;
@property (weak) IBOutlet NSSlider *sliderValue;

@property (weak) IBOutlet NSTextField *numberOfContours;
@property (weak) IBOutlet NSStepper *stepperValue;
@property (weak) IBOutlet NSButton *contourCheckBox;

- (void) updatePaletteImage;

// Contours tab
@property (weak) IBOutlet NSPopUpButtonCell *numberOfContoursPopup;
@property (weak) IBOutlet NSButton *colorMinMaxButton;
@property (weak) IBOutlet NSButton *dataMinMaxButton;
@property (weak) IBOutlet NSButton *colorCheckbox;
@property (weak) IBOutlet NSTextField *contour1;
@property (weak) IBOutlet NSTextField *contour2;
@property (weak) IBOutlet NSTextField *contour3;
@property (weak) IBOutlet NSTextField *contour4;
@property (weak) IBOutlet NSTextField *contour5;
@property (weak) IBOutlet NSTextField *contour6;
@property (weak) IBOutlet NSTextField *contour7;
@property (weak) IBOutlet NSTextField *contour8;
@property (weak) IBOutlet NSTextField *contour9;
@property (weak) IBOutlet NSTextField *contour10;



@end
