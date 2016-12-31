//
//  JavaVirtualMachine.h
//  XSLPalette
//
//  Created by Todd Ditchendorf on 8/18/06.
//  Copyright 2006 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "utils.h"

@interface NSObject (JavaObjectAdditions)
- (void)invokeVoidMethod:(NSString *)name withSignature:(NSString *)javaSignature;
- (void)invokeVoidMethod:(NSString *)name withSignature:(NSString *)javaSignature arg:(id)arg;
//- (void)invokeVoidMethod:(NSString *)name withSignature:(NSString *)javaSignature args:(NSArray *)args;
- (id)invokeObjectMethod:(NSString *)name withSignature:(NSString *)javaSignature;
- (id)invokeObjectMethod:(NSString *)name withSignature:(NSString *)javaSignature arg:(id)arg;
- (id)invokeObjectMethod:(NSString *)name withSignature:(NSString *)javaSignature arg:(id)arg0 arg:(id)arg1;
- (id)invokeObjectMethod:(NSString *)name withSignature:(NSString *)javaSignature args:(NSArray *) args;
@end

@interface JavaVirtualMachine : NSObject {
	JNIEnv *env;
	JavaVM *theVM;
	jclass mainClass;
	
	NSString *classPath;
}
+ (id)sharedVirtualMachine;

// Designated initializer
- (id)initWithClassPath:(NSString *)newPath;
- (id)initWithClassPath:(NSString *)newPath properties:(NSDictionary *)properties;
- (id)initWithClassPathComponents:(NSArray *)components;
- (id)initWithClassPathComponents:(NSArray *)components properties:(NSDictionary *)properties;

- (id)objectWithJavaClassName:(NSString *)qName;

- (NSString *)classPath;
@end
