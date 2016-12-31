//
//  XSLTServiceBaseJavaImpl.h
//  XSLPalette
//
//  Created by Todd Ditchendorf on 11/25/06.
//  Copyright 2006 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XSLTServiceBaseImpl.h"

@class JavaVirtualMachine;

@interface XSLTServiceBaseJavaImpl : XSLTServiceBaseImpl {
	JavaVirtualMachine *jvm;
	NSString *adapterClassName;
}

@end