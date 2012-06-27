//#ifndef oma2_commands_1_h
//#define oma2_commands_1_h


#include "Image.h"
#include "ImageBitmap.h"


extern "C" int null_c(int,char*);

extern "C" int addfile_c(int,char*);
extern "C" int concatenatefile_c(int,char*);
extern "C" int croprectangle_c(int,char*);
extern "C" int calc_cmd_c(int,char*);
extern "C" int calcall_c(int,char*);
extern "C" int divfile_c(int,char*);
extern "C" int divide_c(int,char*);
extern "C" int getfile_c(int,char*);
extern "C" int invert_c(int,char*);
extern "C" int minus_c(int,char*);
extern "C" int mulfile_c(int,char*);
extern "C" int multiply_c(int,char*);
int palette_c(int,char*);
extern "C" int plus_c(int,char*);

extern "C" int rectan_c(int,char*);
extern "C" int rgb2red_c(int,char*);

extern "C" int rgb2green_c(int,char*);
extern "C" int rgb2blue_c(int,char*);
extern "C" int rotate_c(int,char*);
extern "C" int setcminmax_c(int,char*);
extern "C" int size_c(int,char*);
extern "C" int smooth_c(int,char*);
extern "C" int subfile_c(int,char*);




void update_UI();    // return ibuffer to the old oma

char* fullname(char* fnam,int  type);
int calc(point,point);


//#endif