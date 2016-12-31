//
//  MyDocument.m
//  XSLHelper
//
//  Created by itod on 7/20/06.
//  Copyright Todd Ditchendorf 2006 . All rights reserved.
//

#import "MyDocument.h"
#import "PrettyPrinter.h"
#import "XSLTService.h"
#import <WebKit/WebKit.h>
//#import <xercesc/util/PlatformUtils.hpp>
//XERCES_CPP_NAMESPACE_USE 


#define SOURCE_TAG 0
#define STYLE_TAG  1

static NSString * const EmptyHTML  = @"<html></html>";
static NSString * const WhiteSpace = @" ";

@interface MyDocument (Private)
- (void)handleTableClicked:(id)sender;
- (void)handleTextChanged:(id)sender;

- (void)setupParamsTable;
- (NSImage *)plusImage;
- (NSImage *)minusImage;
- (NSTextFieldCell *)textFieldCellWithTag:(int)tag;
- (void)registerForNotifications;
- (void)makeTextViewScrollHorizontally:(NSTextView *)textView 
					  withinScrollView:(NSScrollView *)scrollView;
- (void)windowDidResize:(NSNotification *)aNotification;
- (void)insertParamAtIndex:(int)index;
- (void)removeParamAtIndex:(int)index;

- (BOOL)paramsAreEmpty;
- (void)appendConsoleString:(NSString *)newStr;

- (id <XSLTService>)service;
- (void)setService:(id <XSLTService>)newService;
- (NSMutableDictionary *)params;
- (void)setParams:(NSMutableDictionary *)newParams;
- (NSMutableArray *)paramsOrder;
- (void)setParamsOrder:(NSMutableArray *)newOrder;
@end


@interface NSObject (Private)
- (void)sayHello;
@end

@implementation MyDocument

/*
+ (void)initiaze;
{
	try {
		XMLPlatformUtils::Initialize();
	}
	catch (const XMLException& toCatch) {
	
	}
	
	// Do your actual work with Xerces-C++ here.
	
	XMLPlatformUtils::Terminate();
	

}
*/
- (id)init;
{
    self = [super init];
    if (self) {
		prettyPrinter = [[PrettyPrinter alloc] init];
		[self setParams:[NSMutableDictionary dictionaryWithObject:WhiteSpace forKey:WhiteSpace]];
		[self setParamsOrder:[NSMutableArray arrayWithObject:WhiteSpace]];
		[self updateChangeCount:NSChangeCleared];
		
		NSString *path = [[NSBundle mainBundle] pathForResource:@"EngineTypes" ofType:@"plist"];
		engineTypes = [[NSArray alloc] initWithContentsOfFile:path];
	}
    return self;
}


- (void)dealloc;
{
	[engineTypes release];
	[prettyPrinter release];
	[self setErrorString:nil];
	[self setSourceURLString:nil];
	[self setStyleURLString:nil];
	[self setRawResultString:nil];
	[self setPrettyResultString:nil];
	[self setWindowFrameString:nil];
	[self setService:nil];
	[self setParams:nil];
	[self setParamsOrder:nil];
	[super dealloc];
}



- (NSString *)windowNibName;
{
    return @"MyDocument";
}


- (void)windowControllerDidLoadNib:(NSWindowController *)aController;
{
    [super windowControllerDidLoadNib:aController];
	
	BOOL floatingPanel = [[[NSUserDefaults standardUserDefaults] objectForKey:@"floatingPanel"] boolValue];
	[(NSPanel *)[aController window] setFloatingPanel:floatingPanel];
	[(NSPanel *)[aController window] setHidesOnDeactivate:NO];
	
	[[aController window] setFrameFromString:windowFrameString];
	
	NSFont *monaco = [NSFont fontWithName:@"Monaco" size:10.];
	[rawResultTextView setFont:monaco];
	[errorTextView setFont:monaco];
	[splitView setDelegate:self];
	
	[self setupParamsTable];
	
	[self makeTextViewScrollHorizontally:errorTextView
						withinScrollView:errorScrollView];
	[self makeTextViewScrollHorizontally:rawResultTextView
						withinScrollView:rawResultScrollView];
}


- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError;
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
	if (sourceURLString) {
		[dict setObject:sourceURLString forKey:@"source"];
	}
	if (styleURLString) {
		[dict setObject:styleURLString forKey:@"style"];
	}
	[dict setObject:[NSNumber numberWithInt:engineType] forKey:@"engineType"];
	[dict setObject:[NSNumber numberWithInt:transformLang] forKey:@"transformLang"];
	[dict setObject:[NSNumber numberWithBool:verbose] forKey:@"verbose"];
	[dict setObject:params forKey:@"params"];
	[dict setObject:paramsOrder forKey:@"paramsOrder"];
	[dict setObject:[[[[self windowControllers] objectAtIndex:0] window] stringWithSavedFrame] forKey:@"windowFrameString"];
	
	//NSLog(@"saving: %@", dict);
	
    return [NSKeyedArchiver archivedDataWithRootObject:dict];
}


- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError;
{
	NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	NSString *sourceURLStr = [dict objectForKey:@"source"];
	NSString *styleURLStr = [dict objectForKey:@"style"];
	if (sourceURLStr) {
		[self setSourceURLString:sourceURLStr];
	}
	if (styleURLStr) {
		[self setStyleURLString:styleURLStr];
	}
	[self setEngineType:(EngineType)[[dict objectForKey:@"engineType"] intValue]];
	[self setTransformLang:(TransformLang)[[dict objectForKey:@"transformLang"] intValue]];
	[self setVerbose:[[dict objectForKey:@"verbose"] boolValue]];
	[self setParams:[dict objectForKey:@"params"]];
	[self setParamsOrder:[dict objectForKey:@"paramsOrder"]];
	[self setWindowFrameString:[dict objectForKey:@"windowFrameString"]];
	
	//NSLog(@"reading: %@", dict);
	
    return YES;
}


#pragma mark -
#pragma mark Actions

- (IBAction)transform:(id)sender;
{	
	[self clear:self];
	
	if (![sourceURLString length] || ![styleURLString length]) {
		NSBeep();
		return;
	}
	
	[self setTransforming:YES];
	NSDictionary *sentParams;

	if ([self paramsAreEmpty]) {
		sentParams = [NSDictionary dictionary];
	} else {
		sentParams = params;
	}
	
	NSString *currentServiceClassName = NSStringFromClass([service class]);
	NSString *newServiceClassName = [engineTypes objectAtIndex:engineType];

	if (!service || ![currentServiceClassName isEqualToString:newServiceClassName]) {
		//NSLog(@"creating new service");
		[self setService:[[NSClassFromString(newServiceClassName) alloc] initWithDelegate:self]];
	}
	
	[service transformSource:sourceURLString
			  withStylesheet:styleURLString
					  params:sentParams
						lang:transformLang
					 verbose:verbose];
}


- (IBAction)browse:(id)sender;
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	const int res = [panel runModalForDirectory:nil file:nil];
	if (NSFileHandlingPanelOKButton == res) {
		if (SOURCE_TAG == [sender tag]) {
			[self setSourceURLString:[panel filename]];
		} else {
			[self setStyleURLString:[panel filename]];
		}
	}
}


- (IBAction)clear:(id)sender;
{
	[[prettyResultWebView mainFrame] loadHTMLString:EmptyHTML baseURL:nil];
	[[renderedResultWebView mainFrame] loadHTMLString:EmptyHTML baseURL:nil];	
	[self setRawResultString:nil];
	[self setPrettyResultString:nil];
	[self setErrorString:[NSMutableString string]];
	[errorTextView setString:@""];
}


- (IBAction)insertParam:(id)sender;
{
	int index = [paramsTable selectedRow];
	[self insertParamAtIndex:index+1];
	[paramsTable reloadData];
}


- (IBAction)removeParam:(id)sender;
{
	int index = [paramsTable selectedRow];
	[self removeParamAtIndex:index];
	[paramsTable reloadData];
}


- (IBAction)langChanged:(id)sender;
{
	TransformLang newLang = (TransformLang)[sender selectedTag];
	
	if (newLang == TransformLangXQuery) {
		
		if (engineType == EngineTypeLibxslt 
			|| engineType == EngineTypeSaxon6_5 
			|| engineType == EngineTypeXT 
			|| engineType == EngineTypeXalanJ) {
			[self setEngineType:EngineTypeSaxon8_7];
		}
		
	} else if (newLang == TransformLangXSLT) {
		
		if (engineType == EngineTypeNSXML) {
			[self setEngineType:EngineTypeLibxslt];
		}
		
	}
}


