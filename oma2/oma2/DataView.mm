
//
//  DataView.m
//  oma2
//
//  Created by Marshall Long on 4/19/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#import "DataView.h"
#import "AppController.h"
#import "DrawingWindowController.h"
#import "ImageBitmap.h"
#import "UI.h"
#import "sep.h"
#import "oma2.h"


extern ImageBitmap iBitmap;
extern Image iBuffer;
extern AppController* appController; 
extern oma2UIData UIData;
extern sep_catalog* catalog;



@implementation DataView

@synthesize rowLine;
@synthesize colLine;
@synthesize rowWindowController;
@synthesize colWindowController;
@synthesize eraseLines;
@synthesize minMax;
@synthesize minMax2;
//@synthesize theLabel;
@synthesize labelArray;
@synthesize degrees;
@synthesize zoom;

@synthesize selectedIndex;


- (void)drawRect:(NSRect)dirtyRect{
    [super drawRect:dirtyRect];         // crash here when resizing data window that is not the current one [or when printing an image not the last one displayed]
    
    if (!eraseLines) {
        if (mouse_down) {
            
            // only want to do this if mouse is pressed --
            // without this condition, this gets done for every DISPLAY command
            
            //tools are: CROSS,SELRECT,CALCRECT,RULER,LINEPLOT
            NSBezierPath *path = [NSBezierPath bezierPath];
            [[NSColor grayColor] set];
            [path setLineWidth:2.0];
            
            switch  (appController.tool){
                case CALCRECT:
                case SELRECT:
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
        if (rowLine >= 0) {
            NSBezierPath *path = [NSBezierPath bezierPath];
            [[NSColor grayColor] set];
            [path setLineWidth:2.0];
            NSPoint pt;
            pt.x = 0.;
            pt.y = rowLine;
            [path moveToPoint:pt];
            pt.x = [self frame].size.width -1;
            [path lineToPoint:pt];
            [path stroke];
        }
        if (colLine >= 0) {
            NSBezierPath *path = [NSBezierPath bezierPath];
            [[NSColor grayColor] set];
            [path setLineWidth:2.0];
            NSPoint pt;
            pt.x = colLine;
            pt.y = 0.;
            [path moveToPoint:pt];
            pt.y = [self frame].size.height -1;
            [path lineToPoint:pt];
            [path stroke];
        }
    }

    NSMutableDictionary *stringAttributes = [[NSMutableDictionary alloc] init];
    [stringAttributes setValue:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
    [stringAttributes setValue:[NSColor whiteColor] forKey:NSBackgroundColorAttributeName];
    [stringAttributes setValue:[NSFont fontWithName:@"Monaco" size:16] forKey:NSFontAttributeName];
    
    
    // loop over the numbered labels
    for(int i=0; i<[labelArray count]; i+=2){
        NSPoint thePoint;
        thePoint.x = 10;
        //thePoint.y = dirtyRect.size.height  - 20*([labelArray[i+1] intValue]+1);
        thePoint.y = self.window.contentView.visibleRect.size.height - 20*([labelArray[i+1] intValue]+1);
        [labelArray[i] drawAtPoint:thePoint withAttributes:stringAttributes];
    }
    
    if (minMax) {
        NSPoint thePoint;
        thePoint.x = 10;
        thePoint.y = 25;
        [minMax drawAtPoint:thePoint withAttributes:stringAttributes];
        thePoint.y = 5;
        [minMax2 drawAtPoint:thePoint withAttributes:stringAttributes];
    }
    
    if(catalog){
        float scalex = self.frame.size.width/iBitmap.getwidth();
        float scaley = self.frame.size.height/iBitmap.getheight();
        float wh=[self frame].size.height ;
        NSColor *myColor = [NSColor colorWithCalibratedRed:UIData.highlightSaturatedRed/255. green:UIData.highlightSaturatedGreen/255. blue:UIData.highlightSaturatedBlue/255. alpha:1.0f];


        for(int i=0; i< catalog->nobj;i++){
            if(catalog->flag[i] != SEP_OBJ_EXCLUDE){
                NSBezierPath *path = [NSBezierPath bezierPath];
                [myColor set];
                [path setLineWidth:2.0];
                //float scalex = self.frame.size.width/iBitmap.getwidth();
                //float scaley = self.frame.size.height/iBitmap.getheight();
                //float wh=[self frame].size.height ;
                float x0 = catalog->x[i]-catalog->a[i];
                float y0 = wh - (catalog->y[i]+catalog->b[i]);
                float w = 2*catalog->a[i]*scalex;
                float h = 2*catalog->b[i]*scaley;
                x0 *= scalex;
                y0 *= scaley;
                [path appendBezierPathWithOvalInRect:
                 NSMakeRect(x0,y0,w,h)];
                
                NSAffineTransform *transform = [NSAffineTransform transform];
                [transform translateXBy: catalog->x[i]*scalex yBy:  wh - (catalog->y[i])*scaley];
                [transform rotateByRadians:-catalog->theta[i]];
                [transform translateXBy: -catalog->x[i]*scalex yBy: -(wh - (catalog->y[i]))*scaley];
                [path transformUsingAffineTransform: transform];
                
                [path stroke];
            }
            if(selectedIndex >= 0){
                NSMutableDictionary *stringAttributes = [[NSMutableDictionary alloc] init];
                 [stringAttributes setValue: myColor forKey:NSForegroundColorAttributeName];
                 [stringAttributes setValue:[NSFont fontWithName:@"Monaco" size:10] forKey:NSFontAttributeName];

                float scalex = self.frame.size.width/iBitmap.getwidth();
                float scaley = self.frame.size.height/iBitmap.getheight();
                float wh=[self frame].size.height ;

                NSString *label =[NSString stringWithFormat:@"Size: %.2f\nEllip: %.2f\nFlux: %.1e\n",catalog->a[selectedIndex] + catalog->b[selectedIndex], (catalog->a[selectedIndex] - catalog->b[selectedIndex])/catalog->a[selectedIndex], catalog->flux[selectedIndex]];
                NSPoint startPoint;
                startPoint.x = catalog->x[selectedIndex]*scalex+10;
                if(startPoint.x + 80 >= self.frame.size.width)
                    startPoint.x = catalog->x[selectedIndex]*scalex - 90;
                startPoint.y = wh - catalog->y[selectedIndex]*scaley-35;
                //NSDictionary *attributes = @{ NSForegroundColorAttributeName : [NSColor textColor]};
                [label drawAtPoint:startPoint withAttributes: stringAttributes];
                

            }
        }
        
    }


}

- (void) addItem: (NSObject*) theItem{
    if(!labelArray){
        labelArray = [[NSMutableArray alloc] init];
    }
    [labelArray addObject: theItem];
}

- (void) mouseDown:(NSEvent *)theEvent{
    extern int last_x_val,last_y_val;
    
    // toggle alpha if right click
    /*
    if ([theEvent modifierFlags] & 1){              // need to figure out the name of this constant
        if ([[theEvent window] alphaValue] == 1.0)
            [[theEvent window] setAlphaValue:UIData.alphaValue];
        else
            [[theEvent window] setAlphaValue:1.0];
    }
     */
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
    
    if (rowLine >= 0){
        int newLine = self.frame.size.height-y/heightScale;
        if (rowLine != newLine){
            [rowWindowController updateRowDrawing:y/heightScale];
            /*
            if(rowLine > newLine){
                [rowWindowController updateRowDrawing:y/heightScale];
            }else{
                if (y<=0) y=1;
                [rowWindowController updateRowDrawing:(y-1)/heightScale];
            }
            */
            rowLine = newLine;
        }
    }
    
    if (colLine >= 0){
        int newLine = x/widthScale;
        if (colLine != newLine){
            [colWindowController updateColDrawing:x/widthScale];
            /*
             if(colLine > newLine){
             if (x<=0) x=1;
             [colWindowController updateColDrawing:x-1/heightScale];
             }else{
             [colWindowController updateColDrawing:x/heightScale];
             }
             */
            colLine = newLine;
        }
    }
    if(catalog ){
        if(appController.tool == CROSS){
            float dist,minDist;
            int minIndex,i=0;
            int x = startRect.x;
            int y = startRect.y;
            while(catalog->flag[i] == SEP_OBJ_EXCLUDE) i++; // skip past any excluded items
            minDist = pow(x-catalog->x[i],2) + pow(y-catalog->y[i],2);
            minIndex = i;
            for(int j=i+1; j<catalog->nobj; j++){
                dist = pow(x-catalog->x[j],2) + pow(y-catalog->y[j],2);
                if(dist < minDist && catalog->flag[j] != SEP_OBJ_EXCLUDE){
                    minDist = dist;
                    minIndex = j;
                }
            }
            printf("Size: %.2f  Ellipticity: %.2f Flux: %.1e\n",catalog->a[minIndex] + catalog->b[minIndex], (catalog->a[minIndex] - catalog->b[minIndex])/catalog->a[minIndex], catalog->flux[minIndex]);
            
            selectedIndex = minIndex;
            [self setNeedsDisplay:YES];

        } else {
            selectedIndex = -1;
        }
    }

    [statusController labelX0:x Y0:y Z0: iBuffer.getpix(y,x)];
    [statusController labelX1:-1 Y1:-1 Z1: 0];
    last_x_val = x;
    last_y_val = y;
}


- (void) mouseDragged:(NSEvent *)theEvent{
    extern int last_x_val,last_y_val;
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
    
    last_x_val = x;
    last_y_val = y;

    if(appController.tool < SELRECT)
        [statusController labelX0:x Y0:y Z0: iBuffer.getpix(y,x)];
    else
        [statusController labelX1:x Y1:y Z1: iBuffer.getpix(y,x)];
    
    if (rowLine >= 0){
        int newLine = self.frame.size.height-y/heightScale;
        if (rowLine != newLine){
            [rowWindowController updateRowDrawing:y/heightScale];
            /*
             if(rowLine > newLine){
             [rowWindowController updateRowDrawing:y/heightScale];
             }else{
             if (y<=0) y=1;
             [rowWindowController updateRowDrawing:(y-1)/heightScale];
             }
             */
            rowLine = newLine;
        }
    }
    if (colLine >= 0){
        int newLine = x/widthScale;
        if (colLine != newLine){
            [colWindowController updateColDrawing:x/widthScale];
            colLine = newLine;
        }
    }
    
    [self setNeedsDisplay:YES];
}

- (void) mouseUp:(NSEvent *)theEvent{
    
    startPoint = startRect;
    endPoint = endRect;
    // remove restriction on the way a rectangle is defined
    // previously, the assumption was that all rectangles were defined from the upper left to lower right
    
    int x = endRect.x;
    int y = endRect.y;
    
    //float widthScale = iBitmap.getwidth()/self.frame.size.width;
    //float heightScale = iBitmap.getheight()/self.frame.size.height;
    //x *= widthScale;
    //y *= heightScale;
    
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
            // add calculation here
            point start,end;
            start.h = startRect.x;
            start.v = startRect.y;
            end.h = endRect.x;
            end.v = endRect.y;
            printf("\n");
            calc(start,end);
            
            //break;    // in this implementation, this does redefine the image rectangle

        case SELRECT:
            
            UIData.iRect.ul.h = startRect.x;
            UIData.iRect.ul.v = startRect.y;
            UIData.iRect.lr.h = endRect.x;
            UIData.iRect.lr.v = endRect.y;           
            
            break;
        case RULER:{
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
        case LINEPLOT:
            [appController plotLineFrom: startPoint To: endPoint];
            
            break;

            
    }
    mouse_down = 0;
    
}

- (void) rightMouseDown:(NSEvent *)theEvent{
    
    NSUInteger flags = theEvent.modifierFlags;
    if( flags & NSEventModifierFlagCommand){
        if(degrees != 0){
            char args[128];
            sprintf(args,"%d",degrees);
            rotate_c(degrees,args);
            printf("Current image rotated by %d degrees.\nOMA2>",degrees);
            sprintf(args,"Rotated: %d degrees",degrees);
            display(0,args);
            return;
        }
    }
    
    if ([[theEvent window] alphaValue] == 1.0)
        [[theEvent window] setAlphaValue:UIData.alphaValue];
    else
        [[theEvent window] setAlphaValue:1.0];
}

- (void) setAlpha: (float) newAlpha{
    [[self window] setAlphaValue:newAlpha];
    
}

- (void) scrollWheel: (NSEvent *)theEvent{
    
    NSUInteger flags = theEvent.modifierFlags;
    if( flags & NSEventModifierFlagCommand){
        
        degrees=0; // clear rotation if we are zooming
        
        if( [theEvent scrollingDeltaY] >0)
            zoom*=1.05;
        else
            zoom/=1.05;

        NSBitmapImageRep* bitmap = [[NSBitmapImageRep alloc]
                                    initWithBitmapDataPlanes: nil
                                    pixelsWide: iBitmap.getwidth() pixelsHigh: iBitmap.getheight()
                                    bitsPerSample: 8 samplesPerPixel: 3 hasAlpha: NO isPlanar:NO
                                    colorSpaceName:NSDeviceRGBColorSpace
                                    bytesPerRow: 3*iBitmap.getwidth()
                                    bitsPerPixel: 24];
        
        memcpy([bitmap  bitmapData], iBitmap.getpixdata(), iBitmap.getheight()*iBitmap.getwidth()*3);

        NSImage *image = [[NSImage alloc] init];
        [image addRepresentation:bitmap];
        
        float zx,zy,wx,hy;
        
        wx = self.window.contentView.visibleRect.size.width;
        hy = self.window.contentView.visibleRect.size.height;
        zx = (1.-zoom)*wx;
        zy = (1.-zoom)*hy;
        //printf("zoom: %f\n",zoom);
        NSRect newRect = NSMakeRect(zx*startPoint.x/iBitmap.getwidth(),zy*(1.-startPoint.y/iBitmap.getheight()), wx-zx,hy-zy);
        
        [self setFrame:newRect];       // this is a must
        //[self setImageScaling:NSImageScaleNone];
        //[self setImageScaling:NSImageScaleProportionallyUpOrDown];
        [self setImageScaling:NSImageScaleAxesIndependently];
        [self setImage:image];
        [self display];
        return;
    }
    
    zoom=1.0;     // clear zoom if we are rotating
    
    if( [theEvent scrollingDeltaY] >0)
        degrees--;
    else
        degrees++;
    
    CGFloat angle = degrees * M_PI / 180.0, dx,dy,dx1,dy1;

    // uses the data in the current image buffer
    // should really be sure that this only applies to the window associated with iBuffer
    
    NSBitmapImageRep* bitmap = [[NSBitmapImageRep alloc]
                                initWithBitmapDataPlanes: nil
                                pixelsWide: iBitmap.getwidth() pixelsHigh: iBitmap.getheight()
                                bitsPerSample: 8 samplesPerPixel: 3 hasAlpha: NO isPlanar:NO
                                colorSpaceName:NSDeviceRGBColorSpace
                                bytesPerRow: 3*iBitmap.getwidth()
                                bitsPerPixel: 24];
    
    memcpy([bitmap  bitmapData], iBitmap.getpixdata(), iBitmap.getheight()*iBitmap.getwidth()*3);
    CIImage *ciImage = [[CIImage alloc] initWithBitmapImageRep:bitmap];
    // sizes of original bitmap image
    dx = iBitmap.getwidth()/2;
    dy = iBitmap.getheight()/2;


    NSImage *image = [[NSImage alloc] init];
    
    /*
    // this attempt to use the image asociated with this window didn't work properly
    image = [self image];
    NSData* tiffData = [image TIFFRepresentation];
    NSBitmapImageRep* bitmap2;
    bitmap2 = [NSBitmapImageRep imageRepWithData:tiffData];
    CIImage *ciImage = [[CIImage alloc] initWithBitmapImageRep:bitmap2];
    dx = self.window.contentLayoutRect.size.width/2;
    dy = self.window.contentLayoutRect.size.height/2;
    */
    
    // rotated image sizes
    dx1 = (self.window.contentLayoutRect.size.width * fabs(cos(angle)) + self.window.contentLayoutRect.size.height * fabs(sin(angle)))/2;
    dy1 = (self.window.contentLayoutRect.size.width * fabs(sin(angle)) + self.window.contentLayoutRect.size.height * fabs(cos(angle)))/2;
    

    NSRect newRect = NSMakeRect(0,0, dx1*2,dy1*2);
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(dx,dy);
    transform = CGAffineTransformRotate(transform, angle);
    transform = CGAffineTransformTranslate(transform,-dx,-dy);
    
    CIImage *output = [ciImage imageByApplyingTransform:transform];

    [image addRepresentation:[NSCIImageRep imageRepWithCIImage:output]];
    
    [self setFrame:newRect];       // this is a must
    [self setImageScaling:NSImageScaleAxesIndependently];
    [self setImage:image];

    [self display];

    
}

@end
