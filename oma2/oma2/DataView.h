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
    DrawingWindowController *drawingWindowController;
}

@property int rowLine;
@property int colLine;
@property DrawingWindowController *drawingWindowController;
@end

