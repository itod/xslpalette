//
//  XSLTServiceXTImpl.m
//  XSLPalette
//
//  Created by Todd Ditchendorf on 11/25/06.
//  Copyright 2006 Todd Ditchendorf. All rights reserved.
//

#import "XSLTServiceXTImpl.h"


@implementation XSLTServiceXTImpl

- (id)initWithDelegate:(id)aDelegate;
{
	self = [super initWithDelegate:aDelegate];
	if (self != nil) {
		adapterClassName = @"XTAdapter";
	}
	return self;
}

@end
