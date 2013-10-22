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
@synthesize colData;
@synthesize bytesPerRow;
@synthesize pixPerPt;

- (void)drawRect:(NSRect)dirtyRect{

    [super drawRect:dirtyRect];
    if(rowData){
        NSBezierPath *path = [NSBezierPath bezierPath];
        [[NSColor redColor] setStroke];
        [path setLineWidth:1.0];
        unsigned char* rowData_ = (unsigned char*)[rowData bytes];
        
        float scalex = self.window.frame.size.width/(float)bytesPerRow/pixPerPt;
        float scaley = self.window.frame.size.height/(255.-20.);
        
        NSPoint pt;
        pt.x = 0.;
        pt.y = *rowData_*scaley;
        [path moveToPoint:pt];
        for (int i=SAMPLESPERPIX; i< bytesPerRow;i+=SAMPLESPERPIX){
            pt.x = (float)i*scalex*pixPerPt;
            pt.y = *(rowData_+i)*scaley;
            [path lineToPoint:pt];
        }

        [path stroke];
        
        NSBezierPath *path2 = [NSBezierPath bezierPath];
        [[NSColor greenColor] setStroke];
        pt.x = 0.;
        pt.y = (*rowData_+1)*scaley;
        [path2 moveToPoint:pt];
        for (int i=SAMPLESPERPIX; i< bytesPerRow;i+=SAMPLESPERPIX){
            pt.x = (float)i*scalex*pixPerPt;
            pt.y = *(rowData_+i+1)*scaley;
            [path2 lineToPoint:pt];
        }
        [path2 stroke];
        
        NSBezierPath *path3 = [NSBezierPath bezierPath];
        [[NSColor blueColor] setStroke];
        pt.x = 0.;
        pt.y = (*rowData_+2)*scaley;
        [path3 moveToPoint:pt];
        for (int i=SAMPLESPERPIX; i< bytesPerRow;i+=SAMPLESPERPIX){
            pt.x = (float)i*scalex*pixPerPt;
            pt.y = *(rowData_+i+2)*scaley;
            [path3 lineToPoint:pt];
        }
        
        [path3 stroke];
    }
    if(colData){
        NSBezierPath *path = [NSBezierPath bezierPath];
        [[NSColor redColor] setStroke];
        [path setLineWidth:1.0];
        
        float pixPerPt = bytesPerRow/[self frame].size.width/SAMPLESPERPIX;
        
        NSPoint pt;
        pt.x = 0.;
        pt.y = *colData;
        [path moveToPoint:pt];
        for (int i=SAMPLESPERPIX; i< bytesPerRow;i+=SAMPLESPERPIX){
            pt.x = (float)i/pixPerPt/SAMPLESPERPIX;
            pt.y = *(colData+i);
            [path lineToPoint:pt];
        }
        
        [path stroke];
        
        NSBezierPath *path2 = [NSBezierPath bezierPath];
        [[NSColor greenColor] setStroke];
        pt.x = 0.;
        pt.y = *colData+1;
        [path2 moveToPoint:pt];
        for (int i=SAMPLESPERPIX; i< bytesPerRow;i+=SAMPLESPERPIX){
            pt.x = (float)i/pixPerPt/SAMPLESPERPIX;
            pt.y = *(colData+i+1);
            [path2 lineToPoint:pt];
        }
        [path2 stroke];
        
        NSBezierPath *path3 = [NSBezierPath bezierPath];
        [[NSColor blueColor] setStroke];
        pt.x = 0.;
        pt.y = *colData+2;
        [path3 moveToPoint:pt];
        for (int i=SAMPLESPERPIX; i< bytesPerRow;i+=SAMPLESPERPIX){
            pt.x = (float)i/pixPerPt/SAMPLESPERPIX;
            pt.y = *(colData+i+2);
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
