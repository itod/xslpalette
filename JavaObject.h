//
//  JavaObject.h
//  XSLPalette
//
//  Created by Todd Ditchendorf on 8/19/06.
//  Copyright 2006 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "utils.h"


@interface JavaObject : NSObject {
	JNIEnv *env;
	jclass javaclass;
	jobject javaobject;
}
// designated initializer
- (id)initWithJclass:(jclass)ajclass JNIEnv:(JNIEnv *)env;
- (void)invokeVoidMethod:(NSString *)name withSignature:(NSString *)javaSignature;
- (void)invokeVoidMethod:(NSString *)name withSignature:(NSString *)javaSignature arg:(id)arg;
//- (void)invokeVoidMethod:(NSString *)name withSignature:(NSString *)javaSignature args:(NSArray *)args;
- (id)invokeObjectMethod:(NSString *)name withSignature:(NSString *)javaSignature;
- (id)invokeObjectMethod:(NSString *)name withSignature:(NSString *)javaSignature arg:(id)arg;
- (id)invokeObjectMethod:(NSString *)name withSignature:(NSString *)javaSignature arg:(id)arg0 arg:(id)arg1;
- (id)invokeObjectMethod:(NSString *)name withSignature:(NSString *)javaSignature args:(NSArray *) args;
@end
