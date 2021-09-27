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
extern RGBColor color[256][8];

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
    
    if(bytesPerPlot < 0 ){    // a contour plot
        
        static short table[3][3][3]={{{0,0,8},{0,2,5},{7,6,9}},{{0,3,4},{1,3,1},{4,3,0}},{{9,6,7},{5,2,0},{8,0,0}}};
        
        short nt,nc,l,m,isignz[5],icase,m1,m2,m3;
        DATAWORD    imin,imax,iz;
        DATAWORD ctrmin,ctrmax;
        
        int  ctrclr[MAX_CONTOURS];
        
        // global?
        float truclevls[MAX_CONTOURS],clengths[MAX_CONTOURS];
        
        
        float dx[5];                //  = {0.,1.,1.,0.,0.5};
        float dy[5];                //  = {0.,0.,1.,1.,0.5};
        float dz[5],x1=0,x2=0,y1=0,y2=0;
        
        dx[0] = dx[3] = dy[0] = dy[1] = 0.;
        dx[1] = dx[2] = dy[2] = dy[3] = 1.0;
        dx[4] = dy[4] = 0.5;
        
        float ymax=self.window.frame.size.height- TITLEBAR_HEIGHT;
        float scalex = self.window.frame.size.width/(float)iBuffer.width();
        float scaley = ymax/iBuffer.height();
        
        
        NSPoint pt;
        
        
        if(UIData.minMaxFromData) {
            ctrmin = iBuffer.getvalue(MIN);
            ctrmax = iBuffer.getvalue(MAX);
        } else {
            ctrmin = UIData.cmin;
            ctrmax = UIData.cmax;
        }
        
        for(l=0; l<UIData.numberOfContours; l++) {
            truclevls[l] = UIData.contourLevels[l]*(ctrmax-ctrmin) + ctrmin;
            clengths[l] = 0.0;
            if(UIData.colorContours) {
                m = (truclevls[l] - UIData.cmin) * NCOLORS/(UIData.cmax-UIData.cmin);
                if(m > NCOLORS-1) m = NCOLORS-1;
                if(m < 0) m = 0;
                ctrclr[l] = m;
            }
        }
        for(int c =0; c < iBuffer.isColor()*2+1; c++){
            for(l=0; l< UIData.numberOfContours; l++) {
                NSBezierPath *path = [NSBezierPath bezierPath];
                [path setLineWidth:1.0];
                
                if(iBuffer.isColor()){
                    switch (c) {
                        case 0:
                            [[NSColor redColor] setStroke];
                            break;
                        case 1:
                            [[NSColor greenColor] setStroke];
                            break;
                        case 2:
                            [[NSColor blueColor] setStroke];
                            break;
                    }
                } else if(UIData.colorContours) {
                    //newpen_q(lgContext,ctrclr[l]) ;     // Pen color
                    float r=color[ctrclr[l]][UIData.thepalette].red/255.;
                    float g=color[ctrclr[l]][UIData.thepalette].green/255.;
                    float b=color[ctrclr[l]][UIData.thepalette].blue/255.;
                    NSColor *myColor = [NSColor colorWithCalibratedRed:r green:g blue:b alpha:1.0f];
                    [myColor setStroke];
                } else {
                    [[NSColor blackColor] setStroke];
                }
                iz=truclevls[l] ;
                
                // ****** The meat of it *********************
                for( nt=0; nt<=iBuffer.height()-2; nt++) {
                    int h = nt+c*iBuffer.height();
                    for(nc=0; nc<iBuffer.width()-1;nc++) {
                        //        Check values at corners of grid box
                        
                        imin = iBuffer.getpix(h,nc);
                        if (iBuffer.getpix(h,nc+1) < imin) imin=iBuffer.getpix(h,nc+1);
                        if (iBuffer.getpix(h+1,nc) <imin)  imin=iBuffer.getpix(h+1,nc);
                        if (iBuffer.getpix(h+1,nc+1)<imin) imin=iBuffer.getpix(h+1,nc+1);
                        imax=iBuffer.getpix(h,nc);
                        if (iBuffer.getpix(h,nc+1) > imax)   imax=iBuffer.getpix(h,nc+1);
                        if (iBuffer.getpix(h+1,nc) > imax)   imax=iBuffer.getpix(h+1,nc);
                        if (iBuffer.getpix(h+1,nc+1) > imax) imax=iBuffer.getpix(h+1,nc+1);
                        
                        //       If values not in right range, move to next box
                        if ((imax < truclevls[l]) || (imin > truclevls[l]))  continue;
                        
                        if (iz < imin) continue;
                        if (iz > imax) continue;
                        
                        //If box OK, draw where internal
                        //! triangles cut contour z planes
                        //!    3 *********** 2
                        //!    * *         * *
                        //!    *   *     *   *
                        //!    *      4      *
                        //!    *   *     *   *
                        //!    * *         * *
                        //!    0 *********** 1
                        dz[0]=iBuffer.getpix(h,nc)-iz;
                        dz[1]=iBuffer.getpix(h,nc+1)-iz;
                        dz[2]=iBuffer.getpix(h+1,nc+1)-iz;
                        dz[3]=iBuffer.getpix(h+1,nc)-iz;
                        dz[4]=(dz[1]+dz[2]+dz[3]+dz[0])/4.;
                        for(m=0; m<5; m++)
                            //Are points below/above z plane?
                            isignz[m]=(dz[m]<0) ? 0 :((dz[m]>0) ? 2 : 1);
                        
                        for(m=0; m<4; m++){            //! Look at each triangle in turn
                            m1=m;
                            m2=4;
                            m3=m+1;
                            if (m3==4) m3=0;
                            //             Lookup instructions:
                            icase=table[isignz[m3]][isignz[m2]][isignz[m1]];
                            switch(icase) {
                                case 1:
                                    x1=nc+dx[m1];          //!  Link 1,2
                                    y1=nt+dy[m1];
                                    x2=nc+dx[m2];
                                    y2=nt+dy[m2];
                                    break;
                                case 2:
                                    x1=nc+dx[m2];            //! Link 2,3
                                    y1=nt+dy[m2];
                                    x2=nc+dx[m3];
                                    y2=nt+dy[m3];
                                    break;
                                case 3:
                                    x1=nc+dx[m3];           //! Link 3,1
                                    y1=nt+dy[m3];
                                    x2=nc+dx[m1];
                                    y2=nt+dy[m1];
                                    break;
                                case 4:
                                    x1=nc+dx[m1];            //! Link 1, side 2-3
                                    y1=nt+dy[m1];
                                    x2=(dz[m3]*(nc+dx[m2])-dz[m2]*(nc+dx[m3]))/(dz[m3]-dz[m2]);
                                    y2=(dz[m3]*(nt+dy[m2])-dz[m2]*(nt+dy[m3]))/(dz[m3]-dz[m2]);
                                    break;
                                case 5:
                                    x1=nc+dx[m2];           //! Link 2, side 3-1
                                    y1=nt+dy[m2];
                                    x2=(dz[m1]*(nc+dx[m3])-dz[m3]*(nc+dx[m1]))/(dz[m1]-dz[m3]);
                                    y2=(dz[m1]*(nt+dy[m3])-dz[m3]*(nt+dy[m1]))/(dz[m1]-dz[m3]);
                                    break;
                                case 6:
                                    x1=nc+dx[m3];            //! Link 3, side 1-2
                                    y1=nt+dy[m3];
                                    x2=(dz[m2]*(nc+dx[m1])-dz[m1]*(nc+dx[m2]))/(dz[m2]-dz[m1]);
                                    y2=(dz[m2]*(nt+dy[m1])-dz[m1]*(nt+dy[m2]))/(dz[m2]-dz[m1]);
                                    break;
                                case 7:
                                    //! Link sides 1-2, 2-3
                                    x1=(dz[m2]*(nc+dx[m1])-dz[m1]*(nc+dx[m2]))/(dz[m2]-dz[m1]);
                                    y1=(dz[m2]*(nt+dy[m1])-dz[m1]*(nt+dy[m2]))/(dz[m2]-dz[m1]);
                                    x2=(dz[m3]*(nc+dx[m2])-dz[m2]*(nc+dx[m3]))/(dz[m3]-dz[m2]);
                                    y2=(dz[m3]*(nt+dy[m2])-dz[m2]*(nt+dy[m3]))/(dz[m3]-dz[m2]);
                                    break;
                                case 9:
                                    //! Link sides 2-3, 3-1
                                    x1=(dz[m3]*(nc+dx[m2])-dz[m2]*(nc+dx[m3]))/(dz[m3]-dz[m2]);
                                    y1=(dz[m3]*(nt+dy[m2])-dz[m2]*(nt+dy[m3]))/(dz[m3]-dz[m2]);
                                    x2=(dz[m1]*(nc+dx[m3])-dz[m3]*(nc+dx[m1]))/(dz[m1]-dz[m3]);
                                    y2=(dz[m1]*(nt+dy[m3])-dz[m3]*(nt+dy[m1]))/(dz[m1]-dz[m3]);
                                    break;
                                case 8:
                                    // Link sides 3-1, 1-2
                                    x1=(dz[m1]*(nc+dx[m3])-dz[m3]*(nc+dx[m1]))/(dz[m1]-dz[m3]);
                                    y1=(dz[m1]*(nt+dy[m3])-dz[m3]*(nt+dy[m1]))/(dz[m1]-dz[m3]);
                                    x2=(dz[m2]*(nc+dx[m1])-dz[m1]*(nc+dx[m2]))/(dz[m2]-dz[m1]);
                                    y2=(dz[m2]*(nt+dy[m1])-dz[m1]*(nt+dy[m2]))/(dz[m2]-dz[m1]);
                                case 0:
                                    break;
                                    
                            } // end of switch
                            if (icase != 0) {
                                //set(x1,y1);        // Put pen down
                                //dvect(x2,y2);        // Link to appropriate point
                                pt.x = x1*scalex;
                                pt.y = ymax-y1*scaley;
                                [path moveToPoint:pt];
                                pt.x=x2*scalex;
                                pt.y=ymax-y2*scaley;
                                [path lineToPoint:pt];
                                
                                //printf("%f\t%f\n",x1,y1);
                                clengths[l] += sqrt((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2));
                                
                            }
                        }     // Next triangle to consider
                    }     // Next Channel
                }     // Next Track
                [path stroke];
            }      // Next contour level
        }       // Next color
        return;
    }
    
    
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
