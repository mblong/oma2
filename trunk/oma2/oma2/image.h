#include "oma2.h"
#include "Image_support.h"
#include "UI.h"
//#include "ImageBitmap.h"


#ifndef oma2_Image_h
#define oma2_Image_h



/******************** Constants for Classes ********************/
#define NSPECS  16   // number of integers in an Image specification array
#define NVALUES 16   // number of values associated with an Image (things like min, max, etc.)
#define NRULERCHAR 16   // number of characters in the units of the ruler

// locations within the specs array
enum {ROWS,COLS,X0,Y0,DX,DY,LMAX,LMIN,IS_COLOR,HAVE_MAX};

// locations within the values array
enum {MIN,MAX,RMAX,RMIN,GMAX,GMIN,BMAX,BMIN};

// Image error codes and command return codes
enum {NO_ERR,SIZE_ERR,FILE_ERR,MEM_ERR,ARG_ERR,GET_MACRO_LINE};

/******************** Class Definitions ********************/

class Image
{
protected:
    DATAWORD*   data;
    int         specs[NSPECS];      // information on Image size, type, etc.
    DATAWORD    values[NVALUES];    // important values (things like min, max, etc.)
    int         error;
    int         has_ruler;
    float       ruler_scale;
    char        unit_text[NRULERCHAR];
    int         is_big_endian;
public:
    Image();            // default constructor with no arguments
    Image(int,int);     // constructor -- specify rows and columns, other values are defaults
    Image(char*);       // constructor -- new Image from filename
    
    void operator+(DATAWORD);  // constant arithmetic, modifies the current Image
    void operator-(DATAWORD);  //    does not calculate min/max
    void operator*(DATAWORD);
    void operator/(DATAWORD);
    
    void operator+(Image);     // Image arithmetic, modifies the current Image
    void operator-(Image);     //    does not calculate min/max
    void operator*(Image);
    void operator/(Image);
    
    Image operator<<(Image);    // make a copy of an image
    
    bool operator==(Image);     // true if Images are the same size
    bool operator!=(Image);     // true if Images are not the same size
    
    int err();                  // return the error code (= 0 if no error)
    void errclear();            // clear the image error code
    void free();                // release the data associated with an Image
    void getmaxx();             // fill in the min and max for the current Image
    
    void copyABD(Image);        // copy All But Data from one image to another
    int* getspecs();            // returns a copy of the image specs array
    void setspecs(int*);        // sets the image specs array
    DATAWORD* getvalues();      // returns a copy of the image values array

    DATAWORD getpix(int,int);     // get a pixel value at the specified row and column
    DATAWORD getpix(float,float); // get an interpoated pixel value at the specified 
                                  // fractional row and column
    void setpix(int,int,DATAWORD);   // set a pixel value at the specified row and column
    
    void crop(rect);           // crop the current image or return an error if there was one
    void rotate(float);        // rotate the current image or return an error if there was one
    void invert();             // invert the current image
    void rgb2color(int);       // crop an rgb image to color 0,1, or 2 (red, green, or blue)
    void concat(Image);        // concatenate two images. Error if images are not the same width.
    friend class ImageBitmap; 
    friend int process_old_header(TWOBYTE* header,char* comment,TWOBYTE* trailer,Image* im);
};

#endif
