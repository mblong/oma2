//
//  DataView.h
//  oma2
//
//  Created by Marshall Long on 4/19/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#import <AppKit/AppKit.h>

@class DrawingWindowController;

@interface DataView : NSImageView{
    NSPoint startPoint,endPoint;
    NSPoint startRect,endRect;
    int mouse_down;
    int rowLine;
    int colLine;
    int eraseLines;
    int degrees;
    float zoom;

    DrawingWindowController *rowWindowController;
    DrawingWindowController *colWindowController;
    
    NSMutableArray *labelArray;
}

@property int rowLine;  // this is the window row
@property int colLine;  // this is the window column
@property DrawingWindowController *rowWindowController;
@property DrawingWindowController *colWindowController;
@property int eraseLines;
@property NSString *minMax;
@property NSString *minMax2;
@property NSMutableArray *labelArray;
@property int degrees;
@property float zoom;

-(void) addItem: (NSObject*) theItem;
-(void) setAlpha: (float) newAlpha;
@end

