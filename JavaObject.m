//
//  JavaObject.m
//  XSLPalette
//
//  Created by Todd Ditchendorf on 8/19/06.
//  Copyright 2006 Todd Ditchendorf. All rights reserved.
//

#import "JavaObject.h"

@implementation JavaObject

// TODO fix this
- (id)init;
{
	return nil;
}


- (id)initWithJclass:(jclass)ajclass JNIEnv:(JNIEnv *)anenv;
{
	self = [super init];
	if (self != nil) {
		javaclass = ajclass;
		env = anenv;
		
		jmethodID cid;		
		cid = (*env)->GetMethodID(env, javaclass, "<init>", "()V");
		if (cid == NULL) {
			NSLog(@"couldn't get constructor ID");
		} else {
			javaobject = (*env)->NewObject(env, javaclass, cid);
		}
	}
	return self;
}


- (void)dealloc;
{
	
	// NEED TO RELEASE jobject here!!!!!!!!!!!
	// is this right?????
	(*env)->DeleteLocalRef(env, javaobject);
	[super dealloc];
}


- (void)invokeVoidMethod:(NSString *)name withSignature:(NSString *)javaSignature arg:(id)arg;
{
	if ([NSString class] == [arg class]) {
		jmethodID mid;	
		mid = (*env)->GetMethodID(env, javaclass, [name UTF8String], [javaSignature UTF8String]);
		if (mid == NULL) {
			NSLog(@"couldn't get method ID for name: %@ javaSignature: %@", name, javaSignature);
			return;
		}
		
		const char* buf = [arg UTF8String];
		jstring javastr = (*env)->NewStringUTF(env, buf);
		
		(*env)->CallObjectMethod(env, javaobject, mid, javastr);
		(*env)->ReleaseStringUTFChars(env, javastr, buf);
	}
}


- (void)invokeVoidMethod:(NSString *)name withSignature:(NSString *)javaSignature;
{
	//NSLog(@"invokeVoidMethod: %@ withSig: %@", name, javaSignature);

	jmethodID mid;	
	mid = (*env)->GetMethodID(env, javaclass, [name UTF8String], [javaSignature UTF8String]);
	if (mid == NULL) {
		NSLog(@"couldn't get method ID for name: %@ javaSignature: %@", name, javaSignature);
		return;
	}
	
	(*env)->CallObjectMethod(env, javaobject, mid);
}


- (id)invokeObjectMethod:(NSString *)name withSignature:(NSString *)javaSignature;
{
	//NSLog(@"invokeObjectMethod: %@ withSig: %@", name, javaSignature);
	id result = nil;
	
	jmethodID mid;	
	mid = (*env)->GetMethodID(env, javaclass, [name UTF8String], [javaSignature UTF8String]);
	if (mid == NULL) {
		NSLog(@"couldn't get method ID for name: %@ javaSignature: %@", name, javaSignature);
		return result;
	}
	
	jstring res = (*env)->CallObjectMethod(env, javaobject, mid);
	
	const char *str;
	str = (*env)->GetStringUTFChars(env, res, NULL);
	printf("%s", str);
	
	result = [NSString stringWithUTF8String:str];
	
	(*env)->ReleaseStringUTFChars(env, res, (const char*)str);
	
	return result;
}



- (id)invokeObjectMethod:(NSString *)name withSignature:(NSString *)javaSignature arg:(id)arg;
{
	//NSLog(@"invokeObjectMethod: %@ withSig: %@ arg: %@", name, javaSignature, arg);
	id result = nil;
	
	jmethodID mid;	
	mid = (*env)->GetMethodID(env, javaclass, [name UTF8String], [javaSignature UTF8String]);
	if (mid == NULL) {
		NSLog(@"couldn't get method ID for name: %@ javaSignature: %@", name, javaSignature);
		return result;
	}
	
	const char* buf = [arg UTF8String];
	jstring javastr = (*env)->NewStringUTF(env, buf);
	
	jstring res = (*env)->CallObjectMethod(env, javaobject, mid, javastr);
	(*env)->ReleaseStringUTFChars(env, javastr, NULL);
	
	const char *str;
	str = (*env)->GetStringUTFChars(env, res, NULL);
	
	result = [NSString stringWithUTF8String:str];
	
	(*env)->ReleaseStringUTFChars(env, res, NULL);
	
	return result;
}


