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
@synthesize theRow;
@synthesize theCol;


- (void)drawRect:(NSRect)dirtyRect{

    [super drawRect:dirtyRect];
    if(rowData){
        NSString *label =[NSString stringWithFormat:@"Row %d",theRow];
        NSPoint startPoint;
        startPoint.x = 10;
        startPoint.y = dirtyRect.size.height  - TITLEBAR_HEIGHT;
        [label drawAtPoint:startPoint withAttributes:NULL];

        NSBezierPath *path = [NSBezierPath bezierPath];
        [[NSColor redColor] setStroke];
        [path setLineWidth:1.0];
        unsigned char* rowData_ = (unsigned char*)[rowData bytes];
        
        float scalex = self.window.frame.size.width/(float)bytesPerRow/pixPerPt;
        float scaley = (self.window.frame.size.height-TITLEBAR_HEIGHT)/(256.);
        
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
        NSString *label =[NSString stringWithFormat:@"Column %d",theCol];
        NSPoint startPoint;
        startPoint.x = 10;
        startPoint.y = dirtyRect.size.height  - TITLEBAR_HEIGHT;
        [label drawAtPoint:startPoint withAttributes:NULL];

        
        NSBezierPath *path = [NSBezierPath bezierPath];
        [[NSColor redColor] setStroke];
        [path setLineWidth:1.0];
        unsigned char* colData_ = (unsigned char*)[colData bytes];
        
        float scalex = self.window.frame.size.width/(float)bytesPerRow/pixPerPt;
        float scaley = (self.window.frame.size.height-TITLEBAR_HEIGHT)/(256.);

        
        NSPoint pt;
        pt.x = 0.;
        pt.y = *colData_*scaley;
        [path moveToPoint:pt];
        for (int i=SAMPLESPERPIX; i< bytesPerRow;i+=SAMPLESPERPIX){
            pt.x = (float)i*scalex*pixPerPt;
            pt.y = *(colData_+i)*scaley;
            [path lineToPoint:pt];
        }
        
        [path stroke];
        
        NSBezierPath *path2 = [NSBezierPath bezierPath];
        [[NSColor greenColor] setStroke];
        pt.x = 0.;
        pt.y = (*colData_+1)*scaley;
        [path2 moveToPoint:pt];
        for (int i=SAMPLESPERPIX; i< bytesPerRow;i+=SAMPLESPERPIX){
            pt.x = (float)i*scalex*pixPerPt;
            pt.y = *(colData_+i+1)*scaley;
            [path2 lineToPoint:pt];
        }
        [path2 stroke];
        
        NSBezierPath *path3 = [NSBezierPath bezierPath];
        [[NSColor blueColor] setStroke];
        pt.x = 0.;
        pt.y = (*colData_+2)*scaley;
        [path3 moveToPoint:pt];
        for (int i=SAMPLESPERPIX; i< bytesPerRow;i+=SAMPLESPERPIX){
            pt.x = (float)i*scalex*pixPerPt;
            pt.y = *(colData_+i+2)*scaley;
            [path3 lineToPoint:pt];
        }
        
        [path3 stroke];
    }

}

- (void) mouseDown:(NSEvent *)theEvent{
    // toggle alpha if right click
    //int number =[theEvent buttonNumber];
    //if ([theEvent buttonNumber] == NSRightMouseDown){
    if ([theEvent modifierFlags] & 1){              // need to figure out the name of this constant
        if ([[theEvent window] alphaValue] == 1.0)
            [[theEvent window] setAlphaValue:UIData.alphaValue];
        else
            [[theEvent window] setAlphaValue:1.0];
    }
    
}

- (void) rightMouseDown:(NSEvent *)theEvent{
    if ([[theEvent window] alphaValue] == 1.0)
        [[theEvent window] setAlphaValue:UIData.alphaValue];
    else
        [[theEvent window] setAlphaValue:1.0];
}


@end
