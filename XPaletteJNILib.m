/*
 *  XPaletteJNILib.c
 *  XSLPalette
 *
 *  Created by Todd Ditchendorf on 8/19/06.
 *  Copyright 2006 Todd Ditchendorf. All rights reserved.
 *
 */

#import "TraceListenerImpl.h"
#import <Foundation/Foundation.h>

static NSFileHandle *handle;

void xpaletteLog(JNIEnv *env, jstring jstr)
{
	const char *str;
	str = (*env)->GetStringUTFChars(env, jstr, NULL);	
	printf("%s\n", str);
	
	NSString *msg = [NSString stringWithUTF8String:str];
	
	if (!handle) {
		NSArray *components = [NSArray arrayWithObjects:
			[[NSBundle mainBundle] resourcePath],
			@"console.txt",
			nil];
		
		NSString *path = [NSString pathWithComponents:components];
		handle = [[NSFileHandle fileHandleForWritingAtPath:path] retain];
	}

	[handle synchronizeFile];
	[handle writeData:[msg dataUsingEncoding:NSUTF8StringEncoding]];
	
	(*env)->ReleaseStringUTFChars(env, jstr, str);	
}

JNIEXPORT void JNICALL Java_TraceListenerImpl_doSendMessage
(JNIEnv *env, jobject obj, jstring jstr)
{
	xpaletteLog(env, jstr);
}

JNIEXPORT void JNICALL Java_TraceListenerImpl_soSendError
(JNIEnv *env, jobject obj, jstring jstr)
{
	xpaletteLog(env, jstr);
}
