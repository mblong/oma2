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
    
    NSLog(ext);
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
        Image qlImage = Image((char*)cname,LONG_NAME);
        if(qlImage.err()){
            handler(nil,nil);
            return;
        }
        // look at the histogram to to get cmin and cmax
        extern DATAWORD cmax,cmin;
        extern unsigned int histogram[];
        int i;
        // disregard if LHS of histogram is < 5% RHS of histogram is < 5% -- optomized for raw data
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
        NSLog(@"%f %f ",cmin,cmax);
        
        ImageBitmap qlBitmap;
        qlBitmap = qlImage;
        
        NSBitmapImageRep* bitmap = [[NSBitmapImageRep alloc]
                                    //initWithBitmapDataPlanes: qlBitmap.getpixdatap()
                                    initWithBitmapDataPlanes: nil
                                    pixelsWide: qlBitmap.getwidth() pixelsHigh: qlBitmap.getheight()
                                    bitsPerSample: 8 samplesPerPixel: 3 hasAlpha: NO isPlanar:NO
                                    colorSpaceName:NSDeviceRGBColorSpace
                                    bytesPerRow: 3*qlBitmap.getwidth()
                                    bitsPerPixel: 24];
        
        memcpy([bitmap  bitmapData], qlBitmap.getpixdata(), qlBitmap.getheight()*qlBitmap.getwidth()*3);
        NSImage* image = [[NSImage alloc] initWithSize:NSMakeSize(qlBitmap.getwidth(), qlBitmap.getheight())];
        [image addRepresentation:bitmap];
        
        NSLog(name);
        UTType* contentType = UTTypeImage; //replace with your data type
        int width=qlBitmap.getwidth();
        int height=qlBitmap.getheight();
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
                    width*4,
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
    @end
    
