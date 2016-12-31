//
//  XSLTServiceBaseImpl.h
//  XSLPalette
//
//  Created by Todd Ditchendorf on 8/19/06.
//  Copyright 2006 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XSLTService.h"

@interface XSLTServiceBaseImpl : NSObject <XSLTService> {
	id delegate;
	NSFileHandle *handle;
}
- (void)doneTransforming:(NSString *)result;
- (void)doDoneTransforming:(NSString *)result;
- (void)message:(NSString *)msg;
- (void)doMessage:(NSString *)msg;
- (void)error:(NSString *)msg;
- (void)doError:(NSString *)msg;

- (void)clearConsoleFile;
- (void)showConsoleData;
- (NSArray *)packageJavaArgsAsArray:(NSArray *)args;

- (NSFileHandle *)handle;
- (void)setHandle:(NSFileHandle *)newHandle;
@end
