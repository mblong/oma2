

#ifndef oma2_image_support_h
#define oma2_image_support_h

#include    "oma2.h"
#include    "UI.h"
#include    "image.h"


void swap_bytes_routine(char* co, int num, int nb);
int get_byte_swap_value(short);
int two_to_four(DATAWORD*,int,TWOBYTE);
char* fullname(char*,int);
int loadprefs(char*);
int process_old_header(TWOBYTE* header,char* comment,TWOBYTE* trailer,Image* );

#endif

