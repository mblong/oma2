//
//  PreviewProvider.h
//  oma2Quicklook
//
//  Created by Marshall Long on 11/23/24.
//  Copyright © 2024 Yale University. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <AppKit/AppKit.h>

#include "QLimage.h"
#include "QLImageBitmap.h"
//#include "oma2.h"

@interface PreviewProvider : QLPreviewProvider <QLPreviewingController>

- (NSImage *)imageWithTextOverlay:(NSImage *)image text:(NSString *)text;
@end
