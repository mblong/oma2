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
}

@property (copy) NSString *windowName;
@property (weak) IBOutlet DataView *imageView;

-(void) placeImage;
-(void) updateImage;

@end
