//
//  XSLTServiceXalanJImpl.m
//  XSLPalette
//
//  Created by Todd Ditchendorf on 11/25/06.
//  Copyright 2006 Todd Ditchendorf. All rights reserved.
//

#import "XSLTServiceXalanJImpl.h"

@implementation XSLTServiceXalanJImpl

- (id)initWithDelegate:(id)aDelegate;
{
	self = [super initWithDelegate:aDelegate];
	if (self != nil) {
		adapterClassName = @"XalanJAdapter";
	}
	return self;
}

@end