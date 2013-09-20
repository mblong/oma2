#include "Image.h"


// The list of globals -- keep this VERY small
// globals should be named iSomething (note capitalization)
// Whenever possible, imbed things as static variables inside a function
// See fullname() for example, where that is the location of all the prefix/suffix related storage

char    reply[1024];          // buffer for sending messages to be typed out by the user interface
Image   iBuffer(200,200);     // the image buffer
oma2UIData UIData;            // Put all the UI globals here
Image  iTempImages[NUM_TEMP_IMAGES];  // temporary in-memmory images
int numberNamedTempImages = 0;
Variable namedTempImages[NUM_TEMP_IMAGES-NUMBERED_TEMP_IMAGES];

//extern "C" int get_byte_swap_value(short);
//extern "C" void swap_bytes_routine(char* co, int num,int nb);

Image::Image()              // create an empty Image
{
    data = NULL;
    specs[ROWS]=specs[COLS]=0;

    specs[Y0] = specs[X0] = specs[IS_COLOR] = specs[HAVE_MAX] = 0;
    specs[DX] = specs[DY] = 1;
    error = 0;
    specs[HAS_RULER]=0;
    values[RULER_SCALE]=1.;
    unit_text[0] = 0;
    is_big_endian = IS_BIG_ENDIAN;
}



Image::Image(int rows, int cols)
{
    data = new DATAWORD[rows*cols];
    if(data == 0){
        specs[ROWS]=specs[COLS]=0;
        error = MEM_ERR;
    } else {
        specs[ROWS]=rows;
        specs[COLS]=cols;
    }
    specs[Y0] = specs[X0] = specs[IS_COLOR] = specs[HAVE_MAX] = 0;
    specs[DX] = specs[DY] = 1;
    error = 0;
    specs[HAS_RULER]=0;
    values[RULER_SCALE]=1.;
    unit_text[0] = 0;
    is_big_endian = IS_BIG_ENDIAN;
    
    
}

Image::Image(char* filename)
{
    unsigned long fd,nr,nbyte;
    TWOBYTE header[HEADLEN];
    char comment[COMLEN];
    TWOBYTE trailer[TRAILEN];
    int swap_bytes;
    int doffset=80;
    
    data=NULL;
    specs[ROWS]=specs[COLS]=0;
    
    specs[Y0] = specs[X0] = specs[IS_COLOR] = specs[HAVE_MAX] = 0;
    specs[DX] = specs[DY] = 1;
    error = 0;
    specs[HAS_RULER]=0;
    values[RULER_SCALE]=1.;
    unit_text[0] = 0;
    is_big_endian = IS_BIG_ENDIAN;
    
    fd = open(filename,O_RDONLY);
    if(fd == -1) {
        error = FILE_ERR;
        return;
    }
    
    nr = read((int)fd,(char*)header,HEADLEN);
    nr = read((int)fd,comment,COMLEN);
    nr = read((int)fd,(char*)trailer,TRAILEN);
    
    swap_bytes = process_old_header((TWOBYTE*)header,(char*)comment,(TWOBYTE*)trailer, this);
    nbyte = specs[ROWS]*specs[COLS]*DATABYTES;
    
    // problem of how to get rid of the old 80 data word offset and still read in old oma files
    
    data = new DATAWORD[specs[ROWS]*specs[COLS]];
    if(data == 0){
        specs[ROWS]=specs[COLS]=0;
        error = MEM_ERR;
        return;
    }
    
    // in old oma files, there is an 80 element data offset -- skip over this
    nr = read((int)fd,data,doffset*DATABYTES);
    
    nr = read((int)fd,(char*)data, nbyte);
    printf2("%d Bytes read.\n",(int)nr);
    
    if(nbyte/nr == 2) {
        // this is a 2-byte data file
        // adjust to 4-byte format
        printf1("2-byte input file\n");
        if(swap_bytes)  swap_bytes_routine((char*) data,(int) nr,2);
		two_to_four(data,(int)nr/2,trailer[SFACTR]);
    } else {
        if(swap_bytes) swap_bytes_routine((char*) data, (int)nr, DATABYTES);
    }
    
    close((int)fd);
    return;
}


