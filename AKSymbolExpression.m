//
//  AKSymbolExpression.m
//  Math
//
//  Created by Tomas Franzén on 2010-05-18.
//  Copyright 2010 Lighthead Software. All rights reserved.
//

#import "AKSymbolExpression.h"
#import "AKConstantExpression.h"

@implementation AKSymbolExpression
@synthesize symbol;

static NSMutableDictionary *staticDefinitions = nil;

+ (void)defineGlobalSymbol:(NSString*)name value:(AKExpression*)v {
	[staticDefinitions setObject:v forKey:name];
}

+ (void)initialize {
	staticDefinitions = [NSMutableDictionary dictionary];
	[self defineGlobalSymbol:@"pi" value:[AKConstantExpression expressionWithValue:M_PI]];
	[self defineGlobalSymbol:@"e" value:[AKConstantExpression expressionWithValue:M_E]];
}

+ (id)expressionWithSymbol:(NSString*)s {
	return [[[self alloc] initWithSymbol:s] autorelease];
}

- (id)initWithSymbol:(NSString*)s {
	[super init];
	NSParameterAssert(s != nil);
	self.symbol = s;
	return self;
}

- (void)dealloc {
	[symbol release];
	[super dealloc];
}

- (AKExpression*)evaluateWithDefinitions:(NSDictionary*)defs {
	return [[defs objectForKey:symbol] evaluateWithDefinitions:defs] ?: ([[staticDefinitions objectForKey:symbol] evaluateWithDefinitions:defs] ?: self);
}

- (NSString*)description {
	return self.symbol;
}

@end
