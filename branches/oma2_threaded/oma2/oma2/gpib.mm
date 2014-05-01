/*
OMAX -- Photometric Image Processing and Display
Copyright (C) 2006  by the Developers of OMA

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/

#ifdef VISA

#include <stdio.h>
#include <stdlib.h>

#include <VISA/visa.h>

#include "oma2.h"
#include "UI.h"

#include "gpib.h"

static char instrDescriptor[VI_FIND_BUFLEN];
static ViUInt32 numInstrs;
static ViFindList findList;
static ViSession defaultRM, instr;
static ViStatus status;
static ViUInt32 retCount;
static ViUInt32 writeCount;
static ViEvent ehandle;
static ViEventType etype;


//-----------------------------------------------------------------------------------

extern char	   syncflag;
int io_err = 0;


/* ********** */

int synch(int n,char* args)	// Set flag for CC200/uVAX synchronization
{
	syncflag = n;
	return io_err;
}

/* ********** */

int conect(int n,char* args)
{
	if( n < 0 ) {
		n = abs(n);
		if( n > 8 ) n = 8;
		omaio(FORCE_INIT,n,NULL);
	} else {
		if( n > 8 ) n = 8;
		if( n == 0 ) n=1;
		omaio(INIT,n,NULL);
	}
	return io_err;
}

/* ********** */

int run(int n,char* args)
{
	omaio(RUN,0,NULL);
	return io_err;
}
/* ********** */


int discon(int n,char* args)
{
	omaio(BYE,0,NULL);
	return io_err;
}

/* ********** */

int inform(int n,char* args)
{
	omaio(INFO,0,NULL);
	return io_err;
}
/* ********** */

int flush(int n,char* args)
{
	omaio(FLUSH,0,NULL);
	return io_err;
}

/* ********** */

int send(int n,char* args)
{
	
	//strcpy(txt,args);
	omaio(SEND,0,args);
	return io_err;
}

/* ********** */

int ask(int n,char* args)
{
	omaio(ASK,0,NULL);
	return io_err;
}

/* ********** */

int transfer(int n,char* args)
{
	omaio(TRANS,0,NULL);
	return io_err;
}

/* ********** */

int receiv(int n,char* args)
{
//	omaio(TTIME);		// Put time in the log block first 
//	header[NCHAN] = 390;	// allocate a bigish space for this 
//	header[NTRAK] = 590;	// this may be too big but just need to be sure 
//	if(checkpar() == 1) return; 	
	
	omaio(RECEIVE,0,NULL);
//	checkpar();		// go make the buffer the right size
	//have_max = 0;
//	maxx();		Speed up. Put correct min/max in log block 
	return io_err;
}

/* ********** */
int gpibdv(int n,char* args)
{
	extern short dev;
	
	dev = n-1;
	if( dev < 0 ) dev = 0;
	return 0;
}

/* ********** */


//-----------------------------------------------------------------------------------


/* Global variable meanings:

dev -- index that tells what instrument (device) is currently being accessed 
		dev = n-1, where n comes from the "GPIB n" command
dev indexes arrays:

detlist
*/




short	dev = 0;							/* the current gpib device addressed */
short	numdev = 0;							/* the number of active gpib devices */
//short 	devlist[16];						/* a list of gpib devices */
short	detlist[16];						// identifies the detector type for each device 

char instrDescriptorList[16][VI_FIND_BUFLEN];
char	poll;								/* the status of gpib stuff */
short	bd,cam;								/* the board and camera numbers */
short	forceinit = 0;						/* forces "successful" INIT even if error */

short gpib_time_flag = 1;					/* flag that determines if gpib time out is set
											   GPIBTO command */

/* for the Star 1 */

extern int star_time;
extern int star_treg;
extern int star_auto;
extern int star_gain;

/* For Princeton Instruments */
int pi_chan_max[16],pi_track_max[16];
int j5;


