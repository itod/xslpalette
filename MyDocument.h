//
//  MyDocument.h
//  XSLHelper
//
//  Created by itod on 7/20/06.
//  Copyright Todd Ditchendorf 2006 . All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "XSLTService.h"

@class PrettyPrinter;
@class WebView;

typedef enum {
	EngineTypeLibxslt = 0,
	EngineTypeXalanJ,
	EngineTypeXT,
	EngineTypeSaxon6_5,
	EngineTypeSaxon8_7,
	EngineTypeNSXML
} EngineType;

@interface MyDocument : NSDocument
{
	IBOutlet NSTextView *errorTextView;
	IBOutlet NSScrollView *errorScrollView;
	IBOutlet NSTextView *rawResultTextView;
	IBOutlet NSScrollView *rawResultScrollView;
	IBOutlet NSSplitView *splitView;
	IBOutlet NSTableView *paramsTable;
	IBOutlet WebView *prettyResultWebView;
	IBOutlet WebView *renderedResultWebView;
	
	PrettyPrinter *prettyPrinter;
	id <XSLTService> service;
	NSArray *engineTypes;
	
	BOOL transforming;
	BOOL verbose;
	EngineType engineType;
	TransformLang transformLang;
	NSString *sourceURLString;
	NSString *styleURLString;
	NSMutableString *errorString;
	NSString *rawResultString;
	NSString *prettyResultString;
	NSString *windowFrameString;
	
	int lastClickedCol;
	
	NSMutableDictionary *params;
	NSMutableArray *paramsOrder;
}

- (IBAction)transform:(id)sender;
- (IBAction)browse:(id)sender;
- (IBAction)clear:(id)sender;
- (IBAction)insertParam:(id)sender;
- (IBAction)removeParam:(id)sender;
- (IBAction)langChanged:(id)sender;
- (IBAction)engineChanged:(id)sender;

- (BOOL)transforming;
- (BOOL)verbose;
- (EngineType)engineType;
- (TransformLang)TransformLang;
- (NSString *)sourceURLString;
- (NSString *)styleURLString;
- (NSString *)errorString;
- (NSString *)rawResultString;
- (NSString *)prettyResultString;
- (NSString *)windowFrameString;

- (void)setTransforming:(BOOL)yn;
- (void)setVerbose:(BOOL)yn;
- (void)setEngineType:(EngineType)newType;
- (void)setTransformLang:(TransformLang)newLang;
- (void)setSourceURLString:(NSString *)newStr;
- (void)setStyleURLString:(NSString *)newStr;
- (void)setErrorString:(NSMutableString *)newStr;
- (void)setRawResultString:(NSString *)newStr;
- (void)setPrettyResultString:(NSString *)newStr;
- (void)setWindowFrameString:(NSString *)newStr;
@end
