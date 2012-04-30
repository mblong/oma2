//
//  StatusController.h
//  tst2
//
//  Created by Marshall Long on 3/20/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface StatusController : NSWindowController {
@private
    //int tool_selected;
    int MinMaxInc;
    IBOutlet NSSlider *slide_val;   // lesson 8
    IBOutlet NSTextField *slide_label;

    
}
//
@property int tool_selected;

// Min/Max Increment outlets
@property int MinMaxInc;
- (IBAction)changedMinMaxInc:(id)sender;
//@property (weak) IBOutlet NSSliderCell *minMaxIncSetting;

// Color Min and Max values
@property (weak) IBOutlet NSTextField *ColorMinLabel;
@property (weak) IBOutlet NSTextField *ColorMaxLabel;

// Image Specs
@property (weak) IBOutlet NSTextField *MinLabel;
@property (weak) IBOutlet NSTextField *MaxLabel;
@property (weak) IBOutlet NSTextField *ColsLabel;
@property (weak) IBOutlet NSTextField *RowsLabel;
@property (weak) IBOutlet NSTextField *X0Label;
@property (weak) IBOutlet NSTextField *Y0Label;
@property (weak) IBOutlet NSTextField *DXLabel;
@property (weak) IBOutlet NSTextField *DYLabel;

// mouse click/drag labels
@property (weak) IBOutlet NSTextField *XLabel;
@property (weak) IBOutlet NSTextField *YLabel;
@property (weak) IBOutlet NSTextField *ZLabel;

- (IBAction)scaleCheckbox:(id)sender;
@property (weak) IBOutlet NSButton *scaleState;

- (IBAction)updateCheckbox:(id)sender;
@property (weak) IBOutlet NSButton *updateState;



// Tool selection
- (IBAction)selectTool:(id)sender;
@property (weak) IBOutlet NSMatrix *toolSelected;


// Color Min/Max "-" and "+" buttons
- (IBAction)decreaseColorMin:(id)sender;
- (IBAction)increaseColorMin:(id)sender;
- (IBAction)decreaseColorMax:(id)sender;
- (IBAction)increaseColorMax:(id)sender;


- (void) labelColorMinMax;
- (void) labelX0:(int) x Y0:(int) y Z0:(float) z;

-(id) whoami;

@end
