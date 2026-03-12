//
//  ImageBitmap.h
//  oma2
//
//  Created by Marshall Long on 3/30/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#ifndef oma2_ImageBitmap_h
#define oma2_ImageBitmap_h

#include <iostream>
#include "image.h"


#define NCOLORS 256
#define NCOLORS16 65536

typedef  unsigned char PIXBYTES;
typedef  unsigned short PIXBYTES16;


/******************** Class Definitions ********************/

class ImageBitmap
{
private:
    PIXBYTES**  pdptr;
    PIXBYTES*   pixdata;            // the 8-bit RGB to be displayed
    PIXBYTES16* pixdata16;          // the 16-bit RGB for HDR color display
    int         width;              // 
    int         height;
    int         thePalette;
    DATAWORD    cmin;
    DATAWORD    crange;
    PIXBYTES*   intensity;          // for false color plots, this is the intensity (i.e., palette index)
    int         hdrActive;          // 1 if pixdata16 was populated on last conversion

    

public:
    ImageBitmap();            // default constructor with no arguments
    
    void operator=(Image);
    void freeMaps();
    
    PIXBYTES* getpixdata();
    PIXBYTES16* getpixdata16();
    PIXBYTES** getpixdatap();
    PIXBYTES* getintensitydata();
    int getwidth();
    int getheight();
    int getpalette();
    int isHDR();
    int scale_pixval(DATAWORD);
    int scale_pixval16(DATAWORD);
};



#endif
