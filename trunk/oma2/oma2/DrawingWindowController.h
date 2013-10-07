//
//  DrawingWindowController.h
//  oma2
//
//  Created by Marshall Long on 10/6/13.
//  Copyright (c) 2013 Yale University. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DrawingView;

@interface DrawingWindowController : NSWindowController{
    NSString    *windowName;
    DrawingView    *__weak drawingView;

}

@property (copy) NSString *windowName;
@property (weak) IBOutlet DrawingView *drawingView;
@property NSRect windowRect;

//-(void) placeDrawing: (NSRect) theRect;
-(void) placeDrawing: (NSRect) theLocation fromRect:(NSRect) dataRect;
@end
