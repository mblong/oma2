//
//  DrawingView.h
//  oma2
//
//  Created by Marshall Long on 10/6/13.
//  Copyright (c) 2013 Yale University. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DrawingView : NSView{
    NSData* rowData;
    NSData* colData;
    int theRow;
    int theCol;
    int bytesPerRow;
    int pixPerPt;
    int isColor;
    float heightScale;
    float widthScale;
 
}

@property NSData* rowData;
@property NSData* colData;
@property int theRow;
@property int theCol;
@property int bytesPerRow;
@property int pixPerPt;
@property int isColor;
@property float heightScale;
@property float widthScale;


@end
