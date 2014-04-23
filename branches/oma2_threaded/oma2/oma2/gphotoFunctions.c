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

//#include "impdefs.h"

//#include "gp-params.h"
#define _(String) (String)

#define ALL 0
#define VALUE 1

extern int gphoto_inited;
extern Camera	*camera;
extern GPContext *cameracontext;
extern GPParams gp_params;


/*
static void errordumper(GPLogLevel level, const char *domain, const char *format,
                 va_list args, void *data) {
  vfprintf(stdout, format, args);
  fprintf(stdout, "\n");
}
*/

int
_find_widget_by_name (GPParams *p, const char *name, CameraWidget **child, CameraWidget **rootconfig) {
	int	ret;
	
	ret = gp_camera_get_config (p->camera, rootconfig, p->context);
	if (ret != GP_OK) return ret;
	ret = gp_widget_get_child_by_name (*rootconfig, name, child);
	if (ret != GP_OK) 
		ret = gp_widget_get_child_by_label (*rootconfig, name, child);
	if (ret != GP_OK) {
		char		*part, *s, *newname;
		
		newname = strdup (name);
		if (!newname)
			return GP_ERROR_NO_MEMORY;
		
		*child = *rootconfig;
		part = newname;
		while (part[0] == '/')
			part++;
		while (1) {
			CameraWidget *tmp;
			
			s = strchr (part,'/');
			if (s)
				*s='\0';
			ret = gp_widget_get_child_by_name (*child, part, &tmp);
			if (ret != GP_OK)
				ret = gp_widget_get_child_by_label (*child, part, &tmp);
			if (ret != GP_OK)
				break;
			*child = tmp;
			if (!s) /* end of path */
				break;
			part = s+1;
			while (part[0] == '/')
				part++;
		}
		if (s) { /* if we have stuff left over, we failed */
			gp_context_error (p->context, _("%s not found in configuration tree."), newname);
			free (newname);
			gp_widget_free (*rootconfig);
			return GP_ERROR;
		}
		free (newname);
	}
	return GP_OK;
}

/* From the strftime(3) man page:
 * BUGS
 *     Some buggy versions of gcc complain about the use of %c: warning:
 *     %c yields only last 2 digits of year in some  locales.
 *     Of course programmers are encouraged to use %c, it gives the
 *     preferred date and time representation. One meets all kinds of
 *     strange obfuscations to circumvent this gcc problem. A relatively
 *     clean one is to add an intermediate function
 */

size_t
my_strftime(char *s, size_t max, const char *fmt, const struct tm *tm)
{
	return strftime(s, max, fmt, tm);
}



