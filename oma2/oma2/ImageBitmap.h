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

typedef  unsigned char PIXBYTES;


/******************** Class Definitions ********************/

class ImageBitmap
{
private:
    PIXBYTES**  pdptr;
    PIXBYTES*   pixdata;            //
    int         width;              // 
    int         height;
    int         thePalette;
    DATAWORD    cmin;
    DATAWORD    crange;
    PIXBYTES*   intensity;

    

public:
    ImageBitmap();            // default constructor with no arguments
    
    void operator=(Image);
    
    PIXBYTES* getpixdata();
    PIXBYTES** getpixdatap();
    PIXBYTES* getintensitydata();
    int getwidth();
    int getheight();
    int getpalette();
    int scale_pixval(DATAWORD);
};



#endif
