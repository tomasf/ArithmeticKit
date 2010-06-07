//
//  AKConstantExpression.m
//  Math
//
//  Created by Tomas Franzén on 2010-05-18.
//  Copyright 2010 Lighthead Software. All rights reserved.
//

#import "AKConstantExpression.h"


@implementation AKConstantExpression
@synthesize value;

+ (id)expressionWithValue:(double)v {
	return [[[self alloc] initWithValue:v] autorelease];
}

- (id)initWithValue:(double)v {
	[super init];
	self.value = v;
	return self;
}

- (AKExpression*)evaluateWithDefinitions:(NSDictionary*)defs {
	return self;
}

- (BOOL)isConstant {
	return YES;
}

- (NSString*)description {
	return [NSString stringWithFormat:@"%f", self.value];
}

@end
