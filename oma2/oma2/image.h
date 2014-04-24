#include "oma2.h"
#include "image_support.h"
#include "UI.h"
#include <math.h>
//#include "ImageBitmap.h"


#ifndef oma2_Image_h
#define oma2_Image_h



/******************** Constants for Classes ********************/
#define NSPECS  32   // number of integers in an Image specification array
#define NVALUES 16   // number of values associated with an Image (things like min, max, etc.)
#define NRULERCHAR 16   // number of characters in the units of the ruler
#define NUM_IMAGE_PTRS 3    // the number of pointers in the Image Class

// locations within the specs array
enum {ROWS,COLS,X0,Y0,DX,DY,LMAX,LMIN,IS_COLOR,HAVE_MAX,HAS_RULER,
        LRMAX,LRMIN,LGMAX,LGMIN,LBMAX,LBMIN};

// locations within the values array
enum {MIN,MAX,RMAX,RMIN,GMAX,GMIN,BMAX,BMIN,RULER_SCALE};

// Image error codes and command return codes
enum {NO_ERR,SIZE_ERR,FILE_ERR,MEM_ERR,ARG_ERR,CMND_ERR,HARD_ERR,GET_MACRO_LINE,GET_COMMENT_LINE};

/******************** Class Definitions ********************/

class Image
{
protected:
    int         specs[NSPECS];      ///< Information on Image size, type, etc.
    DATAWORD    values[NVALUES];    ///< Important values (things like min, max, etc.)
    char        unit_text[NRULERCHAR]; ///< Label for the ruler units
    int         error;              ///< An error flag
    int         is_big_endian;  ///< You guessed it.
    int         commentSize;    ///< Size of text entered with the LOG command
    int         extraSize;      ///< Space of extra buffer to be stored with an image. Not used so far.
    char*       comment;        ///< Text entered with the LOG command
    float*      extra;          ///< Pointer to extra data (float)
    DATAWORD*   data;           ///< Pointer to image data (DATAWORD=float currently)
public:
    Image();            ///< default constructor with no arguments
    //~Image();           ///< destructor
    Image(int,int);     ///< constructor -- specify rows and columns, other values are defaults
    Image(char*,int);   ///< constructor -- new Image from filename.
                        ///< Second argument says what to do with filling in name
    
    void operator+(DATAWORD);  ///< constant arithmetic, modifies the current Image; does not calculate min/max
    void operator-(DATAWORD);  ///< constant arithmetic, modifies the current Image; does not calculate min/max
    void operator*(DATAWORD);  ///< constant arithmetic, modifies the current Image; does not calculate min/max
    void operator/(DATAWORD);  ///< constant arithmetic, modifies the current Image; does not calculate min/max
    void power(DATAWORD);      ///< Raise to the specified power
    
    
    void operator+(Image);     ///< Image arithmetic, modifies the current Image; does not calculate min/max
    void operator-(Image);     ///< Image arithmetic, modifies the current Image; does not calculate min/max
    void operator*(Image);     ///< Image arithmetic, modifies the current Image; does not calculate min/max
    void operator/(Image);     ///< Image arithmetic, modifies the current Image; does not calculate min/max
    
    
    Image operator<<(Image);    ///< make a copy of an image
    
    
    bool operator==(Image);     ///< true if Images are the same size
    bool operator!=(Image);     ///< true if Images are not the same size
    bool isEmpty();             ///< true if Image has no data
    bool isColor();             ///< true if Image is flagged as color
    
    int width();                ///< image width
    int height();               ///< image height -- for color images this is pixHeight/3
    
    int err();                  ///< return the error code (= 0 if no error)
    void errclear();            ///< clear the image error code
    void free();                ///< release the data associated with an Image
    void zero();                ///< set the data associated with an Image to 0
    void getmaxx();             ///< fill in the min and max for the current Image
    void clip(DATAWORD);        ///< set values > specifiedValue to specifiedValue
    void floor(DATAWORD);       ///< set values < specifiedValue to specifiedValue
    void saveFile(char*, int);  ///< write the Image to a file; second argument tells if name is complete or not
    
    void copyABD(Image);        ///< copy All But Data from one image to another
    int* getspecs();            ///< returns a copy of the image specs array
    int rows();                 ///< returns the number of rows in the current image (height)
    int cols();                 ///< returns the number of columns in the current image (width)
    void setspecs(int*);        ///< sets the image specs array
    DATAWORD* getvalues();      ///< returns a copy of the image values array
    char* getunit_text();       ///< returns a copy of the image ruler units
    char* getComment();        ///< returns a copy of the comment buffer
    void setComment(char*,int);        ///< Loads the comment buffer with the specified number of characters
    void setRuler(float rulerScale, char* unit_text); ///< Set scale factor and units of a ruler for the current image
    
    DATAWORD getpix(int,int);     ///< get a pixel value at the specified row and column
    DATAWORD getpix(float,float); ///< get an interpoated pixel value at the specified fractional row and column
    void setpix(int,int,DATAWORD);   ///< set a pixel value at the specified row and column
    
    void crop(rect);           ///< crop the current image or return an error if there was one
    void rotate(float);        ///< rotate the current image or return an error if there was one
    
    void invert();             ///< invert the current image
    void mirror();             ///< mirror the current image
    
    void rgb2color(int);       ///< crop an rgb image to color 0,1, or 2 (red, green, or blue)
    void composite(Image);     ///< composite two images. Error if images are not the same width.
    void resize(int,int);      ///< resize the current image to specified rows and columns
    
    
    
    // These friends help read in images
    friend int process_old_header(TWOBYTE* header,char* comment,TWOBYTE* trailer,Image* im);
    friend int read_jpeg(char* filename,int thecolor, Image*);
    friend int readJpeg(char* filename, Image*);
    friend int readTiff(char* filename, Image*);
    friend int readHDR(char* filename, Image*);
    friend void oma_write_ppm_tiff (int thecolor, Image* im);
    // Special friends that need to go fast
    friend  int dofft(int,char*);
    friend class ImageBitmap;
};

#endif
