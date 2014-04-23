/* compile with gcc -Wall -o canon-capture -lgphoto2 canon-capture.c
 * This code released into the public domain 21 July 2008
 * 
 * This program does the equivalent of:
 * gphoto2 --shell
 *   > set-config capture=1
 *   > capture-image-and-download
 * compile with gcc -Wall -o canon-capture -lgphoto2 canon-capture.c
 *
 * Taken from: http://credentiality2.blogspot.com/2008/07/linux-libgphoto2-image-capture-from.html 
 */

#ifdef GPHOTO

#include "oma2.h"
#include "UI.h"


#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdarg.h>
#include <string.h>

#include "gphotoFunctions.h"

#include <gphoto2/gphoto2.h>

#define _(String) (String)

#define ALL 0
#define VALUE 1

int gphoto_inited = 0;
Camera	*camera;
GPContext *cameracontext;
GPParams gp_params;



int capture(int n, char* args)
{

	//int	retval;
	
	
	if(!gphoto_inited) {
		if(init_gphoto_cam() != GP_OK){
			beep();
			printf("Can't init camera.\n");
		}
	}
	
	canon_enable_capture(camera, TRUE, cameracontext);
	/*set_capturetarget(canon, canoncontext);*/
	capture_to_file(camera, cameracontext, fullname(args,SAVE_DATA_NO_SUFFIX));
	//gp_camera_exit(canon, canoncontext);
	return 0;
}

/*
 
 CAMLISTSETTINGS
 
 */

int camlistsettings(int n, char* args)
{
	int	ret;
	CameraWidget *rootconfig;
	
	
	if(!gphoto_inited) {
		if(init_gphoto_cam() != GP_OK){
			beep();
			printf("Can't init camera.\n");
		}
	}

	ret = gp_camera_get_config (camera, &rootconfig, cameracontext);
	if (ret != GP_OK) return ret;
	display_widgets (rootconfig, "");
	gp_widget_free (rootconfig);
	
	return (GP_OK);
}

/*
 
 CAMEXPOSE frames
 
 This does not work reliably for reasons unknown
 It behaves like the commandline gphoto2 where exposures are made, but not read to the computer and deleted -- 
 after a while, an error of -1 is returned.
 
 Taken out of comdecx for now.
 
 To do bracketing, write a macero using capture and setting exposures through the macro.
 
 */

int camexpose(int n, char* args)
{
    
    int	retval = GP_OK,i,fd;
    
    CameraFilePath camera_file_path[100];
	CameraFile *camerafile;
	char fn[1024];
	
	if (n < 1) n = 1;	// the number of exposures to take

    if(!gphoto_inited) {
		if(init_gphoto_cam() != GP_OK){
			beep();
			printf("Can't init camera.\n");
		}
    }
    
    canon_enable_capture(camera, TRUE, cameracontext);
    
    printf("Capturing.\n");
    
    for(i=0; i<n && retval == GP_OK; i++){
		/* NOP: This gets overridden in the library to /capt0000.jpg */
		strcpy(camera_file_path[i].folder, "/");
		strcpy(camera_file_path[i].name, "foo.jpg");
		
		retval = gp_camera_capture(camera, GP_CAPTURE_IMAGE, &camera_file_path[i], cameracontext);
		if(retval != GP_OK) printf("  capture return: %d\n", retval);
		
		printf("Pathname on the camera: %s/%s\n", camera_file_path[i].folder, camera_file_path[i].name);
    }

	for(i=0; i<n && retval == GP_OK; i++){
		sprintf(fn,"pic_%d.nef",i);
		sprintf(fn,fullname(fn,SAVE_DATA_NO_SUFFIX));
		printf("File is: %s\n",fn);
		fd = open(fn, O_CREAT | O_WRONLY, 0644);
		retval = gp_file_new_from_fd(&camerafile, fd);
		if(retval != GP_OK) printf("  new file from fd return: %d\n", retval);
		retval = gp_camera_file_get(camera, camera_file_path[i].folder, camera_file_path[i].name,
									GP_FILE_TYPE_NORMAL, camerafile, cameracontext);
		if(retval != GP_OK) printf("  get camera file return: %d\n", retval);
		
		//printf("Deleting.\n");
		retval = gp_camera_file_delete(camera, camera_file_path[i].folder, camera_file_path[i].name,
									   cameracontext);
		if(retval != GP_OK) printf("  camera file delete return: %d\n", retval);
		
		gp_file_free(camerafile);
    }
	
    return 0;
}

/*
 
 CAMGETSETTING setting_name
 
 */

int camgetsetting(int n, char* args)
{
	int ret;
	
	
	if(!gphoto_inited) {
		if(init_gphoto_cam() != GP_OK){
			beep();
			printf("Can't init camera.\n");
		}
	}
	
	ret = get_config_action (&gp_params, args,ALL);
	if (ret != GP_OK) printf("  Error: %d\n", ret);

	return ret;
}

/*
 
 CAMSETSETTING setting_name setting_value
 
*/

int camsetsetting(int n, char* args)
{
	int ret,i;
	
	
	if(!gphoto_inited) {
		if(init_gphoto_cam() != GP_OK){
			beep();
			printf("Can't init camera.\n");
		}
	}
	for(i=0; args[i] != ' ' && args[i] != 0; i++);
	args[i] = 0;
	
	printf("Set %s to value: %s\n",args, &args[i+1]);
	
	ret = set_config_action (&gp_params, args, &args[i+1]);
	if (ret != GP_OK) {
		printf("  Error: %d\n", ret);
	}
	
	return ret;
}

#endif