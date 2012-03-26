//
//  AppController.h
//  tst2
//
//  Created by Marshall Long on 3/20/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PreferenceController;

@interface AppController : NSObject{
    
    PreferenceController *preferenceController;
    
}


- (IBAction)showPrefs:(id)sender;
    
@end

