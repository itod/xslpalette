//
//  AppDelegate.m
//  XSLPalette
//
//  Created by Todd Ditchendorf on 8/23/06.
//  Copyright 2006 Todd Ditchendorf. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate

+ (void)initialize;
{
	NSDictionary *values = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
													   forKey:@"floatingPanel"];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:values];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
	NSDocumentController *docController = [NSDocumentController sharedDocumentController];
	int count = [[docController documents] count];	
	return !count;
}

@end
