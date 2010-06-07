//
//  AKConstantExpression.h
//  Math
//
//  Created by Tomas Franzén on 2010-05-18.
//  Copyright 2010 Lighthead Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AKExpression.h"

@interface AKConstantExpression : AKExpression {
	double value;
}

@property double value;

+ (id)expressionWithValue:(double)v;
- (id)initWithValue:(double)v;

@end