int
get_config_action (GPParams *p, const char *name, int do_print) {
	CameraWidget *rootconfig,*child;
	int	ret;
	const char *label;
	CameraWidgetType	type;
	
	ret = _find_widget_by_name (p, name, &child, &rootconfig);
	if (ret != GP_OK)
		return ret;
	
	ret = gp_widget_get_type (child, &type);
	if (ret != GP_OK) {
		gp_widget_free (rootconfig);
		return ret;
	}
	ret = gp_widget_get_label (child, &label);
	if (ret != GP_OK) {
		gp_widget_free (rootconfig);
		return ret;
	}
	
	if(do_print == ALL) printf ("Label: %s\n", label); /* "Label:" is not i18ned, the "label" variable is */
	switch (type) {
		case GP_WIDGET_TEXT: {		/* char *		*/
			char *txt;
			
			ret = gp_widget_get_value (child, &txt);
			if (ret == GP_OK) {
				if(do_print == ALL) printf ("Type: TEXT\n"); /* parsed by scripts, no i18n */
				printf ("Current: %s\n",txt);
			} else {
				gp_context_error (p->context, _("Failed to retrieve value of text widget %s."), name);
			}
			break;
		}
		case GP_WIDGET_RANGE: {	/* float		*/
			float	f, t,b,s;
			
			ret = gp_widget_get_range (child, &b, &t, &s);
			if (ret == GP_OK)
				ret = gp_widget_get_value (child, &f);
			if (ret == GP_OK) {
				if(do_print == ALL) printf ("Type: RANGE\n");	/* parsed by scripts, no i18n */
				printf ("Current: %g\n", f);	/* parsed by scripts, no i18n */
				if(do_print == ALL) printf ("Bottom: %g\n", b);	/* parsed by scripts, no i18n */
				if(do_print == ALL) printf ("Top: %g\n", t);	/* parsed by scripts, no i18n */
				if(do_print == ALL) printf ("Step: %g\n", s);	/* parsed by scripts, no i18n */
			} else {
				gp_context_error (p->context, _("Failed to retrieve values of range widget %s."), name);
			}
			break;
		}
		case GP_WIDGET_TOGGLE: {	/* int		*/
			int	t;
			
			ret = gp_widget_get_value (child, &t);
			if (ret == GP_OK) {
				if(do_print == ALL) printf ("Type: TOGGLE\n");
				printf ("Current: %d\n",t);
			} else {
				gp_context_error (p->context, _("Failed to retrieve values of toggle widget %s."), name);
			}
			break;
		}
		case GP_WIDGET_DATE:  {		/* int			*/
			int	ret, t;
			time_t	xtime;
			struct tm *xtm;
			char	timebuf[200];
			
			ret = gp_widget_get_value (child, &t);
			if (ret != GP_OK) {
				gp_context_error (p->context, _("Failed to retrieve values of date/time widget %s."), name);
				break;
			}
			xtime = t;
			xtm = localtime (&xtime);
			ret = (int)my_strftime (timebuf, sizeof(timebuf), "%c", xtm);
			if(do_print == ALL) printf ("Type: DATE\n");
			if(do_print == ALL) printf ("Current: %d\n", t);
			printf ("Printable: %s\n", timebuf);
			break;
		}
		case GP_WIDGET_MENU:
		case GP_WIDGET_RADIO: { /* char *		*/
			int cnt, i;
			char *current;
			
			ret = gp_widget_get_value (child, &current);
			if (ret == GP_OK) {
				cnt = gp_widget_count_choices (child);
				if (type == GP_WIDGET_MENU)
					if(do_print == ALL) printf ("Type: MENU\n");
				else
					if(do_print == ALL) printf ("Type: RADIO\n");
				printf ("Current: %s\n",current);
				for ( i=0; i<cnt; i++) {
					const char *choice;
					ret = gp_widget_get_choice (child, i, &choice);
					if(do_print == ALL) printf ("Choice: %d %s\n", i, choice);
				}
			} else {
				gp_context_error (p->context, _("Failed to retrieve values of radio widget %s."), name);
			}
			break;
		}
			
			/* ignore: */
		case GP_WIDGET_WINDOW:
		case GP_WIDGET_SECTION:
		case GP_WIDGET_BUTTON:
			break;
	}
	gp_widget_free (rootconfig);
	return (GP_OK);
}

