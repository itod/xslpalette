//
//  PrettyPrinter.m
//  AquaPath
//
//  Created by Todd Ditchendorf on 7/18/06.
//  Copyright 2006 Todd Ditchendorf. All rights reserved.
//

#import "PrettyPrinter.h"

static NSData *compiledStylesheet;

@interface PrettyPrinter (Private)
+ (void)compileXSLT;
@end

@implementation PrettyPrinter

+ (void)initialize;
{
	[self compileXSLT];
}


+ (void)compileXSLT;
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"prettyxml" ofType:@"xsl"];
	compiledStylesheet = [[NSData alloc] initWithContentsOfFile:path];
}


- (void)dealloc;
{
	[super dealloc];
}


#pragma mark -
#pragma mark Public

- (NSString *)prettyStringForXMLString:(NSString *)XMLString;
{
	NSXMLDocument *doc = [[NSXMLDocument alloc] initWithXMLString:XMLString
														  options:NSXMLDocumentTidyHTML
															error:nil];

	id res = [doc objectByApplyingXSLT:compiledStylesheet arguments:nil error:nil];
	//NSLog(@"res : %@", res);
	//NSLog(@"[res class] : %@", [res class]);

	return [res XMLString];
}

@end
