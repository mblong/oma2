

#include "Image.h"
#include "ImageBitmap.h"

#define MAXDOFFSET 80		/* the maximum databuffer offset */


int moveOMA2toOMA(int n,char* args);
void moveOMAtoOMA2();

void nomemory();
void update_status();
void setarrow();
void maxx();
int checkpar();
void beep();


DATAWORD idat(int nt,int nc);
float fdat(int nt,int nc);
int float_image();
int new_float_image(int nx, int ny);
int get_float_image();

void update_UI();    

char* fullname(char* fnam,int  type);
int calc(point,point);

/* *********************** */

int block_g(int n,char* args);
int block(int n,int index);
int blockrgb(int n,int index);

int cyl2_g(int n,char* args);
int Cyl2(int,int);

int kwabel_g(int n, char* args);
int kwabel(int n);

int abelinv_g(int n, char* args);
int abelinv(int n,int index);
float OP0(int i,int j);
float OP1(int i,int j);
float OP_D(int i,int j);

int fold_g(int n, char* args);
int fold(int n, int index);

int abelprep_g(int n, char* args);
int abelprep(int n, int index);

int abelrect_g(int n, char* args);
int abelrect(int n, int index);


