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

extern ImageBitmap iBitmap;
extern Image iBuffer;
extern AppController* appController; 


@implementation DataView

- (void) mouseDown:(NSEvent *)theEvent{
    NSPoint point = [theEvent locationInWindow];
    startPoint = [self convertPoint:point fromView:nil];
    [statusController labelX0:startPoint.x Y0:startPoint.y 
                           Z0: iBuffer.getpix((int)startPoint.x,(int)startPoint.y)];
    //startPoint = [self convertPoint:point fromView:nil];
    
    
}

- (void)drawRect:(NSRect)dirtyRect{
    [super drawRect:dirtyRect];
    [[NSBezierPath bezierPathWithRect:NSMakeRect(startPoint.x, startPoint.y, endPoint.x-startPoint.x, endPoint.y-startPoint.y)] stroke] ;
    
}

- (void) mouseDragged:(NSEvent *)theEvent{
    NSPoint point = [theEvent locationInWindow];
    endPoint = [self convertPoint:point fromView:nil];
    [statusController labelX0:endPoint.x Y0:endPoint.y  
                           Z0: iBuffer.getpix((int)endPoint.x,(int)endPoint.y)];
    
    [[NSBezierPath bezierPathWithRect:NSMakeRect(startPoint.x, startPoint.y, endPoint.x-startPoint.x, endPoint.y-startPoint.y)] stroke] ;
    
    [self setNeedsDisplay:YES];
    
}

@end
