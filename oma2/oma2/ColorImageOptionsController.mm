//
//  colorImageOptionsController.m
//  oma2
//
//  Created by Marshall Long on 3/16/21.
//  Copyright © 2021 Yale University. All rights reserved.
//

#import "ColorImageOptionsController.h"
extern oma2UIData UIData;
extern AppController *appController;

@interface ColorImageOptionsController ()

@end

@implementation ColorImageOptionsController

- (void)windowDidLoad {
    [super windowDidLoad];
    [_redGammaSlideValue setFloatValue: 2*log(UIData.redGamma)/log(CSF)];
    [_greenGammaSlideValue setFloatValue: 2*log(UIData.greenGamma)/log(CSF)];
    [_blueGammaSlideValue setFloatValue: 2*log(UIData.blueGamma)/log(CSF)];
    [_redGammaLabel setTitle:
     [NSString stringWithFormat: @"Red Gamma: %.2f",UIData.redGamma]];
    [_redGammaLabel display];
    [_greenGammaLabel setTitle:
     [NSString stringWithFormat: @"Green Gamma: %.2f",UIData.greenGamma]];
    [_greenGammaLabel display];
    [_blueGammaLabel setTitle:
     [NSString stringWithFormat: @"Blue Gamma: %.2f",UIData.blueGamma]];
    [_blueGammaLabel display];

    [_redSlideValue setFloatValue: 2*log(UIData.r_scale)/log(CSF)];
    [_greenSlideValue setFloatValue: 2*log(UIData.g_scale)/log(CSF)];
    [_blueSlideValue setFloatValue: 2*log(UIData.b_scale)/log(CSF)];
    
    [_redMultiplierLabel setTitle:
     [NSString stringWithFormat: @"Blue Multiplier: %.2f",UIData.r_scale]];
    [_redMultiplierLabel display];
    [_greenMultiplierLabel setTitle:
     [NSString stringWithFormat: @"Blue Multiplier: %.2f",UIData.g_scale]];
    [_greenMultiplierLabel display];
    [_blueMultiplierLabel setTitle:
     [NSString stringWithFormat: @"Blue Multiplier: %.2f",UIData.b_scale]];
    [_blueMultiplierLabel display];




    
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)multiplyRGB:(id)sender {
    
    char values[128];
    sprintf(values,"%f %f %f", UIData.r_scale, UIData.g_scale, UIData.b_scale );
    mulRGB_c(0, values);
    
    [_redSlideValue setFloatValue: 0.0];
    UIData.r_scale = 1.0;
    [_greenSlideValue setFloatValue: 0.0];
    UIData.g_scale = 1.0;
    [_blueSlideValue setFloatValue: 0.0];
    UIData.b_scale = 1.0;
    
    [_redMultiplierLabel setTitle:
     [NSString stringWithFormat: @"Blue Multiplier: %.2f",UIData.r_scale]];
    [_redMultiplierLabel display];
    [_greenMultiplierLabel setTitle:
     [NSString stringWithFormat: @"Blue Multiplier: %.2f",UIData.g_scale]];
    [_greenMultiplierLabel display];
    [_blueMultiplierLabel setTitle:
     [NSString stringWithFormat: @"Blue Multiplier: %.2f",UIData.b_scale]];
    [_blueMultiplierLabel display];


    [appController updateDataWindow];
}

    // note that _redMultiplierLabel seems to be shorthand for [self redMultiplierLabel]

- (IBAction)setRedMultiplier:(id)sender {
    UIData.r_scale = pow(CSF,[_redSlideValue floatValue]/2);
    
    [[self redMultiplierLabel] setTitle:
     [NSString stringWithFormat: @"Red Multiplier: %.2f",UIData.r_scale]];
    [_redMultiplierLabel display];
    
    [appController updateDataWindow];
    
}

- (IBAction)setGreenMultiplier:(id)sender {
    UIData.g_scale = pow(CSF,[_greenSlideValue floatValue]/2);
    [_greenMultiplierLabel setTitle:
     [NSString stringWithFormat: @"Green Multiplier: %.2f",UIData.g_scale]];
    [_greenMultiplierLabel display];
    
    [appController updateDataWindow];

}

- (IBAction)setBlueMultiplier:(id)sender {
    UIData.b_scale = pow(CSF,[_blueSlideValue floatValue]/2);
    [_blueMultiplierLabel setTitle:
     [NSString stringWithFormat: @"Blue Multiplier: %.2f",UIData.b_scale]];
    [_blueMultiplierLabel display];
    
    [appController updateDataWindow];

}

- (IBAction)resetRGBmultipliers:(id)sender {
    [_redSlideValue setFloatValue: 0.0];
    UIData.r_scale = 1.0;
    [_greenSlideValue setFloatValue: 0.0];
    UIData.g_scale = 1.0;
    [_blueSlideValue setFloatValue: 0.0];
    UIData.b_scale = 1.0;
    
    [_redMultiplierLabel setTitle:
     [NSString stringWithFormat: @"Red Multiplier: %.2f",UIData.r_scale]];
    [_redMultiplierLabel display];
    [_greenMultiplierLabel setTitle:
     [NSString stringWithFormat: @"Green Multiplier: %.2f",UIData.g_scale]];
    [_greenMultiplierLabel display];
    [_blueMultiplierLabel setTitle:
     [NSString stringWithFormat: @"Blue Multiplier: %.2f",UIData.b_scale]];
    [_blueMultiplierLabel display];


    [appController updateDataWindow];
}

