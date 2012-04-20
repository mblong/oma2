//
//  DataView.m
//  oma2
//
//  Created by Marshall Long on 4/19/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#import "DataView.h"
#import "AppController.h"
#import "ImageBitmap.h"
#import "UI.h"

extern ImageBitmap iBitmap;
extern Image iBuffer;
extern AppController* appController; 
extern oma2UIData UIData;



@implementation DataView

- (void)drawRect:(NSRect)dirtyRect{
    [super drawRect:dirtyRect];
    //NSLog(@"TooL: %d",statusController.tool_selected);    // don't know why this doesn't work
    if(appController.tool){
    
        [[NSBezierPath 
          bezierPathWithRect:NSMakeRect(startPoint.x, startPoint.y, 
            endPoint.x-startPoint.x, endPoint.y-startPoint.y)]stroke];
        UIData.iRect.ul.h = startRect.x;
        UIData.iRect.ul.v = startRect.y;
        UIData.iRect.lr.h = endRect.x;
        UIData.iRect.lr.v = endRect.y;
        // remove restriction on the way a rectangle is defined
        // previously, the assumption was that all rectangles were defined from the upper left to lower right
        if(endRect.x < startRect.x){
            UIData.iRect.lr.h = startRect.x;
            UIData.iRect.ul.h = endRect.x;
        }
        if(endRect.y < startRect.y){
            UIData.iRect.lr.v = startRect.y;
            UIData.iRect.ul.v = endRect.y;
        }
    }
    
}

- (void) mouseDown:(NSEvent *)theEvent{
    NSPoint point = [theEvent locationInWindow];
    startPoint = [self convertPoint:point fromView:nil];
    int x = startPoint.x;
    int y = self.frame.size.height - startPoint.y;
    if(x < 0) x = 0;
    if(x > self.frame.size.width-1) x = self.frame.size.width-1;
    if(y < 0) y = 0;
    if(y > self.frame.size.height-1) y = self.frame.size.height-1;
    startRect.x = x;
    startRect.y = y;
    
    [statusController labelX0:x Y0:y Z0: iBuffer.getpix(y,x)];
}


- (void) mouseDragged:(NSEvent *)theEvent{
    NSPoint point = [theEvent locationInWindow];
    endPoint = [self convertPoint:point fromView:nil];
    int x = endPoint.x;
    int y = self.frame.size.height - endPoint.y;
    if(x < 0) x = 0;
    if(x > self.frame.size.width-1) x = self.frame.size.width-1;
    if(y < 0) y = 0;
    if(y > self.frame.size.height-1) y = self.frame.size.height-1;
    endRect.x = x;
    endRect.y = y;

    [statusController labelX0:x Y0:y Z0: iBuffer.getpix(y,x)];
        
    [self setNeedsDisplay:YES];
}

@end
