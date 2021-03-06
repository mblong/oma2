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

#define SAMPLESPERPIX 3

extern ImageBitmap iBitmap;
extern Image iBuffer;
extern AppController* appController;
extern oma2UIData UIData;

@implementation DrawingView

@synthesize rowData;
@synthesize colData;
@synthesize bytesPerPlot;
@synthesize pixPerPt;
@synthesize theRow;
@synthesize theCol;
@synthesize isColor;
@synthesize heightScale;
@synthesize widthScale;



- (void)drawRect:(NSRect)dirtyRect{
    
    int samplesPerPix;
    
    [super drawRect:dirtyRect];
    if(rowData){
        // theRow is the data window row
        // the data window height is
        // the data height is
        //iBitmap.getheight()/self.frame.size.height;
        int theDataRow = theRow*heightScale;
        
        NSString *label =[NSString stringWithFormat:@"Row %d",theDataRow];
        NSPoint startPoint;
        startPoint.x = 10;
        startPoint.y = dirtyRect.size.height  - TITLEBAR_HEIGHT;
        NSDictionary *attributes = @{ NSForegroundColorAttributeName : [NSColor textColor]};
        [label drawAtPoint:startPoint withAttributes: attributes];
        //[label drawAtPoint:startPoint withAttributes:NULL];
        
        NSBezierPath *path = [NSBezierPath bezierPath];
        if (isColor) {
            [[NSColor redColor] setStroke];
            samplesPerPix = 3;
        } else {
            [[NSColor textColor] setStroke];
            samplesPerPix = 1;
        }
        
        [path setLineWidth:1.0];
        unsigned char* rowData_ = (unsigned char*)[rowData bytes];
        
        float scalex = self.window.frame.size.width/(float)bytesPerPlot/pixPerPt;
        float scaley = (self.window.frame.size.height-TITLEBAR_HEIGHT)/(256.);
        
        NSPoint pt;
        pt.x = 0.;
        pt.y = *rowData_*scaley;
        [path moveToPoint:pt];
        for (int i=samplesPerPix; i< bytesPerPlot;i+=samplesPerPix){
            pt.x = (float)i*scalex*pixPerPt;
            pt.y = *(rowData_+i)*scaley;
            [path lineToPoint:pt];
        }
        
        [path stroke];
        if (isColor) {
            NSBezierPath *path2 = [NSBezierPath bezierPath];
            [[NSColor greenColor] setStroke];
            pt.x = 0.;
            pt.y = (*rowData_+1)*scaley;
            [path2 moveToPoint:pt];
            for (int i=samplesPerPix; i< bytesPerPlot;i+=samplesPerPix){
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
            for (int i=samplesPerPix; i< bytesPerPlot;i+=samplesPerPix){
                pt.x = (float)i*scalex*pixPerPt;
                pt.y = *(rowData_+i+2)*scaley;
                [path3 lineToPoint:pt];
            }
            
            [path3 stroke];
        }
    }
    if(colData){
        if(theCol >=0){ // this is a column plot
            int theDataCol = theCol*widthScale;
            NSString *label =[NSString stringWithFormat:@"Column %d",theDataCol];
            NSPoint startPoint;
            startPoint.x = 10;
            startPoint.y = dirtyRect.size.height  - TITLEBAR_HEIGHT;
            NSDictionary *attributes = @{ NSForegroundColorAttributeName : [NSColor textColor]};
            [label drawAtPoint:startPoint withAttributes: attributes];
            
            NSBezierPath *path = [NSBezierPath bezierPath];
            if (isColor) {
                [[NSColor redColor] setStroke];
                samplesPerPix = 3;
            } else {
                [[NSColor textColor] setStroke];
                samplesPerPix = 1;
            }
            [path setLineWidth:1.0];
            unsigned char* colData_ = (unsigned char*)[colData bytes];
            
            float scalex = self.window.frame.size.width/(float)bytesPerPlot/pixPerPt;
            float scaley = (self.window.frame.size.height-TITLEBAR_HEIGHT)/(256.);
            
            
            NSPoint pt;
            pt.x = 0.;
            pt.y = *colData_*scaley;
            [path moveToPoint:pt];
            for (int i=samplesPerPix; i< bytesPerPlot;i+=samplesPerPix){
                pt.x = (float)i*scalex*pixPerPt;
                pt.y = *(colData_+i)*scaley;
                [path lineToPoint:pt];
            }
            
            [path stroke];
            if (isColor) {
                NSBezierPath *path2 = [NSBezierPath bezierPath];
                [[NSColor greenColor] setStroke];
                pt.x = 0.;
                pt.y = (*colData_+1)*scaley;
                [path2 moveToPoint:pt];
                for (int i=samplesPerPix; i< bytesPerPlot;i+=samplesPerPix){
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
                for (int i=samplesPerPix; i< bytesPerPlot;i+=samplesPerPix){
                    pt.x = (float)i*scalex*pixPerPt;
                    pt.y = *(colData_+i+2)*scaley;
                    [path3 lineToPoint:pt];
                }
                
                [path3 stroke];
            }
            
        } else { // this is a line plot
            NSBezierPath *path = [NSBezierPath bezierPath];
            if (isColor) {
                [[NSColor redColor] setStroke];
                samplesPerPix = 3;
            } else {
                [[NSColor textColor] setStroke];
                samplesPerPix = 1;
            }
            [path setLineWidth:1.0];
            unsigned char* colData_ = (unsigned char*)[colData bytes];
            
            float scalex = self.window.frame.size.width/(float)bytesPerPlot/pixPerPt;
            float scaley = (self.window.frame.size.height-TITLEBAR_HEIGHT)/(256.);
            
            
            NSPoint pt;
            pt.x = 0.;
            pt.y = *colData_*scaley;
            [path moveToPoint:pt];
            for (int i=samplesPerPix; i< bytesPerPlot;i+=samplesPerPix){
                pt.x = (float)i*scalex*pixPerPt;
                pt.y = *(colData_+i)*scaley;
                [path lineToPoint:pt];
            }
            
            [path stroke];
            if (isColor) {
                NSBezierPath *path2 = [NSBezierPath bezierPath];
                [[NSColor greenColor] setStroke];
                pt.x = 0.;
                pt.y = (*colData_+1)*scaley;
                [path2 moveToPoint:pt];
                for (int i=samplesPerPix; i< bytesPerPlot;i+=samplesPerPix){
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
                for (int i=samplesPerPix; i< bytesPerPlot;i+=samplesPerPix){
                    pt.x = (float)i*scalex*pixPerPt;
                    pt.y = *(colData_+i+2)*scaley;
                    [path3 lineToPoint:pt];
                }
                
                [path3 stroke];
            }
        }
        
    }
}


- (void) rightMouseDown:(NSEvent *)theEvent{
    if ([[theEvent window] alphaValue] == 1.0)
        [[theEvent window] setAlphaValue:UIData.alphaValue];
    else
        [[theEvent window] setAlphaValue:1.0];
}

- (void) setAlphaDraw: (float) newAlpha{
    [[self window] setAlphaValue:newAlpha];
    
}

@end
