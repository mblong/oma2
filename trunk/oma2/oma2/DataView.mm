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
    [super drawRect:dirtyRect];         // crash here when resizing data window that is not the current one
    //NSLog(@"TooL: %d",statusController.tool_selected);    // don't know why this doesn't work
    
    if (mouse_down) {
        
        // only want to do this if mouse is pressed -- 
        // without this condition, this gets done for every DISPLAY command
        
        //tools are: CROSS,RECT,CALCRECT,RULER,LINEPLOT
        NSBezierPath *path = [NSBezierPath bezierPath];
        [[NSColor grayColor] set];
        [path setLineWidth:2.0];
        
        switch  (appController.tool){     
            case CALCRECT:
            case RECT:
                //[[NSBezierPath bezierPathWithRect:NSMakeRect(startPoint.x, startPoint.y, 
                //      endPoint.x-startPoint.x, endPoint.y-startPoint.y)]stroke];
                
                [path appendBezierPathWithRect:
                 NSMakeRect(startPoint.x, startPoint.y,
                            endPoint.x-startPoint.x, endPoint.y-startPoint.y)];
                [path stroke];
                break;
                
            case RULER:
            case LINEPLOT:
                [path moveToPoint:startPoint];
                [path lineToPoint:endPoint];
                [path stroke];
                
                //[NSBezierPath strokeLineFromPoint:startPoint toPoint: endPoint];
                
                break;
                
            default:
                break;
        }
    }
}

- (void) mouseDown:(NSEvent *)theEvent{
    mouse_down = 1;
    NSPoint point = [theEvent locationInWindow];
    startPoint = [self convertPoint:point fromView:nil];
    int x = startPoint.x;
    int y = self.frame.size.height - startPoint.y;
    if(x < 0) x = 0;
    if(x > self.frame.size.width-1) x = self.frame.size.width-1;
    if(y < 0) y = 0;
    if(y > self.frame.size.height -1)
        y = self.frame.size.height -1;
    
    float widthScale = iBitmap.getwidth()/self.frame.size.width;
    float heightScale = iBitmap.getheight()/self.frame.size.height;
    x *= widthScale;
    y *= heightScale;
    
    startRect.x = x;
    startRect.y = y;
    
    [statusController labelX0:x Y0:y Z0: iBuffer.getpix(y,x)];
    [statusController labelX1:-1 Y1:-1 Z1: 0];
}


- (void) mouseDragged:(NSEvent *)theEvent{
    NSPoint point = [theEvent locationInWindow];
    endPoint = [self convertPoint:point fromView:nil];
    int x = endPoint.x;
    int y = self.frame.size.height - endPoint.y;
    if(x < 0) x = 0;
    if(x > self.frame.size.width-1) x = self.frame.size.width-1;
    if(y < 0) y = 0;
    if(y > self.frame.size.height -1)
        y = self.frame.size.height -1;
    
    float widthScale = iBitmap.getwidth()/self.frame.size.width;
    float heightScale = iBitmap.getheight()/self.frame.size.height;
    x *= widthScale;
    y *= heightScale;
    
    endRect.x = x;
    endRect.y = y;
    

    if(appController.tool < RECT)
        [statusController labelX0:x Y0:y Z0: iBuffer.getpix(y,x)];
    else
        [statusController labelX1:x Y1:y Z1: iBuffer.getpix(y,x)];
        
    [self setNeedsDisplay:YES];
}

- (void) mouseUp:(NSEvent *)theEvent{
    
    
    // remove restriction on the way a rectangle is defined
    // previously, the assumption was that all rectangles were defined from the upper left to lower right
    
    int x = endRect.x;
    int y = endRect.y;
    
    float widthScale = iBitmap.getwidth()/self.frame.size.width;
    float heightScale = iBitmap.getheight()/self.frame.size.height;
    x *= widthScale;
    y *= heightScale;
    
    if(endRect.x < startRect.x){
        endRect.x = startRect.x;
        startRect.x = x;
    }
    if(endRect.y < startRect.y){
        endRect.y = startRect.y;
        startRect.y = y;
    }
    
    switch  (appController.tool){     
        case CALCRECT:
            // in this implementation, this does not redefine the image rectangle
            // add calculation here
            point start,end;
            start.h = startRect.x;
            start.v = startRect.y;
            end.h = endRect.x;
            end.v = endRect.y;
            calc(start,end);
            
            break;
        case RECT:
            
            UIData.iRect.ul.h = startRect.x;
            UIData.iRect.ul.v = startRect.y;
            UIData.iRect.lr.h = endRect.x;
            UIData.iRect.lr.v = endRect.y;           
            
            break;
        case RULER:
            DATAWORD* buffervalues = iBuffer.getvalues();
            int* bufferspecs = iBuffer.getspecs();
            char* unit_text = iBuffer.getunit_text();
            float dist,dx,dy;
            extern char reply[];

            dx = -(startRect.x - endRect.x);
            dy = -(startRect.y - endRect.y);
            dist = sqrt( dx*dx + dy*dy);
            
            
            if( bufferspecs[HAS_RULER] ) {
                dist /= buffervalues[RULER_SCALE];
                dx /= buffervalues[RULER_SCALE];
                dy /= buffervalues[RULER_SCALE];
            }              
            printf("dx:\t%g\tdy:\t%g\tL:\t%g",dx,dy,dist);
            if( bufferspecs[HAS_RULER]!= 0  && unit_text[0]!=0 ){
                printf("\t%s\n",unit_text);
            } else {
                printf("\n");
            }
            
            free( buffervalues);
            free( bufferspecs);
            free( unit_text);
            
            break;
            
    }   
    
    mouse_down = 0;
}

@end
