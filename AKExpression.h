//
//  AKExpression.h
//  Math
//
//  Created by Tomas Franzén on 2010-05-17.
//  Copyright 2010 Lighthead Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class AKConstantExpression;

@interface AKExpression : NSObject {

}

@property(readonly, getter=isConstant) BOOL constant;
@property(readonly) AKConstantExpression *evaluatedConstant;

+ (AKExpression*)expressionWithString:(NSString*)string error:(NSError**)error;

- (AKExpression*)evaluateWithDefinitions:(NSDictionary*)defs;

@end


extern NSString *const AKErrorDomain;
extern NSInteger const AKErrorParseError;