int
set_config_action (GPParams *p, const char *name, const char *value) {
	CameraWidget *rootconfig,*child;
	int	ret;
	const char *label;
	CameraWidgetType	type;
	
	ret = _find_widget_by_name (p, name, &child, &rootconfig);
	if (ret != GP_OK)
		return ret;
	
	ret = gp_widget_get_type (child, &type);
	if (ret != GP_OK) {
		gp_widget_free (rootconfig);
		return ret;
	}
	ret = gp_widget_get_label (child, &label);
	if (ret != GP_OK) {
		gp_widget_free (rootconfig);
		return ret;
	}
	
	switch (type) {
		case GP_WIDGET_TEXT: {		/* char *		*/
			ret = gp_widget_set_value (child, value);
			if (ret != GP_OK)
				gp_context_error (p->context, _("Failed to set the value of text widget %s to %s."), name, value);
			break;
		}
		case GP_WIDGET_RANGE: {	/* float		*/
			float	f,t,b,s;
			
			ret = gp_widget_get_range (child, &b, &t, &s);
			if (ret != GP_OK)
				break;
			if (!sscanf (value, "%f", &f)) {
				gp_context_error (p->context, _("The passed value %s is not a floating point value."), value);
				ret = GP_ERROR_BAD_PARAMETERS;
				break;
			}
			if ((f < b) || (f > t)) {
				gp_context_error (p->context, _("The passed value %f is not within the expected range %f - %f."), f, b, t);
				ret = GP_ERROR_BAD_PARAMETERS;
				break;
			}
			ret = gp_widget_set_value (child, &f);
			if (ret != GP_OK)
				gp_context_error (p->context, _("Failed to set the value of range widget %s to %f."), name, f);
			break;
		}
		case GP_WIDGET_TOGGLE: {	/* int		*/
			int	t;
			
			t = 2;
			if (	!strcasecmp (value, "off")	|| !strcasecmp (value, "no")	||
				!strcasecmp (value, "false")	|| !strcmp (value, "0")		||
				!strcasecmp (value, _("off"))	|| !strcasecmp (value, _("no"))	||
				!strcasecmp (value, _("false"))
				)
				t = 0;
			if (	!strcasecmp (value, "on")	|| !strcasecmp (value, "yes")	||
				!strcasecmp (value, "true")	|| !strcmp (value, "1")		||
				!strcasecmp (value, _("on"))	|| !strcasecmp (value, _("yes"))	||
				!strcasecmp (value, _("true"))
				)
				t = 1;
			/*fprintf (stderr," value %s, t %d\n", value, t);*/
			if (t == 2) {
				gp_context_error (p->context, _("The passed value %s is not a valid toggle value."), value);
				ret = GP_ERROR_BAD_PARAMETERS;
				break;
			}
			ret = gp_widget_set_value (child, &t);
			if (ret != GP_OK)
				gp_context_error (p->context, _("Failed to set values %s of toggle widget %s."), value, name);
			break;
		}
		case GP_WIDGET_DATE:  {		/* int			*/
			int	t = -1;
			//struct tm xtm;
			
#ifdef HAVE_STRPTIME
			if (strptime (value, "%c", &xtm) || strptime (value, "%Ec", &xtm))
				t = mktime (&xtm);
#endif
			if (t == -1) {
				if (!sscanf (value, "%d", &t)) {
					gp_context_error (p->context, _("The passed value %s is neither a valid time nor an integer."), value);
					ret = GP_ERROR_BAD_PARAMETERS;
					break;
				}
			}
			ret = gp_widget_set_value (child, &t);
			if (ret != GP_OK)
				gp_context_error (p->context, _("Failed to set new time of date/time widget %s to %s."), name, value);
			break;
		}
		case GP_WIDGET_MENU:
		case GP_WIDGET_RADIO: { /* char *		*/
			int cnt, i;
			
			cnt = gp_widget_count_choices (child);
			if (cnt < GP_OK) {
				ret = cnt;
				break;
			}
			ret = GP_ERROR_BAD_PARAMETERS;
			for ( i=0; i<cnt; i++) {
				const char *choice;
				
				ret = gp_widget_get_choice (child, i, &choice);
				if (ret != GP_OK)
					continue;
				if (!strcmp (choice, value)) {
					ret = gp_widget_set_value (child, value);
					break;
				}
			}
			if (i != cnt)
				break;
			
			if (sscanf (value, "%d", &i)) {
				if ((i>= 0) && (i < cnt)) {
					const char *choice;
					
					ret = gp_widget_get_choice (child, i, &choice);
					if (ret == GP_OK)
						ret = gp_widget_set_value (child, choice);
					break;
				}
			}
			gp_context_error (p->context, _("Choice %s not found within list of choices."), value);
			break;
		}
			
			/* ignore: */
		case GP_WIDGET_WINDOW:
		case GP_WIDGET_SECTION:
		case GP_WIDGET_BUTTON:
			gp_context_error (p->context, _("The %s widget is not configurable."), name);
			ret = GP_ERROR_BAD_PARAMETERS;
			break;
	}
	if (ret == GP_OK) {
		ret = gp_camera_set_config (p->camera, rootconfig, p->context);
		if (ret != GP_OK)
			gp_context_error (p->context, _("Failed to set new configuration value %s for configuration entry %s."), value, name);
	}
	gp_widget_free (rootconfig);
	return (ret);
}



