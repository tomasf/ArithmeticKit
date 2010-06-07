//
//  AKFunctionExpression.h
//  Math
//
//  Created by Tim Andersson on 2010-05-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AKExpression.h"

@interface AKFunctionExpression : AKExpression {
	NSString *functionName;
	NSArray *arguments;
}

@property(copy) NSString *functionName;
@property(copy) NSArray *arguments;

+ (void)registerFunctionWithName:(NSString*)name argumentCount:(NSUInteger)numArgs implementation:(double(^)(double args[]))imp;

+ (NSSet *)validFunctions;
+ (BOOL)functionIsValid:(NSString *)f;

+ (id)expressionWithFunction:(NSString *)f;
- (id)initWithFunction:(NSString *)f;
- (id)initWithFunction:(NSString *)f arguments:(NSArray *)args;

- (NSUInteger)numberOfWantedArguments;

@end
