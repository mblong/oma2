//
//  DataWindowController.h
//  oma2
//
//  Created by Marshall Long on 3/29/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DataView;

@interface DataWindowController : NSWindowController{
    NSString    *windowName;
    DataView    *__weak imageView;
    int         hasRowPlot;
    int         hasColPlot;
    
}

@property (copy) NSString *windowName;
@property (weak) IBOutlet DataView *imageView;
@property NSRect windowRect;
@property int         hasRowPlot;
@property int         hasColPlot;


-(void) placeImage: (NSRect) theRect;
-(void) placeRowLine: (int) theRow;
-(void) updateImage;

@end