- (IBAction)engineChanged:(id)sender;
{
	EngineType newType = (EngineType)[sender selectedTag];
	
	if (transformLang == TransformLangXQuery) {
		
		if (engineType == EngineTypeLibxslt 
			|| engineType == EngineTypeSaxon6_5 
			|| engineType == EngineTypeXT 
			|| engineType == EngineTypeXalanJ) {
			[self setTransformLang:TransformLangXSLT];
		}
		
	} else if (transformLang == TransformLangXSLT) {
		
		if (newType == EngineTypeNSXML) {
			[self setTransformLang:TransformLangXQuery];
		}
		
	}
}


#pragma mark -
#pragma mark XSLTServiceDelegate

- (void)XSLTService:(id <XSLTService>)service didTransform:(NSString *)result;
{
	[self setRawResultString:result];
	[self setPrettyResultString:[prettyPrinter prettyStringForXMLString:rawResultString]];

	@try {
		[[renderedResultWebView mainFrame] loadData:[rawResultString dataUsingEncoding:NSUTF8StringEncoding] MIMEType:nil textEncodingName:@"utf-8" baseURL:nil];
		[[prettyResultWebView mainFrame] loadData:[prettyResultString dataUsingEncoding:NSUTF8StringEncoding] MIMEType:nil textEncodingName:@"utf-8" baseURL:nil];
	}
	@finally {
		[self setTransforming:NO];
		[[NSSound soundNamed:@"Hero"] play];
	}
}


- (void)XSLTService:(id <XSLTService>)service message:(NSString *)msg;
{
	[self appendConsoleString:msg];
}


- (void)XSLTService:(id <XSLTService>)service error:(NSString *)msg;
{
	if (msg) {
		[self appendConsoleString:msg];
	}
	[self setTransforming:NO];
	[[NSSound soundNamed:@"Basso"] play];
}


#pragma mark -
#pragma mark PrivateActions

- (void)handleTableClicked:(id)sender;
{
	lastClickedCol = [sender clickedColumn];
}


- (void)handleTextChanged:(id)sender;
{
	int rowIndex = [sender selectedRow];
	int colIndex = [sender clickedColumn];
	if (-1 == colIndex) {
		colIndex = lastClickedCol;
	}
	
	NSMutableDictionary *reqHeaders = [self params];
	NSMutableArray *headerOrder = [self paramsOrder];
	
	//NSLog(@"row: %i, col: %i",rowIndex,colIndex);
	if (0 == colIndex) { // name changed
		
		NSString *oldName = [headerOrder objectAtIndex:rowIndex];
		NSString *newName = [sender stringValue];
		NSString *value   = [reqHeaders objectForKey:oldName];
		[headerOrder replaceObjectAtIndex:rowIndex withObject:newName];
		[reqHeaders removeObjectForKey:oldName];
		[reqHeaders setObject:value forKey:newName];
		
	} else { // value changed
		
		NSString *name = [headerOrder objectAtIndex:rowIndex];
		NSString *value = [sender stringValue];
		[reqHeaders setObject:value forKey:name];
		
	}
}


#pragma mark -
#pragma mark Private

- (BOOL)paramsAreEmpty;
{
	return ([params count] == 0 || ([params count] == 1 && [[paramsOrder objectAtIndex:0] isEqualToString:WhiteSpace]));
}


- (void)appendConsoleString:(NSString *)newStr;
{
	NSMutableString *str = nil;
	if (errorString) {
		[errorString appendString:newStr];
		str = [NSMutableString stringWithString:errorString];
	} else {
		str = [NSMutableString stringWithString:newStr];
	}
	[self setErrorString:str];
	[errorTextView setString:errorString];
}


- (void)setupParamsTable;
{	
	[paramsTable setTarget:self];
	[paramsTable setAction:@selector(handleTableClicked:)];
	
	//[[paramsTable tableColumnWithIdentifier:@"name"] setDataCell:[self textFieldCellWithTag:0]];
	//[[paramsTable tableColumnWithIdentifier:@"value"] setDataCell:[self textFieldCellWithTag:1]];
	
	NSButtonCell *cell = [[paramsTable tableColumnWithIdentifier:@"plus"] dataCell];
	[cell setTarget:self];
	[cell setAction:@selector(insertParam:)];
	[cell setImage:[self plusImage]];
	[cell setImagePosition:NSImageOnly];
	
	cell = [[paramsTable tableColumnWithIdentifier:@"minus"] dataCell];
	[cell setTarget:self];
	[cell setAction:@selector(removeParam:)];
	[cell setImage:[self minusImage]];
	[cell setImagePosition:NSImageOnly];
	
	//[paramsTable setIntercellSpacing:NSMakeSize(7, 7)];
}


