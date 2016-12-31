//
//  JavaVirtualMachine.m
//  XSLPalette
//
//  Created by Todd Ditchendorf on 8/18/06.
//  Copyright 2006 Todd Ditchendorf. All rights reserved.
//

#import "JavaVirtualMachine.h"
#import "JavaObject.h"
#import <sys/stat.h>
#import <sys/resource.h>
#import <pthread.h>


@interface JavaVirtualMachine (Private)
- (NSString *)composeClassPath:(NSArray *)components;
- (int)startupJava:(void *)options;
- (void)setClassPath:(NSString *)newPath;
@end

@implementation JavaVirtualMachine

+ (id)sharedVirtualMachine;
{
	static JavaVirtualMachine *instance;
	
	@synchronized (self) {
		if (!instance) {
			NSBundle *bundle = [NSBundle mainBundle];
			
			NSString *dir6_5	= [NSString pathWithComponents:[NSArray arrayWithObjects:@"Java", @"saxon6_5", nil]];
			NSString *dir8		= [NSString pathWithComponents:[NSArray arrayWithObjects:@"Java", @"saxon8_7", nil]];
			NSString *dirXT		= [NSString pathWithComponents:[NSArray arrayWithObjects:@"Java", @"xt"		 , nil]];
			NSString *dirXalanJ	= [NSString pathWithComponents:[NSArray arrayWithObjects:@"Java", @"xalanj"  , nil]];
			NSString *type = @"jar";
			
			NSArray *components = [NSArray arrayWithObjects:
								   
				// Saxon 6.5
				[bundle pathForResource:@"saxon-jdom"		ofType:type inDirectory:dir6_5],
				[bundle pathForResource:@"saxon-xml-apis"	ofType:type inDirectory:dir6_5],
				[bundle pathForResource:@"saxon"			ofType:type inDirectory:dir6_5],

				// Saxon 8
				[bundle pathForResource:@"saxon8-dom"		ofType:type inDirectory:dir8],
				[bundle pathForResource:@"saxon8-dom4j"		ofType:type inDirectory:dir8],
				[bundle pathForResource:@"saxon8-jdom"		ofType:type inDirectory:dir8],
				[bundle pathForResource:@"saxon8-sql"		ofType:type inDirectory:dir8],
				[bundle pathForResource:@"saxon8-xom"		ofType:type inDirectory:dir8],
				[bundle pathForResource:@"saxon8-xpath"		ofType:type inDirectory:dir8],
				[bundle pathForResource:@"saxon8"			ofType:type inDirectory:dir8],

				// XT
				[bundle pathForResource:@"xt20051206"		ofType:type inDirectory:dirXT],

				// XalanJ
				[bundle pathForResource:@"jaxp-api"			ofType:type inDirectory:dirXalanJ],
				[bundle pathForResource:@"serializer"		ofType:type inDirectory:dirXalanJ],
				[bundle pathForResource:@"xalan"			ofType:type inDirectory:dirXalanJ],
				[bundle pathForResource:@"xercesImpl"		ofType:type inDirectory:dirXalanJ],
				[bundle pathForResource:@"xml-apis"			ofType:type inDirectory:dirXalanJ],
				nil];

			NSArray *extDirs = [NSArray arrayWithObjects:
				[[bundle resourcePath] stringByAppendingPathComponent:dir6_5],
				[[bundle resourcePath] stringByAppendingPathComponent:dir8],
				[[bundle resourcePath] stringByAppendingPathComponent:dirXT],
				[[bundle resourcePath] stringByAppendingPathComponent:dirXalanJ], 
				nil];
			
			NSString *extDirsStr = [extDirs componentsJoinedByString:@":"];
			NSDictionary *properties = [NSDictionary dictionaryWithObject:extDirsStr forKey:@"java.ext.dirs"];
			
			//NSLog(@"cp components: %@", components);
			instance = [[JavaVirtualMachine alloc] initWithClassPathComponents:components properties:properties];
		}
	}
	return instance;
}

- (id)init;
{
	return [self initWithClassPathComponents:nil];
}


- (id)initWithClassPathComponents:(NSArray *)components;
{
	return [self initWithClassPathComponents:components properties:nil];
}


- (id)initWithClassPathComponents:(NSArray *)components properties:(NSDictionary *)properties;
{
	return [self initWithClassPath:[self composeClassPath:components] 
						properties:properties];
}

