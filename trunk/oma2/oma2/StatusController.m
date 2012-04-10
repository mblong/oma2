//
//  StatusController.m
//  tst2
//
//  Created by Marshall Long on 3/20/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#import "StatusController.h"
#import "ImageBitmap.h"

//extern ImageBitmap iBitmap;

@implementation StatusController
@synthesize toolSelected;

@synthesize ColorMinLabel;
@synthesize ColorMaxLabel;
@synthesize colorMin;
@synthesize colorMax;
@synthesize autoScale;

//@synthesize MinMaxIncrementVal;
//@synthesize MinMaxIncLabel;
@synthesize MinMaxInc;

StatusController *statusController;

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
    [self setMinMaxInc:5];
    //[self setColorMin:0];
    //[self setColorMax:1];
    [self setAutoScale:YES];

    
    /*
    [MinMaxIncrementVal setIntValue:startMinMaxInc];
    NSString *str = [NSString stringWithFormat:@"%d %%",startMinMaxInc];
    [MinMaxIncLabel setStringValue:str];*/
   
    [ColorMaxLabel setStringValue:[NSString stringWithFormat:@"%g",1000.]];
    [ColorMinLabel setStringValue:[NSString stringWithFormat:@"%g",0.]];
    //statusController = [self whoami];
    
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



- (void) labelColorMin:(float) cmin Max:(float) cmax{
    [ColorMaxLabel setStringValue:[NSString stringWithFormat:@"%g",cmax]];
    [ColorMinLabel setStringValue:[NSString stringWithFormat:@"%g",cmin]];
    //[self setAutoScale:NO];
}

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

-(id) whoami{
    return self;
}

- (IBAction)scaleCheckbox:(id)sender {
//    if([scaleCheckbox state])
//        iBitmap.setautoscale(1);
//    else
//        iBitmap.setautoscale(0);
    
}
@end
