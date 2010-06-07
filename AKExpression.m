//
//  AKExpression.m
//  Math
//
//  Created by Tomas Franzén on 2010-05-17.
//  Copyright 2010 Lighthead Software. All rights reserved.
//

#import "AKExpression.h"
#import <ParseKit/ParseKit.h>
#import "AKOperationExpression.h"
#import "AKConstantExpression.h"
#import "AKSymbolExpression.h"
#import "AKFunctionExpression.h"

NSString *const AKErrorDomain = @"AKErrorDomain";
NSInteger const AKErrorParseError = 1;


@interface NSMutableArray (AKStackExtras)
- (id)stackPop;
- (void)stackPush:(id)obj;
@end


@implementation NSMutableArray (AKStackExtras)

- (id)stackPop {
	id obj = [[[self lastObject] retain] autorelease];
	if(!obj) return nil;
	[self removeObjectAtIndex:[self count]-1];
	return obj;
}

- (void)stackPush:(id)obj {
	[self addObject:obj];
}

@end



@implementation AKExpression

- (AKExpression*)evaluateWithDefinitions:(NSDictionary*)defs {
	[NSException raise:NSInternalInconsistencyException format:@"%@ must override %@", [self class], NSStringFromSelector(_cmd)];
	return nil;
}

- (BOOL)isConstant {
	return NO;
}



+ (AKOperationType)operationTypeFromOperatorString:(NSString*)string {
	if([string isEqual:@"+"]) return AKOperationTypeAddition;
	if([string isEqual:@"-"]) return AKOperationTypeSubtraction;
	if([string isEqual:@"*"]) return AKOperationTypeMultiplication;
	if([string isEqual:@"/"]) return AKOperationTypeDivision;
	if([string isEqual:@"^"]) return AKOperationTypeExponentiation;
	return AKOperationTypeInvalid;
}



+ (BOOL)operationType:(AKOperationType)a precedesOperationType:(AKOperationType)b {
	NSArray *precedence = [NSArray arrayWithObjects:
						   [NSNumber numberWithInt:AKOperationTypeExponentiation],
						   [NSNumber numberWithInt:AKOperationTypeMultiplication],
						   [NSNumber numberWithInt:AKOperationTypeDivision],
						   [NSNumber numberWithInt:AKOperationTypeAddition],
						   [NSNumber numberWithInt:AKOperationTypeSubtraction],
						   nil];
	return [precedence indexOfObject:[NSNumber numberWithInt:a]] < [precedence indexOfObject:[NSNumber numberWithInt:b]];
}




// Preprocess tokens and convert -x to (0-x) unless token before - is a value
// This avoids ambiguity of "-" representing both the subtraction operator and the negative modifier

+ (NSArray*)preprocessedObjectsFromTokenizer:(PKTokenizer*)t {
	NSMutableArray *output = [NSMutableArray array];
	PKToken *tok, *eof = [PKToken EOFToken];
	BOOL tokenWasValue = NO, shouldAddClosingParenthesis = NO, setShould = NO;
	AKOperationType type;
	
	while((tok = [t nextToken]) != eof) {
		NSString *s = [tok stringValue];
		
		if([s isEqual:@"-"] && !tokenWasValue) {
			[output addObject:@"("];
			[output addObject:[AKConstantExpression expressionWithValue:0]];
			setShould = YES;
		}
		
		
		tokenWasValue = NO;
		
		if(tok.number) {
			[output addObject:[[[AKConstantExpression alloc] initWithValue:tok.floatValue] autorelease]];
			tokenWasValue = YES;
			
		}else if(type = [self operationTypeFromOperatorString:s]) {
			[output addObject:[NSNumber numberWithInt:type]];
		
		}else if([s isEqual:@"("]) {
			[output addObject:s];
			[output addObjectsFromArray:[self preprocessedObjectsFromTokenizer:t]];
			
		}else if([s isEqual:@")"]) {
			[output addObject:s];
			tokenWasValue = YES;
			break;
			
		} else if([s isEqual:@","]) {
			[output addObject:s];
		} else if([AKFunctionExpression functionIsValid:s]) {
			[output addObject:[AKFunctionExpression expressionWithFunction:s]];
			
			if(shouldAddClosingParenthesis) {
				setShould = YES;
				shouldAddClosingParenthesis = NO;
			}
		} else {
			[output addObject:[AKSymbolExpression expressionWithSymbol:s]];
			tokenWasValue = YES;
		}
		
		
		if(shouldAddClosingParenthesis) {
			[output addObject:@")"];
			shouldAddClosingParenthesis = NO;
		}
		
		if(setShould) {
			shouldAddClosingParenthesis = YES;
			setShould = NO;
		}
	}
	
	return output;
}


