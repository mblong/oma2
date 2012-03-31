//
//  DataWindowController.h
//  oma2
//
//  Created by Marshall Long on 3/29/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DataWindowController : NSWindowController{
    NSString    *windowName;
    NSImageView *imageView;
}

@property (copy) NSString *windowName;


@property (assign) IBOutlet NSImageView *imageView;

-(void) placeImage;

@end