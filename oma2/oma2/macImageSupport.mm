//
//  macImageSupport.mm
//  oma2
//
//  Created by Marshall Long on 4/5/14.
//  Copyright (c) 2014 Yale University. All rights reserved.
//

#include "macImageSupport.h"

int readJpeg(char* filename,Image* im)
{
    NSString *file = [[NSString alloc] initWithCString:filename encoding:NSASCIIStringEncoding];
    NSImage* nsim = [[NSImage alloc] initByReferencingFile:file];
    // the source of the data
	if (![nsim isValid]) {
        beep();
	    printf( "Can't open %s\n", filename);
        return(FILE_ERR);
	}

    NSBitmapImageRep* imageRep = [[NSBitmapImageRep alloc] initWithData:[nsim TIFFRepresentation]];
    int bytesPerPixel  = (int)[imageRep bitsPerPixel]/8;
    int bytesPerRow = (int)[imageRep bytesPerRow];
    unsigned char* bytes = [imageRep bitmapData];
    
    int cols = im->specs[COLS] = nsim.size.width;
    int rows = im->specs[ROWS] = nsim.size.height;

    if(bytesPerPixel == 3){
        im->specs[IS_COLOR] = 1;
        im->specs[ROWS] *= 3;
    }
    
    im->data = new DATAWORD[im->specs[ROWS]*cols];
    if(im->data == NULL){
        im->specs[ROWS]=im->specs[COLS]=0;
        im->error = MEM_ERR;
        return MEM_ERR;
    }
   
    DATAWORD* pt = im->data;
    DATAWORD* pt_green = pt + rows*cols;
    DATAWORD* pt_blue =  pt_green + rows*cols;
    
    for(int i=0; i< rows; i++){
        for(int j=0; j< cols;j++){
            *pt++ = *(bytes+i*bytesPerRow+j*bytesPerPixel);
            if(bytesPerPixel == 3){
                *pt_green++ = *(bytes+i*bytesPerRow+j*bytesPerPixel+1);
                *pt_blue++ = *(bytes+i*bytesPerRow+j*bytesPerPixel+2);
            }
        }
    }
    return NO_ERR;

}
/*
 from the web
 
 http://stackoverflow.com/questions/19023182/how-can-i-extract-raw-data-from-a-tiff-image-in-objective-c/19025960#19025960
 
NSImage *image = [[NSImage alloc] initWithContentsOfFile:[@"~/Desktop/image.tiff" stringByExpandingTildeInPath]];
NSData *imageData = [image TIFFRepresentation];
CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)CFBridgingRetain(imageData), NULL);
CGImageRef imageRef =  CGImageSourceCreateImageAtIndex(source, 0, NULL);
NSUInteger numberOfBitsPerPixel = CGImageGetBitsPerPixel(imageRef);
NSLog(@"Number Of Bits Per Pixel %lu", (unsigned long)numberOfBitsPerPixel);
 */
