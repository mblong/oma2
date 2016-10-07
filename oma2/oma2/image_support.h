

#ifndef oma2_image_support_h
#define oma2_image_support_h

#include    "oma2.h"
#include    "UI.h"
#include    "image.h"
#include    "dofft.h"

enum {HOBJ_NO_DEMOSAIC=59457,HOBJ_DOC2RGB,HOBJ_BILINEAR,HOBJ_MALVAR};   // start at a funny number

//#define PMODE 0666 // RW  for writing files that we can open

void setUpUIData();
int two_to_four(DATAWORD*,int,TWOBYTE);
int get_byte_swap_value(short);
void swap_bytes_routine(char* co, int num, int nb);
char* fullname(char*,int);
void trimName(char*);
int loadprefs(char*);
int saveprefs(char*);
int process_old_header(TWOBYTE* header,char* comment,TWOBYTE* trailer,Image* );
int getpalettefile(char*);
unsigned long fsize(char* file);

int dcrawGlue(char* name, int thecolor,Image*);
int read_jpeg(char* filename,int thecolor,Image*);

// for reading hdr images
typedef struct  {
	int width, height;
	// each pixel takes 3 float32, each component can be of any value...
	float *cols;
} HDRLoaderResult;
int readHDR(char* filename,Image*);
int loadHDR(const char*, HDRLoaderResult*);
int readHobj(char* filename,Image*);
int readBinary(char* filename,Image*,int,int,int,int,int,int);



#endif