void Image::operator+(DATAWORD val){
    for(int i=0; i<specs[ROWS]*specs[COLS];i++){
        *(data+i) += val;
    }
    specs[HAVE_MAX]=0;
    //return *this;
}

void Image::operator-(DATAWORD val){
    for(int i=0; i<specs[ROWS]*specs[COLS];i++){
        *(data+i) -= val;
    }
    specs[HAVE_MAX]=0;
    //return *this;
}

void Image::operator*(DATAWORD val){
    for(int i=0; i<specs[ROWS]*specs[COLS];i++){
        *(data+i) *= val;
    }
    specs[HAVE_MAX]=0;
    //return *this;
}

void Image::operator/(DATAWORD val){
    for(int i=0; i<specs[ROWS]*specs[COLS];i++){
        *(data+i) /= val;
    }
    specs[HAVE_MAX]=0;
    //return *this;
}

void Image::operator+(Image im2){
    if (*this != im2){
        error = SIZE_ERR;
        //return *this;
        return;
    }
    for(int i=0; i<specs[ROWS]*specs[COLS];i++){
        *(data+i) += *(im2.data+i);
    }
    specs[HAVE_MAX]=0;
    //return *this;
}

void Image::operator-(Image im2){
    if (*this != im2){
        error = SIZE_ERR;
        //return *this;
        return;
    }
    for(int i=0; i<specs[ROWS]*specs[COLS];i++){
        *(data+i) -= *(im2.data+i);
    }
    specs[HAVE_MAX]=0;
    //return *this;
}

void Image::operator*(Image im2){
    if (*this != im2){
        error = SIZE_ERR;
        //return *this;
        return;
    }
    for(int i=0; i<specs[ROWS]*specs[COLS];i++){
        *(data+i) *= *(im2.data+i);
    }
    specs[HAVE_MAX]=0;
    //return *this;
}

void Image::operator/(Image im2){
    if (*this != im2){
        error = SIZE_ERR;
        //return *this;
        return;
    }
    for(int i=0; i<specs[ROWS]*specs[COLS];i++){
        *(data+i) /= *(im2.data+i);
    }
    specs[HAVE_MAX]=0;
    //return *this;
}

Image Image::operator<<(Image im){
    // in case the current image is not empty, free the space
    this->free();
    Image copy;
    // allocate space for data
    copy.data = new DATAWORD[im.specs[ROWS]*im.specs[COLS]];
    if (copy.data==NULL){
        error = MEM_ERR;
        return copy;
    }
    copy.copyABD(im); // get the specs
    // get the data
    for(int i=0; i<im.specs[ROWS]*im.specs[COLS]; i++){
        *(copy.data+i) =  *(im.data+i);
    }
    
    *this = copy;
    return *this;
}


bool Image::operator==(Image im2){
    if (specs[ROWS] == im2.specs[ROWS] && specs[COLS] == im2.specs[COLS]) {
        return true;
    }
    return false;
}

bool Image::operator!=(Image im2){
    return !(*this == im2);
}

int Image::err(){
    return error;
}

int Image::width(){
    if(data)
        return specs[COLS];
    else
        return 0;
}

int Image::height(){
    if(data)
        if(specs[IS_COLOR])
            return specs[ROWS]/3;
        else
            return specs[ROWS];
    else
        return 0;
}


bool Image::isEmpty(){
    if (data == NULL) 
        return true;
    else
        return false;
}

bool Image::isColor(){
    if (specs[IS_COLOR])
        return true;
    else
        return false;
}


void Image::errclear(){
    error=0;
}

void Image::free(){
    if(data != NULL){
        delete[] data;
        data = NULL;
    }
}