- (id)invokeObjectMethod:(NSString *)name withSignature:(NSString *)javaSignature arg:(id)arg0 arg:(id)arg1;
{
	//NSLog(@"invokeObjectMethod: %@ withSig: %@ arg: %@ arg:%@", name, javaSignature, arg0, arg1);
	id result = nil;
	
	jmethodID mid;	
	mid = (*env)->GetMethodID(env, javaclass, [name UTF8String], [javaSignature UTF8String]);
	if (mid == NULL) {
		NSLog(@"couldn't get method ID for name: %@ javaSignature: %@", name, javaSignature);
		return result;
	}
	
	const char* buf0 = [arg0 UTF8String];
	jstring javastr0 = (*env)->NewStringUTF(env, buf0);

	const char* buf1 = [arg1 UTF8String];
	jstring javastr1 = (*env)->NewStringUTF(env, buf1);
	
	jstring res = (*env)->CallObjectMethod(env, javaobject, mid, javastr0, javastr1);
	(*env)->ReleaseStringUTFChars(env, javastr0, NULL);
	(*env)->ReleaseStringUTFChars(env, javastr1, NULL);
	
	const char *str;
	str = (*env)->GetStringUTFChars(env, res, NULL);
	
	result = [NSString stringWithUTF8String:str];
	
	(*env)->ReleaseStringUTFChars(env, res, NULL);
	
	return result;
}





- (id)invokeObjectMethod:(NSString *)name withSignature:(NSString *)javaSignature args:(NSArray *)args;
{
	//NSLog(@"invokeObjectMethod: %@ withSig: %@ args: %@", name, javaSignature, args);
	id result = nil;
	
	jmethodID mid;	
	mid = (*env)->GetMethodID(env, javaclass, [name UTF8String], [javaSignature UTF8String]);
	if (mid == NULL) {
		NSLog(@"couldn't get method ID for name: %@ javaSignature: %@", name, javaSignature);
		return result;
	}
	
	const int len = [args count];
	char *buf[len+1];
	int i;
	id el;
	for (i = 0; i < len; i++) {
		buf[i] = (char*)[[args objectAtIndex:i] UTF8String];
	}
	buf[++i] = NULL;
		
	jobjectArray jarray = NewPlatformStringArray(env, buf, len);	

	jstring res = (*env)->CallObjectMethod(env, javaobject, mid, jarray);
	//(*env)->ReleaseOjectArrayElements(env, jarray, NULL);
	//TODO leaking here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		
	const char *str;
	str = (*env)->GetStringUTFChars(env, res, NULL);

		result = [NSString stringWithUTF8String:str];
	
	(*env)->ReleaseStringUTFChars(env, res, NULL);
	
	return result;
}




/*

+ (BOOL)instancesRespondToSelector:(SEL)aSelector;
{
	return YES;
}


- (BOOL)respondsToSelector:(SEL)aSelector;
{
	return YES;
}


+ (NSMethodSignature *)instanceMethodSignatureForSelector:(SEL)aSelector;
{
	
	return [super instanceMethodSignatureForSelector:aSelector];
}


- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector;
{
	return [super methodSignatureForSelector:aSelector];
}


- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	NSString *selectorName = NSStringFromSelector([anInvocation selector]);
	NSLog(@"called unknown method: %@", selectorName);
}


- (NSString *)descriptionWithLocale:(NSDictionary *)locale
{
	return @"A cute little Java Object";
}


- (void)doesNotRecognizeSelector:(SEL)aSelector;
{
	//NSLog(@"doesNotRecognizeSelector: %@", NSStringFromSelector(aSelector));
	[super doesNotRecognizeSelector:aSelector];
}

*/


@end
