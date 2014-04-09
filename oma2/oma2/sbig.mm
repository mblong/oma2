/*
 Commands for SBIG cameras
 */
#ifdef SBIG

#include "SBIGUDrv/sbigudrv.h"
#include "oma2.h"
#include "UI.h"
#include "stdio.h"

int omaprintf();
int linked = 0;
/*
 
 Temperature Conversion Constants
 Defined in the SBIG Universal Driver Documentation
 
 */
#define T0      25.0
#define R0       3.0
#define DT_CCD  25.0
#define DT_AMB  45.0
#define RR_CCD   2.57
#define RR_AMB   7.791
#define RB_CCD  10.0
#define RB_AMB   3.0
#define MAX_AD  4096

typedef short PAR_ERROR_;



unsigned short DegreesCToAD(float degC, MY_LOGICAL ccd);
float ADToDegreesC(unsigned short ad, MY_LOGICAL ccd);
PAR_ERROR_ QueryTemperatureStatus(MY_LOGICAL* enabled, float* ccdTemp,
                                 float* setpointTemp, float* percentTE);
PAR_ERROR_ SetTemperatureRegulation(MY_LOGICAL enable, float setpoint);
void report_error(PAR_ERROR_ err);
int close_SBIG();
short select_filter(int Filter);
static unsigned short our_cfw_model= 0;
int sbig(int n, int index);
void report_error(PAR_ERROR_ err);

/*
 
 DegreesCToAD:
 
 Convert temperatures in degrees C to
 camera AD setpoints.
 
 */
unsigned short DegreesCToAD(float degC, MY_LOGICAL ccd) // = TRUE )
{
	float r;
	unsigned short setpoint;
	
	if ( degC < -50.0 )
		degC = -50.0;
	else if ( degC > 35.0 )
		degC = 35.0;
	if ( ccd ) {
		r = R0 * exp(log(RR_CCD)*(T0 - degC)/DT_CCD);
		setpoint = (unsigned short)(MAX_AD/((RB_CCD/r) + 1.0) + 0.5);
	} else {
		r = R0 * exp(log(RR_AMB)*(T0 - degC)/DT_AMB);
		setpoint = (unsigned short)(MAX_AD/((RB_AMB/r) + 1.0) + 0.5);
	}
	return setpoint;
}

/*
 
 ADToDegreesC:
 
 Convert camera AD temperatures to
 degrees C
 
 */
float ADToDegreesC(unsigned short ad, MY_LOGICAL ccd) // = TRUE )
{
	double r, degC;
	
	if ( ad < 1 )
		ad = 1;
	else if ( ad >= MAX_AD - 1 )
		ad = MAX_AD - 1;
	if ( ccd ) {
		r = RB_CCD/(((float)MAX_AD/ad) - 1.0);
		degC = T0 - DT_CCD*(log(r/R0)/log(RR_CCD));
	} else {
		r = RB_AMB/(((float)MAX_AD/ad) - 1.0);
		degC = T0 - DT_AMB*(log(r/R0)/log(RR_AMB));
	}
	return degC;
}


/*
 
 QueryTemperatureStatus:
 
 Get whether the cooling is enabled, the CCD temp
 and setpoint in degrees C and the percent power
 applied to the TE cooler.
 
 */
PAR_ERROR_ QueryTemperatureStatus(MY_LOGICAL* enabled, float* ccdTemp,
                                 float* setpointTemp, float* percentTE)
{
	QueryTemperatureStatusResults qtsr;
	PAR_ERROR_ err;
    err = SBIGUnivDrvCommand(CC_QUERY_TEMPERATURE_STATUS, NULL, &qtsr);
	
	if ( err == CE_NO_ERROR ) {
		*enabled = qtsr.enabled;
		*ccdTemp = ADToDegreesC(qtsr.ccdThermistor, TRUE);
		*setpointTemp = ADToDegreesC(qtsr.ccdSetpoint, TRUE);
		*percentTE = qtsr.power/255.0;
	}
	return err;
}

/*PAR_ERROR_ EstablishLink(void)
 {
 PAR_ERROR_ res;
 EstablishLinkResults elr;
 //EstablishLinkParams elp;
 
 res = SBIGUnivDrvCommand(CC_ESTABLISH_LINK, NULL, &elr);
 //if ( res == CE_NO_ERROR )
 //	m_eCameraType = (CAMERA_TYPE)elr.cameraType;
 return res;
 }*/