void Image::getmaxx()
{
    DATAWORD *locmin,*locmax,*locrmin,*locrmax,*locgmin,*locgmax,*locbmin,*locbmax;
    DATAWORD *mydatpt;
    DATAWORD rmax=0,gmax=0,bmax=0,rmin=0,gmin=0,bmin=0;
    int npts=specs[ROWS]*specs[COLS];
    
    //if( specs[HAVE_MAX] == 1)return;      // Disable for now. May want to add an argument to this to look at the
                                            // flag or not.
    
    mydatpt = data;
    locmin = locmax = mydatpt;
    locrmin = locrmax = locgmin = locgmax = locbmin = locbmax = mydatpt;
    
    if(specs[IS_COLOR]){ 
        for (locrmin = locrmax = mydatpt; mydatpt < data+npts/3; mydatpt++ ) {
            if ( *mydatpt > *locmax )  locmax = mydatpt;
            if ( *mydatpt < *locmin )  locmin = mydatpt;
            if ( *mydatpt > *locrmax ) locrmax = mydatpt;
            if ( *mydatpt < *locrmin ) locrmin = mydatpt;
        }
 
        for (locgmin = locgmax = mydatpt; mydatpt < data+2*npts/3; mydatpt++ ) {
            if ( *mydatpt > *locmax )  locmax = mydatpt;
            if ( *mydatpt < *locmin )  locmin = mydatpt;
            if ( *mydatpt > *locgmax ) locgmax = mydatpt;
            if ( *mydatpt < *locgmin ) locgmin = mydatpt;
        }

        for (locbmin = locbmax = mydatpt; mydatpt < data+npts; mydatpt++ ) {
            if ( *mydatpt > *locmax )  locmax = mydatpt;
            if ( *mydatpt < *locmin )  locmin = mydatpt;
            if ( *mydatpt > *locbmax ) locbmax = mydatpt;
            if ( *mydatpt < *locbmin ) locbmin = mydatpt;
        }
        rmax = *locrmax;
        rmin = *locrmin;
        gmax = *locgmax;
        gmin = *locgmin;
        bmax = *locbmax;
        bmin = *locbmin;

    } else{
        while ( mydatpt < data+npts ) {
            if ( *mydatpt > *locmax ) locmax = mydatpt;
            if ( *mydatpt < *locmin ) locmin = mydatpt;
            mydatpt++;
        }
        
    }
    values[MIN] = *locmin;
    values[MAX] = *locmax;
    values[RMAX] = rmax;
    values[RMIN] = rmin;
    values[GMAX] = gmax;
    values[GMIN] = gmin;
    values[BMAX] = bmax;
    values[BMIN] = bmin;
    
    specs[LMIN] = (int)(locmin - data);
    specs[LMAX] = (int)(locmax - data);
    specs[LRMIN] = (int)(locrmin - data);
    specs[LRMAX] = (int)(locrmax - data);
    specs[LGMIN] = (int)(locgmin - data - npts/3);
    specs[LGMAX] = (int)(locgmax - data - npts/3);
    specs[LBMIN] = (int)(locbmin - data - 2*npts/3);
    specs[LBMAX] = (int)(locbmax - data - 2*npts/3);

    specs[HAVE_MAX] = 1;
    
    /*
     lmx = (int) (locmax - datpt - doffset);
     lmn = (int) (locmin - datpt - doffset);
     n = header[NCHAN];
     header[LMAX] = lmx/n;	      		// This is the row of the max 
     header[NMAX] = lmx - lmx/n*n;   	// Column of max 
     header[LMIN] = lmn/n;	      		// This is the row of the min 
     header[NMIN] = lmn - lmn/n*n;   	// Column of min 
     */
    
    if(specs[IS_COLOR]){
        printf4("Red Maximum %g at Row %d and Column %d\n", values[RMAX], specs[LRMAX]/specs[COLS], specs[LRMAX]%specs[COLS]);
        printf4("Red Minimum %g at Row %d and Column %d\n\n", values[RMIN], specs[LRMIN]/specs[COLS], specs[LRMIN]%specs[COLS]);

        printf4("Green Maximum %g at Row %d and Column %d\n", values[GMAX], specs[LGMAX]/specs[COLS], specs[LGMAX]%specs[COLS]);
        printf4("Green Minimum %g at Row %d and Column %d\n\n", values[GMIN], specs[LGMIN]/specs[COLS], specs[LGMIN]%specs[COLS]);

        printf4("Blue Maximum %g at Row %d and Column %d\n", values[BMAX], specs[LBMAX]/specs[COLS], specs[LBMAX]%specs[COLS]);
        printf4("Blue Minimum %g at Row %d and Column %d\n", values[BMIN], specs[LBMIN]/specs[COLS], specs[LBMIN]%specs[COLS]);

    } else {
        printf4("Maximum %g at Row %d and Column %d\n", values[MAX], specs[LMAX]/specs[COLS], specs[LMAX]%specs[COLS]);
        printf4("Minimum %g at Row %d and Column %d\n", values[MIN], specs[LMIN]/specs[COLS], specs[LMIN]%specs[COLS]);
    }
    
}

