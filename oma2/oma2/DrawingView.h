//
//  DrawingView.h
//  oma2
//
//  Created by Marshall Long on 10/6/13.
//  Copyright (c) 2013 Yale University. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DrawingView : NSView{
    unsigned char* rowData;
    unsigned char* colData;
    int bytesPerRow;
    
}
@property unsigned char* rowData;
@property unsigned char* colData;
@property int bytesPerRow;


@end