void
capture_to_file(Camera *camera, GPContext *cameracontext, char *fn) {
	int fd, retval;
	CameraFile *camerafile;
	CameraFilePath camera_file_path;

	printf("Capturing.\n");

	/* NOP: This gets overridden in the library to /capt0000.jpg */
	strcpy(camera_file_path.folder, "/");
	strcpy(camera_file_path.name, "foo.jpg");

	retval = gp_camera_capture(camera, GP_CAPTURE_IMAGE, &camera_file_path, cameracontext);
	if(retval != GP_OK) printf("  capture return: %d\n", retval);
    
	printf("Pathname on the camera: %s/%s\n", camera_file_path.folder, camera_file_path.name);

	fd = open(fn, O_CREAT | O_WRONLY, 0644);
	retval = gp_file_new_from_fd(&camerafile, fd);
	if(retval != GP_OK) printf("  new file from fd return: %d\n", retval);
	retval = gp_camera_file_get(camera, camera_file_path.folder, camera_file_path.name,
		     GP_FILE_TYPE_NORMAL, camerafile, cameracontext);
	if(retval != GP_OK) printf("  get camera file return: %d\n", retval);

	//printf("Deleting.\n");
	retval = gp_camera_file_delete(camera, camera_file_path.folder, camera_file_path.name,
			cameracontext);
	if(retval != GP_OK) printf("  camera file delete return: %d\n", retval);

	gp_file_free(camerafile);
}

void
display_widgets (CameraWidget *widget, char *prefix) {
	int 	ret, n, i;
	char	*newprefix;
	const char *label, *name, *uselabel;
	CameraWidgetType	type;
	
	gp_widget_get_label (widget, &label);
	/* fprintf(stderr,"label is %s\n", label); */
	ret = gp_widget_get_name (widget, &name);
	/* fprintf(stderr,"name is %s\n", name); */
	gp_widget_get_type (widget, &type);
	
	if (strlen(name))
		uselabel = name;
	else
		uselabel = label;
	
	n = gp_widget_count_children (widget);
	
	newprefix = malloc(strlen(prefix)+1+strlen(uselabel)+1);
	if (!newprefix)
		abort();
	sprintf(newprefix,"%s/%s",prefix,uselabel);
	
	if ((type != GP_WIDGET_WINDOW) && (type != GP_WIDGET_SECTION)) {
		printf("%s\n",newprefix);
		for(i=(int)strlen(newprefix)-1; newprefix[i] != '/' && i!= 0; i--);
		//printf("\t%s\n",&newprefix[i+1]);
		printf("\t");
		ret = get_config_action (&gp_params, &newprefix[i+1],VALUE );
	}
	for (i=0; i<n; i++) {
		CameraWidget *child;
		
		ret = gp_widget_get_child (widget, i, &child);
		if (ret != GP_OK)
			continue;
		display_widgets (child, newprefix);
	}
	free(newprefix);
}


