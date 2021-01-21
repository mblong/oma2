
#include "oma2.h"
#include "image_support.h"
#include "UI.h"
#include <math.h>
#include "dmbilinear.h"
#include "dmmalvar.h"


#ifndef oma2_Image_h
#define oma2_Image_h



typedef struct{
    char ext[6];
    int decoder;
} FileDecoderExtensions;



/******************** Constants for Classes ********************/
#define NSPECS  32   // number of integers in an Image specification array
#define NVALUES 16   // number of values associated with an Image (things like min, max, etc.)
#define NRULERCHAR 16   // number of characters in the units of the ruler
#define NUM_IMAGE_PTRS 3    // the number of pointers in the Image Class

// locations within the specs array
enum {ROWS,COLS,X0,Y0,DX,DY,LMAX,LMIN,IS_COLOR,HAVE_MAX,HAS_RULER,
    LRMAX,LRMIN,LGMAX,LGMIN,LBMAX,LBMIN,NFRAMES,SAVE_FORMAT};

// types if integers the data can be saved as
enum {UNSIGNED16=59464,SIGNED16,UNSIGNED8,SIGNED8};

// SAVE_FORMAT is a 2021 addition to the specs array
// This will be used to save data in other than DATAWORD types
// Will assume that the chances of specs[SAVE_FORMAT] accidentally being one of the magic values is small

// locations within the values array
enum {MIN,MAX,RMAX,RMIN,GMAX,GMIN,BMAX,BMIN,RULER_SCALE,EXPOSURE,APERTURE,ISO};

// Image error codes and command return codes
enum {NO_ERR,SIZE_ERR,FILE_ERR,MEM_ERR,ARG_ERR,CMND_ERR,HARD_ERR,GET_MACRO_LINE,GET_COMMENT_LINE};

// arguments for getmaxx
enum {NO_PRINT,PRINT_RESULT};

// demosaic algorithms
enum {BILINEAR,MALVAR};

// special file reader types
enum {DCRAW,JPEG,TIFREAD,HDR,HOBJ,OMA,TXT,RAW};
#define RAW_FILE_EXT_INDEX 12


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
    int         extraSize;      ///< Space of extra buffer to be stored with an image. Used for exposure values in HDR sequence files.
    char*       comment;        ///< Text entered with the LOG command
    float*      extra;          ///< Pointer to extra data (float)
    DATAWORD*   data;           ///< Pointer to image data (DATAWORD=float currently)
public:
    Image();            ///< default constructor with no arguments
    ~Image();           ///< destructor
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
    void abs();                 ///< take the absolute value of an image
    void getmaxx(char);         ///< fill in the min and max for the current Image; argument is print flag
    void clip(DATAWORD);        ///< set values > specifiedValue to specifiedValue
    void floor(DATAWORD);       ///< set values < specifiedValue to specifiedValue
    void saveFile(char*, int);  ///< write the Image to a file; second argument tells if name is complete or not
    void saveFile(char*, int,int);  ///< write the Image to a file as integers; second argument tells if name is complete or not; third argument is type -- uint16 int16 char8 uchar8
    
    void copyABD(Image);        ///< copy All But Data from one image to another
    int* getspecs();            ///< returns a copy of the image specs array
    float* getextra();          ///< returns a copy of the extra data array
    void setExtra(float*,int);  ///< Loads the extra buffer with the specified number of floating point values
    int getExtraSize();         ///< returns the size of the extra data array
    int rows();                 ///< returns the number of rows in the current image (height)
    int cols();                 ///< returns the number of columns in the current image (width)
    void setspecs(int*);        ///< sets the image specs array
    DATAWORD* getvalues();      ///< returns a copy of the image values array
    DATAWORD min();             ///< returns the image min
    DATAWORD max();             ///< returns the image max
    void setvalues(DATAWORD*);  ///< sets the image values array
    char* getunit_text();       ///< returns a copy of the image ruler units
    char* getComment();        ///< returns a copy of the comment buffer
    void setComment(char*,int);        ///< Loads the comment buffer with the specified number of characters
    void setRuler(float rulerScale, char* unit_text); ///< Set scale factor and units of a ruler for the current image
    
    DATAWORD getpix(int,int);     ///< get a pixel value at the specified row and column
    DATAWORD getpix(float,float); ///< get an interpoated pixel value at the specified fractional row and column
    DATAWORD* getImageData();     ///< returns the data pointer
    
    void setpix(int,int,DATAWORD);   ///< set a pixel value at the specified row and column
    
    void crop(rect);           ///< crop the current image or return an error if there was one
    void rotate(float);        ///< rotate the current image or return an error if there was one
    
    void invert();             ///< invert the current image
    void mirror();             ///< mirror the current image
    
    void rgb2color(int);       ///< crop an rgb image to color 0,1, or 2 (red, green, or blue)
    void composite(Image);     ///< composite two images. Error if images are not the same width.
    void resize(int,int);      ///< resize the current image to specified rows and columns
    
    void rgbMult(float,float,float);
    void rgbDiv(float,float,float);
    void rgbAdd(float,float,float);
    void rgbSub(float,float,float);
    void rgbPow(float,float,float);

    void demosaic(Image, int, int, int ); // demosaic
    
    
    // These friends help read in images
    friend int process_old_header(TWOBYTE* header,char* comment,TWOBYTE* trailer,Image* im);
    friend int read_jpeg(char* filename,int thecolor, Image*);
    friend int readJpeg(char* filename, Image*);
    friend int readTiff(char* filename, Image*);
    friend int readHDR(char* filename, Image*);
    friend int readHobj(char* filename, Image*);
    friend int readCsv(char* filename, Image*);
    friend void oma_write_ppm_tiff (int thecolor, Image* im);
#ifdef GIGE_
    friend int gige(int n, char* args);
#endif
    // Special friends that need to go fast
    friend  int dofft(int,char*);
    friend  int warp_c(int,char*);
    friend class ImageBitmap;
    friend void BilinearDemosaic(float *Output, const float *Input, int Width, int Height,
                                 int RedX, int RedY);
    friend void MalvarDemosaic(float *Output, const float *Input, int Width, int Height,
                                 int RedX, int RedY);
};

#endif
