//
//  StatusController.m
//  tst2
//
//  Created by Marshall Long on 3/20/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#import "StatusController.h"
#import "ImageBitmap.h"

extern ImageBitmap iBitmap;
extern oma2UIData  UIData;     


@implementation StatusController
@synthesize toolSelected;

@synthesize ColorMinLabel;
@synthesize ColorMaxLabel;

@synthesize scaleState;
@synthesize updateState;

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
   
    [ColorMaxLabel setStringValue:[NSString stringWithFormat:@"%g",1000.]];
    [ColorMinLabel setStringValue:[NSString stringWithFormat:@"%g",0.]];
}


- (void) labelColorMinMax{
    [ColorMaxLabel setStringValue:[NSString stringWithFormat:@"%g",UIData.cmax]];
    [ColorMinLabel setStringValue:[NSString stringWithFormat:@"%g",UIData.cmin]];
}

- (IBAction)decreaseColorMin:(id)sender {
    UIData.cmin -= MinMaxInc/100.0*(UIData.max - UIData.min);
    [ColorMinLabel setStringValue:[NSString stringWithFormat:@"%g",UIData.cmin]];
    if(UIData.autoupdate) [appController updateDataWindow];
}

- (IBAction)increaseColorMin:(id)sender {
    UIData.cmin += MinMaxInc/100.0*(UIData.max - UIData.min);
    [ColorMinLabel setStringValue:[NSString stringWithFormat:@"%g",UIData.cmin]];
    if(UIData.autoupdate) [appController updateDataWindow];
}

- (IBAction)decreaseColorMax:(id)sender {
    UIData.cmax -= MinMaxInc/100.0*(UIData.max - UIData.min);
    [ColorMaxLabel setStringValue:[NSString stringWithFormat:@"%g",UIData.cmax]];
    if(UIData.autoupdate) [appController updateDataWindow];
}

- (IBAction)increaseColorMax:(id)sender {
    UIData.cmax += MinMaxInc/100.0*(UIData.max - UIData.min);
    [ColorMaxLabel setStringValue:[NSString stringWithFormat:@"%g",UIData.cmax]];
    if(UIData.autoupdate) [appController updateDataWindow];
}

- (IBAction)selectTool:(id)sender {
    tool_selected = (int)[toolSelected selectedColumn];
    NSLog(@" Tool number %d\n",tool_selected);
    
}

-(id) whoami{
    return self;
}

- (IBAction)scaleCheckbox:(id)sender {
    if([scaleState state] )
        UIData.autoscale = 1;
    else
        UIData.autoscale = 0;
}

- (IBAction)updateCheckbox:(id)sender {
    if([updateState state] )
        UIData.autoupdate = 1;
    else
        UIData.autoupdate = 0;
}


- (void)keyDown:(NSEvent *)anEvent{
    [[appController theWindow] sendEvent: anEvent];
}

@end