int star_send(char* string){

	
	status = viSetAttribute (instr, VI_ATTR_TMO_VALUE, 3000);		// 3 second timeout
	status = viWrite (instr, (ViBuf)string, strlen(string), &writeCount);
	if (status < VI_SUCCESS) {
		printf("    Error writing to the device\n");
		status = viClose(instr);
		return -1;
	}


	if (!syncflag) return 0;			// If no sync, don't wait for CC200 
	
	status = viWaitOnEvent (instr, VI_EVENT_SERVICE_REQ, 3000, &etype, &ehandle);	// wait 3 seconds
	ViUInt16 statusByte;
	viReadSTB (instr, &statusByte);

	return 0;
}

int set_star_param(char* cmd, int value)
{
	extern char txt[];

	sprintf(txt,"%s%d",cmd,value);
	//printf("%s%d",cmd,value);
	status = viWrite (instr, (ViBuf)txt, strlen(txt), &writeCount);
	if (status < VI_SUCCESS) {
		printf("    Error writing to the device\n");
		status = viClose(instr);
		return -1;
	}
	status = viWaitOnEvent (instr, VI_EVENT_SERVICE_REQ, 1000, &etype, &ehandle);	// wait 1 second
	ViUInt16 statusByte;
	viReadSTB (instr, &statusByte);
	//printf("  Status: %x\n",statusByte); 
	if( statusByte == 0x60)
		return 0;
	else if (statusByte == 0x40)
		return 1;
	return 2;
}