void report_error(PAR_ERROR_ err){
	GetErrorStringParams gesp;
	GetErrorStringResults gesr;
    
	gesp.errorNo = err;
	SBIGUnivDrvCommand(CC_GET_ERROR_STRING, &gesp, &gesr);
	//beep();
	printf("%s\n",gesr.errorString);
}

/*
 
 SetTemperatureRegulation:
 
 Enable or disable the temperatre controll at
 the passed setpoint which is the absolute
 (not delta) temperature in degrees C.
 
 */
PAR_ERROR_ SetTemperatureRegulation(MY_LOGICAL enable, float setpoint)
{
	SetTemperatureRegulationParams strp;
	strp.regulation = enable ? REGULATION_ON : REGULATION_OFF;
	strp.ccdSetpoint = DegreesCToAD(setpoint, TRUE);
	return SBIGUnivDrvCommand(CC_SET_TEMPERATURE_REGULATION, &strp, NULL);
}


#define INVALID_HANDLE_VALUE -1
int close_SBIG()
{
	short err;
	SetDriverHandleParams sdhp;
	
	CFWParams cfwp;
	CFWResults cfwr;
    
	cfwp.cfwCommand = CFWC_CLOSE_DEVICE;
	cfwp.cfwModel = our_cfw_model;	//autodetect
	err = SBIGUnivDrvCommand(CC_CFW, &cfwp, &cfwr);
	
	if(err != CE_NO_ERROR ) report_error(err);
	
	
	sdhp.handle = INVALID_HANDLE_VALUE;
	SBIGUnivDrvCommand(CC_SET_DRIVER_HANDLE, &sdhp, NULL);
	
	err = SBIGUnivDrvCommand(CC_CLOSE_DEVICE, NULL, NULL);
	if(err != CE_NO_ERROR)  report_error(err);
	err = SBIGUnivDrvCommand(CC_CLOSE_DRIVER, NULL, NULL);
	if(err != CE_NO_ERROR)  report_error(err);
	linked = 0;
	return 0;
}

short select_filter(int Filter){
	
	CFWParams cfwp;
	CFWResults cfwr;
	short err;
    
	cfwp.cfwModel = our_cfw_model;
	cfwp.cfwCommand = CFWC_GOTO ;
	cfwp.cfwParam1 = Filter;
	
	err = SBIGUnivDrvCommand(CC_CFW, &cfwp, &cfwr);
	if(err != CE_NO_ERROR )
        report_error(err);
    
	while(TRUE){
		cfwp.cfwCommand = CFWC_QUERY;
		err = SBIGUnivDrvCommand(CC_CFW, &cfwp, &cfwr);
		if(err != CE_NO_ERROR ) report_error(err);
        
		if(cfwr.cfwStatus == CFWS_IDLE)
			break;
		
	}
    
	return err;
}


//extern DATAWORD *datpt;
//extern TWOBYTE 	specs[],trailer[];
//extern float *fdatpt;
//extern char 	comment[];
//extern int 		doffset;
//extern int     	maxint;		// the max count CC200 can store
//extern int		npts;		// number of data points
//extern int		have_max;	// indicates whether or not the minimum and maximum value have been found for the data in the current buffer. 0 -> no;  1 -> yes
//extern char    cmnd[];  	// the command buffer
//extern int	   dlen,dhi;

/* ************ */
/*
 Commands for newer SBIG detectors.
 Use these via the SBIG OMA command.
 Format is:
 
 SBIG command_string [parameters]
 command_string specifies a SBIG command.
 Only the first 3 characters of SBIG commands matter
 The values for parameters depend on the particular command.
 
 
 Commands:
 
 EXPosure TEMperature ACQuire STAtus FILter DISconnect
 
 */


#define 	SET_RETURN_VALUES	user_variables[0].fvalue = setpointTemp; \
user_variables[0].is_float = 1;	\
user_variables[1].fvalue = ccdTemp; \
user_variables[1].is_float = 1;	\
user_variables[2].fvalue = ExposureTime; \
user_variables[2].is_float = 1;	\
user_variables[3].ivalue = Filter; \
user_variables[3].is_float = 0;	\