DATAWORD Image::getpix(int r ,int c)   // get a pixel value at the specified row and column
{
	if (data == NULL) return 0.;
	if(c < 0) c = 0;
	if(r < 0) r = 0;
	if(c > specs[COLS]-1) c = specs[COLS]-1;
	if(r > specs[ROWS]-1) r = specs[ROWS]-1;
	return  *(data + c + r*specs[COLS]);
}

DATAWORD Image::getpix(float yi, float xi)

{
	float z,xf,yf;
	int ix,iy;
	DATAWORD z1,z2,z3,z4,a00,a11,a10,a01;

	ix = xi;
	iy = yi;
	
	if( (ix+1) == specs[COLS] || (iy+1) == specs[ROWS]) 
		return(getpix(iy,ix));
	
	xf = xi - ix;	/* the fraction part */
	yf = yi - iy;
	//		z3-----------z4
	//		|             |
	//		|             |
	//		|             |
	//		|             |
	//		|             |
	//      z1-----------z2
	
	z1 = getpix(iy,ix);
	z2 = getpix(iy,ix+1);
	z3 = getpix(iy+1,ix);
	z4 = getpix(iy+1,ix+1);

	// Bilinear Interpolation
    
	a00 = z1;
	a10 = z2 - z1;
	a01 = z3 - z1;
	a11 = z1 - z2 - z3 + z4;
	z = a00 + a10*xf + a01*yf + a11*xf*yf;
	
	return(z);
	
}


void Image::setpix(int r ,int c,DATAWORD val)   // set a pixel value at the specified row and column
{
	if (data == NULL) return;
	if(c < 0) c = 0;
	if(r < 0) r = 0;
	if(c > specs[COLS]-1) c = specs[COLS]-1;
	if(r > specs[ROWS]-1) r = specs[ROWS]-1;
    *(data + c + r*specs[COLS]) = val;
}

int* Image::getspecs(){
    int* thespecs;
    thespecs = new int [NSPECS];
    for(int i=0; i<NSPECS; i++){
        thespecs[i] = specs[i];
    }
    return thespecs;
}

DATAWORD* Image::getvalues(){
   DATAWORD* thevalues = new DATAWORD[NVALUES];
    for(int i=0; i<NVALUES; i++){
        thevalues[i] = values[i];
    }
    return thevalues;
}

char* Image::getunit_text(){
    char* thetext = new char[NRULERCHAR];
    for(int i=0; i<NRULERCHAR; i++){
        thetext[i] = unit_text[i];
    }
    return thetext;
}


void Image::setspecs(int* newspecs){
    // resize if necessary
    if(newspecs[ROWS]*newspecs[COLS] != specs[ROWS]*specs[COLS]){
        delete[] data;
        data =  new DATAWORD[newspecs[ROWS]*newspecs[COLS]];
        if (data==NULL) {
            specs[ROWS]=specs[COLS]=0;
            error = MEM_ERR;
            return;
        }
    }
    for(int i=0; i<NSPECS; i++){
        specs[i] = newspecs[i];
    }
}

void Image::copyABD(Image im){    // copy All But Data from one image to another
    int i;
    for( i=0; i<NSPECS; i++){
        specs[i] = im.specs[i];
    }
    for( i=0; i<NVALUES; i++){
        values[i] = im.values[i];
    }

    for( i=0; i<NRULERCHAR; i++){
        unit_text[i] = im.unit_text[i];
    }

    error = im.error;
    is_big_endian = im.is_big_endian;
}

