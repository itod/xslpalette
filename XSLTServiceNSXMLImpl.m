//
//  XSLTServiceNSXMLImpl.m
//  XSLPalette
//
//  Created by Todd Ditchendorf on 8/23/06.
//  Copyright 2006 Todd Ditchendorf. All rights reserved.
//

#import "XSLTServiceNSXMLImpl.h"

@interface XSLTServiceNSXMLImpl (Private)
- (void)doTransform:(NSArray *)args;
- (NSURL *)URLForString:(NSString *)str;
@end

@implementation XSLTServiceNSXMLImpl

- (id)init;
{
	return [self initWithDelegate:nil];
}


- (id)initWithDelegate:(id)aDelegate;
{
	self = [super init];
	if (self != nil) {
		delegate = aDelegate;
	}
	return self;
}

- (void)transformSource:(NSString *)sourceURLString
		 withStylesheet:(NSString *)styleURLString
				 params:(NSDictionary *)params
				   lang:(TransformLang)lang
				verbose:(BOOL)verbose;
{
	NSArray *args = [NSArray arrayWithObjects:sourceURLString, styleURLString,
		params, [NSNumber numberWithInt:lang], [NSNumber numberWithBool:verbose], nil];
	
	[NSThread detachNewThreadSelector:@selector(doTransform:)
							 toTarget:self
						   withObject:args];
}


- (void)doTransform:(NSArray *)args;
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *sourceURLString =  [args objectAtIndex:0];
	NSString *xqueryURLString =  [args objectAtIndex:1];
	NSDictionary *params	  =  [args objectAtIndex:2];
	BOOL verbose			  = [[args objectAtIndex:4] boolValue];

	NSURL *sourceURL = [self URLForString:sourceURLString];
	NSURL *xqueryURL = [self URLForString:xqueryURLString];
	
	NSString *xqueryStr = [NSString stringWithContentsOfURL:xqueryURL];
	
	NSError *err = nil;
	
	NSXMLDocument *doc = [[NSXMLDocument alloc] initWithContentsOfURL:sourceURL
															  options:NSXMLNodePreserveAll
																error:&err];
	if (err) {
		[self error:[err localizedDescription]];
	} else if (!doc) {
		[self error:[NSString stringWithFormat:@"Unknown error while parsing source XML document: %@", sourceURLString]];
	}
	
	id result = [doc objectsForXQuery:xqueryStr
							constants:params
								error:&err];
	
	if (err) {
		[self error:[err localizedDescription]];
	}
	
	if ([result isKindOfClass:[NSArray class]] && 1 == [result count]) {
		result = [result objectAtIndex:0];
	}
	
	if ([result isKindOfClass:[NSXMLNode class]]) {
		result = [result XMLString];
	} else {
		result = [result description];
	}
	
	[self doneTransforming:result];
	
	[pool release];
}


- (NSURL *)URLForString:(NSString *)str;
{
	return ([str hasPrefix:@"http://"]) ?
	[NSURL URLWithString:str] :
	[NSURL fileURLWithPath:str];
}

@end
