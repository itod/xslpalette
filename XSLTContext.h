//
//  XSLTContext.h
//  XSLPalette
//
//  Created by Todd Ditchendorf on 8/20/06.
//  Copyright 2006 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DOMDocument;
@class DOMNode;

@interface XSLTContext : NSObject {
	DOMDocument *document;
	DOMNode *contextNode;
	DOMNode *currentNode;
	int contextPosition;
	int contextSize;
}
- (id)systemPropertyForURI:(NSString *)nsURI localName:(NSString *)localName;
- (id)stringValue:(DOMNode *)node;

// Accessors
- (DOMDocument *)document;
- (DOMNode *)contextNode;
- (DOMNode *)currentNode;
- (int)contextPosition;
- (int)contextSize;
@end
