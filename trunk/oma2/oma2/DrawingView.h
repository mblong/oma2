//
//  DrawingView.h
//  oma2
//
//  Created by Marshall Long on 10/6/13.
//  Copyright (c) 2013 Yale University. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DrawingView : NSView

@property NSData* rowData;
@property NSData* colData;
@property int bytesPerRow;
@property int pixPerPt;


@end
