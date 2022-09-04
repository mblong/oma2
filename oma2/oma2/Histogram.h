//
//  Histogram.h
//  oma2
//
//  Created by Marshall Long on 8/29/22.
//  Copyright © 2022 Yale University. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Histogram;
@class HistogramView;

#import "HistogramView.h"
#import "AppController.h"
#include "UI.h"



//NS_ASSUME_NONNULL_BEGIN

@interface Histogram : NSWindowController{
    float yScale;
    char zoomX;
}

@property (weak) IBOutlet HistogramView *histogramView;
@property (weak) IBOutlet NSTextField *MinLabel;
@property (weak) IBOutlet NSTextField *MaxLabel;
@property (weak) IBOutlet NSTextField *MidLabel;
@property (weak) IBOutlet NSButton *toggleZoomX;
@property (weak) IBOutlet NSTextField *cminLabel;
@property (weak) IBOutlet NSTextField *cmaxLabel;

- (void)updateHistogram;

@end

//NS_ASSUME_NONNULL_END