- (NSImage *)plusImage;
{
    float scaleFactor = 1.0;// hi dpi...? * [[NSScreen mainScreen] use
    float imageSize = 8 * scaleFactor;
    NSImage *result = [[[NSImage alloc] initWithSize:NSMakeSize(imageSize, imageSize)] autorelease];
    [result lockFocus];
    [[NSColor grayColor] set];
	
    // Horz line
    NSRectFill(NSMakeRect(0, 3 * scaleFactor, imageSize, 2 * scaleFactor));
    // Top part
    NSRectFill(NSMakeRect(3 * scaleFactor, 0, 2 * scaleFactor, 3 * scaleFactor));
    // Bottom part
    NSRectFill(NSMakeRect(3 * scaleFactor, imageSize - 3 * scaleFactor, 2 * scaleFactor, 3 * scaleFactor));
	
    [result unlockFocus];
	
    return result;
}


- (NSImage *)minusImage;
{
    float scaleFactor = 1.0;// hi dpi...? * [[NSScreen mainScreen] use
    float imageSize = 8 * scaleFactor;
    NSImage *result = [[[NSImage alloc] initWithSize:NSMakeSize(imageSize, imageSize)] autorelease];
    [result lockFocus];
    [[NSColor grayColor] set];
	
    // Horz line
    NSRectFill(NSMakeRect(0, 3 * scaleFactor, imageSize, 2 * scaleFactor));	
	
    [result unlockFocus];
	
    return result;
}


- (NSTextFieldCell *)textFieldCellWithTag:(int)tag;
{
	NSTextFieldCell *tfCell = [[NSTextFieldCell alloc] init];
	[tfCell setEditable:YES];
	[tfCell setFocusRingType:NSFocusRingTypeNone];
	[tfCell setControlSize:NSSmallControlSize];
	[tfCell setFont:[NSFont fontWithName:@"Lucida Grande" size:10.]];
	[tfCell setTarget:self];
	[tfCell setAction:@selector(handleTextChanged:)];
	[tfCell setTag:tag];
	return tfCell;
}


- (void)registerForNotifications;
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(controlTextDidChange:)
			   name:NSControlTextDidChangeNotification
			 object:paramsTable];
	[nc addObserver:self
		   selector:@selector(controlTextDidEndEditing:)
			   name:NSControlTextDidEndEditingNotification
			 object:paramsTable];
}


