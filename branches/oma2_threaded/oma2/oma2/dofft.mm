/*OMAX -- Photometric Image Processing and DisplayCopyright (C) 2006  by the Developers of OMAThis program is free software; you can redistribute it and/ormodify it under the terms of the GNU General Public Licenseas published by the Free Software Foundation; either version 2of the License, or (at your option) any later version.This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with this program; if not, write to the Free SoftwareFoundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.*/#include "dofft.h"#include "image.h"#include "ImageBitmap.h"extern Image   iBuffer;/* ***************** *//* fft 0 n		return the magnitude scaled by n fft 1 n		return the real part scaled by n fft 2 n		return the imaginary part scaled by n fft 3 n		return inverse - input is real part scaled by n fft 4 n		return inverse - input is imaginary part scaled by n fft 5 n		return the log of the magnitude squared scaled by n fft 6 n		return the magnitude squared scaled by n fft 7 n		return the autocorrelation scaled by n fft 8 n		return inverse - input is a filter scaled by n  */float 	*a,*b,*work1,*work2;float	*x,*y;Boolean	is_fft = false;Boolean	is_fft_memory = false;int dofft(int n,char* args) // fourier transform of the data array{	int size,i,j,k;	DATAWORD *datp;	static int n1 = 0;	static int n2 = 0;	float scale = 1.0;		/* in case no scale factor is specified */    	/* Check to see if there was a second argument */	    sscanf(args,"%d %f",&n,&scale);	int nChan = iBuffer.specs[COLS];	int nTrak = iBuffer.specs[ROWS];		size = nChan*nTrak;	datp = iBuffer.data;		if( (nChan == 1 && !is_power_2(nTrak))  ||       (nTrak == 1 && !is_power_2(nChan)) ) {		beep();		printf("Array size must be a power of 2.\n");		return SIZE_ERR;	}	if( nChan!= 1 && nTrak != 1) {		if ( !is_power_2(nChan) || !is_power_2(nTrak) ) {			beep();			printf("Image size must be a power of 2.\n");			return SIZE_ERR;		}	}	/* --------------------------------------------------------- */	/*			1 D Case		returns magnitude only			 */	/* --------------------------------------------------------- */		if( nChan == 1 || nTrak == 1 ) {	/* the 1-D case */		printf(" 1-D transform returns magnitude only.\n");		x = (float *)malloc(size*4);		y = (float *)malloc(size*4);        		if( x==0 || y==0 ) {			nomemory();			return MEM_ERR;		}                		for(i=0; i<size; i++){			x[i] = *(datp++);			y[i] = 0.0;		}        		fastf(x,y,&size);        datp = iBuffer.data;        		for(i=0; i<size; i++){			*(datp++) = sqrt(x[i]*x[i] + y[i]*y[i])*scale;            /*	*(datp++) = x[i]*scale;		*/		}		free(x);		free(y);        iBuffer.getmaxx();        update_UI();		return NO_ERR;			}		/* --------------------------------------------------------- */	/*						End	1 D Case						 */	/* --------------------------------------------------------- */    		/* --------------------------------------------------------- */	/*					Inverse Transform Cases					 */	/* --------------------------------------------------------- */    	if( n == 3) {		if( !is_fft_memory ) {			beep();			printf("No FFT. Can't do inverse.\n");			return CMND_ERR;		}        		if( n1 != nChan || n2 != nTrak ) {			beep();			printf("Size of FFT Does Not Match Current Image.\n");			return SIZE_ERR;		}        		for(i=0; i<size; i++) {			a[i] =  *(datp++);			a[i] /= scale;		}		n1 = -n1;		n2 = -n2;        		FT2D(a,b,work1,work2,&n1,&n2);        		datp = iBuffer.data;		k = 0;		for(i=1; i<=nTrak; i++) {			for(j=1; j<=nChan; j++) {				if( 1 & (i+j))					*(datp++) = -a[k]; 	/* for optical rather than standard ordering */				else					*(datp++) = a[k];				k++;			}		}        iBuffer.getmaxx();        update_UI();		return NO_ERR;	}	if( n == 4) {		if( !is_fft_memory ) {			beep();			printf("No FFT. Can't do inverse.\n");			return CMND_ERR;		}		if( n1 != nChan || n2 != nTrak ) {			beep();			printf("Size of FFT Does Not Match Current Image.\n");			return SIZE_ERR;		}        		for(i=0; i<nTrak*nChan; i++) {			b[i] =  *(datp++);			b[i] /= scale;		}		n1 = -n1;		n2 = -n2;        		FT2D(a,b,work1,work2,&n1,&n2);        		datp = iBuffer.data;		k = 0;		for(i=1; i<=nTrak; i++) {			for(j=1; j<=nChan; j++) {				if( 1 & (i+j))					*(datp++) = -a[k]; 	/* for optical rather than standard ordering */				else					*(datp++) = a[k];				k++;			}		}        iBuffer.getmaxx();        update_UI();		return NO_ERR;	}    	if( n == 8) {		if( !is_fft_memory ) {			beep();			printf("No FFT. Can't do inverse.\n");			return CMND_ERR;		}		if( n1 != nChan || n2 != nTrak ) {			beep();			printf("Size of FFT Does Not Match Current Image.\n");			return SIZE_ERR;		}        		printf("Using Input as a Filter.\n");        		for(i=0; i<nTrak*nChan; i++) {			a[i] = a[i] * (*(datp)) / scale;			b[i] = b[i] * (*(datp++)) / scale;		}		n1 = -n1;		n2 = -n2;        		FT2D(a,b,work1,work2,&n1,&n2);        		datp = iBuffer.data;		k = 0;		for(i=1; i<=nTrak; i++) {			for(j=1; j<=nChan; j++) {				if( 1 & (i+j))					*(datp++) = -a[k]; 	/* for optical rather than standard ordering */				else					*(datp++) = a[k];				k++;			}		}        iBuffer.getmaxx();        update_UI();		return NO_ERR;	}	/* --------------------------------------------------------- */	/*				End of Inverse Transform Cases				 */	/* --------------------------------------------------------- */    	if( n1 != nChan || n2 != nTrak ) {		if( is_fft_memory) {		/* sizes have changed, have to reallocate */			free(a);			free(b);			free(work1);			free(work2);			is_fft_memory = false;		}	}    	n1 = nChan;	n2 = nTrak;    	if( !is_fft_memory ) {		a = (float *)malloc(size*4);		b = (float *)malloc(size*4);		work1 = (float *)malloc(n2*4);		work2 = (float *)malloc(n2*4);		if( a==0 || b==0 || work1==0 || work2 == 0) {			nomemory();			return MEM_ERR;		}		else {			is_fft_memory = true;		}	}		k = 0;	for(i=1; i<=nTrak; i++) {		for(j=1; j<=nChan; j++) {			if( 1 & (i+j))				a[k] =  -(*(datp++)); 	/* for optical rather than standard ordering */			else				a[k] = *(datp++);			b[k] = 0.0;			k++;		}	}    	FT2D(a,b,work1,work2,&n1,&n2);	datp = iBuffer.data;		switch (n) {		case 0:			for(i=0; i<nTrak*nChan; i++) {				*(datp++) = sqrt(a[i]*a[i] + b[i]*b[i])*scale;			}			break;		case 1:			for(i=0; i<nTrak*nChan; i++) {				*(datp++) = a[i]*scale;			}			break;		case 2:			for(i=0; i<nTrak*nChan; i++) {				*(datp++) = b[i]*scale;			}			break;		case 5:			for(i=0; i<nTrak*nChan; i++) {				*(datp++) = log(a[i]*a[i] + b[i]*b[i])*scale;			}			break;		case 6:			for(i=0; i<nTrak*nChan; i++) {				*(datp++) = (a[i]*a[i] + b[i]*b[i])*scale;			}			break;		case 7:			k = 0;			for(i=1; i<=nTrak; i++) {				for(j=1; j<=nChan; j++) {					a[k] = (a[k]*a[k] + b[k]*b[k]);					if( 1 & (i+j))						a[k] =  -a[k]; 	/* for optical rather than standard ordering */					b[k] = 0.0;					k++;				}			}			n1 = -n1;			n2 = -n2;            			FT2D(a,b,work1,work2,&n1,&n2);            			for(i=0; i<nTrak*nChan; i++) {				*(datp++) = sqrt(a[i]*a[i] + b[i]*b[i])*scale;			}			break;		case 9:			k = 0;			for(i=1; i<=nTrak; i++) {				for(j=1; j<=nChan; j++) {					if( 1 & (i+j))						b[k] =  -b[k]; 	/* for optical rather than standard ordering */					k++;				}			}            			for(i=0; i<nTrak*nChan; i++) {				*(datp++) = b[i]*scale;			}			break;            	}	// end switch     iBuffer.getmaxx();    update_UI();	return NO_ERR;}int is_power_2(int i)			/* checks for power of 2 < 2^20 and >= 4 */{	int mask = 1;	int bits_set = 0;	int j;	for(j=0; j<20; j++) {		if( mask & i) 			bits_set++;			mask = mask << 1;	}	if( bits_set != 1  || i<4)		return(0);	else		return(1);}/*---------------------------------------------------------------------------*/int FASTF(float xreal[],float ximag[], int *isize){	int n,ifacc,ifaca,itime,litla,i0,i1,ii;	int j1,j2,j3,j4,j5,j6,j7,j8,j9,j10,j11,j12;	int l[12],k,ifcab,i2,i3;		float bcos,xs0,xs1,xs2,xs3,ys0,ys1,ys2,ys3,x1,y1,x2,y2,x3,y3;	float cw1,cw2=0,cw3=0,sw1,sw2=0,sw3=0,z,tempr,bsin;		n = abs(*isize);		if(n < 4) return -1;/* SET UP INITIAL VALUES OF TRANSFORM SPLIT */	ifacc = 1;	if(*isize < 0) {		/* IF THIS IS TO BE AN INVERSE TRANSFORM, CONJUGATE THE DATA */		for(k=0; k<n; k++) ximag[k] = -ximag[k];	}	itime = 0;	for(ifaca = n/4; ifaca > 0; ifaca/=4) {		ifcab = ifaca*4;		itime +=2;/*		do the transforms required by this stage */		z=PI/ifcab;		bcos=-2.*(sin(z)*sin(z));		bsin=sin(2.*z);		cw1=1.;		sw1=0.;		for(litla=0; litla<ifaca; litla++) {	  		for(i0=litla; i0<n; i0+=ifcab) {				/* THIS IS THE MAIN CALCULATION OF RADIX 4 TRANSFORMS */				i1=i0+ifaca;				i2=i1+ifaca;				i3=i2+ifaca;				xs0=xreal[i0]+xreal[i2];				xs1=xreal[i0]-xreal[i2];				ys0=ximag[i0]+ximag[i2];				ys1=ximag[i0]-ximag[i2];				xs2=xreal[i1]+xreal[i3];				xs3=xreal[i1]-xreal[i3];				ys2=ximag[i1]+ximag[i3];				ys3=ximag[i1]-ximag[i3];				xreal[i0]=xs0+xs2;				ximag[i0]=ys0+ys2;				x1=xs1+ys3;				y1=ys1-xs3;				x2=xs0-xs2;				y2=ys0-ys2;				x3=xs1-ys3;				y3=ys1+xs3;				if(litla==0) {					xreal[i2]=x1;					ximag[i2]=y1;					xreal[i1]=x2;					ximag[i1]=y2;					xreal[i3]=x3;					ximag[i3]=y3;				} else {					/* MULTIPLY BY TWIDDLE FACTORS IF REQUIRED */					xreal[i2]=x1*cw1+y1*sw1;					ximag[i2]=y1*cw1-x1*sw1;					xreal[i1]=x2*cw2+y2*sw2;					ximag[i1]=y2*cw2-x2*sw2;					xreal[i3]=x3*cw3+y3*sw3;					ximag[i3]=y3*cw3-x3*sw3;				}			} /* 8 */			if(litla < ifaca-1) {				/* CALCULATE A NEW SET OF TWIDDLE FACTORS */				z=cw1*bcos-sw1*bsin+cw1;				sw1=bcos*sw1+bsin*cw1+sw1;				tempr=1.5-0.5*(z*z+sw1*sw1);				cw1=z*tempr;				sw1=sw1*tempr;				cw2=cw1*cw1-sw1*sw1;				sw2=2.*cw1*sw1;				cw3=cw1*cw2-sw1*sw2;				sw3=cw1*sw2+cw2*sw1;			}		}  /* 10 */		if( ifaca > 1) {			/* SET UP THE TRANSFORM SPLIT FOR THE NEXT STAGE */			ifacc *= 4;		} else goto L14;	} /* 	THIS IS THE CALCULATION OF A RADIX TWO STAGE */	for(k=0; k<n; k+=2) {		tempr=xreal[k]+xreal[k+1];		xreal[k+1]=xreal[k]-xreal[k+1];		xreal[k]=tempr;		tempr=ximag[k]+ximag[k+1];		ximag[k+1]=ximag[k]-ximag[k+1];		ximag[k]=tempr;	}	itime++;L14:	if(*isize <0) {		/* IF THIS WAS AN INVERSE TRANSFORM, CONJUGATE THE RESULT */		for(k=0; k<n; k++) ximag[k] = -ximag[k];	} else {		/* IF THIS WAS A FORWARD TRANSFORM, SCALE THE RESULT */		z=1./n;		for(k=0; k<n; k++) {			xreal[k]=xreal[k]*z;			ximag[k]=ximag[k]*z;		}	}	/* UNSCRAMBLE THE RESULT */	i1 = 12 - itime;	for(k=0; k<i1; k++) {		l[k] = 1;	} /* 20 */	ii = 1;	for( k=i1; k< 12; k++) {		ii *= 2;		l[k] = ii;		}	ii = 0;	for(j1=0; j1<l[0]; j1++) {		 for(j2=j1; j2<l[1]; j2+=l[0]) {		  for(j3=j2; j3<l[2]; j3+=l[1]) {		   for(j4=j3; j4<l[3]; j4+=l[2]) {		    for(j5=j4; j5<l[4]; j5+=l[3]) {		     for(j6=j5; j6<l[5]; j6+=l[4]) {		      for(j7=j6; j7<l[6]; j7+=l[5]) {		       for(j8=j7; j8<l[7]; j8+=l[6]) {		        for(j9=j8; j9<l[8]; j9+=l[7]) {		         for(j10=j9; j10<l[9]; j10+=l[8]) {		          for(j11=j10; j11<l[10]; j11+=l[9]) {		           for(j12=j11; j12<l[11]; j12+=l[10]) {						if(ii<j12) {						tempr=xreal[ii];						xreal[ii]=xreal[j12];						xreal[j12]=tempr;						tempr=ximag[ii];						ximag[ii]=ximag[j12];						ximag[j12]=tempr;					}					ii++;			   }              }             }            }           }          }         }        }       }      }     }    }	return 0;}void fastf(float r[],float i[], int *n){	int k,nn,isign;	float x[4096];		nn = abs(*n);	if (*n<0) 		isign = -1;	else 		isign = 1;			for( k=0; k<nn; k++){		x[k*2] = r[k];		x[k*2+1] = i[k];	}	four1(x-1,nn,isign);		for( k=0; k<nn; k++){		r[k] = x[k*2];		i[k] = x[k*2+1];		if (isign == 1) {			r[k] /=nn;			i[k] /=nn;		}	}	}int FT2D(float a[],float b[],float work1[],float work2[] ,int *n1,int *n2){	int m1,m2,k,l,kk;		m1 = abs(*n1);	m2 = abs(*n2);	/* DO THE ROWS IN WORKING ARRAYS */	for(k=0; k<m1; k++) {		for(l=0; l<m2; l++) {					kk=k+m1*l;			work1[l]=a[kk];			work2[l]=b[kk];		}		FASTF(work1,work2,n2);		for(l=0; l<m2; l++) {					kk=k+m1*l;			a[kk]=work1[l];			b[kk]=work2[l];		}	}	/* DO THE COLUMNS IN PLACE */	for(k=0; k<m2; k++) {		kk=m1*k;		FASTF(&a[kk],&b[kk],n1);	}	return 0;}#define SWAP(a,b) tempr=(a);(a)=(b);(b)=temprvoid four1(float data[],int nn,int isign){	int n, mmax,m,j,istep,i;	double wtemp,wr,wpr,wpi,wi,theta;	//Double precision for the trigonometric		float tempr, tempi;				 	//recurrences.		n=nn << 1;	j=1;	for (i=1;i<n;i+=2) {				//This is the bit-reversal section of the routine					if (j > i) {					    SWAP(data[j],data[i]);		//Exchange the two complex numbers.		    SWAP(data[j+1],data[i+1]);		}		m=n >> 1;		while (m >=2 && j > m) {		    j -= m;		    m >>= 1;		}		j += m;	}	mmax=2;								//Here begins the danielson-Lanczos section of the routine	while (n > mmax) {					//Outer loop executed log2 nn times.		istep=2*mmax;		theta=6.28318530717959/(isign*mmax);	//Initalize for the trigonometric 				wtemp=sin(0.5*theta);					//recurrence.		wpr = -2.0*wtemp*wtemp;		wpi=sin(theta);		wr=1.0;		wi=0.0;		for (m=1;m<mmax;m+=2) {					//Here are the two nested inner loops.		      for (i=m;i<=n;i+=istep) {		        j=i+mmax;						//This is the Danielson-Lanczos formula:			 	tempr=wr*data[j]-wi*data[j+1];			 	tempi=wr*data[j+1]+wi*data[j];			 	data[j]=data[i]-tempr;			 	data[j+1]=data[i+1]-tempi;			 	data[i] += tempr;			 	data[i+1] += tempi;			}										//Trigonometric recurrence.			wr=(wtemp=wr)*wpr-wi*wpi+wr;			wi=wi*wpr+wtemp*wpi+wi;		}		mmax=istep;	}}void realft(float data[],int n,int isign){	int i,i1,i2,i3,i4,n2p3;	float c1=0.5,c2,h1r,h1i,h2r,h2i;	double wr,wi,wpr,wpi,wtemp,theta;		//Double precison for the trigonometric 	                                            //recurrences.		theta=3.141592653589793/(double) n;		//Initialize the recurrence.	if (isign == 1) {		c2 = -0.5;		four1(data,n,1);					//The forward transform is here.	} else {		c2=0.5;								//Otherwise set up for an inverse transform.		theta = -theta;						}	wtemp=sin(0.5*theta);	wpr = -2.0*wtemp*wtemp;	wpi=sin(theta);	wr=1.0+wpr;	wi=wpi;	n2p3=2*n+3;	for (i=2;i<=n/2;i++) {					//Case i=1 done separately below.		i4=1+(i3=n2p3-(i2=1+(i1=i+i-1)));		h1r=c1*(data[i1]+data[i3]);			//The two separate transforms are separated		h1i=c1*(data[i2]-data[i4]);			//out of data.		h2r = -c2*(data[i2]+data[i4]);		h2i=c2*(data[i1]-data[i3]);		data[i1]=h1r+wr*h2r-wi*h2i;			//Here they are recombined to form the true		data[i2]=h1i+wr*h2i+wi*h2r;			//transorm of the original real data.		data[i3]=h1r-wr*h2r+wi*h2i;		data[i4] = -h1i+wr*h2i+wi*h2r;		wr=(wtemp=wr)*wpr-wi*wpi+wr;		//The recurrence.		wi=wi*wpr+wtemp*wpi+wi;	}	if (isign == 1) {		data[1] = (h1r=data[1])+data[2];		//Squeeze the first and last data together to get		data[2] = h1r-data[2];				//them all within the original array.	} else {		data[1]=c1*((h1r=data[1])+data[2]);		data[2]=c1*(h1r-data[2]);			//This is the inverse transform for the case 				four1(data,n,-1);					//isign=-1.	}}