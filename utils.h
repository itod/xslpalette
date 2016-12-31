#include <JavaVM/jni.h>

/* This structure will be used to store the options, args, */
/* and main class needed to invoke this application */
typedef struct {
    void *		options;
    int			nOptions;
    char *	 	mainClass;
    char **		args;
    int			numberOfArgs;
} VMLaunchOptions;

/* Parses command line options for the VM options, properties,
   main class, and main class args and returns them in the VMLaunchOptions
   structure.
*/
extern VMLaunchOptions * NewVMLaunchOptions(int argc, const char **argv);

/* Release the Memory used by the VMLaunchOptions */
void freeVMLaunchOptions( VMLaunchOptions * vmOptionsPtr);

/*
 * Returns a new array of Java string objects for the specified
 * array of platform strings.
 */
extern jobjectArray NewPlatformStringArray(JNIEnv *env, char **strv, int strc);

/* Sets the applications name for the application menu */
extern void setAppName(const char * name);
