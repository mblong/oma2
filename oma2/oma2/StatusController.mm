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

@synthesize MinLabel;
@synthesize MaxLabel;
@synthesize ColsLabel;
@synthesize RowsLabel;
@synthesize X0Label;
@synthesize Y0Label;
@synthesize DXLabel;
@synthesize DYLabel;


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
    [[self window]registerForDraggedTypes:[NSArray arrayWithObject:NSURLPboardType]];   // all types
}


- (void) labelColorMinMax{
    [ColorMaxLabel setStringValue:[NSString stringWithFormat:@"%g",UIData.cmax]];
    [ColorMinLabel setStringValue:[NSString stringWithFormat:@"%g",UIData.cmin]];
    
    [MinLabel setStringValue:[NSString stringWithFormat:@"Min: %g",UIData.min]];
    [MaxLabel setStringValue:[NSString stringWithFormat:@"Max: %g",UIData.max]];
    [RowsLabel setStringValue:[NSString stringWithFormat:@"Rows: %d",UIData.rows]];
    [ColsLabel setStringValue:[NSString stringWithFormat:@"Cols: %d",UIData.cols]];
    [DXLabel setStringValue:[NSString stringWithFormat:@"DX: %d",UIData.dx]];
    [DYLabel setStringValue:[NSString stringWithFormat:@"DY: %d",UIData.dy]];
    [X0Label setStringValue:[NSString stringWithFormat:@"X0: %d",UIData.x0]];
    [Y0Label setStringValue:[NSString stringWithFormat:@"Y0: %d",UIData.y0]];

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


// ******** drag and drop related

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    if ([NSImage canInitWithPasteboard:[sender draggingPasteboard]] &&
        [sender draggingSourceOperationMask] & NSDragOperationCopy) {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    if ([NSImage canInitWithPasteboard:[sender draggingPasteboard]]) {
        //NSImage *newImage = [[NSImage alloc] initWithPasteboard:[sender draggingPasteboard]];
        //[self setImage:newImage];
        //[newImage release];
        return YES;
    }
    return NO;
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender {
    //[self setNeedsDisplay:YES];
}


@end
