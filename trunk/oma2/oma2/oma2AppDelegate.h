//
//  oma2AppDelegate.h
//  oma2
//
//  Created by Marshall Long on 3/20/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class StatusController;


@interface oma2AppDelegate : NSObject <NSApplicationDelegate>{
    StatusController    *statusController;
}

@property (assign) IBOutlet NSWindow *window;

@end
