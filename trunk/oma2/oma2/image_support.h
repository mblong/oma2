

#ifndef oma2_image_support_h
#define oma2_image_support_h

#include    "oma2.h"
#include    "UI.h"
#include    "image.h"

#define PMODE 0666 // RW  for writing files that we can open

void setUpUIData();
int two_to_four(DATAWORD*,int,TWOBYTE);
int get_byte_swap_value(short);
void swap_bytes_routine(char* co, int num, int nb);
char* fullname(char*,int);
int loadprefs(char*);
int saveprefs(char*);
int process_old_header(TWOBYTE* header,char* comment,TWOBYTE* trailer,Image* );
int getpalettefile(char*);

int dcrawGlue(char* name, int thecolor,Image*);

#endif

