//
//  Histogram.m
//  oma2
//
//  Created by Marshall Long on 8/29/22.
//  Copyright © 2022 Yale University. All rights reserved.
//

#import "Histogram.h"

extern AppController* appController;
extern Image iBuffer;
extern char histogramIsVisible;
extern oma2UIData UIData;

@interface Histogram ()

@end

@implementation Histogram

@synthesize histogramView;
@synthesize MinLabel;
@synthesize MidLabel;
@synthesize MaxLabel;
@synthesize cminLabel;
@synthesize cmaxLabel;
@synthesize toggleZoomX;


- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    iBuffer.gethistogram();
    [MinLabel setStringValue:[NSString stringWithFormat:@"%g",iBuffer.min()]];
    [MidLabel setStringValue:[NSString stringWithFormat:@"%g",(iBuffer.max() -iBuffer.min())/2.0]];
    [MaxLabel setStringValue:[NSString stringWithFormat:@"%g",iBuffer.max()]];
    [cmaxLabel setStringValue:[NSString stringWithFormat:@"Cmax: %g",UIData.cmax]];
    [cminLabel setStringValue:[NSString stringWithFormat:@"Cmin: %g",UIData.cmin]];

    yScale=255.;
    zoomX=0;
    [histogramView setYScale:yScale];
    [histogramView setZoomX:zoomX];

    [histogramView display];
    histogramIsVisible=1;
    }

- (void)updateHistogram {
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    iBuffer.gethistogram();
    if(zoomX){
        [MinLabel setStringValue:[NSString stringWithFormat:@"%g",UIData.cmin]];
        [MidLabel setStringValue:[NSString stringWithFormat:@"%g",(UIData.cmax - UIData.cmin)/2.0 + UIData.cmin]];
        [MaxLabel setStringValue:[NSString stringWithFormat:@"%g",UIData.cmax]];
        [toggleZoomX setTitle:@"UnZoom X"];
    } else {
        [MinLabel setStringValue:[NSString stringWithFormat:@"%g",iBuffer.min()]];
        [MidLabel setStringValue:[NSString stringWithFormat:@"%g",(iBuffer.max() - iBuffer.min())/2.0 + iBuffer.min()]];
        [MaxLabel setStringValue:[NSString stringWithFormat:@"%g",iBuffer.max()]];
        [toggleZoomX setTitle:@"Zoom X"];
    }
    [cmaxLabel setStringValue:[NSString stringWithFormat:@"Cmax: %g",UIData.cmax]];
    [cminLabel setStringValue:[NSString stringWithFormat:@"Cmin: %g",UIData.cmin]];
/*
    extern Variable user_variables[];
    user_variables[0].fvalue = UIData.cmin;
    user_variables[0].ivalue = UIData.cmin;
    user_variables[0].is_float = 1;
    user_variables[1].fvalue = UIData.cmax;
    user_variables[1].ivalue = UIData.cmax;
    user_variables[1].is_float = 1;
*/
    histogramIsVisible=1;
    [histogramView display];

}

- (void) windowWillClose:(NSNotification *) notification
{
    histogramIsVisible=0;
}

- (void)keyDown:(NSEvent *)anEvent{
    [[appController theWindow] sendEvent: anEvent];
}

- (IBAction)ZoomIn:(id)sender {
    yScale*= 2.;
    [histogramView setYScale:yScale];
    [histogramView display];
}

- (IBAction)ZoomOut:(id)sender {
    yScale/= 2.;
    [histogramView setYScale:yScale];
    [histogramView display];
}

- (IBAction)toggleZoomX:(id)sender {
    if(zoomX){
        zoomX=0;
        //[_toggleZoomX setStringValue:@"Zoom X"];
    } else {
        zoomX=1;
        //[_toggleZoomX setStringValue:@"UnZoom X"];
    }
    [histogramView setZoomX:zoomX];
    [self updateHistogram];

}

- (IBAction)clipImage:(id)sender {
    extern int printMax;
    if(iBuffer.min() != UIData.cmin) iBuffer.floor(UIData.cmin);
    if(iBuffer.max() != UIData.cmax) iBuffer.clip(UIData.cmax);
    zoomX=0;
    UIData.displaySaturateValue = 1.0;
    UIData.displayFloorValue=0.0;
    iBuffer.getmaxx(printMax);
    update_UI();
    [self updateHistogram];
    
}


@end
