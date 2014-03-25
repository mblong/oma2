//#ifndef oma2_commands_1_h
//#define oma2_commands_1_h


#include "image.h"
#include "ImageBitmap.h"
#include "UI.h"

#ifdef MacOSX_UI
extern "C" {
#include "tiffio.h"
}
#endif

// Commands

int null_c(int,char*);

int addfile_c(int,char*);
int addtmp_c(int,char*);
int accumulate_c(int,char*);
int acdelete_c(int,char*);
int acget_c(int,char*);
int acadd_c(int,char*);

int bit8_c(int,char*);
int bit16_c(int,char*);

int colorflag_c(int,char*);
int compositefile_c(int,char*);
int comtmp_c(int n, char* args);
int croprectangle_c(int,char*);
int calc_cmd_c(int,char*);
int calcall_c(int,char*);
int clip_c(int,char*);
int clipfraction_c(int,char*);
int clipbottom_c(int,char*);
int clipfbottom_c(int,char*);
int clearbad_c(int,char*);

int dcrawarg_c(int,char*);
int divfile_c(int,char*);
int diffx_c(int,char*);
int diffy_c(int,char*);
int divtmp_c(int,char*);
int divide_c(int,char*);
int delay_c(int,char*);

int echo_c(int,char*);

int fopen_c (int,char*);
int fclose_c (int,char*);
int fecho_c (int,char*);
int frame_c(int n, char* args);
int ftemp_c(int, char*);
int findbad_c(int,char*);
int fwdatm_c(int n,char* args);

int getfile_c(int,char*);
int getFileNames_c(int,char*);
int getfun_c(int,char*);
int gaussian_c(int,char*);
int grey2rgb_c(int,char*);
int gmacro_c(int,char*);
int gradient_c(int,char*);
int gsmooth_c(int, char*);
int gtemp_c(int, char*);

int invert_c(int,char*);
int integrate_c(int,char*);
int intfill_c(int,char*);
int integrateFill(int,char*,int);

int killBox_c(int,char*);

int list_c(int,char*);
int ltemp_c(int,char*);
int lookup_c(int,char*);
int ln_c(int,char*);

int minus_c(int,char*);
int mirror_c(int,char*);
int mulfile_c(int,char*);
int multmp_c(int,char*);
int multiply_c(int,char*);

int newWindow_c(int,char*);
int nextFile_c(int,char*);

int palette_c(int,char*);
int plus_c(int,char*);
int power_c(int,char*);
int positive_c(int, char*);

int rectan_c(int,char*);
int resize_c(int,char*);
int rgb2grey_c(int,char*);
int rgb2red_c(int,char*);
int rgb2green_c(int,char*);
int rgb2blue_c(int,char*);
int rotate_c(int,char*);
int readbad_c(int,char*);
int ramp_c(int,char*);
int roundUp_c(int,char*);
int roundoff_c(int,char*);

int setcminmax_c(int,char*);
int size_c(int,char*);
int sinGrid_c(int, char*);
int smooth_c(int,char*);
int stemp_c(int, char*);
int stringmacro_c(int,char*);
int subfile_c(int,char*);
int subtmp_c(int, char*);
int savefile_c(int,char*);
int satiff_c(int,char*);
int satiffscaled_c(int,char*);
int sysCommand_c(int,char*);

int tsmooth_c(int,char*);

int writebad_c(int,char*);

// Others
int temp_image_index (char* name,int define);

void update_UI();    

char* fullname(char* fnam,int  type);
int calc(point,point);

float tabfun(int,float);


//#endif