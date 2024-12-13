//
//  PreviewViewController.m
//  oma2Quicklook
//
//  Created by Marshall Long on 11/23/24.
//  Copyright © 2024 Yale University. All rights reserved.
//

#import "PreviewViewController.h"
#import <Quartz/Quartz.h>

@interface PreviewViewController () <QLPreviewingController>
    
@end

@implementation PreviewViewController

- (NSString *)nibName {
    return @"PreviewViewController";
}

- (void)loadView {
    [super loadView];
    NSLog(@"loadView\n ");
    // Do any additional setup after loading the view.
}

/*
 * Implement this method and set QLSupportsSearchableItems to YES in the Info.plist of the extension if you support CoreSpotlight.
 *
- (void)preparePreviewOfSearchableItemWithIdentifier:(NSString *)identifier queryString:(NSString *)queryString completionHandler:(void (^)(NSError * _Nullable))handler {
    
    // Perform any setup necessary in order to prepare the view.
    
    // Call the completion handler so Quick Look knows that the preview is fully loaded.
    // Quick Look will display a loading spinner while the completion handler is not called.

    handler(nil);
}
*/

- (void)preparePreviewOfFileAtURL:(NSURL *)url completionHandler:(void (^)(NSError * _Nullable))handler {
    
    // Add the supported content types to the QLSupportedContentTypes array in the Info.plist of the extension.
    
    // Perform any setup necessary in order to prepare the view.
    
    // Call the completion handler so Quick Look knows that the preview is fully loaded.
    // Quick Look will display a loading spinner while the completion handler is not called.
    NSError *theErr = nil;
    NSStringEncoding stringEncoding;
    NSString *fileString = [NSString stringWithContentsOfURL:url usedEncoding:&stringEncoding error:&theErr];
    NSLog(@"prepare\n");
    
    
    //[providePreviewForFileRequest:(QLFilePreviewRequest *)request completionHandler:handler];
    
    
    
    handler(nil);
}

@end

