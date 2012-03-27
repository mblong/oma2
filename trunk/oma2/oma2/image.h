#include "oma2.h"
#include "Image_support.h"
#include "UI.h"

/******************** Constants for Classes ********************/
#define NSPECS  16   // number of integers in an Image specification array
#define NVALUES 16   // number of values associated with an Image (things like min, max, etc.)
#define NRULERCHAR 16   // number of characters in the units of the ruler

// locations within the specs array
enum {ROWS,COLS,X0,Y0,DX,DY,LMAX,LMIN,IS_COLOR,HAVE_MAX};

// locations within the values array
enum {MIN,MAX,RMAX,RMIN,GMAX,GMIN,BMAX,BMIN};

// Image error codes
enum {NO_ERR,SIZE_ERR,FILE_ERR,MEM_ERR};

/******************** Class Definitions ********************/

class Image
{
private:
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
    
    Image operator+(DATAWORD);  // constant arithmetic, modifies the current Image
    Image operator-(DATAWORD);  //    does not calculate min/max
    Image operator*(DATAWORD);
    Image operator/(DATAWORD);
    
    Image operator+(Image);     // Image arithmetic, modifies the current Image
    Image operator-(Image);     //    does not calculate min/max
    Image operator*(Image);
    Image operator/(Image);
    
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

    DATAWORD getpix(int,int);     // get a pixel value at the specified row and column
    DATAWORD getpix(float,float); // get an interpoated pixel value at the specified 
                                  // fractional row and column
    void setpix(int,int,DATAWORD);   // set a pixel value at the specified row and column
    
    Image crop(rect);           // crop the current image or return an error if there was one
    Image rotate(float);        // rotate the current image or return an error if there was one
    Image invert();             // invert the current image
    Image rgb2color(int);       // crop an rgb image to color 0,1, or 2 (red, green, or blue)
    Image concat(Image);        // concatenate two images. Error if images are not the same width.
        
};
