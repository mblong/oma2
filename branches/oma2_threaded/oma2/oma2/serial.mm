//
//  serial.mm
//  oma2
//
//  Created by Marshall B. Long on 3/28/14.
//  Copyright (c) 2014 Yale University. All rights reserved.
//


#ifdef SERIAL_PORT

#include "oma2.h"
#include "UI.h"


// use unix terminal control routies
#include <termios.h> /* POSIX terminal control definitions */

int serial_fd; /* File descriptor for the port */
struct termios serial_options;
int serial_inited = 0;

int open_serial_port(char* dev_name){
    serial_fd = open(dev_name, O_RDWR | O_NOCTTY | O_NDELAY);
    if (serial_fd == -1) {
		return -1;
    }else{
		fcntl(serial_fd, F_SETFL, 0);
		fcntl(serial_fd, F_SETFL, FNDELAY);		// return at once from a read, even if there are no characters ready
    }
    
    //Get the current options for the port...
    tcgetattr(serial_fd, &serial_options);
    
    // Set the baud
    cfsetispeed(&serial_options, B9600);
    cfsetospeed(&serial_options, B9600);
    //cfsetispeed(&serial_options, B19200);
    //cfsetospeed(&serial_options, B19200);
    
    // Enable the receiver and set local mode...
    
    serial_options.c_cflag |= (CLOCAL | CREAD);
    
	serial_options.c_cflag &= ~CSIZE; /* Mask the character size bits */
    serial_options.c_cflag |= CS8;    /* Select 8 data bits */
	serial_options.c_cflag &= ~PARENB;
	serial_options.c_cflag &= ~CSTOPB;
	serial_options.c_cflag &= ~CSIZE;
	serial_options.c_cflag |= CS8;
    //options.c_cflag &= ~CNEW_RTSCTS;
	
    // Set the new options for the port...
    tcsetattr(serial_fd, TCSANOW, &serial_options);
	return 0;
}

int serclo(int n, char* args)
{
	if(serial_inited == 0) {
		beep();
		printf("Serial port not initialized.\n");
		return -1;
	} else {
		close(serial_fd);
		serial_inited = 0;
		return 0;
	}
    
    
}


int serial(int n, char* args)
{
	unsigned long length,i;
    //extern char cmnd[];
	char buffer[ESTRING_LENGTH];
	extern Variable user_variables[];
	
	if(serial_inited == 0) {
        if(open_serial_port(args) != 0){
			beep();
            printf("Can't open serial port %s.\n",args);
			return -1;
		} else {
            printf("Opened serial port %s.\n",args);
			serial_inited = 1;
			return 0;
		}
	}
    length = strlen(args);
	if( length == 0 ) {
		beep();
		printf("Nothing sent\n");
		return -1;
	}
    args[length] = 13;	// add a <CR> (=13)
	length++;
    write(serial_fd, args, length);
	//echo any reply
	length = read(serial_fd, buffer, ESTRING_LENGTH-1);
	for(i=0;i<length;i++)buffer[i] &= 127;
	while (length > 0){
		buffer[length] = 0;
		printf("%d characters returned",length);
		pprintf("%s\n",buffer);
		strcpy(&user_variables[0].estring[0],buffer);
		user_variables[0].is_float = -1;
		length = read(serial_fd, buffer, ESTRING_LENGTH-1);
        
	}
    //printf("sent %d characters -%s-\n",length,args);
	return 0;
}



#endif

