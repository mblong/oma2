//
//  DrawingView.m
//  oma2
//
//  Created by Marshall Long on 10/6/13.
//  Copyright (c) 2013 Yale University. All rights reserved.
//

#import "DrawingView.h"
#import "AppController.h"
#import "ImageBitmap.h"
#import "UI.h"

#define SAMPLESPERPIX 4

extern ImageBitmap iBitmap;
extern Image iBuffer;
extern AppController* appController;
extern oma2UIData UIData;

@implementation DrawingView

@synthesize rowData;
@synthesize bytesPerRow;

- (void)drawRect:(NSRect)dirtyRect{

    [super drawRect:dirtyRect];
    if(rowData){
        NSBezierPath *path = [NSBezierPath bezierPath];
        [[NSColor redColor] setStroke];
        [path setLineWidth:1.0];
        
        float pixPerPt = bytesPerRow/[self frame].size.width/SAMPLESPERPIX;
        
        NSPoint pt;
        pt.x = 0.;
        pt.y = *rowData;
        [path moveToPoint:pt];
        for (int i=SAMPLESPERPIX; i< bytesPerRow;i+=SAMPLESPERPIX){
            pt.x = (float)i/pixPerPt/SAMPLESPERPIX;
            pt.y = *(rowData+i);
            [path lineToPoint:pt];
        }

        [path stroke];
        
        NSBezierPath *path2 = [NSBezierPath bezierPath];
        [[NSColor greenColor] setStroke];
        pt.x = 0.;
        pt.y = *rowData+1;
        [path2 moveToPoint:pt];
        for (int i=SAMPLESPERPIX; i< bytesPerRow;i+=SAMPLESPERPIX){
            pt.x = (float)i/pixPerPt/SAMPLESPERPIX;
            pt.y = *(rowData+i+1);
            [path2 lineToPoint:pt];
        }
        [path2 stroke];
        
        NSBezierPath *path3 = [NSBezierPath bezierPath];
        [[NSColor blueColor] setStroke];
        pt.x = 0.;
        pt.y = *rowData+2;
        [path3 moveToPoint:pt];
        for (int i=SAMPLESPERPIX; i< bytesPerRow;i+=SAMPLESPERPIX){
            pt.x = (float)i/pixPerPt/SAMPLESPERPIX;
            pt.y = *(rowData+i+2);
            [path3 lineToPoint:pt];
        }
        
        [path3 stroke];
    }
}
/*
-(void) plotRow: (unsigned char*) rowData rowBytes: (int) bytesPerRow{
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    [[NSColor redColor] set];
    [path setLineWidth:2.0];
    
    NSPoint pt;
    pt.x = 0;
    pt.y = *rowData;
    [path moveToPoint:pt];
    for (int i=4; i< bytesPerRow;i+=4){
        pt.x = i/4;
        pt.y = *(rowData+i);
        [path lineToPoint:pt];
        //printf("%d %d %d %d\n",*(rowData+i),*(rowData+i+1),*(rowData+i+2),*(rowData+i+3));
    }
    [path stroke];
    [self display];
}
*/
@end
