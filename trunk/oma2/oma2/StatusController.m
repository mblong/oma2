//
//  StatusController.m
//  tst2
//
//  Created by Marshall Long on 3/20/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#import "StatusController.h"

@implementation StatusController
@synthesize toolSelected;

@synthesize ColorMinLabel;
@synthesize ColorMaxLabel;

@synthesize MinMaxIncrementVal;
@synthesize MinMaxIncLabel;
@synthesize MinMaxInc;


- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void) awakeFromNib{
    MinMaxInc = 5;
    /*
    [MinMaxIncrementVal setIntValue:startMinMaxInc];
    NSString *str = [NSString stringWithFormat:@"%d %%",startMinMaxInc];
    [MinMaxIncLabel setStringValue:str];*/
    colormin = 0.;
    colormax = 1000;
    [ColorMaxLabel setStringValue:[NSString stringWithFormat:@"%g",colormax]];
    [ColorMinLabel setStringValue:[NSString stringWithFormat:@"%g",colormin]];
    
    
}
/*
- (IBAction)UpdateMinMaxInc:(id)sender {
    // get a string with the slider value and display it
    int MinMaxInc = [MinMaxIncrementVal intValue];
    NSString *str = [NSString stringWithFormat:@"%d %%",MinMaxInc];
    [MinMaxIncLabel setStringValue:str];
    // send the value to the UI
    
}
*/
- (IBAction)decreaseColorMin:(id)sender {
}

- (IBAction)increaseColorMin:(id)sender {
}

- (IBAction)decreaseColorMax:(id)sender {
}

- (IBAction)increaseColorMax:(id)sender {
}

- (IBAction)selectTool:(id)sender {
    tool_selected = (int)[toolSelected selectedColumn];
    NSLog(@" Tool number %d\n",tool_selected);
    
}
@end