- (void)makeTextViewScrollHorizontally:(NSTextView *)textView 
					  withinScrollView:(NSScrollView *)scrollView;
{
	[scrollView setHasHorizontalScroller:YES];
	[textView setHorizontallyResizable:YES];
	[textView setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
	[[textView textContainer] setContainerSize:NSMakeSize(MAXFLOAT, MAXFLOAT)];
	[[textView textContainer] setWidthTracksTextView:NO];	
	[textView setMaxSize:NSMakeSize(MAXFLOAT, MAXFLOAT)];
}


- (void)windowDidResize:(NSNotification *)aNotification;
{
	[paramsTable sizeToFit];
}


- (void)insertParamAtIndex:(int)index;
{
	[[self paramsOrder] insertObject:WhiteSpace atIndex:index];
	[[self params] setObject:WhiteSpace forKey:WhiteSpace];
}


- (void)removeParamAtIndex:(int)index;
{
	NSString *name = [[self paramsOrder] objectAtIndex:index];
	[[self params] removeObjectForKey:name];
	[[self paramsOrder] removeObjectAtIndex:index];
	
	if (0 == index && 0 == [[self paramsOrder] count]) {
		[[self params] setObject:WhiteSpace forKey:WhiteSpace];
		[[self paramsOrder] addObject:WhiteSpace];
	}
	
}








#pragma mark -
#pragma mark SplitViewDelegate

- (float)splitView:(NSSplitView *)sender constrainMaxCoordinate:(float)proposedMax ofSubviewAt:(int)offset;
{
	if (offset == 0) {
		NSRect r = [[[[self windowControllers] objectAtIndex:0] window] frame];
		return r.size.height - 142;
	}
	return proposedMax;
}


- (float)splitView:(NSSplitView *)sender constrainMinCoordinate:(float)proposedMin ofSubviewAt:(int)offset;
{
	if (offset == 0) {
		return 18;
	}
	return proposedMin;
}


#pragma mark -
#pragma mark NSTableDataSource

- (int)numberOfRowsInTableView:(NSTableView *)aTableView;
{
	return [[self params] count];
}


- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
{
	NSString *identifier = [aTableColumn identifier];
	NSString *name = [[self paramsOrder] objectAtIndex:rowIndex];
	
	if ([identifier isEqualToString:@"name"]) {
		return name;
	} else if ([identifier isEqualToString:@"value"]) {
		return [[self params] objectForKey:name];
	} else if ([identifier isEqualToString:@"buttons"]) {
		return [NSNumber numberWithInt:1];
	}
	return nil;
}


#pragma mark -
#pragma mark NSControlTextChangedNotification

- (void)controlTextDidChange:(NSNotification *)aNotification;
{
	id obj = [aNotification object];
	if (obj == paramsTable) {
		[self handleTextChanged:[aNotification object]];
		[self updateChangeCount:NSChangeDone];
	}
}


#pragma mark -
#pragma mark NSControlTextChangedNotification

- (void)controlTextDidEndEditing:(NSNotification *)aNotification;
{
	if (0 == lastClickedCol) {
		lastClickedCol++;
	}
}


#pragma mark -
#pragma mark Accessors

- (BOOL)transforming;
{
	return transforming;
}


- (BOOL)verbose;
{
	return verbose;
}


- (EngineType)engineType;
{
	return engineType;
}


- (TransformLang)TransformLang;
{
	return transformLang;
}


- (NSString *)sourceURLString;
{
	return sourceURLString;
}


- (NSString *)styleURLString;
{
	return styleURLString;
}


- (NSString *)errorString;
{
	return errorString;
}


- (NSString *)rawResultString;
{
	return rawResultString;
}


- (NSString *)prettyResultString;
{
	return prettyResultString;
}


- (NSString *)windowFrameString;
{
	return windowFrameString;
}


- (void)setTransforming:(BOOL)yn;
{
	transforming = yn;
}


- (void)setVerbose:(BOOL)yn;
{
	verbose = yn;
}


- (void)setEngineType:(EngineType)newType;
{
	engineType = newType;
}


- (void)setTransformLang:(TransformLang)newLang;
{
	transformLang = newLang;
}


- (void)setSourceURLString:(NSString *)newStr;
{
	if (sourceURLString != newStr) {
		[sourceURLString autorelease];
		sourceURLString = [newStr retain];
	}
}


- (void)setStyleURLString:(NSString *)newStr;
{
	if (styleURLString != newStr) {
		[styleURLString autorelease];
		styleURLString = [newStr retain];
	}
}


- (void)setErrorString:(NSMutableString *)newStr;
{
	if (errorString != newStr) {
		[errorString autorelease];
		errorString = [newStr retain];
	}
}


- (void)setRawResultString:(NSString *)newStr;
{
	if (rawResultString != newStr) {
		[rawResultString autorelease];
		rawResultString = [newStr retain];
	}
}


- (void)setPrettyResultString:(NSString *)newStr;
{
	if (prettyResultString != newStr) {
		[prettyResultString autorelease];
		prettyResultString = [newStr retain];
	}
}


- (void)setWindowFrameString:(NSString *)newStr;
{
	if (windowFrameString != newStr) {
		[windowFrameString autorelease];
		windowFrameString = [newStr retain];
	}
}


- (id <XSLTService>)service;
{
	return service;
}


- (void)setService:(id <XSLTService>)newService;
{
	if (service != newService) {
		[service release];
		service = [newService retain];
	}
}


- (NSMutableDictionary *)params;
{
	return params;
}


- (void)setParams:(NSMutableDictionary *)newParams;
{
	if (params != newParams) {
		[params autorelease];
		params = [newParams retain];
	}
}


- (NSMutableArray *)paramsOrder;
{
	return paramsOrder;
}


- (void)setParamsOrder:(NSMutableArray *)newOrder;
{
	if (paramsOrder != newOrder) {
		[paramsOrder autorelease];
		paramsOrder = [newOrder retain];
	}
}


@end