- (id)initWithClassPath:(NSString *)newPath;
{
	return [self initWithClassPath:newPath properties:nil];
}


- (id)initWithClassPath:(NSString *)newPath properties:(NSDictionary *)properties;
{
	self = [super init];
	if (self != nil) {
		[self setClassPath:newPath];
		
		NSString *resPath = [[NSBundle mainBundle] resourcePath];
		NSString *libPath = [NSString pathWithComponents:[NSArray arrayWithObjects:resPath, @"Java", @"libXPaletteJNILib.jnilib", nil]];
		
		NSString *dir6_5	= [NSString pathWithComponents:[NSArray arrayWithObjects:@"Java", @"saxon6_5", nil]];
		NSString *dir8	= [NSString pathWithComponents:[NSArray arrayWithObjects:@"Java", @"saxon8_7", nil]];
		NSString *dirXT		= [NSString pathWithComponents:[NSArray arrayWithObjects:@"Java", @"xt"		 , nil]];
		NSString *dirXalanJ	= [NSString pathWithComponents:[NSArray arrayWithObjects:@"Java", @"xalanj"  , nil]];
		NSBundle *bundle = [NSBundle mainBundle];

		int argc = 6;
		NSMutableString *propStr = [NSMutableString string];
		
		if ([properties count]) {
			NSEnumerator *e = [properties keyEnumerator];
			NSString *key = nil;
			while (key = [e nextObject]) {
				[propStr appendFormat:@"-D%@=\"%@\" ", key, [properties objectForKey:key]];
			}
		}
		
		//NSLog(@"classPath: %@", classPath);
		NSLog(@"properties: %@", propStr);
		const char *argv[] = {
			"java",
			"-cp",
			[classPath UTF8String],
			[propStr UTF8String],
			"CausewayBridgeMain",
			[libPath UTF8String],
			NULL
		};
		
		VMLaunchOptions * launchOptions = NewVMLaunchOptions(argc, argv);
		
		// Startup the JVM (startupJava is a C function defined elsewhere)
		int result = [self startupJava:launchOptions];
		
	}
	return self;
}


- (void)dealloc;
{
	NSLog(@"dealloc JVM");
	(*theVM)->DestroyJavaVM(theVM);
	[super dealloc];
}


#pragma mark -
#pragma mark Private

- (id)objectWithJavaClassName:(NSString *)qName;
{
	id result = nil;
	
	//NSLog(@"findClass: %@", qName);
	jclass javaclass = (*env)->FindClass(env, [qName UTF8String]);
    
	if ( javaclass == NULL ) {
		NSLog(@"couldn't find requested Java class: %@", qName);
        (*env)->ExceptionDescribe(env);
		return result;
    }
	
	result = [[JavaObject alloc] initWithJclass:javaclass JNIEnv:env];
	return result;
}


#pragma mark -
#pragma mark Private

- (NSString *)composeClassPath:(NSArray *)components;
{
	NSString *resPath = [[NSBundle mainBundle] pathForResource:@"JavaPackage" 
														ofType:@"jar"
												   inDirectory:@"Java"];
	
	NSMutableArray *allComponents = [NSMutableArray arrayWithObjects:@"$CLASSPATH", resPath, nil];
	
	if (components && [components count]) {
		[allComponents addObjectsFromArray:components];
	}
	NSString *result = [allComponents componentsJoinedByString:@":"];
	//NSLog(@"composed classPath: %@", result);
	return result;
}