void Image::crop(rect crop_rect){
    int sizx,sizy,x0,y0;

    x0 = crop_rect.ul.h;
    y0 = crop_rect.ul.v;
    sizx = crop_rect.lr.h - crop_rect.ul.h +1;
    sizy = crop_rect.lr.v - crop_rect.ul.v +1;
    
    if(x0 + sizx > specs[COLS] || y0 + sizy > specs[ROWS]){
        //beep();
        printf1("Rectangle is not contained within the current image.\n");
        error = SIZE_ERR;
        //return *this;
        return;
    }
    
    int save_rgb_rectangle = specs[IS_COLOR];
    
    if(save_rgb_rectangle){
        if( y0 + sizy*3 >= specs[ROWS] ){
            //beep();
            printf1("Can't save rectangle as RGB image -- rectangle size problem.\n");
            error = SIZE_ERR;
            //return *this;
            return;
        } else {
            sizy *= 3;
        }
    }
    
    // get a new image
    Image cropped_image(sizy,sizx);
    if (cropped_image.err()) {
        error = MEM_ERR;
        //return *this;
        return;
    }
    
    cropped_image.copyABD(*this); // copy all but the data from the current image
    
    int i=0;
    for (int image_part = 0; image_part < (2 * save_rgb_rectangle)+1 ; image_part++){
		for(int nt=y0+image_part*specs[ROWS]/3; nt<=crop_rect.lr.v+image_part*specs[ROWS]/3; nt++) {
			for(int nc=x0; nc<=crop_rect.lr.h;nc++){
				*(cropped_image.data + i++) = *(data + nc + nt*specs[COLS]);
			}
		}
	}

    printf3("%d x %d Image.\n",sizx,sizy);
	printf3("Current image starts at: %d\t%d\n",x0,y0);
    
    cropped_image.specs[X0] = x0*specs[DX];
    cropped_image.specs[Y0] = y0*specs[DY];
    cropped_image.specs[ROWS] = sizy;
    cropped_image.specs[COLS] = sizx;
    cropped_image.specs[HAVE_MAX] = 0;
    
    this->free();
    *this = cropped_image;
    //return *this;
}

void Image::invert(){
    int size,i,ncolors;
	DATAWORD *datp2,*datp,temp;
	if (specs[IS_COLOR]) {
        size = specs[ROWS] * specs[COLS]/3;
        ncolors = 3;
    } else {
        size = specs[ROWS] * specs[COLS];
        ncolors=1;
    }
    for(int c=0; c<ncolors;c++){
        datp = data + c*size;
        datp2 = data + (c+1)*size -1;
        for(i=0; i < size/2 ; i++){
            temp = *(datp+i);
            *(datp+i) = *(datp2-i);
            *(datp2-i) = temp;
        }
    }
    if (ncolors == 1) {
        specs[LMAX] = size-1-specs[LMAX];
        specs[LMIN] = size-1-specs[LMIN];
    } else {
        specs[HAVE_MAX]=0;
    }
    //return *this;
}

