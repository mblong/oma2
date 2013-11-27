//#ifndef oma2_commands_1_h
//#define oma2_commands_1_h


#include "Image.h"
#include "ImageBitmap.h"

// Commands

int null_c(int,char*);

int addfile_c(int,char*);
int addtmp_c(int n, char* args);

int colorflag_c(int n, char* args);
int compositefile_c(int,char*);
int comtmp_c(int n, char* args);
int croprectangle_c(int,char*);
int calc_cmd_c(int,char*);
int calcall_c(int,char*);
int clip_c(int,char*);
int clipfraction_c(int,char*);
int clipbottom_c(int,char*);
int clipfbottom_c(int,char*);

int dcrawarg_c(int n, char* args);
int divfile_c(int,char*);
int diffx_c(int n,char* args);
int diffy_c(int n,char* args);
int divtmp_c(int n, char* args);
int divide_c(int,char*);
int delay_c(int,char*);

int echo_c(int,char*);

int fopen_c (int n,char* args);
int fclose_c (int n,char* args);
int fecho_c (int n,char* args);
int ftemp_c(int, char*);

int getfile_c(int,char*);
int getFileNames_c(int n,char* args);
int gmacro_c(int n,char* args);
int gradient_c(int n,char* args);
int gtemp_c(int, char*);

int invert_c(int,char*);

int killBox_c(int n, char* args);

int list_c(int n, char* args);
int ltemp_c(int n, char* args);

int minus_c(int,char*);
int mulfile_c(int,char*);
int multmp_c(int n, char* args);
int multiply_c(int,char*);

int newWindow_c(int,char*);
int nextFile_c(int,char*);

int palette_c(int,char*);
int plus_c(int,char*);
int power_c(int,char*);
int positive_c(int, char*);

int rectan_c(int,char*);
int resize_c(int,char*);
int rgb2red_c(int,char*);
int rgb2green_c(int,char*);
int rgb2blue_c(int,char*);
int rotate_c(int,char*);

int setcminmax_c(int,char*);
int size_c(int,char*);
int sinGrid_c(int, char*);
int smooth_c(int,char*);
int stemp_c(int, char*);
int stringmacro_c(int,char*);
int subfile_c(int,char*);
int subtmp_c(int, char*);
int savefile_c(int,char*);
int sysCommand_c(int,char*);

// Others
int temp_image_index (char* name,int define);

void update_UI();    

char* fullname(char* fnam,int  type);
int calc(point,point);


//#endif