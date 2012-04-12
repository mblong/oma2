//
//  StatusController.h
//  tst2
//
//  Created by Marshall Long on 3/20/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface StatusController : NSWindowController{
    int tool_selected;
    int MinMaxInc;
    //NSButton *scaleState;
    //BOOL Update;
    
}


// Min/Max Increment outlets
@property int MinMaxInc;

// Color Min and Max values
@property (assign) IBOutlet NSTextField *ColorMinLabel;
@property (assign) IBOutlet NSTextField *ColorMaxLabel;

- (IBAction)scaleCheckbox:(id)sender;
@property (assign) IBOutlet NSButton *scaleState;

- (IBAction)updateCheckbox:(id)sender;
@property (assign) IBOutlet NSButton *updateState;



// Tool selection
- (IBAction)selectTool:(id)sender;
@property (assign) IBOutlet NSMatrix *toolSelected;


// Color Min/Max "-" and "+" buttons
- (IBAction)decreaseColorMin:(id)sender;
- (IBAction)increaseColorMin:(id)sender;
- (IBAction)decreaseColorMax:(id)sender;
- (IBAction)increaseColorMax:(id)sender;


- (void) labelColorMinMax;

-(id) whoami;

@end
