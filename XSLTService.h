//
//  XSLTService.h
//  XSLPalette
//
//  Created by Todd Ditchendorf on 8/18/06.
//  Copyright 2006 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
	TransformLangXSLT = 0,
	TransformLangXQuery
} TransformLang;

@protocol XSLTService <NSObject>

- (id)initWithDelegate:(id)aDelegate;

- (void)transformSource:(NSString *)sourceURLString
		 withStylesheet:(NSString *)styleURLString
				 params:(NSDictionary *)params
				   lang:(TransformLang)lang
				verbose:(BOOL)verbose;
@end


@interface NSObject (XSLTServiceDelegate)
- (void)XSLTService:(id <XSLTService>)service didTransform:(NSString *)result;
- (void)XSLTService:(id <XSLTService>)service message:(NSString *)msg;
- (void)XSLTService:(id <XSLTService>)service error:(NSString *)msg;
@end