int init_gphoto_cam()
{
	int	retval;
	
	// if this process is running, we won't get the camera, so kill it
	system("killall PTPCamera");
	
	cameracontext = sample_create_context();
	gp_params.context = cameracontext;
	// mbl this not found
	//gp_log_add_func(GP_LOG_ERROR, errordumper, NULL);
	
	gp_camera_new(&camera);
	gp_params.camera = camera;
	
	/* When I set GP_LOG_DEBUG instead of GP_LOG_ERROR above, I noticed that the
	 * init function seems to traverse the entire filesystem on the camera.  This
	 * is partly why it takes so long.
	 * (Marcus: the ptp2 driver does this by default currently.)
	 */
	printf("Camera init.  Takes about 10 seconds.\n");
	retval = gp_camera_init(camera, cameracontext);
	if (retval != GP_OK) {
		printf("  Retval: %d\n", retval);
		return (-1);
	}
	gphoto_inited = 1;
	return GP_OK;
}

int close_gphoto_cam()
{
	
	if(gphoto_inited) gp_camera_exit(camera, cameracontext);
	gphoto_inited = 0;
	
	return 0;
}
/*
static void
ctx_error_func (GPContext *context, const char *format, va_list args, void *data)
{
    fprintf  (stderr, "\n");
    fprintf  (stderr, "*** Contexterror ***              \n");
    vfprintf (stderr, format, args);
    fprintf  (stderr, "\n");
    fflush   (stderr);
}

static void
ctx_status_func (GPContext *context, const char *format, va_list args, void *data)
{
    vfprintf (stderr, format, args);
    fprintf  (stderr, "\n");
    fflush   (stderr);
}
*/
GPContext* sample_create_context() {
	GPContext *context;
    
	/* This is the mandatory part */
	context = gp_context_new();
    
	/* All the parts below are optional! */
    //gp_context_set_error_func (context, ctx_error_func, NULL);
    //gp_context_set_status_func (context, ctx_status_func, NULL);
    
	/* also:
     gp_context_set_cancel_func    (p->context, ctx_cancel_func,  p);
     gp_context_set_message_func   (p->context, ctx_message_func, p);
     if (isatty (STDOUT_FILENO))
     gp_context_set_progress_funcs (p->context,
     ctx_progress_start_func, ctx_progress_update_func,
     ctx_progress_stop_func, p);
	 */
	return context;
}

int
_lookup_widget(CameraWidget*widget, const char *key, CameraWidget **child) {
	int ret;
	ret = gp_widget_get_child_by_name (widget, key, child);
	if (ret < GP_OK)
		ret = gp_widget_get_child_by_label (widget, key, child);
	return ret;
}

/* Gets a string configuration value.
 * This can be:
 *  - A Text widget
 *  - The current selection of a Radio Button choice
 *  - The current selection of a Menu choice
 *
 * Sample (for Canons eg):
 *   get_config_value_string (camera, "owner", &ownerstr, context);
 */
int
get_config_value_string (Camera *camera, const char *key, char **str, GPContext *context) {
	CameraWidget		*widget = NULL, *child = NULL;
	CameraWidgetType	type;
	int			ret;
	char			*val;
    
	ret = gp_camera_get_config (camera, &widget, context);
	if (ret < GP_OK) {
		fprintf (stderr, "camera_get_config failed: %d\n", ret);
		return ret;
	}
	ret = _lookup_widget (widget, key, &child);
	if (ret < GP_OK) {
		fprintf (stderr, "lookup widget failed: %d\n", ret);
		goto out;
	}
    
	/* This type check is optional, if you know what type the label
	 * has already. If you are not sure, better check. */
	ret = gp_widget_get_type (child, &type);
	if (ret < GP_OK) {
		fprintf (stderr, "widget get type failed: %d\n", ret);
		goto out;
	}
	switch (type) {
        case GP_WIDGET_MENU:
        case GP_WIDGET_RADIO:
        case GP_WIDGET_TEXT:
            break;
        default:
            fprintf (stderr, "widget has bad type %d\n", type);
            ret = GP_ERROR_BAD_PARAMETERS;
            goto out;
	}
    
	/* This is the actual query call. Note that we just
	 * a pointer reference to the string, not a copy... */
	ret = gp_widget_get_value (child, &val);
	if (ret < GP_OK) {
		fprintf (stderr, "could not query widget value: %d\n", ret);
		goto out;
	}
	/* Create a new copy for our caller. */
	*str = strdup (val);
out:
	gp_widget_free (widget);
	return ret;
}


