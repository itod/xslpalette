//
//  XSLTServiceLibxsltImpl.m
//  XSLPalette
//
//  Created by Todd Ditchendorf on 8/19/06.
//  Copyright 2006 Todd Ditchendorf. All rights reserved.
//

#import "XSLTServiceLibxsltImpl.h"
#import "AGRegex.h"
#import <libxml/xmlmemory.h>
#import <libxml/debugXML.h>
#import <libxml/HTMLtree.h>
#import <libxml/xmlIO.h>
#import <libxml/xinclude.h>
#import <libxml/catalog.h>
#import <libxslt/xslt.h>
#import <libxslt/xsltinternals.h>
#import <libxslt/transform.h>
#import <libxslt/xsltutils.h>
#import <libxslt/extensions.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>
#import <libexslt/exslt.h>


@interface XSLTServiceLibxsltImpl (Private)
- (void)doTransform:(NSArray *)args;
- (void)doneTransforming:(NSString *)result;
- (void)doDoneTransforming:(NSString *)result;
- (void)message:(NSString *)msg;
- (void)doMessage:(NSString *)msg;
- (void)error:(NSString *)msg;
- (void)doError:(NSString *)msg;
@end

@implementation XSLTServiceLibxsltImpl

static void myErrorHandler(id self, const char * msg, ...)
{
	va_list vargs;
	va_start(vargs, msg);
	
	NSString *msgStr = [[NSString alloc] initWithFormat:[NSString stringWithUTF8String:msg] arguments:vargs];
	
	[self message:msgStr];
	
	[msgStr autorelease];
	va_end(vargs);
}


static void regexpModuleElementScript(xsltTransformContextPtr ctxt,
									  xmlNodePtr inputNode,
									  xmlNodePtr sheetNode,
									  xsltStylePreCompPtr comp)
{
	NSLog(@"script! inputNode: %s", inputNode->name);
	NSLog(@"script! sheetNode: %s", sheetNode->name);
	/*
	 // get the 'select' attribute of my <say> element
	 xmlAttrPtr selectAttr = sheetNode->properties;
	 const xmlChar *selectExpr = selectAttr->children->content;
	 NSLog(@"selectExpr : %s", selectExpr);
	 
	 // get the current transformation's XPath context
	 xmlXPathContextPtr xpathCtxt = ctxt->xpathCtxt;
	 // set the XPath context's context node to the input node matched by <xsl:template>
	 xpathCtxt->node = inputNode;
	 // evaluate the selectExpr against the XPath context
	 xmlXPathObjectPtr xpathObj = xmlXPathEvalExpression(selectExpr, xpathCtxt);
	 // get the resulting node-set
	 xmlNodeSetPtr nodeSet = xpathObj->nodesetval;
	 
	 // loop thru nodeset.
	 xmlNodePtr cur;
	 int i;
	 int size = (nodeSet) ? nodeSet->nodeNr : 0;
	 NSLog(@"size : %i", size);
	 for (i = 0; i < size; i++) {
		 cur = nodeSet->nodeTab[i];
		 //NSLog(@"node NS: %s, localName: %s, content: %s", cur->ns->href, cur->name, cur->children->content);
		 
		 xmlChar *text = cur->content;
		 doSpeech(text);
	 }*/
}


static int regexpModuleGetOptions(xmlChar *optStr)
{
	int opts = 0;
	NSString *flags = [NSString stringWithUTF8String:(char *)optStr];
	NSRange r = [flags rangeOfString:@"i"];
	if (NSNotFound != r.location)
		opts = (opts|AGRegexCaseInsensitive);
	r = [flags rangeOfString:@"s"];
	if (NSNotFound != r.location)
		opts = (opts|AGRegexDotAll);
	r = [flags rangeOfString:@"x"];
	if (NSNotFound != r.location)
		opts = (opts|AGRegexExtended);
	r = [flags rangeOfString:@"m"];
	if (NSNotFound != r.location)
		opts = (opts|AGRegexMultiline);	
	return opts;
}


static void regexpModuleFunctionReplace(xmlXPathParserContextPtr ctxt, int nargs)
{	
	int opts = 0;
	if (4 == nargs) {
		opts = regexpModuleGetOptions(xmlXPathPopString(ctxt));
	}
	
	const xmlChar *replacePattern = xmlXPathPopString(ctxt);
	const xmlChar *matchPattern = xmlXPathPopString(ctxt);
	const xmlChar *input = xmlXPathPopString(ctxt);
	
	AGRegex *regex = [AGRegex regexWithPattern:[NSString stringWithUTF8String:(const char*)matchPattern]
									   options:opts];
	
	NSString *result = [regex replaceWithString:[NSString stringWithUTF8String:(const char*)replacePattern]
									   inString:[NSString stringWithUTF8String:(const char*)input]];
	//NSLog(@"result: %@", result);
	
	xmlXPathObjectPtr value = xmlXPathNewString((xmlChar *)[result UTF8String]);
	valuePush(ctxt, value);
}


