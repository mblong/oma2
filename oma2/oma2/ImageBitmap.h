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
#include "Image.h"


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
    int         is_color;
    int         pixsiz;
    int         autoscale;
    DATAWORD    cmin;
    DATAWORD    cmax;
public:
    ImageBitmap();            // default constructor with no arguments
    
    void operator=(Image);
    void setcmin(DATAWORD);
    void setcmax(DATAWORD);
    DATAWORD getcmin();
    DATAWORD getcmax();

    void setautoscale(int);
    int getautoscale();
    
    PIXBYTES* getpixdata();
    PIXBYTES** getpixdatap();
    int getwidth();
    int getheight();
};



#endif