/* Sets a string configuration value.
 * This can set for:
 *  - A Text widget
 *  - The current selection of a Radio Button choice
 *  - The current selection of a Menu choice
 *
 * Sample (for Canons eg):
 *   get_config_value_string (camera, "owner", &ownerstr, context);
 */
int
set_config_value_string (Camera *camera, const char *key, const char *val, GPContext *context) {
	CameraWidget		*widget = NULL, *child = NULL;
	CameraWidgetType	type;
	int			ret;
    
	ret = gp_camera_get_config (camera, &widget, context);
	if (ret < GP_OK) {
		fprintf (stderr, "camera_get_config failed: %d\n", ret);
		return ret;
	}
	ret = _lookup_widget (widget, key, &child);
	if (ret < GP_OK) {
		fprintf (stderr, "lookup widget failed: %d\n", ret);
		goto out;
	}
    
	/* This type check is optional, if you know what type the label
	 * has already. If you are not sure, better check. */
	ret = gp_widget_get_type (child, &type);
	if (ret < GP_OK) {
		fprintf (stderr, "widget get type failed: %d\n", ret);
		goto out;
	}
	switch (type) {
        case GP_WIDGET_MENU:
        case GP_WIDGET_RADIO:
        case GP_WIDGET_TEXT:
            break;
        default:
            fprintf (stderr, "widget has bad type %d\n", type);
            ret = GP_ERROR_BAD_PARAMETERS;
            goto out;
	}
    
	/* This is the actual set call. Note that we keep
	 * ownership of the string and have to free it if necessary.
	 */
	ret = gp_widget_set_value (child, val);
	if (ret < GP_OK) {
		fprintf (stderr, "could not set widget value: %d\n", ret);
		goto out;
	}
	/* This stores it on the camera again */
	ret = gp_camera_set_config (camera, widget, context);
	if (ret < GP_OK) {
		fprintf (stderr, "camera_set_config failed: %d\n", ret);
		return ret;
	}
out:
	gp_widget_free (widget);
	return ret;
}


/*
 * This enables/disables the specific canon capture mode.
 *
 * For non canons this is not required, and will just return
 * with an error (but without negative effects).
 */
int
canon_enable_capture (Camera *camera, int onoff, GPContext *context) {
	CameraWidget		*widget = NULL, *child = NULL;
	CameraWidgetType	type;
	int			ret;
    
	ret = gp_camera_get_config (camera, &widget, context);
	if (ret < GP_OK) {
		fprintf (stderr, "camera_get_config failed: %d\n", ret);
		return ret;
	}
	ret = _lookup_widget (widget, "capture", &child);
	if (ret < GP_OK) {
		/*fprintf (stderr, "lookup widget failed: %d\n", ret);*/
		goto out;
	}
    
	ret = gp_widget_get_type (child, &type);
	if (ret < GP_OK) {
		fprintf (stderr, "widget get type failed: %d\n", ret);
		goto out;
	}
	switch (type) {
        case GP_WIDGET_TOGGLE:
            break;
        default:
            fprintf (stderr, "widget has bad type %d\n", type);
            ret = GP_ERROR_BAD_PARAMETERS;
            goto out;
	}
	/* Now set the toggle to the wanted value */
	ret = gp_widget_set_value (child, &onoff);
	if (ret < GP_OK) {
		fprintf (stderr, "toggling Canon capture to %d failed with %d\n", onoff, ret);
		goto out;
	}
	/* OK */
	ret = gp_camera_set_config (camera, widget, context);
	if (ret < GP_OK) {
		fprintf (stderr, "camera_set_config failed: %d\n", ret);
		return ret;
	}
out:
	gp_widget_free (widget);
	return ret;
}


#endif