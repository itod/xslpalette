//
//  XSLTServiceBaseImpl.m
//  XSLPalette
//
//  Created by Todd Ditchendorf on 8/19/06.
//  Copyright 2006 Todd Ditchendorf. All rights reserved.
//

#import "XSLTServiceBaseImpl.h"

NSString * const TrueString  = @"true";
NSString * const FalseString = @"false";


@implementation XSLTServiceBaseImpl


- (id)initWithDelegate:(id)aDelegate;
{
	self = [super init];
	if (self != nil) {
		delegate = aDelegate;
		
		NSArray *components = [NSArray arrayWithObjects:
			[[NSBundle mainBundle] resourcePath],
			@"console.txt",
			nil];
		
		NSString *path = [NSString pathWithComponents:components];
		[self setHandle:[NSFileHandle fileHandleForUpdatingAtPath:path]];
		
	}
	return self;
}

- (void)dealloc;
{
	[self setHandle:nil];
	[super dealloc];
}

- (void)transformSource:(NSString *)sourceURLString
		 withStylesheet:(NSString *)styleURLString
				 params:(NSDictionary *)params
				   lang:(TransformLang)lang
				verbose:(BOOL)verbose;
{}


- (void)doneTransforming:(NSString *)result;
{
	[self performSelectorOnMainThread:@selector(doDoneTransforming:)
						   withObject:result
						waitUntilDone:NO];
}


- (void)doDoneTransforming:(NSString *)result;
{
	[delegate XSLTService:self didTransform:result];
}


- (void)message:(NSString *)msg;
{
	[self performSelectorOnMainThread:@selector(doMessage:)
						   withObject:msg
						waitUntilDone:NO];	
}


- (void)doMessage:(NSString *)msg;
{
	[delegate XSLTService:self message:[NSString stringWithFormat:@"%@\n", msg]];
}


- (void)error:(NSString *)msg;
{
	[self performSelectorOnMainThread:@selector(doError:)
						   withObject:msg
						waitUntilDone:NO];
}


- (void)doError:(NSString *)msg;
{
	[delegate XSLTService:self error:[NSString stringWithFormat:@"%@\n", msg]];
}


- (void)clearConsoleFile;
{
	[handle truncateFileAtOffset:0];
	[handle synchronizeFile];
}


- (void)showConsoleData;
{
	[handle synchronizeFile];
	NSData *data = [handle readDataToEndOfFile];
	[self message:[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]];	
}


- (NSArray *)packageJavaArgsAsArray:(NSArray *)args;
{
	int		lang			  = [[args objectAtIndex:0] intValue];
	NSString *sourceURLString =  [args objectAtIndex:1];
	NSString *styleURLString  =  [args objectAtIndex:2];
	BOOL verbose			  = [[args objectAtIndex:3] boolValue];
	NSDictionary *params	  =  [args objectAtIndex:4];
	
	NSString *verboseString = (verbose) ? TrueString : FalseString;
	
	NSMutableArray *result = [NSMutableArray array];
	[result addObject:(lang ? @"xquery" : @"xslt")];
	[result addObject:sourceURLString];
	[result addObject:styleURLString];
	[result addObject:verboseString];
	
	NSEnumerator *e = [params keyEnumerator];
	id key;
	while (key = [e nextObject]) {
		[result addObject:key];
		[result addObject:[params objectForKey:key]];
	}	
	
	//NSLog(@"args: %@", result);
	return result;
}


- (NSFileHandle *)handle;
{
	return handle;
}


- (void)setHandle:(NSFileHandle *)newHandle;
{
	if (handle != newHandle) {
		[handle autorelease];
		handle = [newHandle retain];
	}
}

@end