+ (BOOL)applyOperation:(AKOperationType)op toValueStack:(NSMutableArray*)stack {
	AKExpression *v1 = [stack stackPop];
	AKExpression *v2 = [stack stackPop];
	if(!v1 || !v2) return NO;
	[stack stackPush:[AKOperationExpression expressionWithOperationType:op leftOperand:v2 rightOperand:v1]];
	return YES;
}

+ (BOOL)applyFunction:(AKFunctionExpression *)function toValueStack:(NSMutableArray *)stack {
	NSMutableArray *args = [NSMutableArray array];
	for(int i = 0; i < [function numberOfWantedArguments]; i++) [args addObject:[stack stackPop]];
	[function setArguments:[[args reverseObjectEnumerator] allObjects]];
	[stack stackPush:function];
	return YES;
}

// Implementation of shunting-yard algorithm with inline operation application
+ (AKExpression*)expressionFromObjects:(NSArray*)objects error:(NSError**)error {
	NSMutableArray *outputStack = [NSMutableArray array];
	NSMutableArray *operationStack = [NSMutableArray array];
	
	for(id object in objects) {
		if([object isKindOfClass:[AKFunctionExpression class]]) {
			[operationStack addObject:object];
		} else if([object isKindOfClass:[AKExpression class]])
			[outputStack addObject:object];
		
		else if([object isKindOfClass:[NSNumber class]]) {
			AKOperationType type = [object intValue];
			
			for(int i=[operationStack count]-1; i>=0; i--) {
				
				
				if([[operationStack objectAtIndex:i] isKindOfClass:[AKFunctionExpression class]]) {
					[self applyFunction:[operationStack objectAtIndex:i] toValueStack:outputStack];
					[operationStack stackPop];
					continue;
				}
				
				AKOperationType type2 = [[operationStack objectAtIndex:i] intValue];
				if(![self operationType:type precedesOperationType:type2]) {
					[self applyOperation:type2 toValueStack:outputStack];
					[operationStack stackPop];
				}else break;
			}
			[operationStack stackPush:object];
			
		}else if([object isEqual:@"("]) {
			[operationStack stackPush:object];
			
		}else if([object isEqual:@")"]) {
			BOOL didFindLeftParenthesis = NO;
			for(int i=[operationStack count]-1; i>=0; i--) {
				id op = [operationStack stackPop];
				
				if([op isKindOfClass:[AKFunctionExpression class]]) {
					[self applyFunction:op toValueStack:outputStack];
				} else if([op isEqual:@"("]) {
					didFindLeftParenthesis = YES;
					break;
				} else
					[self applyOperation:[op intValue] toValueStack:outputStack];
			}
			
			if(!didFindLeftParenthesis){
				if(error) *error = [NSError errorWithDomain:AKErrorDomain code:AKErrorParseError userInfo:[NSDictionary dictionaryWithObject:@"Mismatched parantheses" forKey:NSLocalizedDescriptionKey]];
				return nil;
			}
		} else if([object isEqual:@","]) {
			BOOL didFindLeftParenthesis = NO;
			for(int i=[operationStack count]-1; i>=0; i--) {
				id op = [operationStack stackPop];
				
				if([op isKindOfClass:[AKFunctionExpression class]]) {
					[self applyFunction:op toValueStack:outputStack];
				} else if([op isEqual:@"("]) {
					[operationStack stackPush:op];
					didFindLeftParenthesis = YES;
					break;
				} else
					[self applyOperation:[op intValue] toValueStack:outputStack];
			}
			
			if(!didFindLeftParenthesis){
				if(error) *error = [NSError errorWithDomain:AKErrorDomain code:AKErrorParseError userInfo:[NSDictionary dictionaryWithObject:@"Mismatched parantheses" forKey:NSLocalizedDescriptionKey]];
				return nil;
			}
		}
	}
	
	for(id op in [operationStack reverseObjectEnumerator])
		if([op isKindOfClass:[AKFunctionExpression class]]) {
			[self applyFunction:op toValueStack:outputStack];
		} else if(![self applyOperation:[op intValue] toValueStack:outputStack]) {
			if(error) *error = [NSError errorWithDomain:AKErrorDomain code:AKErrorParseError userInfo:[NSDictionary dictionaryWithObject:@"Missing operand" forKey:NSLocalizedDescriptionKey]];
			return nil;
		}

	return [outputStack objectAtIndex:0];
}


+ (AKExpression*)expressionWithString:(NSString*)string error:(NSError**)error {
	PKTokenizer *t = [PKTokenizer tokenizerWithString:string];
	[t setTokenizerState:t.symbolState from:'-' to:'-']; // Parse dashes as separate symbols, not prefixes for negative numbers
	
	NSArray *objects = [self preprocessedObjectsFromTokenizer:t];
	AKExpression *exp = [self expressionFromObjects:objects error:error];
	return exp;
}

- (AKConstantExpression*)evaluatedConstant {
	AKExpression *expr = [self evaluateWithDefinitions:nil];
	return expr.constant ? (AKConstantExpression*)expr : nil;
}

@end
