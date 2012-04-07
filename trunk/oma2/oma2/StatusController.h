//
//  StatusController.h
//  tst2
//
//  Created by Marshall Long on 3/20/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface StatusController : NSWindowController{
    float colormin;
    float colormax;
    int tool_selected;
    int MinMaxInc;
    
}


// Min/Max Increment outlets
@property (assign) IBOutlet NSSlider *MinMaxIncrementVal;
@property (assign) IBOutlet NSTextField *MinMaxIncLabel;
@property int MinMaxInc;

// Color Min and Max values
@property (assign) IBOutlet NSTextField *ColorMinLabel;
@property (assign) IBOutlet NSTextField *ColorMaxLabel;

// Tool selection
- (IBAction)selectTool:(id)sender;
@property (assign) IBOutlet NSMatrix *toolSelected;



// the slider action
//- (IBAction)UpdateMinMaxInc:(id)sender;

// Color Min/Max "-" and "+" buttons
- (IBAction)decreaseColorMin:(id)sender;
- (IBAction)increaseColorMin:(id)sender;
- (IBAction)decreaseColorMax:(id)sender;
- (IBAction)increaseColorMax:(id)sender;


@end