int omaio(int code,int index, char* string)
//char string[];
{
	extern int npts;
	extern DATAWORD *datpt;
	extern TWOBYTE header[];
	extern TWOBYTE trailer[];
	extern char cmnd[];
	extern char txt[];
	extern char syncflag;
	extern int  exflag,macflag;
	extern int is_big_endian;
	
	extern int	doffset;
	extern short pixsiz;
	extern char	lastname[];
	extern void redoMenus();
	
	extern short	detector;
	extern Variable user_variables[];
/*	extern int scope_rec;
	extern FILE *fp_scope;*/
	
	// Definitions for National Instruments VAX GPIB subroutines 

	static int bsize = 18000; /* Block size for data transfer */ 
							  /* changed from 32000 (6-2) */
	static char trq = 192;	  /* Device request to talk    */
	static char ccdok = 32;	  	/* CC200 successful command code*/
	static int recimageno;		/* incremented each time a new image is received */

	
	unsigned char wfm[1028];            /* for waveform received from scope   */
	int checksum;						/* for checking whether data read from scope is garbage */
	
	
	int i,j,k,l;
	unsigned char spr;
	char *pointer,ch;
	short ccdheader[HEADERLENGTH] = {0};		/* the 80 word header from the ccd */
	char name[8];						/* for various names */
	
	int two_to_four(DATAWORD* dpt, int num, TWOBYTE scale);
		
	if(code != INIT && code != FORCE_INIT) {
		if( (numdev == 0) ){
			beep();
			printf("Use CONECT First.\n");
			return -1; 
		}
		if( dev < 0 || dev > numdev-1 ) {
			beep();
			printf("Reference to Non-Responding Device\n");
			return -1;
		}
		// get the name of the instrument already opened
		strcpy(instrDescriptor,&instrDescriptorList[dev][0]);
		// open the instrument
		status = viOpen (defaultRM, instrDescriptor, VI_NULL, VI_NULL, &instr);
		if (status < VI_SUCCESS) {
			  printf ("An error occurred opening a session to %s\n",instrDescriptor);
			  return status;
		}
		//  Now we must enable the service request event so that VISA will receive the events.
		status = viEnableEvent (instr, VI_EVENT_SERVICE_REQ, VI_QUEUE, VI_NULL);
	    if (status < VI_SUCCESS){
			printf("The SRQ event could not be enabled");
			status = viClose(instr);
			return -1;
	   }

	}

	switch (code) {
	case FORCE_INIT:
		forceinit = 1;	
	case INIT:		// init gpib  
			numdev = 0;
		   // First we will need to open the default resource manager. This stays open
		   status = viOpenDefaultRM (&defaultRM);
		   if (status < VI_SUCCESS)
		   {
			  printf("Could not open a session to the VISA Resource Manager!\n");
			  return -1;
		   }  

			/*
			 * Find all the VISA resources in our system and store the number of resources
			 * in the system in numInstrs.  Notice the different query descriptions a
			 * that are available.

				Interface         Expression
			--------------------------------------
				GPIB              "GPIB[0-9]*::?*INSTR"
				VXI               "VXI?*INSTR"
				GPIB-VXI          "GPIB-VXI?*INSTR"
				Any VXI           "?*VXI[0-9]*::?*INSTR"
				Serial            "ASRL[0-9]*::?*INSTR"
				PXI               "PXI?*INSTR"
				All instruments   "?*INSTR"
				All resources     "?*"
				visa://cld6.eng.yale.edu/PXI0::6::INSTR
				visa://cld6.eng.yale.edu/GPIB[0-9]*::?*INSTR
			*/
			
			// find GPIB resources
		   status = viFindRsrc (defaultRM,"GPIB[0-9]*::?*INSTR", &findList, &numInstrs, instrDescriptor);
		   if (status < VI_SUCCESS)
		   {
			  printf ("An error occurred while finding resources.\n");
			  viClose (defaultRM);
			  return status;
		   }

		   printf("%d GPIB devices found.",numInstrs);
		   numdev = numInstrs;
		   
		   for(i=0; i< numInstrs; i++){
			   if(i != 0){
				  status = viFindNext (findList, instrDescriptor);  /* find next desriptor */
				  if (status < VI_SUCCESS) 
				  {   /* did we find the next resource? */
					 printf ("An error occurred finding the next resource.");
					 //viClose (defaultRM);
					 continue; 
				  } 
				}

			   detlist[i] = STAR_1;
			   printf("\nGPIB %d:\t%s \n",i+1,instrDescriptor);

			   // Now we will open a session to the instrument we just found.
			   status = viOpen (defaultRM, instrDescriptor, VI_NULL, VI_NULL, &instr);
			   if (status < VI_SUCCESS) {
				  printf ("An error occurred opening a session to %s\n",instrDescriptor);
				  return status;
			   } else {
					strcpy(&instrDescriptorList[i][0],instrDescriptor);
					status = viSetAttribute (instr, VI_ATTR_TMO_VALUE, 1000);		// 1 second timeout
					strcpy(name,"ID?");
					status = viWrite (instr, (ViBuf)name, strlen(name), &writeCount);
					if (status < VI_SUCCESS) {
						printf("    Error writing to the device\n");
						status = viClose(instr);
						continue;
					}
					status = viRead (instr, wfm, 100, &retCount);
					if (status < VI_SUCCESS) {
						// no response from the ID querry, look for specific cameras that we have
						// first, the STAR 1
						star_send("!A2");	// try to set and read the exposure time
						star_send("@A");
						status = viRead (instr, wfm, 100, &retCount);
						if (status < VI_SUCCESS) { // it's not a STAR 1
								printf("    Error reading a response from the device\n");
								status = viClose(instr);
								continue;
						}
						// just check to be sure this is right
						sscanf((char*)wfm,"%d",&l);
						if( l == 2){
							  printf("\tSTAR 1\n");
							  status = viClose(instr);
							  continue;
						}
						printf("    Error reading a response from the device\n");
						status = viClose(instr);
						continue;
				   } else {
					if ((strspn((char*)wfm,"TEK") >= 3) || (strspn((char*)wfm,"ID TEK") >= 5)) {
						detlist[i] = OSCOPE;
						printf("\tTEK SCOPE\n"); 
					}
					printf("\tData read: %*s\n",retCount,wfm);
				   }
					viClose (instr);
			   }
			}

		   status = viClose(findList);
		   //status = viClose (defaultRM);
			
	
		break;


	case BYE:		/* Put the controller back in local */
		//ibloc(cam);	
		break;

	case RECEIVE:		
	
		switch(detlist[dev]) {
		case STAR_1:
		
			//omaio(RUN,0,0);				// first, reset the parameters
			set_star_param("!D",header[NX0]);
			set_star_param("!E",header[NY0]);
			set_star_param("!F",header[NDX]*header[NCHAN]);
			set_star_param("!G",header[NDY]*header[NTRAK]);
			star_send(":S");

			for(j=0; j< HEADERLENGTH; j++)
				*(datpt+j) = ccdheader[j];
 
			j = 0;					
			pointer = (char*)(datpt+HEADERLENGTH/2);

			strcpy(name,":J");
			status = viWrite (instr, (ViBuf)name, strlen(name), &writeCount);
			if (status < VI_SUCCESS) {
				printf("    Error writing to the device\n");
				status = viClose(instr);
				//status = viClose(defaultRM);
				return -1;
			}
			status = viWaitOnEvent (instr, VI_EVENT_SERVICE_REQ, 5000, &etype, &ehandle);	// wait 5 seconds
			ViUInt16 statusByte;
			viReadSTB (instr, &statusByte);
            bsize = header[NCHAN]*2*header[NTRAK];
			status = viRead (instr, (unsigned char*)pointer, bsize, &retCount);
			if (status < VI_SUCCESS) {
				printf("    Error reading a response from the device\n");
				status = viClose(instr);
				//status = viClose(defaultRM);
				return -1;
		   } else {
			  printf("%d Bytes read\n",retCount);
		   }
		   
		   
		   if(is_big_endian){
				pointer = (char*)(datpt + HEADERLENGTH/2);	
				for(i=0; i<header[NCHAN]*2*header[NTRAK]; i+=2) {
					ch = *(pointer+i);
					*(pointer+i) = *(pointer+i+1);
					*(pointer+i+1) = ch;
				}
		   }
			user_variables[0].ivalue = retCount;
			user_variables[0].is_float = 0;

		   two_to_four(datpt,retCount/2,1);
		   

			viClose (instr);

			/*						

			two_to_four(datpt,j/2,1);

		*/


			
			break;
		case PHOTOMETRICS_CC200:

			break;
		case PRINCETON_INSTRUMENTS_1:

			break;
		
		case OSCOPE:
			
			bsize = 1028;             /* time of full scope scan is digitized into 
										1024 one byte segments       */	
			header[NCHAN] = 1024;
			header[NTRAK] = 1;
			header[NDX] = 1;
			header[NDY] = 1;
			header[NX0] = 0;
			header[NY0] = 0;
	   		trailer[SFACTR] = 1;

			if(checkpar() == 1) {
				printf(" %d Channels & %d Tracks Reset to 1.\n",header[NCHAN],header[NTRAK]);
				header[NCHAN] = header[NTRAK] = npts = 1;
				return -1;					/* not enough memory  -- this will leave things unread */
			}	
			
			//ibonl(cam,1);		
			
			//ibwrt(cam,"path off;data encdg:rpbinary",28L);   // gets rid of path string
				//which would precede data and specifies data format as pos. integers
				//from 0-255      */
			
			//ibwrt(cam,"curve?",6L);		  /* tells scope that you want to read waveform */
			star_send("curve?");
			status = viRead (instr, wfm, bsize, &retCount);
			if (status < VI_SUCCESS) {
				printf("    Error writing to the device\n");
				status = viClose(instr);
				return -1;
			}
			status = viClose(instr);
			//ibrsp(cam,&poll);		 /* Clear service reqest  6-2 */
			
			//ibrd(cam,wfm,bsize);          /* read waveform from scope into wfm[] */
			
			
			
			//int nread = ibcnt;
			int nread = retCount;
			printf("%d bytes received\n",nread);
			
			//ibrsp(cam,&poll);		 /* Clear service reqest  6-2 */
			
			user_variables[0].ivalue = nread;
			user_variables[0].is_float = 0;


			checksum = 0;
			for (i = 0; i<nread; i++){
				if((i>0) && (i<nread)){
					checksum += wfm[i];
					checksum = checksum % 256;
				}
				/*if((i<10)||(i>1020)){
					printf("%d    %d\n",i,wfm[i]); 
				}*/
				if((i>2) && (i<nread)){
					*(datpt+i-3+doffset) = wfm[i];
				}
			}
			checksum = 256 - checksum;

			if(checksum != wfm[nread-1]){
				printf("Checksum?\n");
			}
			//ibonl(cam,0);	
			break;				
				
				
		//default:
			//break;
		} /* end of detector type switch for RECEIVE case */
		break; /* end of RECEIVE */
		
	case FLUSH:		/* Flush any data from the controller */
		pointer = (char*)datpt;


		break;

		
	case RUN:	/* fill the command buffer with a ccdformat command */
		
		switch(detlist[dev]) {
		case STAR_1:
			set_star_param("!D",header[NX0]);
			set_star_param("!E",header[NY0]);
			set_star_param("!F",header[NDX]*header[NCHAN]);
			set_star_param("!G",header[NDY]*header[NTRAK]);
			star_send(":S");
			status = viClose(instr);
			break;
		
		case PHOTOMETRICS_CC200:
	
			sprintf(cmnd,"%d %d %d %d %d %d ccdfmt",
		  		header[NX0],header[NY0],header[NCHAN],header[NTRAK],
		  		header[NDX],header[NDY]);
		
			for (i = 0; cmnd[i] != '\0'; i++){};
		
			//ibwrt(cam,cmnd,i);				/* send format command */
			waitreply();
			break;
			
		case PRINCETON_INSTRUMENTS_1:

			if ((header[NX0]+header[NDX]*header[NCHAN]>pi_chan_max[dev]) ||
			   (header[NY0]+header[NDY]*header[NTRAK]>pi_track_max[dev])){
				printf("Invalid CCD specification (%d x %d max)\n",pi_chan_max[dev],
						pi_track_max[dev]);
				beep();
				break;
			}
			/* Wait for bit 0 on jumper J5 to go high (default case) */
//			cmnd[2] =  " "; 
//			j5=0;			
//			while(j5!=5){	
//				ibwrt(cam,"RP",2);	 	// Send query  
//				ibrd(cam,(char*)cmnd,CHPERLN);	 // Read reply  
//				cmnd[ibcnt] = 0;	// put in end of message flag 
//				sscanf(&cmnd[2],"%d",&j5);							
//				printf("%d\n",j5);  								
//			}	 													

			
			sprintf(cmnd,"sdb,1,%d,u,0,%d,%d,b,1,%d",
		  			header[NX0],header[NDX]*header[NCHAN],header[NCHAN],
		 			pi_chan_max[dev] - header[NX0] - header[NDX]*header[NCHAN]);

			for (i = 0; cmnd[i] != '\0'; i++){};

			/* send sdb command */

			//ibwrt(cam,cmnd,i);				
			//ibrsp(cam,&poll);
/*			printf("%s\n",cmnd);*/

			if ((pi_track_max[dev] - header[NY0] - header[NDY]*header[NTRAK])!=0) {
				sprintf(cmnd,"LDb,1,%d,u,0,%d,%d,b,1,%d",
		  				header[NY0],header[NDY]*header[NTRAK],header[NTRAK],
		 	 			pi_track_max[dev] - header[NY0] - header[NDY]*header[NTRAK]);
			}else{
				sprintf(cmnd,"LDb,1,%d,u,0,%d,%d",
		  				header[NY0],header[NDY]*header[NTRAK],header[NTRAK]);
			}
		
			for (i = 0; cmnd[i] != '\0'; i++){};

			/* send ldb command */

			//ibwrt(cam,cmnd,i);				
 			//ibrsp(cam,&poll);	
/*			printf("%s...\npoll %x\n",cmnd,poll);*/

			break;

		default:
			break;
		}
		break;

	case TRANS:		/* Transmit data To the camera controller */

		switch(detlist[dev]) {
		case PHOTOMETRICS_CC200:	
		
			j = i = ( npts + doffset ) * 2 ;  /* the number of bytes */

			/* Now initiate the transfer */
		
			pointer = (char*)datpt;

			//ibwrt(cam,"rcv",3L);  			/* send receive command */
			//ibeot(cam,0);					/* disable EOT messages */
			/*for (ibwrt(cam,pointer,bsize); i >= bsize; ibwrt(cam,pointer,bsize)) {
				pointer += bsize;
				i -= bsize; 
			}
			*/
			//ibeot(cam,1);					/* For this last one, send an end command */
			//ibwrt(cam,pointer,i); 
//			ibrsp(cam,&poll);		 		// Clear service reqest 
			printf("poll: %d\n",poll);
		
			//ibwrt(cam," ",1L);				/* dummy write */
	//		ibrsp(cam,&poll); 

			break;
		case STAR_1:
		case PRINCETON_INSTRUMENTS_1:
			beep();
			printf("Not Used for this Detector.\n");
			break;

		default:
			break;
		}
		break;

	case SEND:		/* Send a command to camera controller */
		switch(detlist[dev]) {
		case OSCOPE:
		case STAR_1:
		case PHOTOMETRICS_CC200:	
			star_send( string);
			status = viClose(instr);
			break;
			
		case PRINCETON_INSTRUMENTS_1:

			for (i = 0; string[i++] != EOL;){};
			i--;
			
			//ibrsp(cam,&poll);
			//ibwrt(cam,string,i);		/* Send commmand */
			//ibrsp(cam,&poll);
			printf("    poll:%x\n",poll);
			break;
			
			
		default:
			break;
		}
		break;

	case ASK:	// Send command to CC200, wait for reply and type it 
		switch(detlist[dev]) {
		case STAR_1:
			

			status = viSetAttribute (instr, VI_ATTR_TMO_VALUE, 3000);		// 3 second timeout
			//strcpy(&cmnd[index],"@F");
			if( star_send(&cmnd[index]) == -1) return -1;
			status = viRead (instr, wfm, 100, &retCount);
			if (status < VI_SUCCESS) {
				printf("    Error reading a response from the device\n");
				status = viClose(instr);
				return -1;
		   } else {
			  printf("Data read: %*s\n",retCount,wfm);
		   }
			viClose (instr);

			break;

		
		case PHOTOMETRICS_CC200:	
			i = 0;
			break;

	case OSCOPE:
		
			i = 0;
			for (j = index; cmnd[j++] != EOL; i++){};

			//ibwrt(cam,&cmnd[index],i);	 /* Send query  */

			//ibrd(cam,(char*)cmnd,CHPERLN);	 /* Read reply  */
		/*
			if (ibcnt<=0) { 
				printf("    No reply - none expected.\n");
				break;
			}
		*/					 
			/* Type out answer */
			printf("    ");
			//cmnd[ibcnt] = 0;	/* put in end of message flag */
			printf("%s \n",cmnd);
/*			if (scope_rec == 1) {
				fprintf(fp_scope,"%s\n",cmnd);
			}
*/			break;

		default:
			break;
		}	
		
		break;

//	case TTIME:		// Print out time and put it in log 
//
//		lib$date_time(&desc);			// Get time 
//		printf("    ");				// Print it 
//		for (j=0; j!=22; putchar(tstring[j++]));
//		printf("\n");
//					// Time in 1st line of log  
//		for (j=0; j!=22; comment[j]=tstring[j++]);
//		comment[j] = EOL;	// Terminate log entry	    
//		break; 
	}
	//ibonl(cam,0);
	
	return 0;
}

void waitreply()	 /* Await reply */

{


	/*
	long 	ticks,t2;								// for changing watches 
	unsigned char spr;
	int i;
	
	ticks = t2 = TickCount();
	poll = 0;
	
	for(i=0;i<10000;i++){};
	
	while( ticks+60*TIMEOUT > TickCount() ) {
		if( !(ibwait(bd,SRQI | TIMO) & TIMO) ) {
			while( !(ibrsp(cam,&spr) & ERR) ) {
				if(spr == 0x60)
					poll = spr;
				else if(spr == 0x40) {
					poll = spr;
					return 0; }
				
				else if (poll == 0x60)
					return 0;
				if( TickCount() > (t2+10)) {		
					t2 = TickCount();
					
				}
				
			}
			return 0;
		}
		if( TickCount() > (t2+10)) {		
			t2 = TickCount();
			
		}
	}
	*/
	//return 0;
}
// end of VISA conditional
#endif


	
