  //
//  PreviewProvider.m
//  oma2Quicklook
//
//  Created by Marshall Long on 11/23/24.
//  Copyright © 2024 Yale University. All rights reserved.
//

/* to get the Uniform Type Identifier (UTI) of a file, use the terminal command:
 
 mdls -name kMDItemContentType -name kMDItemContentTypeTree -name kMDItemKind /Volumes/star/astro/2023-12-21/M33-sub/Light_M33_10.0s_IRCUT_20231221-211630.fit
 
 output is:
 kMDItemContentType     = "dyn.ah62d4rv4ge80q4py"
 kMDItemContentTypeTree = (
     "public.item",
     "dyn.ah62d4rv4ge80q4py",
     "public.data"
 )
 kMDItemKind            = "Flexible Image Transport System File"

 Put dyn.ah62d4rv4ge80q4py into info.plist
 */

#import "PreviewProvider.h"

@implementation PreviewProvider

/*

 Use a QLPreviewProvider to provide data-based previews.
 
 To set up your extension as a data-based preview extension:

 - Modify the extension's Info.plist by setting
   <key>QLIsDataBasedPreview</key>
   <true/>
 
 - Add the supported content types to QLSupportedContentTypes array in the extension's Info.plist.

 - Change the NSExtensionPrincipalClass to this class.
   e.g.
   <key>NSExtensionPrincipalClass</key>
   <string>PreviewProvider</string>
 
 - Implement providePreviewForFileRequest:completionHandler:
 
 */