static void regexpModuleFunctionTest(xmlXPathParserContextPtr ctxt, int nargs)
{	
	int opts = 0;
	if (3 == nargs) {
		opts = regexpModuleGetOptions(xmlXPathPopString(ctxt));
	}
	
	const xmlChar *matchPattern = xmlXPathPopString(ctxt);
	const xmlChar *input = xmlXPathPopString(ctxt);
	
	//NSLog(@"input: %s", input);
	//NSLog(@"matchPattern: %s", matchPattern);
	//NSLog(@"flags: %s", flags);
	
	AGRegex *regex = [AGRegex regexWithPattern:[NSString stringWithUTF8String:(const char*)matchPattern]
									   options:opts];
	
	BOOL result = [[regex findInString:[NSString stringWithUTF8String:(const char*)input]] count];
	//NSLog(@"result: %@", result);
	
	xmlXPathObjectPtr value = xmlXPathNewBoolean(result);
	valuePush(ctxt, value);
}


static void regexpModuleFunctionMatch(xmlXPathParserContextPtr ctxt, int nargs)
{	
	int opts = 0;
	if (3 == nargs) {
		opts = regexpModuleGetOptions(xmlXPathPopString(ctxt));
	}
	
	const xmlChar *matchPattern = xmlXPathPopString(ctxt);
	const xmlChar *input = xmlXPathPopString(ctxt);
	
	//NSLog(@"input: %s", input);
	//NSLog(@"matchPattern: %s", matchPattern);
	//NSLog(@"flags: %s", flags);
	
	AGRegex *regex = [AGRegex regexWithPattern:[NSString stringWithUTF8String:(const char*)matchPattern]
									   options:opts];
	
	AGRegexMatch *match = [[regex findAllInString:[NSString stringWithUTF8String:(const char*)input]] objectAtIndex:0];
	
	int len = [match count];
	//NSLog(@"match: %@", match);
	
	xmlNodePtr node = xmlNewNode(NULL, (const xmlChar *)"match");
	xmlNodeSetContent(node, (const xmlChar *)[[match groupAtIndex:0] UTF8String]);
	xmlNodeSetPtr nodeSet = xmlXPathNodeSetCreate(node);
	
	int i;
	NSString *item;
	for (i = 1; i < len; i++) {
		item = [match groupAtIndex:i];
		
		node = xmlNewNode(NULL, (const xmlChar *)"match");
		if (item) {
			xmlNodeSetContent(node, (const xmlChar *)[[match groupAtIndex:i] UTF8String]);
		} else {
			xmlNodeSetContent(node, (const xmlChar *)"");
		}
		xmlXPathNodeSetAdd(nodeSet, node);
	}
	
	xmlXPathObjectPtr value = xmlXPathWrapNodeSet(nodeSet);
	valuePush(ctxt, value);
}


static void *regexpModuleInit(xsltTransformContextPtr ctxt, const xmlChar *URI)
{	
	//xsltRegisterExtElement(ctxt, (const xmlChar *)"script", URI,
	//					   (xsltTransformFunction)regexpModuleElementScript);
	xsltRegisterExtFunction(ctxt, (const xmlChar *)"replace", URI,
							(xmlXPathFunction)regexpModuleFunctionReplace);
	xsltRegisterExtFunction(ctxt, (const xmlChar *)"test", URI,
							(xmlXPathFunction)regexpModuleFunctionTest);
	xsltRegisterExtFunction(ctxt, (const xmlChar *)"match", URI,
							(xmlXPathFunction)regexpModuleFunctionMatch);
	
	return NULL;
}


static void *regexpModuleShutdown(xsltTransformContextPtr ctxt,
								  const xmlChar *URI,
								  void *data)
{
	return NULL;
}


+ (void)initialize;
{
	xsltRegisterExtModule((const xmlChar *)"http://exslt.org/regular-expressions",
						  (xsltExtInitFunction)regexpModuleInit,
						  (xsltExtShutdownFunction)regexpModuleShutdown);
	
	xmlSubstituteEntitiesDefaultValue = 1;
	xmlLoadExtDtdDefaultValue = 1;
	exsltRegisterAll();
}


- (id)initWithDelegate:(id)aDelegate;
{
	self = [super init];
	if (self != nil) {
		delegate = aDelegate;
	}
	return self;
}


