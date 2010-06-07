//
//  AKOperationExpression.m
//  Math
//
//  Created by Tomas Franzén on 2010-05-18.
//  Copyright 2010 Lighthead Software. All rights reserved.
//

#import "AKOperationExpression.h"
#import "AKConstantExpression.h"


@implementation AKOperationExpression
@synthesize type, leftOperand, rightOperand;


- (AKExpression*)evaluateWithDefinitions:(NSDictionary*)defs {
	AKExpression *l = [leftOperand evaluateWithDefinitions:defs];
	AKExpression *r = [rightOperand evaluateWithDefinitions:defs];
	if(!l.constant || !r.constant) return [[[AKOperationExpression alloc] initWithType:self.type leftOperand:l rightOperand:r] autorelease];
	double a = ((AKConstantExpression*)l).value, b = ((AKConstantExpression*)r).value, result = 0;
	
	switch(type) {
		case AKOperationTypeAddition:
			result = a+b;
			break;
		case AKOperationTypeSubtraction:
			result = a-b;
			break;
		case AKOperationTypeMultiplication:
			result = a*b;
			break;
		case AKOperationTypeDivision:
			result = a/b;
			break;
		case AKOperationTypeExponentiation:
			result = pow(a,b);
			break;
	}
	
	return [[[AKConstantExpression alloc] initWithValue:result] autorelease];
}


+ (id)expressionWithOperationType:(AKOperationType)t leftOperand:(AKExpression*)lhs rightOperand:(AKExpression*)rhs {
	return [[[self alloc] initWithType:t leftOperand:lhs rightOperand:rhs] autorelease];
}


- (id)initWithType:(AKOperationType)t leftOperand:(AKExpression*)lhs rightOperand:(AKExpression*)rhs {
	[super init];
	NSParameterAssert(lhs);
	NSParameterAssert(rhs);
	self.type = t;
	self.leftOperand = lhs;
	self.rightOperand = rhs;	
	return self;
}


- (void)dealloc {
	[leftOperand release];
	[rightOperand release];
	[super dealloc];
}


- (NSString*)operatorString {
	switch(self.type) {
		case AKOperationTypeAddition:
			return @"+";
		case AKOperationTypeSubtraction:
			return @"-";
		case AKOperationTypeMultiplication:
			return @"*";
		case AKOperationTypeDivision:
			return @"/";
		case AKOperationTypeExponentiation:
			return @"^";
	}
	return nil;
}


- (NSString*)description {
	return [NSString stringWithFormat:@"(%@ %@ %@)", self.leftOperand, [self operatorString], self.rightOperand];
}

@end