//
//  HistogramView.h
//  oma2
//
//  Created by Marshall Long on 8/30/22.
//  Copyright © 2022 Yale University. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "UI.h"


//NS_ASSUME_NONNULL_BEGIN

@interface HistogramView : NSView{
    float cminIndex;
    float cmaxIndex;
    char dragCmin;
    float yScale;
    char zoomX;
}

@property float yScale;
@property char zoomX;

@end


//NS_ASSUME_NONNULL_END