- (void)transformSource:(NSString *)sourceURLString
		 withStylesheet:(NSString *)styleURLString
				 params:(NSDictionary *)params
				   lang:(TransformLang)lang
				verbose:(BOOL)verbose;
{
	NSArray *args = [NSArray arrayWithObjects:sourceURLString, styleURLString, 
		[NSNumber numberWithBool:verbose], params, nil];
	
	[NSThread detachNewThreadSelector:@selector(doTransform:)
							 toTarget:self
						   withObject:args];
}


- (void)doTransform:(NSArray *)args;
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSString *sourceURLString =  [args objectAtIndex:0];
	NSString *styleURLString  =  [args objectAtIndex:1];
	BOOL verbose			  = [[args objectAtIndex:2] boolValue];
	NSDictionary *params	  =  [args objectAtIndex:3];
		
	xmlSetGenericErrorFunc((void *)self, (xmlGenericErrorFunc)myErrorHandler);
	xsltSetGenericErrorFunc((void *)self, (xmlGenericErrorFunc)myErrorHandler);
	
	xmlDocPtr source = NULL;
	xsltStylesheetPtr stylesheet = NULL;
	xsltTransformContextPtr xformCtxt = NULL;
	xmlDocPtr res = NULL;
	xmlChar *resultStr = NULL;
	
	NSDate *start1 = [NSDate date];
	source = xmlParseFile([sourceURLString UTF8String]);
	NSDate *end1 = [NSDate date];
	
	if (!source) {
		[self error:nil];
		NSLog(@"error parsing source doc"); 
		
		// free memory
		if (source)
			xmlFreeDoc(source);
		xmlCleanupParser();
		
		[pool release];
		return;
	}
	
	NSTimeInterval duration1 = [end1 timeIntervalSinceDate:start1];
	if (verbose) {
		[self message:[NSString stringWithFormat:@"Parsing source document: %.4f secs\n", duration1]];	
	}

	NSDate *start2 = [NSDate date];
	stylesheet = xsltParseStylesheetFile((const xmlChar*)[styleURLString UTF8String]);
	NSDate *end2 = [NSDate date];
	
	if (!stylesheet) {
		[self error:nil];
		NSLog(@"error parsing stylesheet");
		
		// free memory
		if (source)
			xmlFreeDoc(source);
		if (stylesheet)
			xsltFreeStylesheet(stylesheet);
		xmlCleanupParser();
		
		[pool release];
		return;
	}
	
	NSTimeInterval duration2 = [end2 timeIntervalSinceDate:start2];
	if (verbose) {
		[self message:[NSString stringWithFormat:@"Parsing stylesheet: %.4f secs\n", duration2]];
	}
	
	xformCtxt = xsltNewTransformContext(stylesheet, source);
	xsltSetTransformErrorFunc(xformCtxt, (void *)self, (xmlGenericErrorFunc)myErrorHandler);
	
	
	const int count = [params count]*2 +1;
	const char *parameters[count];
	
	if ([params count] == 0) {
		*parameters = NULL;
	} else {
		NSEnumerator *e = [params keyEnumerator];
		id key, val;
		int i = -1;
		while (key = [e nextObject]) {
			if (![key isEqualToString:@" "]) {
				val = [params objectForKey:key];
				parameters[++i] = [key UTF8String];
				parameters[++i] = [val UTF8String];
			}
		}
		parameters[++i] = NULL;
	}
	
	NSDate *start3 = [NSDate date];
	@try {
		res = xsltApplyStylesheet(stylesheet, source, parameters);
	}
	@catch (NSException *e) {
		[self error:[e reason]];
		NSLog(@"caught!!!!!");
		goto leave;
	}
	
	NSDate *end3 = [NSDate date];
	
	if (!res) {
		[self error:nil];
		NSLog(@"error during transformation");
		goto leave;
	}
	
	NSTimeInterval duration3 = [end3 timeIntervalSinceDate:start3];
	if (verbose) {
		[self message:[NSString stringWithFormat:@"Transformation: %.4f secs\n", duration3]];
	}
	
	int len;
	xsltSaveResultToString(&resultStr, &len, res, stylesheet);
	
	if (!resultStr) {
		[self error:nil];
		NSLog(@"error during saving result");
		goto leave;
	}
	
	NSString *rawResult = [NSString stringWithUTF8String:(const char *)resultStr];
	[self doneTransforming:rawResult];

leave: 
	// free memory
	if (stylesheet)
		xsltFreeStylesheet(stylesheet);
	if (res)
		xmlFreeDoc(res);
	if (source)
		xmlFreeDoc(source);
	if (xformCtxt)
		xsltFreeTransformContext(xformCtxt);
	if (resultStr)
		free(resultStr);
	
	xmlCleanupParser();
	
	[pool release];
}

@end
