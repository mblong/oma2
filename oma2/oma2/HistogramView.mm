//
//  HistogramView.m
//  oma2
//
//  Created by Marshall Long on 8/30/22.
//  Copyright © 2022 Yale University. All rights reserved.
//

#import "HistogramView.h"

@implementation HistogramView

extern unsigned int histogram[];
extern Image iBuffer;
extern oma2UIData UIData;

@synthesize yScale;
@synthesize zoomX;

- (void)drawRect:(NSRect)dirtyRect{
    
    [super drawRect:dirtyRect];
    unsigned int histMax=0;
    int i,startIndex,endIndex,indexRange;
    float binsize = (iBuffer.max()-iBuffer.min())/(HISTOGRAM_SIZE-1.0);
    
    for(i=0; i<HISTOGRAM_SIZE;i++){
        if(histogram[i] > histMax) histMax = histogram[i];
    }
    
    NSPoint pt;
    pt.x = 0.;
    if(zoomX){
        startIndex = (UIData.cmin-iBuffer.min())/binsize;
        endIndex = (UIData.cmax-iBuffer.min())/binsize;
        if(startIndex < 0) startIndex=0;
        if(endIndex > HISTOGRAM_SIZE) endIndex = HISTOGRAM_SIZE;
        indexRange = endIndex - startIndex;
        pt.y = yScale*histogram[startIndex]/histMax;
    } else {
        pt.y = yScale*histogram[0]/histMax;
    }
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:pt];
    
    if(zoomX){
        for(i=startIndex; i < endIndex; i++){
            pt.x = (i-startIndex)*511.0/indexRange;
            pt.y = yScale*histogram[i]/histMax;
            [path lineToPoint:pt];
        }
    } else {
        for(i=1; i<HISTOGRAM_SIZE;i++){
            pt.x = i;
            pt.y = yScale*histogram[i]/histMax;
            [path lineToPoint:pt];
        }
    }
    [path stroke];
    
    // cmin and cmax
    NSBezierPath *path2 = [NSBezierPath bezierPath];
    [[NSColor redColor] setStroke];
    pt.y = 255.0;
    if(zoomX){
        pt.x=0;
    } else {
        cminIndex = (UIData.cmin-iBuffer.min())/binsize;
        pt.x = cminIndex;
    }
    [path2 moveToPoint:pt];
    pt.y = 0.0;
    [path2 lineToPoint:pt];
    
    pt.y = 255.0;
    if(zoomX){
        pt.x=511.0;
    } else {
        cmaxIndex = (UIData.cmax-iBuffer.min())/binsize;
        pt.x = cmaxIndex;
    }
    [path2 moveToPoint:pt];
    pt.y = 0.0;
    [path2 lineToPoint:pt];
    
    [path2 stroke];

}

- (void) mouseDown:(NSEvent *)theEvent{
    extern int last_x_val,last_y_val;
    if(zoomX) return;
    
    NSPoint point = [theEvent locationInWindow];
    point = [self convertPoint:point fromView:nil];
    if( abs(point.x - cminIndex) < abs(point.x - cmaxIndex)){
        // drag the cmin bar
        dragCmin = 1;
    } else {
        dragCmin = 0;
    }
}

- (void) mouseDragged:(NSEvent *)theEvent{
    if(zoomX) return;
    
    float binsize = (iBuffer.max()-iBuffer.min())/(HISTOGRAM_SIZE-1.0);
    NSPoint point = [theEvent locationInWindow];
    point = [self convertPoint:point fromView:nil];

    if(dragCmin){
        UIData.cmin = point.x*binsize+iBuffer.min();
        [appController updateHistogram];

    }else{
        UIData.cmax = point.x*binsize+iBuffer.min();
        [appController updateHistogram];
    }
}

- (void) mouseUp:(NSEvent *)theEvent{
    if(zoomX) return;
    
    UIData.displaySaturateValue = (UIData.cmax-UIData.min)/(UIData.max-UIData.min);
    UIData.displayFloorValue = (UIData.cmin-UIData.min)/(UIData.max-UIData.min);
    NSMutableString *str = [NSMutableString stringWithFormat:@"Mx/Mn %.2g/%.2g",UIData.displaySaturateValue,UIData.displayFloorValue];
    [str setString: [str stringByReplacingOccurrencesOfString:@"0." withString:@"."]];
    [[statusController scaleState] setTitle:str];
    
    //[ColorMaxLabel setStringValue:[NSString stringWithFormat:@"%g",UIData.cmax]];
    if(UIData.autoupdate) {
        int saveAuatoscale = UIData.autoscale;
        UIData.autoscale = 0;
        [appController updateDataWindow];
        UIData.autoscale = saveAuatoscale;
        
        //[self.window makeKeyAndOrderFront:NULL];
    }

    update_UI();
}
@end
