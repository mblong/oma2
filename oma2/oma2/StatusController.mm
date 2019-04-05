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
extern AppController *appController;
StatusController *statusController;


@implementation StatusController
@synthesize PaletteBox;

//@synthesize minMaxIncSetting;
@synthesize toolSelected;
@synthesize tool_selected;

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
@synthesize XLabel;
@synthesize YLabel;
@synthesize ZLabel;
@synthesize XLabel2;
@synthesize YLabel2;
@synthesize ZLabel2;



@synthesize scaleState;
@synthesize updateState;

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
    //[PaletteBox setImage:[NSImage imageNamed:@"pal4.jpg"]];
    [self updatePaletteBox];
    //[self.window setLevel: kCGMainMenuWindowLevelKey];
}

- (void) awakeFromNib{
    [self setMinMaxInc:4];
   
    [ColorMaxLabel setStringValue:[NSString stringWithFormat:@"%g",1000.]];
    [ColorMinLabel setStringValue:[NSString stringWithFormat:@"%g",0.]];
    NSRect screenRect = [[NSScreen mainScreen] visibleFrame];
    NSPoint origin;
    origin.x = screenRect.origin.x+2*WINDOW_OFFSET+COMMANDWIDTH;
    origin.y = 0;
    [self.window setFrameOrigin:origin];

}

- (void) updatePaletteBox{
    
    [PaletteBox setImage:[NSImage imageNamed:
                          [NSString stringWithFormat:@"pal%d.jpg",UIData.thepalette]]];
}

- (void) labelColorMinMax{
    //MinMaxInc = UIData.cminmaxinc;
    [self setMinMaxInc:UIData.cminmaxinc];
    [slide_val setIntValue:UIData.cminmaxinc];   
    [slide_label setIntValue:[slide_val intValue]];

    //[minMaxIncSetting setIntValue:UIData.cminmaxinc];

    
    [ColorMaxLabel setStringValue:[NSString stringWithFormat:@"%g",UIData.cmax]];
    [ColorMinLabel setStringValue:[NSString stringWithFormat:@"%g",UIData.cmin]];
    
    [MinLabel setStringValue:[NSString stringWithFormat:@"Min: %g",UIData.min]];
    [MaxLabel setStringValue:[NSString stringWithFormat:@"Max: %g",UIData.max]];
    if(UIData.iscolor)
        [RowsLabel setStringValue:[NSString stringWithFormat:@"Rows: %d x 3",UIData.rows/3]];
    else
        [RowsLabel setStringValue:[NSString stringWithFormat:@"Rows: %d",UIData.rows]];
    [ColsLabel setStringValue:[NSString stringWithFormat:@"Cols: %d",UIData.cols]];
    [DXLabel setStringValue:[NSString stringWithFormat:@"DX: %d",UIData.dx]];
    [DYLabel setStringValue:[NSString stringWithFormat:@"DY: %d",UIData.dy]];
    [X0Label setStringValue:[NSString stringWithFormat:@"X0: %d",UIData.x0]];
    [Y0Label setStringValue:[NSString stringWithFormat:@"Y0: %d",UIData.y0]];
    
    appController.tool = UIData.toolselected;
    [self setTool_selected:UIData.toolselected];
    [[self toolSelected] selectCellAtRow:0 column:UIData.toolselected];

}

- (void) labelX0:(int) x Y0:(int) y Z0:(float) z{
    [XLabel setStringValue:[NSString stringWithFormat:@"X: %d",x]];
    [YLabel setStringValue:[NSString stringWithFormat:@"Y: %d",y]];
    [ZLabel setStringValue:[NSString stringWithFormat:@"Z: %g",z]];

}

- (void) labelX1:(int) x Y1:(int) y Z1:(float) z{
    if(x<0){
        [XLabel2 setStringValue:@" "];
        [YLabel2 setStringValue:@" "];
        [ZLabel2 setStringValue:@" "];
    } else {
        [XLabel2 setStringValue:[NSString stringWithFormat:@"X: %d",x]];
        [YLabel2 setStringValue:[NSString stringWithFormat:@"Y: %d",y]];
        [ZLabel2 setStringValue:[NSString stringWithFormat:@"Z: %g",z]];
     }
}


- (IBAction)decreaseColorMin:(id)sender {
    UIData.cmin -= MinMaxInc/100.0*(UIData.max - UIData.min);
    [ColorMinLabel setStringValue:[NSString stringWithFormat:@"%g",UIData.cmin]];
    if(UIData.autoupdate){
        int saveAuatoscale = UIData.autoscale;
        UIData.autoscale = 0;
        [appController updateDataWindow];
        UIData.autoscale = saveAuatoscale;
    }
}

- (IBAction)increaseColorMin:(id)sender {
    UIData.cmin += MinMaxInc/100.0*(UIData.max - UIData.min);
    [ColorMinLabel setStringValue:[NSString stringWithFormat:@"%g",UIData.cmin]];
    if(UIData.autoupdate) {
        int saveAuatoscale = UIData.autoscale;
        UIData.autoscale = 0;
        [appController updateDataWindow];
        UIData.autoscale = saveAuatoscale;
    }
}

- (IBAction)decreaseColorMax:(id)sender {
    UIData.cmax -= MinMaxInc/100.0*(UIData.max - UIData.min);
    [ColorMaxLabel setStringValue:[NSString stringWithFormat:@"%g",UIData.cmax]];
    if(UIData.autoupdate) {
        int saveAuatoscale = UIData.autoscale;
        UIData.autoscale = 0;
        [appController updateDataWindow];
        UIData.autoscale = saveAuatoscale;
        
        //[self.window makeKeyAndOrderFront:NULL];
    }
    //NSLog(@"minmaxinc: %d",MinMaxInc);
}

- (IBAction)increaseColorMax:(id)sender {
    UIData.cmax += MinMaxInc/100.0*(UIData.max - UIData.min);
    [ColorMaxLabel setStringValue:[NSString stringWithFormat:@"%g",UIData.cmax]];
    if(UIData.autoupdate) {
        int saveAuatoscale = UIData.autoscale;
        UIData.autoscale = 0;
        [appController updateDataWindow];
        UIData.autoscale = saveAuatoscale;
    }
}

- (IBAction)nextPalette:(id)sender{
    UIData.thepalette++;
    if(UIData.thepalette >= NUMPAL)UIData.thepalette = 0;
    update_UI();
}

- (IBAction)selectTool:(id)sender {
    tool_selected = (int)[toolSelected selectedColumn];
    [self setTool_selected:(int)[toolSelected selectedColumn]];
    appController.tool = tool_selected;
    UIData.toolselected = tool_selected;
    NSLog(@" Tool number %d\n",tool_selected);
    
}


- (IBAction)scaleCheckbox:(id)sender {
    if([scaleState state] ){
        UIData.autoscale = 1;
        if(UIData.displaySaturateValue == 1.0){
            [scaleState setTitle: @"Scale"];
        } else {
            [scaleState setTitle:[NSString stringWithFormat:@"Scale*%g",UIData.displaySaturateValue]];
        }
    }else{
        UIData.autoscale = 0;
        [scaleState setTitle: @"Scale"];
    }
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



- (IBAction)changedMinMaxInc:(id)sender {
    [slide_label setIntValue:[slide_val intValue]];
    MinMaxInc = [slide_val intValue];
    UIData.cminmaxinc = MinMaxInc;
    NSLog(@"minmaxinc: %d",MinMaxInc);
}
@end