- (void)providePreviewForFileRequest:(QLFilePreviewRequest *)request completionHandler:(void (^)(QLPreviewReply * _Nullable reply, NSError * _Nullable error))handler
{
    //You can create a QLPreviewReply in several ways, depending on the format of the data you want to return.
    //To return NSData of a supported content type:
    NSURL *fileURL = request.fileURL;
    NSString *ext = fileURL.pathExtension;
    
    //NSLog(ext);
    if([ext isEqualToString:@"o2m"] || [ext isEqualToString: @"mac"]) {
        
        UTType* contentType = UTTypeUTF8PlainText; //replace with your data type
        
        QLPreviewReply* reply = [[QLPreviewReply alloc] initWithDataOfContentType:contentType contentSize:CGSizeMake(800, 800) dataCreationBlock:^NSData * _Nullable(QLPreviewReply * _Nonnull replyToUpdate, NSError *__autoreleasing  _Nullable * _Nullable error) {
            // Read the content of the file to display it as text
            NSError *ferror = nil;
            NSString *fileContent = [NSString stringWithContentsOfURL:fileURL
                                                             encoding:NSUTF8StringEncoding
                                                                error:&ferror];
            
            NSData* data = [fileContent dataUsingEncoding:NSUTF8StringEncoding];
            
            //setting the stringEncoding for text and html data is optional and defaults to NSUTF8StringEncoding
            replyToUpdate.stringEncoding = NSUTF8StringEncoding;
            
            //initialize your data here
            
            return data;
            //}
            
        }];
        
        //You can also create a QLPreviewReply with a fileURL of a supported file type, by drawing directly into a bitmap context, or by providing a PDFDocument.
        
        handler(reply, nil);
    }
    if([ext isEqualToString:@"o2d"] || [ext isEqualToString: @"fit"] || [ext isEqualToString: @"fits"]) {
        // get the image
        NSString *name = [fileURL path] ;
        const char* cname = [name cStringUsingEncoding:NSASCIIStringEncoding];
        QLImage qlImage = QLImage((char*)cname,LONG_NAME);
        if(qlImage.err()){
            handler(nil,nil);
            return;
        }
        int maxSize = qlImage.width();
        if(maxSize < qlImage.height()) maxSize = qlImage.height();
        int nth = 1;
        if(maxSize>3840) nth=4;
        else if(maxSize>1920) nth=2;
        if(nth != 1) qlImage.resize(qlImage.height()/nth,qlImage.width()/nth);
        // look at the histogram to to get cmin and cmax
        extern DATAWORD cmax,cmin;
        extern unsigned int histogram[];
        int i;
        // disregard if LHS of histogram is < 10% of peak; RHS of histogram is < 1% of peak -- optomized for raw data
        float lower=10., upper=1;
        float binsize=(qlImage.max()-qlImage.min())/(HISTOGRAM_SIZE-1.0);
        qlImage.gethistogram();
        float histMax=0;
        for(i=0; i< HISTOGRAM_SIZE; i++){
            if(histogram[i] > histMax) histMax = histogram[i];
        }
        
        for(i=0; i< HISTOGRAM_SIZE; i++){
            if(histogram[i]/histMax > lower/100.) {
                cmin = i*binsize+qlImage.min();
                break;
            }
        }
        for(i=HISTOGRAM_SIZE-1; i>=0; i--){
            if(histogram[i]/histMax > upper/100.) {
                cmax = i*binsize+qlImage.min();
                break;
            }
        }
        //NSLog(@"%f %f ",cmin,cmax);
        
        QLImageBitmap qlBitmap;
        qlBitmap = qlImage;
        int width=qlBitmap.getwidth();
        int height=qlBitmap.getheight();

        NSBitmapImageRep* bitmap = [[NSBitmapImageRep alloc]
                                    //initWithBitmapDataPlanes: qlBitmap.getpixdatap()
                                    initWithBitmapDataPlanes: nil
                                    pixelsWide: width pixelsHigh: height
                                    bitsPerSample: 8 samplesPerPixel: 3 hasAlpha: NO isPlanar:NO
                                    colorSpaceName:NSDeviceRGBColorSpace
                                    bytesPerRow: 3*width
                                    bitsPerPixel: 24];
        
        memcpy([bitmap  bitmapData], qlBitmap.getpixdata(), qlBitmap.getheight()*qlBitmap.getwidth()*3);
        NSImage* image = [[NSImage alloc] initWithSize:NSMakeSize(qlBitmap.getwidth(), qlBitmap.getheight())];
        [image addRepresentation:bitmap];
        /*
        NSString* text = @"woof";
     
        [NSGraphicsContext saveGraphicsState];
        NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmap];
        [NSGraphicsContext setCurrentContext:context];

        [image drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];

        int fSize=10+width/2000*12;
        NSMutableDictionary *attr = [NSMutableDictionary dictionary];
        [attr setObject:[NSFont fontWithName:@"Lucida Grande" size:fSize] forKey:NSFontAttributeName];
        [attr setObject:[NSColor whiteColor] forKey:NSBackgroundColorAttributeName];
        [attr setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
        NSString *myStr = [NSString stringWithFormat:@"mn/mx: %g %g",qlImage.getvalue(MIN),qlImage.getvalue(MAX)];
        [myStr drawAtPoint:NSMakePoint(2*fSize,height-3*fSize) withAttributes:attr];
        myStr = [NSString stringWithFormat:@"cmn/cmx: %g %g",cmin,cmax];
        [myStr drawAtPoint:NSMakePoint(2*fSize,height-4*fSize) withAttributes:attr];
        myStr = [NSString stringWithFormat:@"exp: %g",qlImage.getvalue(EXPOSURE)];
        [myStr drawAtPoint:NSMakePoint(2*fSize,height-5*fSize) withAttributes:attr];
        myStr = [NSString stringWithFormat:@"gain: %g %d",qlImage.getvalue(ISO),width];
        [myStr drawAtPoint:NSMakePoint(2*fSize,height-6*fSize) withAttributes:attr];

        [NSGraphicsContext restoreGraphicsState];

        NSImage *newImage = [[NSImage alloc] initWithSize:[bitmap size]];
        [newImage addRepresentation:bitmap];
         
         //NSImage* image = [[NSImage alloc] initWithSize:NSMakeSize(qlBitmap.getwidth(), qlBitmap.getheight())];
         //image = [self imageWithTextOverlay: dataImage text: @"woof"];

         */
        
        
        [image lockFocus];
        int fSize=10+width/500*2;
        NSMutableDictionary *attr = [NSMutableDictionary dictionary];
        [attr setObject:[NSFont fontWithName:@"Lucida Grande" size:fSize] forKey:NSFontAttributeName];
        [attr setObject:[NSColor whiteColor] forKey:NSBackgroundColorAttributeName];
        [attr setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
        NSString *myStr = [NSString stringWithFormat:@"mn/mx: %g    %g",qlImage.getvalue(MIN),qlImage.getvalue(MAX)];
        [myStr drawAtPoint:NSMakePoint(2*fSize,height-3*fSize) withAttributes:attr];
        myStr = [NSString stringWithFormat:@"cmn/cmx: %g    %g",cmin,cmax];
        [myStr drawAtPoint:NSMakePoint(2*fSize,height-4*fSize) withAttributes:attr];
        myStr = [NSString stringWithFormat:@"exp: %g",qlImage.getvalue(EXPOSURE)];
        [myStr drawAtPoint:NSMakePoint(2*fSize,height-5*fSize) withAttributes:attr];
        myStr = [NSString stringWithFormat:@"gain: %g ",qlImage.getvalue(ISO)];
        [myStr drawAtPoint:NSMakePoint(2*fSize,height-6*fSize) withAttributes:attr];
        [image unlockFocus];
         

        //NSLog(name);
        UTType* contentType = UTTypeImage; //replace with your data type
        
        if (image) {
            // Convert NSImage to NSData for the preview
            CGImageRef cgImage = [image CGImageForProposedRect:NULL context:nil hints:nil];
            
            NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
            NSDictionary *imageProps = @{};
            NSData *data = [bitmapRep representationUsingType:NSBitmapImageFileTypeTIFF properties:imageProps];
            
            if (data) {
                // Create a QLPreviewReply with the image data
                
                QLPreviewReply* reply = [[QLPreviewReply alloc] initWithDataOfContentType:contentType contentSize:image.size dataCreationBlock:^NSData * _Nullable(QLPreviewReply * _Nonnull replyToUpdate, NSError *__autoreleasing  _Nullable * _Nullable error) {

                    NSRect imageRect = NSMakeRect(0, 0, image.size.width, image.size.height);
                    CGRect drawingRect=imageRect;
                    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
                    
                    CGContextRef context = CGBitmapContextCreate(0, width,
                    height,
                    CGImageGetBitsPerComponent(cgImage),
                    0,
                    colorSpace,
                    kCGImageAlphaNone | kCGImageAlphaNoneSkipLast);
                    
                    
                    
                   
                    // Draw the image in the context
                    CGContextDrawImage(context, drawingRect, cgImage);
                    
                   
                    // Release the context, which allocated memory
                    CFRelease(context);
                    
                    return data;
                }];
                qlImage.free();
                qlBitmap.freeMaps();
                

                // Provide the preview reply
                handler(reply, nil);
            }
        }
    }
}
- (NSImage *)imageWithTextOverlay:(NSImage *)image text:(NSString *)text {
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc]
        initWithBitmapDataPlanes:NULL
        pixelsWide:image.size.width
        pixelsHigh:image.size.height
        bitsPerSample:8
        samplesPerPixel:3
        hasAlpha:NO
        isPlanar:NO
        colorSpaceName:NSCalibratedRGBColorSpace
        bytesPerRow:3*image.size.width
        bitsPerPixel:24];
 
    [NSGraphicsContext saveGraphicsState];
    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmapRep];
    [NSGraphicsContext setCurrentContext:context];

    [image drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];

    NSDictionary *attributes = @{NSFontAttributeName: [NSFont systemFontOfSize:40],
                                 NSForegroundColorAttributeName: [NSColor whiteColor],
                                 NSParagraphStyleAttributeName: [NSParagraphStyle defaultParagraphStyle]};

    NSSize textSize = [text sizeWithAttributes:attributes];
    NSRect textRect = NSMakeRect(0, image.size.height / 2 - textSize.height / 2, image.size.width, textSize.height);
    [text drawInRect:textRect withAttributes:attributes];

    [NSGraphicsContext restoreGraphicsState];

    NSImage *newImage = [[NSImage alloc] initWithSize:[bitmapRep size]];
    [newImage addRepresentation:bitmapRep];

    return newImage;
}
    @end
    