void Image::rotate(float angle){
    
    int size,nt,nc,width=0,height=0,midx=0,midy=0,vrel,hrel,i=0;
    float theta,sintheta=0,costheta=1,ntf,ncf,outsideval;
    
    theta = angle / 180.0 * PI;
    sintheta = sin(theta);
    costheta = cos(theta);
    
    if(angle == 180. || angle == -180.){
        invert();
        //return *this;
        return;
    }
    if(angle == 270. || angle == -90.){
        invert();
        angle=90.;
    }
    
    if(angle == 90.) {
        Image rotated(specs[COLS],specs[ROWS]); // new data space
        if(rotated.err()){
            error = MEM_ERR;
            //return *this;
            return;
        }
        rotated.copyABD(*this);                 // copy the specs etc.
        // rotate 90 degrees
        for(nc=specs[COLS]-1; nc >= 0; nc--) {
            for(nt=0; nt<specs[ROWS];nt++){
                *(rotated.data+i++) = *(data + nt*specs[COLS] + nc);
            }
        }
        
        rotated.specs[COLS] = specs[ROWS];
        rotated.specs[ROWS] = specs[COLS];
        rotated.specs[X0] = specs[Y0];
        rotated.specs[Y0] = specs[X0];
        rotated.specs[DX] = specs[DY];
        rotated.specs[DY] = specs[DX];
        
        rotated.specs[HAVE_MAX]=0;
        free();   // free old data buffer
        *this = rotated;
        //return *this;
        return;
    } else {
        printf3("%f theta, %f sin, ",theta,sintheta);
        printf2("%f cos\n",costheta);
        
        width = specs[COLS]*fabs(costheta) + specs[ROWS]*fabs(sintheta);
        height = specs[ROWS]*fabs(costheta) + specs[COLS]*fabs(sintheta);
        midx = width/2;
        midy = height/2;
        size = width * height;
        printf3("%d %d width height\n",width,height);
        
        Image rotated(width,height); // new data space
        if(rotated.err()){
            error = MEM_ERR;
            //return *this;
            return;
        }
        rotated.copyABD(*this);                 // copy the specs etc.

        // for points outside the image, calculate the average of the perimeter
        outsideval = 0.0;
        for(nc=0; nc<specs[COLS]; nc++) {
            outsideval += *(data+nc);   //idat(0,nc);
            outsideval += *(data+nc+(specs[ROWS]-1)*specs[COLS]);
        }
        for(nt=1; nt<specs[ROWS]-1; nt++) {
            outsideval += *(data+nt*specs[COLS]); // idat(nt,0);
            outsideval += *(data+nt*specs[COLS]+specs[COLS]-1); // idat(nt,specs[COLS]-1);
        }
        outsideval = outsideval/(specs[COLS]+specs[ROWS]-2)/2;
        for(nt=0; nt<height;nt++){
            vrel = nt - midy;
            for(nc=0; nc<width; nc++) {
                hrel = nc-midx;
                ncf = hrel*costheta - vrel*sintheta + specs[COLS]/2.0;
                ntf = vrel*costheta + hrel*sintheta + specs[ROWS]/2.0;
                if( (ntf >= 0.0) && (ntf < (float)specs[ROWS]) &&
                   (ncf >= 0.0) && (ncf < (float)specs[COLS])   ) {
                    *(rotated.data+i++) = this->getpix(ntf,ncf);
                } else {
                    
                    *(rotated.data+i++) = outsideval;	
                }
            }
        }
        
        rotated.specs[COLS] = width;
        rotated.specs[ROWS] = height;
        rotated.specs[HAVE_MAX]=0;
        
        this->free();   // free old data buffer
        *this = rotated;
        //return *this;
        return;
    }
}

void Image::rgb2color(int color){
    rect cropr = {{0,0},{specs[COLS]-1,0}};
    int height=specs[ROWS]/3;
    cropr.ul.v = color*height;
    cropr.lr.v = color*height+height-1;
    // now have the crop rectangle
    specs[IS_COLOR] = 0;    // we're not color any more
    this->crop(cropr);
    //return *this;
}

void Image::composite(Image bottom){
    if( this->specs[COLS] != bottom.specs[COLS]){   // images have to be the same width
        error = SIZE_ERR;
        //return *this;
        return;
    }
    Image newim;            // an empty image
    newim.copyABD(*this);   // get the current specs    
    newim.data = new DATAWORD[(specs[ROWS]+bottom.specs[ROWS])* specs[COLS]]; // allocate space
    if (newim.data == NULL) {
        error = MEM_ERR;
        //return *this;
        return;
    }
    newim.specs[ROWS] = specs[ROWS]+bottom.specs[ROWS];
    // copy the data from the top (current) image
    int i;
    for(i=0; i<specs[ROWS]*specs[COLS]; i++){
        *(newim.data+i) = *(data+i);
    }
    // copy the data from the bottom image
    for(int j=0; j<bottom.specs[ROWS]*bottom.specs[COLS]; j++){
        *(newim.data+i++) = *(bottom.data+j);
    }
    
    newim.specs[HAVE_MAX] = 0;
    this->free();   // free old data buffer
    *this = newim;
    //return *this;
}