int sbig(int n, char* args)
{
	//extern void redoMenus();
	//extern char txt[],cmnd[];
    char txt[CHPERLN];
	extern Variable user_variables[];
    extern Image iBuffer;
    
	short err;
	unsigned short rm;
	
	int nWidth, nHeight, i=0;
	static int ccdWidth, ccdHeight;
	unsigned short *imagebuf;
    //int dquartz();
	
	//GetDriverHandleResults gdhr;	// assume there is only one SBIG device for now
	
	OpenDeviceParams odp;
	GetDriverInfoParams driver_params;
	GetDriverInfoResults0 driver_results;
	static GetCCDInfoResults0 gcir0;
	GetCCDInfoParams gcip;
	StartExposureParams2 sep;
	EndExposureParams eep;
	StartReadoutParams srp;
	ReadoutLineParams rlp;
	EndReadoutParams erp;
    EstablishLinkResults elr;
    //EstablishLinkParams elp;
    
	CFWParams cfwp;
	CFWResults cfwr;
    
	QueryCommandStatusParams qcsp;
	QueryCommandStatusResults qcsr;
	qcsp.command = CC_START_EXPOSURE;
	MY_LOGICAL enabled = FALSE;
	static float ccdTemp = 25., setpointTemp = 25., percentTE = 0., SetTemp = 0.;
	static int Filter,num_filt=0, SetBin = 0;
	static float ExposureTime = 0.1;
	MY_LOGICAL expComp = FALSE;
	imagebuf = 0;
    int ncol, nrow;
    
    
	for( i=0; args[i] != 0; i++) args[i] = toupper(args[i]);
    
	if(*args == 0 && linked != 0) {
		// after initialized, let sbig command be used to acquire
		//index = 1;
		strncpy(args,"ACQ",3);
	}
	
	if(!linked){
		SBIGUnivDrvCommand(CC_CLOSE_DEVICE, NULL, NULL);
		SBIGUnivDrvCommand(CC_CLOSE_DRIVER, NULL, NULL);
        
        
        //open driver
		err = SBIGUnivDrvCommand(CC_OPEN_DRIVER, NULL, NULL);
		//imagebuf = 0;
        if ( err == CE_NO_ERROR ){
			//err = SBIGUnivDrvCommand(CC_GET_DRIVER_HANDLE, NULL, &gdhr); // don't need this for 1 camera
			driver_params.request = DRIVER_STD;
			err = SBIGUnivDrvCommand(CC_GET_DRIVER_INFO, &driver_params, &driver_results);
			printf("%s\nVersion: %2x.%2x\n",driver_results.name,driver_results.version>>8,driver_results.version&0xFF);
		} else {
			report_error(err);
			return err;
		}
        
        //open device
        odp.deviceType = DEV_USB;	// look for a usb camera
        if((err = SBIGUnivDrvCommand(CC_OPEN_DEVICE, &odp, NULL) != CE_NO_ERROR)){
			report_error(err);
			// to close
			SBIGUnivDrvCommand(CC_CLOSE_DRIVER, NULL, NULL);
			return err;
		}
        
        // establish link
        err = SBIGUnivDrvCommand(CC_ESTABLISH_LINK, 0, &elr);
		if(err  != CE_NO_ERROR){
			report_error(err);
			goto close;
		}
		linked = 1;
		
		// get CCD info
		gcip.request = CCD_INFO_IMAGING;	// ask for info on the imaging CCD
        err = SBIGUnivDrvCommand(CC_GET_CCD_INFO, &gcip, &gcir0);
		if ( err != CE_NO_ERROR ){
			report_error(err);
			goto close;
		}
        
        
		rm = gcir0.readoutModes;
		ccdWidth = gcir0.readoutInfo[0].width;
		ccdHeight = gcir0.readoutInfo[0].height; //  ( should be height / vertNBinning?)
        
		// color filter related bits
		cfwp.cfwCommand = CFWC_OPEN_DEVICE;
		cfwp.cfwModel = CFWSEL_AUTO;	//autodetect
		err = SBIGUnivDrvCommand(CC_CFW, &cfwp, &cfwr);
		if(err != CE_NO_ERROR ) report_error(err);
		
		our_cfw_model = cfwr.cfwModel;
		
		// initialize
		cfwp.cfwCommand = CFWC_INIT;
		cfwp.cfwModel = cfwr.cfwModel;
		err = SBIGUnivDrvCommand(CC_CFW, &cfwp, &cfwr);
		if(err != CE_NO_ERROR )
            report_error(err);
        
        // removed initialization otherwise the STF-8300M doesn't work if the filter wheel is not installed
		// wait for it to finish initialization
		/*while(TRUE){
         cfwp.cfwCommand = CFWC_QUERY;
         err = SBIGUnivDrvCommand(CC_CFW, &cfwp, &cfwr);
         if(err != CE_NO_ERROR )
         report_error(err);
         
         if(cfwr.cfwStatus == CFWS_IDLE)
         break;
         }*/
		// done with init
		
		cfwp.cfwCommand = CFWC_GET_INFO;
		cfwp.cfwModel = our_cfw_model ;
		
		cfwp.cfwParam1 = CFWG_FIRMWARE_VERSION;
		err = SBIGUnivDrvCommand(CC_CFW, &cfwp, &cfwr);
		if(err != CE_NO_ERROR ) report_error(err);
		num_filt = (int)cfwr.cfwResult2;
		
		cfwp.cfwCommand = CFWC_QUERY;
		err = SBIGUnivDrvCommand(CC_CFW, &cfwp, &cfwr);
        
		
	}
	if(index == 0){
		SET_RETURN_VALUES
		return 0;
	}
	
	/*
     EXPosure command
     Specify exposure time in seconds
     */
	if( strncmp(args,"EXP",3) == 0){
        SBIGUnivDrvCommand(CC_GET_CCD_INFO, &gcip, &gcir0);
		sscanf(args,"%s %f",txt, &ExposureTime);
        if (strcmp(gcir0.name,"SBIG ST-402 CCD Camera") == 0){
            if( ExposureTime < 0.09) ExposureTime = .09;
        } else if (strcmp(gcir0.name,"SBIG STF-8300 CCD Camera") == 0){
            if( ExposureTime < 0.09) ExposureTime = .09;
        }
        
		printf("Exposure set to %.2f seconds.\n",ExposureTime);
		SET_RETURN_VALUES
		return 0;
        
        /*
         FILter command
         Specify which filter to use
         */
	} else if( strncmp(args,"FIL",3) == 0){
		sscanf(args,"%s %d",txt, &Filter);
		select_filter(Filter);
		printf("Filter %d selected.\n",Filter);
		SET_RETURN_VALUES
		return 0;
        
        /*
         TEMperature command
         Specify set temperature of the CCD in degrees C
         */
	} else if ( strncmp(args,"TEM",3) == 0){
		sscanf(args,"%s %f",txt, &SetTemp);
		err = SetTemperatureRegulation(TRUE, SetTemp);
		printf("Set Temperature to %.1f degrees C.\n",SetTemp);
		SET_RETURN_VALUES
		return err;
		
        /*
         BINning command
         Specify NxN binning of the CCD
         */
    } else if ( strncmp(args,"BIN",3) == 0){
        beep();
        printf("Please use DX and DY (must be equal) to set binning for this camera.\n");
        return -1;
        /*
         SBIGUnivDrvCommand(CC_GET_CCD_INFO, &gcip, &gcir0);
         sscanf(args,"%s %d",txt, &SetBin);
         
         if (strncmp(gcir0.name,"SBIG ST-402 CCD Camera",10) == 0){
         if (SetBin < 1) SetBin = 1;
         if (SetBin > 3) {SetBin = 3; printf("Maximum binning for the ST-402 Camera is 3x3.\n");}
         printf("Set binning to %d x %d .\n",SetBin,SetBin);
         SetBin = SetBin - 1;
         } else if (strncmp(gcir0.name,"SBIG STF-8300 CCD Camera",10) == 0){
         if (SetBin < 1) SetBin = 1;
         if (SetBin > 3 && SetBin != 9) {SetBin = 3; printf("Possible binning for the STF-8300 Camera is 2x2, 3x3, 9x9.\n");}
         printf("Set binning to %d x %d .\n",SetBin,SetBin);
         SetBin = SetBin - 1;
         if (SetBin == 8) SetBin = 9;
         }
         
         SET_RETURN_VALUES
         return 0;
         */
        
        /*
         DISconnect command
         Close the device and driver
         */
	} else if ( strncmp(args,"DIS",3) == 0){
		close_SBIG();
		return 0;
		
        /*
         STAtus command
         Print out CCD info, temperature, exposure, etc.
         */
	} else if (strncmp(args,"STA",3) == 0){
		// get CCD info
		gcip.request = CCD_INFO_IMAGING;	// ask for info on the imaging CCD
		if ( (err = SBIGUnivDrvCommand(CC_GET_CCD_INFO, &gcip, &gcir0)) != CE_NO_ERROR ){
			report_error(err);
			goto close;
		}
        printf("OMA SBIG version: April 2014\n");
		printf("Camera: %s\n",gcir0.name);
		rm = gcir0.readoutModes;
		printf("ReadoutModes: %d\n",rm);
		ccdWidth = (gcir0.readoutInfo[0].width);
		ccdHeight = (gcir0.readoutInfo[0].height); //  ( should be height / vertNBinning?)
		printf("Width: %d  Height: %d\n",ccdWidth, ccdHeight);
		//
        if (SetBin == 9){
            printf("Binning: %d x %d.\n",SetBin,SetBin);
        } else printf("Binning: %d x %d.\n",SetBin+1,SetBin+1);
		QueryTemperatureStatus( &enabled, &ccdTemp, &setpointTemp, &percentTE);
		if( enabled)
			printf("Temperature regulation: Enabled\nCCD Temp: %.1f\nCCD set point: %.1f\nTE Cooler: %.1f Percent\n",
				   ccdTemp, setpointTemp, percentTE*100.);
		else
			printf("Temperature regulation: Disabled\nCCD Temp: %.1f\nCCD set point: %.1f\nTE Cooler: %.1f Percent\n",
				   ccdTemp, setpointTemp, percentTE*100.);
		printf("Exposure time: %.2f seconds.\n",ExposureTime);
		
		cfwp.cfwCommand = CFWC_GET_INFO;
		cfwp.cfwModel = our_cfw_model ;
		
		printf("CFW model is: %d\n",our_cfw_model);
		cfwp.cfwParam1 = CFWG_FIRMWARE_VERSION;
		err = SBIGUnivDrvCommand(CC_CFW, &cfwp, &cfwr);
		if(err != CE_NO_ERROR ) report_error(err);
		//printf("CFW Firmware Version: %2x.%2x\n%d Positions on the color wheel\n",
		//	   cfwr.cfwResult1>>8,cfwr.cfwResult1&0xFF,cfwr.cfwResult2);
		num_filt = (int)cfwr.cfwResult2;
		printf("%d Positions on the color wheel\n",cfwr.cfwResult2);
		
		cfwp.cfwCommand = CFWC_QUERY;
		err = SBIGUnivDrvCommand(CC_CFW, &cfwp, &cfwr);
		
		if(cfwr.cfwPosition == 0)  // unknown position
			printf("Wheel position unknown\n\n");
		else{
			printf("Wheel currently at position %d\n\n",cfwr.cfwPosition);
			Filter = cfwr.cfwPosition;
		}
		SET_RETURN_VALUES
		
		return 0;
		
        /*
         ACQuire command
         Get an image using the current settings
         */
	} else if (strncmp(args,"ACQ",3) == 0){
        int* specs = iBuffer.getspecs();
        
		// check to see if the parameters are OK for this camera
		if( specs[DX]*specs[COLS]+specs[X0] > ccdWidth ||
           specs[DY]*specs[ROWS]+specs[Y0] > ccdHeight || specs[DX] != specs[DY]) {
			beep();
			printf("Incompatible readout parameters. (Row/Column/X0/Y0/DX/DY)\n");
            printf("Possible binning for the STF-8300 Camera is 2x2, 3x3, 9x9.\n");
            free(specs);
			return -5;
		}
        
        ncol = specs[COLS];
        nrow = specs[ROWS];
        
        if(specs[DX] != 1 ){
            // bin pixels on readout
            SetBin = specs[DX];
            if (SetBin !=2 && SetBin != 3 && SetBin != 9) {
                beep();
                printf("Incompatible readout parameters. (Row/Column/X0/Y0/DX/DY)\n");
                free(specs);
                return -1;
            }
            // the following call doesn't return valid information here for some reason
            //SBIGUnivDrvCommand(CC_GET_CCD_INFO, &gcip, &gcir0);
            //sscanf(args,"%s %d",txt, &SetBin);
            
            if (strncmp(gcir0.name,"SBIG ST-402 CCD Camera",10) == 0){
                if (SetBin < 1) SetBin = 1;
                if (SetBin > 3) {
                    SetBin = 3;
                    specs[DX] = specs[DY] = 3;
                    printf("Maximum binning for the ST-402 Camera is 3x3.\n");
                }
                printf("Set binning to %d x %d .\n",SetBin,SetBin);
                SetBin = SetBin - 1;
            } else if (strncmp(gcir0.name,"SBIG STF-8300 CCD Camera",10) == 0){
                if (SetBin < 1) SetBin = 1;
                if (SetBin > 3 && SetBin != 9) {SetBin = 3; printf("Possible binning for the STF-8300 Camera is 2x2, 3x3, 9x9.\n");}
                printf("Set binning to %d x %d .\n",SetBin,SetBin);
                if (SetBin != 9) SetBin -= 1;
            }
        }
        
		nWidth = ncol;
		nHeight = nrow;
		imagebuf = (unsigned short*)malloc(nWidth * nHeight * sizeof(short));
		if(imagebuf == 0){
			beep();
			printf("Memory Error\n");
            free(specs);
			return -1;
		}
        
		// get the temperature
		QueryTemperatureStatus( &enabled, &ccdTemp, &setpointTemp, &percentTE);
        
		// setup exposure
		sep.ccd = CCD_IMAGING;
		sep.exposureTime = (unsigned long)(ExposureTime * 100.0 + 0.5);
		if ( sep.exposureTime < 1 )
			sep.exposureTime = 1;
		//sep.abgState = m_eABGState;		N/A for all but a few cameras (see documentation)
		sep.openShutter = SC_OPEN_SHUTTER;
        sep.readoutMode = SetBin;
        sep.left = specs[X0];
		sep.top = specs[Y0];
		sep.height = nHeight;
		sep.width = nWidth;
		err = SBIGUnivDrvCommand(CC_START_EXPOSURE2, &sep, NULL);
		
		// wait for exposure to finish
		
		while (!expComp) {
			if ((err = SBIGUnivDrvCommand(CC_QUERY_COMMAND_STATUS, &qcsp, &qcsr)) != CE_NO_ERROR){
				report_error(err);
			}
			// consider imaging CCD only
			expComp = (qcsr.status & 0x03) != 0x02;
		}
		
		eep.ccd = CCD_IMAGING;
		err = SBIGUnivDrvCommand(CC_END_EXPOSURE, &eep, NULL);
		//report_error(err);
		
        
		// readout the CCD
		srp.ccd = CCD_IMAGING;
		srp.left = specs[X0];
		srp.top = specs[Y0];
		srp.height = nHeight;
		srp.width = nWidth;
		srp.readoutMode = SetBin;		// 0 = no binning, 1 = 2x2, 2 = 3x3
		if ( (err = SBIGUnivDrvCommand(CC_START_READOUT, &srp, NULL)) != CE_NO_ERROR ) {
			report_error(err);
		} else {
			rlp.ccd = CCD_IMAGING;
			rlp.pixelStart = specs[X0];
			rlp.pixelLength = nWidth;
			rlp.readoutMode = SetBin;
			for (i=0; i< nHeight ; i++ ) {
				err = SBIGUnivDrvCommand(CC_READOUT_LINE, &rlp, (unsigned short*)(imagebuf + (long)i * nWidth));
				if( err != CE_NO_ERROR)
					report_error(err);
			}
		}
		
		//EndReadout
		erp.ccd = CCD_IMAGING;
		err = SBIGUnivDrvCommand(CC_END_READOUT, &erp, NULL);
		
        unsigned short* ptr = imagebuf;
		for(i = 0; i<nHeight; i++){
            for(int j=0; j<nWidth;j++)
                iBuffer.setpix(i, j, *ptr++);
        }
        
        
        SetBin = 0;
        
		iBuffer.getmaxx();
		display(0,(char*)"GigE");
        //dquartz(0,0);
		SET_RETURN_VALUES
        
        
		if(imagebuf != 0) free(imagebuf);
        free(specs);
        return err;
        
	} else {
        printf("Unknown SBIG Command\nValid Commands are: EXPosure TEMperature ACQuire BINning STAtus FILter DISconnect\n");
        return -2;
    }
	
    
    
    
close:		
	// to close
	SBIGUnivDrvCommand(CC_CLOSE_DEVICE, NULL, NULL);
	SBIGUnivDrvCommand(CC_CLOSE_DRIVER, NULL, NULL);
	if(imagebuf != 0) free(imagebuf);
	linked = 0;
	
	return err;
    
}


#endif