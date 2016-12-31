//
//  XSLTContext.m
//  XSLPalette
//
//  Created by Todd Ditchendorf on 8/20/06.
//  Copyright 2006 Todd Ditchendorf. All rights reserved.
//

#import "XSLTContext.h"
#import <WebKit/WebKit.h>

@interface XSLTContext (Private)
- (void)setDocument:(DOMDocument *)newDocument;
- (void)setContextNode:(DOMNode *)newNode;
- (void)setCurrentNode:(DOMNode *)newNode;
- (void)setContextPosition:(int)newPosition;
- (void)setContextSize:(int)newSize;
@end

@implementation XSLTContext

- (id)init;
{
	self = [super init];
	if (self != nil) {
		
	}
	return self;
}


- (void)dealloc;
{
	[self setDocument:nil];
	[self setContextNode:nil];
	[self setCurrentNode:nil];
	[super dealloc];
}


- (id)systemPropertyForURI:(NSString *)nsURI localName:(NSString *)localName;
{
	return nil;
}


- (id)stringValue:(DOMNode *)node;
{
	NSMutableString *result = [NSMutableString string];
	DOMNodeList *children = [node childNodes];
	
	DOMNode *child;
	int i, len = [children length];
	for (i = 0; i < len; i++) {
		child = [children item:i];
		int type = [child nodeType];

		if (type == DOM_TEXT_NODE) {
            [result appendString:[child nodeValue]];
		}
		else if (type == DOM_CDATA_SECTION_NODE) {
            [result appendString:[child nodeValue]];
		}
		else if (type == DOM_ELEMENT_NODE) {
            [result appendString:[self stringValue:child]];
		}
		else if (type == DOM_ENTITY_REFERENCE_NODE) {
            [result appendString:[self stringValue:child]];
		}
	}
	return result;
}


#pragma mark -
#pragma mark WebScripting

+ (NSString *)webScriptNameForSelector:(SEL)aSelector;
{
	if (aSelector == @selector(systemPropertyForURI:localName:))
		return @"systemProperty";
	else if (aSelector == @selector(stringValue:))
		return @"stringValue";
	else 
		return nil;
}


+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector;
{
	return nil == [self webScriptNameForSelector:aSelector];
}


+ (NSString *)webScriptNameForKey:(const char *)name;
{
	return [NSString stringWithUTF8String:name];
}


+ (BOOL)isKeyExcludedFromWebScript:(const char *)name;
{
	return NO;
}


#pragma mark -
#pragma mark Accessors

- (DOMDocument *)document;
{
	return [[document retain] autorelease];
}


- (DOMNode *)contextNode;
{
	return [[contextNode retain] autorelease];
}


- (DOMNode *)currentNode;
{
 	return [[currentNode retain] autorelease];
}


- (int)contextPosition;
{
	return contextPosition;
}


- (int)contextSize;
{
	return contextSize;
}


#pragma mark -
#pragma mark Private

- (void)setDocument:(DOMDocument *)newDocument;
{
	if (document != newDocument) {
		[document autorelease];
		document = [newDocument retain];
	}
}


- (void)setContextNode:(DOMNode *)newNode;
{
	if (contextNode != newNode) {
		[contextNode autorelease];
		contextNode = [newNode retain];
	}
}


- (void)setCurrentNode:(DOMNode *)newNode;
{
	if (currentNode != newNode) {
		[currentNode autorelease];
		currentNode = [newNode retain];
	}
}


- (void)setContextPosition:(int)newPosition;
{
	contextPosition = newPosition;
}


- (void)setContextSize:(int)newSize;
{
	contextSize = newSize;
}

@end
