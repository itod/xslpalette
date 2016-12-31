//
//  XSLTServiceSaxon8_7Impl.m
//  XSLPalette
//
//  Created by Todd Ditchendorf on 8/18/06.
//  Copyright 2006 Todd Ditchendorf. All rights reserved.
//

#import "XSLTServiceSaxon8_7Impl.h"


@implementation XSLTServiceSaxon8_7Impl

- (id)initWithDelegate:(id)aDelegate;
{
	self = [super initWithDelegate:aDelegate];
	if (self != nil) {
		adapterClassName = @"Saxon8_7Adapter";
	}
	return self;
}

@end