- (int)startupJava:(void *)options;
{
	int result = 0;
	
	VMLaunchOptions * launchOptions = (VMLaunchOptions*)options;
	
	JavaVMInitArgs vm_args;
	
	{
		CFStringRef targetJVM = CFSTR("1.5");
		CFBundleRef JavaVMBundle;
		CFURLRef    JavaVMBundleURL;
		CFURLRef    JavaVMBundlerVersionsDirURL;
		CFURLRef    TargetJavaVM;
		UInt8 pathToTargetJVM [PATH_MAX] = "\0";
		struct stat sbuf;
		
		
		// Look for the JavaVM bundle using its identifier
		JavaVMBundle = CFBundleGetBundleWithIdentifier(CFSTR("com.apple.JavaVM") );
		
		if(JavaVMBundle != NULL) {
			// Get a path for the JavaVM bundle
			JavaVMBundleURL = CFBundleCopyBundleURL(JavaVMBundle);
			CFRelease(JavaVMBundle);
			
			if(JavaVMBundleURL != NULL) {
				// Append to the path the Versions Component
				JavaVMBundlerVersionsDirURL = CFURLCreateCopyAppendingPathComponent(kCFAllocatorDefault,JavaVMBundleURL,CFSTR("Versions"),true);
				CFRelease(JavaVMBundleURL);
				
				if(JavaVMBundlerVersionsDirURL != NULL) {
					// Append to the path the target JVM's Version
					TargetJavaVM = CFURLCreateCopyAppendingPathComponent(kCFAllocatorDefault,JavaVMBundlerVersionsDirURL,targetJVM,true);
					CFRelease(JavaVMBundlerVersionsDirURL);
					
					if(TargetJavaVM != NULL) {
						if(CFURLGetFileSystemRepresentation (TargetJavaVM,true,pathToTargetJVM,PATH_MAX )) {
							// Check to see if the directory, or a sym link for the target JVM directory exists, and if so set the
							// environment variable JAVA_JVM_VERSION to the target JVM.
							if(stat((char*)pathToTargetJVM,&sbuf) == 0) {
								// Ok, the directory exists, so now we need to set the environment var JAVA_JVM_VERSION to the CFSTR targetJVM
								// We can reuse the pathToTargetJVM buffer to set the environement var.
								if(CFStringGetCString(targetJVM,(char*)pathToTargetJVM,PATH_MAX,kCFStringEncodingUTF8))
									setenv("JAVA_JVM_VERSION", (char*)pathToTargetJVM,1);
							}
						}
						CFRelease(TargetJavaVM);
					}
				}
			}
		}
	}
	
    /* JNI_VERSION_1_4 is used on Mac OS X to indicate the 1.4.x and later JVM's */
    vm_args.version	= JNI_VERSION_1_4;
    vm_args.options	= launchOptions->options;
    vm_args.nOptions = launchOptions->nOptions;
    vm_args.ignoreUnrecognized	= JNI_TRUE;
	
    /* start a VM session */    
    result = JNI_CreateJavaVM(&theVM, (void**)&env, &vm_args);
	
    if ( result != 0 ) {
        fprintf(stderr, "[JavaAppLauncher Error] Error starting up VM.\n");
        goto leave;
    }
    
    /* Find the main class */
    mainClass = (*env)->FindClass(env, launchOptions->mainClass);
    if ( mainClass == NULL ) {
		NSLog(@"couldn't find CuasewayBridgeMain class... ");
        (*env)->ExceptionDescribe(env);
        result = -1;
        goto leave;
    }
	
    /* Get the application's main method */
    jmethodID mainID = (*env)->GetStaticMethodID(env, mainClass, "main",
                                                 "([Ljava/lang/String;)V");
    if (mainID == NULL) {
        if ((*env)->ExceptionOccurred(env)) {
            (*env)->ExceptionDescribe(env);
        } else {
            fprintf(stderr, "[JavaAppLauncher Error] No main method found in specified class.\n");
        }
        result = -1;
        goto leave;
    }
	
    /* Build argument array */
    jobjectArray mainArgs = NewPlatformStringArray(env, (char **)launchOptions->args, launchOptions->numberOfArgs);
    if (mainArgs == nil) {
        (*env)->ExceptionDescribe(env);
        goto leave;
    }
    
    /* Invoke main method passing in the argument object. */
    (*env)->CallStaticVoidMethod(env, mainClass, mainID, mainArgs);
    if ((*env)->ExceptionOccurred(env)) {
        (*env)->ExceptionDescribe(env);
        result = -1;
        goto leave;
    }
	
leave:
	freeVMLaunchOptions(launchOptions);
	return result;
}


#pragma mark -
#pragma mark Accessors

- (NSString *)classPath;
{
	NSString *result = nil;
	@synchronized (self) {
		result = [[classPath copy] autorelease];
	}
	return result;
}


- (void)setClassPath:(NSString *)newPath;
{
	@synchronized (self) {
		if (classPath != newPath) {
			[classPath release];
			classPath = [newPath copy];
		}
	}
}

@end