- (void)keyDown:(NSEvent *)anEvent{
    [[appController theWindow] sendEvent: anEvent];
}
- (IBAction)setRedGamma:(id)sender {
    UIData.redGamma = pow(CSF,[_redGammaSlideValue floatValue]/2);
    
    [_redGammaLabel setTitle:
     [NSString stringWithFormat: @"Red Gamma: %.2f",UIData.redGamma]];
    [_redGammaLabel display];
    
    if([_lockGammaValue state]){
        UIData.greenGamma = pow(CSF,[_redGammaSlideValue floatValue]/2);
        [_greenGammaLabel setTitle:
         [NSString stringWithFormat: @"Green Gamma: %.2f",UIData.greenGamma]];
        [_greenGammaSlideValue setFloatValue:[_redGammaSlideValue floatValue]];
        [_greenGammaLabel display];
        
        
        UIData.blueGamma = pow(CSF,[_redGammaSlideValue floatValue]/2);
        [_blueGammaLabel setTitle:
         [NSString stringWithFormat: @"Blue Gamma: %.2f",UIData.blueGamma]];
        [_blueGammaSlideValue setFloatValue:[_redGammaSlideValue floatValue]];
        [_blueGammaLabel display];
    }
    
    [appController updateDataWindow];

}
- (IBAction)setGreenGamma:(id)sender {
    UIData.greenGamma = pow(CSF,[_greenGammaSlideValue floatValue]/2);
    
    [_greenGammaLabel setTitle:
     [NSString stringWithFormat: @"Green Gamma: %.2f",UIData.greenGamma]];
    [_greenGammaLabel display];
    
    if([_lockGammaValue state]){
        UIData.redGamma = pow(CSF,[_greenGammaSlideValue floatValue]/2);
        [_redGammaLabel setTitle:
         [NSString stringWithFormat: @"Red Gamma: %.2f",UIData.redGamma]];
        [_redGammaSlideValue setFloatValue:[_greenGammaSlideValue floatValue]];
        [_redGammaLabel display];
        
        
        UIData.blueGamma = pow(CSF,[_redGammaSlideValue floatValue]/2);
        [_blueGammaLabel setTitle:
         [NSString stringWithFormat: @"Blue Gamma: %.2f",UIData.blueGamma]];
        [_blueGammaSlideValue setFloatValue:[_greenGammaSlideValue floatValue]];
        [_blueGammaLabel display];
    }

    [appController updateDataWindow];

}
- (IBAction)setBlueGamma:(id)sender {
    UIData.blueGamma = pow(CSF,[_blueGammaSlideValue floatValue]/2);
    
    [_blueGammaLabel setTitle:
     [NSString stringWithFormat: @"Blue Gamma: %.2f",UIData.blueGamma]];
    [_blueGammaLabel display];
    
    if([_lockGammaValue state]){
        UIData.greenGamma = pow(CSF,[_redGammaSlideValue floatValue]/2);
        [_greenGammaLabel setTitle:
         [NSString stringWithFormat: @"Green Gamma: %.2f",UIData.greenGamma]];
        [_greenGammaSlideValue setFloatValue:[_blueGammaSlideValue floatValue]];
        [_greenGammaLabel display];
        
        
        UIData.redGamma = pow(CSF,[_blueGammaSlideValue floatValue]/2);
        [_redGammaLabel setTitle:
         [NSString stringWithFormat: @"Red Gamma: %.2f",UIData.redGamma]];
        [_redGammaSlideValue setFloatValue:[_blueGammaSlideValue floatValue]];
        [_redGammaLabel display];
    }
    
    [appController updateDataWindow];

}
- (IBAction)lockGammas:(id)sender {
    
}
- (IBAction)applyGamma:(id)sender {
    char values[128];
    sprintf(values,"%f %f %f", 1./UIData.redGamma,1./UIData.greenGamma,1./UIData.blueGamma );
    powRGB_c(0, values);
    [self resetGamma:sender];
}
- (IBAction)resetGamma:(id)sender {
    [_redGammaSlideValue setFloatValue: 0.0];
    UIData.redGamma = 1.0;
    [_greenGammaSlideValue setFloatValue: 0.0];
    UIData.greenGamma = 1.0;
    [_blueGammaSlideValue setFloatValue: 0.0];
    UIData.blueGamma = 1.0;
    
    [_redGammaLabel setTitle:
     [NSString stringWithFormat: @"Red Gamma: %.2f",UIData.redGamma]];
    [_redGammaLabel display];
    [_greenGammaLabel setTitle:
     [NSString stringWithFormat: @"Green Gamma: %.2f",UIData.greenGamma]];
    [_greenGammaLabel display];
    [_blueGammaLabel setTitle:
     [NSString stringWithFormat: @"Blue Gamma: %.2f",UIData.blueGamma]];
    [_blueGammaLabel display];

    [appController updateDataWindow];
}

@end
