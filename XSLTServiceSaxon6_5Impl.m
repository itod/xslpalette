//
//  XSLTServiceSaxon6_5Impl.m
//  XSLPalette
//
//  Created by Todd Ditchendorf on 8/18/06.
//  Copyright 2006 Todd Ditchendorf. All rights reserved.
//

#import "XSLTServiceSaxon6_5Impl.h"


@implementation XSLTServiceSaxon6_5Impl

- (id)initWithDelegate:(id)aDelegate;
{
	self = [super initWithDelegate:aDelegate];
	if (self != nil) {
		adapterClassName = @"Saxon6_5Adapter";
	}
	return self;
}

@end