//
//  AKOperationExpression.h
//  Math
//
//  Created by Tomas Franzén on 2010-05-18.
//  Copyright 2010 Lighthead Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AKExpression.h"

typedef enum {
	AKOperationTypeInvalid,
	AKOperationTypeAddition,
	AKOperationTypeSubtraction,
	AKOperationTypeMultiplication,
	AKOperationTypeDivision,
	AKOperationTypeExponentiation,
} AKOperationType;


@interface AKOperationExpression : AKExpression {
	AKOperationType type;
	AKExpression *leftOperand;
	AKExpression *rightOperand;
}

@property AKOperationType type;
@property(retain) AKExpression *leftOperand;
@property(retain) AKExpression *rightOperand;

+ (id)expressionWithOperationType:(AKOperationType)t leftOperand:(AKExpression*)lhs rightOperand:(AKExpression*)rhs;
- (id)initWithType:(AKOperationType)t leftOperand:(AKExpression*)lhs rightOperand:(AKExpression*)rhs;
@end
