//#ifndef oma2_commands_1_h
//#define oma2_commands_1_h


#include "Image.h"
#include "ImageBitmap.h"


int null_c(int,char*);

int addfile_c(int,char*);
int compositefile_c(int,char*);
int croprectangle_c(int,char*);
int calc_cmd_c(int,char*);
int calcall_c(int,char*);
int divfile_c(int,char*);
int divide_c(int,char*);
int ftemp_c(int, char*);
int getfile_c(int,char*);
int gtemp_c(int, char*);
int invert_c(int,char*);
int ltemp_c(int n, char* args);
int minus_c(int,char*);
int mulfile_c(int,char*);
int multiply_c(int,char*);
int palette_c(int,char*);
int plus_c(int,char*);

int rectan_c(int,char*);
int rgb2red_c(int,char*);

int rgb2green_c(int,char*);
int rgb2blue_c(int,char*);
int rotate_c(int,char*);
int setcminmax_c(int,char*);
int size_c(int,char*);
int smooth_c(int,char*);
int subfile_c(int,char*);

int stemp_c(int n, char* args);
int ltemp_c(int n, char* args);

int divtmp_c(int n, char* args);
int multmp_c(int n, char* args);
int addtmp_c(int n, char* args);
int subtmp_c(int n, char* args);
int comtmp_c(int n, char* args);

int colorflag_c(int n, char* args);



int temp_image_index (char* name,int define);




void update_UI();    // return ibuffer to the old oma

char* fullname(char* fnam,int  type);
int calc(point,point);


//#endif