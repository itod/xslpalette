//
//  XSLTServiceBaseJavaImpl.m
//  XSLPalette
//
//  Created by Todd Ditchendorf on 11/25/06.
//  Copyright 2006 Todd Ditchendorf. All rights reserved.
//

#import "XSLTServiceBaseJavaImpl.h"
#import "JavaVirtualMachine.h"

@interface XSLTServiceBaseJavaImpl (Private)
- (void)doTransform:(NSArray *)args;
@end

@implementation XSLTServiceBaseJavaImpl

- (id)init;
{
	return [self initWithDelegate:nil];
}


- (id)initWithDelegate:(id)aDelegate;
{
	self = [super initWithDelegate:aDelegate];
	if (self != nil) {
		jvm = [JavaVirtualMachine sharedVirtualMachine];
	}
	return self;
}


- (void)dealloc;
{
	[adapterClassName release];
	[super dealloc];
}


- (void)transformSource:(NSString *)sourceURLString
		 withStylesheet:(NSString *)styleURLString
				 params:(NSDictionary *)params
				   lang:(TransformLang)lang
				verbose:(BOOL)verbose;
{
	NSArray *args = [NSArray arrayWithObjects:[NSNumber numberWithInt:lang],
		sourceURLString, styleURLString, 
		[NSNumber numberWithBool:verbose], params, nil];
	
	//[NSThread detachNewThreadSelector:@selector(doTransform:)
	//						 toTarget:self
	//					   withObject:args];
	
	[self doTransform:args];
}


- (void)doTransform:(NSArray *)args;
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[self clearConsoleFile];
	
	id javaObj = [jvm objectWithJavaClassName:adapterClassName];
	
	NSArray *outArgs = [self packageJavaArgsAsArray:args];
	
	id result = [javaObj invokeObjectMethod:@"transform" 
							  withSignature:@"([Ljava/lang/String;)Ljava/lang/String;" 
									   args:outArgs]; 
	
	[self showConsoleData];
	
	[self doneTransforming:result];
	
	[pool release];
}


@end
