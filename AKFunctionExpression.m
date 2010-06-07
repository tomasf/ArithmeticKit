//
//  AKFunctionExpression.m
//  Math
//
//  Created by Tim Andersson on 2010-05-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AKFunctionExpression.h"
#import "AKConstantExpression.h"


@implementation AKFunctionExpression

@synthesize functionName, arguments;

static NSMutableDictionary *AKFunctionImplementations = nil;
static NSMutableDictionary *AKFunctionArgumentCounts = nil;


+ (void)initialize {
	AKFunctionImplementations = [[NSMutableDictionary alloc] init];
	AKFunctionArgumentCounts = [[NSMutableDictionary alloc] init];
	
	[self registerFunctionWithName:@"sqrt" argumentCount:1 implementation:^(double args[]) {
		return sqrt(args[0]);
	}];
	
	[self registerFunctionWithName:@"hypot" argumentCount:2 implementation:^(double args[]) {
		return hypot(args[0], args[1]);
	}];
	
	[self registerFunctionWithName:@"exp" argumentCount:1 implementation:^(double args[]) {
		return exp(args[0]);
	}];
	
	[self registerFunctionWithName:@"abs" argumentCount:1 implementation:^(double args[]) {
		return fabs(args[0]);
	}];
	
	[self registerFunctionWithName:@"sign" argumentCount:1 implementation:^(double args[]) {
		if(!args[0]) return 0.0;
		return (args[0] < 0) ? -1.0 : 1.0;
	}];
	
	[self registerFunctionWithName:@"min" argumentCount:2 implementation:^(double args[]) {
		return fmin(args[0], args[1]);
	}];
	
	[self registerFunctionWithName:@"max" argumentCount:2 implementation:^(double args[]) {
		return fmax(args[0], args[1]);
	}];
	
	srandom(time(NULL));
	[self registerFunctionWithName:@"rand" argumentCount:0 implementation:^(double args[]) {
		return random() / (double)INT32_MAX;
	}];
	
	
	// Rounding
	
	[self registerFunctionWithName:@"floor" argumentCount:1 implementation:^(double args[]) {
		return floor(args[0]);
	}];
	
	[self registerFunctionWithName:@"ceil" argumentCount:1 implementation:^(double args[]) {
		return ceil(args[0]);
	}];
	
	[self registerFunctionWithName:@"round" argumentCount:1 implementation:^(double args[]) {
		return round(args[0]);
	}];
	
	
	// Trigonometry
	
	[self registerFunctionWithName:@"sin" argumentCount:1 implementation:^(double args[]) {
		return sin(args[0]);
	}];
	
	[self registerFunctionWithName:@"cos" argumentCount:1 implementation:^(double args[]) {
		return cos(args[0]);
	}];
	
	[self registerFunctionWithName:@"tan" argumentCount:1 implementation:^(double args[]) {
		return tan(args[0]);
	}];
	
	
	[self registerFunctionWithName:@"asin" argumentCount:1 implementation:^(double args[]) {
		return asin(args[0]);
	}];
	
	[self registerFunctionWithName:@"acos" argumentCount:1 implementation:^(double args[]) {
		return acos(args[0]);
	}];
	
	[self registerFunctionWithName:@"atan" argumentCount:1 implementation:^(double args[]) {
		return atan(args[0]);
	}];
	
	
	[self registerFunctionWithName:@"cot" argumentCount:1 implementation:^(double args[]) {
		return 1/tan(args[0]);
	}];
	
	[self registerFunctionWithName:@"sec" argumentCount:1 implementation:^(double args[]) {
		return 1/cos(args[0]);
	}];
	
	[self registerFunctionWithName:@"csc" argumentCount:1 implementation:^(double args[]) {
		return 1/sin(args[0]);
	}];
	
	
	// Hyperbolics
	
	[self registerFunctionWithName:@"sinh" argumentCount:1 implementation:^(double args[]) {
		return sinh(args[0]);
	}];
	
	[self registerFunctionWithName:@"cosh" argumentCount:1 implementation:^(double args[]) {
		return cosh(args[0]);
	}];
	
	[self registerFunctionWithName:@"tanh" argumentCount:1 implementation:^(double args[]) {
		return tanh(args[0]);
	}];
	
	
	[self registerFunctionWithName:@"asinh" argumentCount:1 implementation:^(double args[]) {
		return asinh(args[0]);
	}];
	
	[self registerFunctionWithName:@"acosh" argumentCount:1 implementation:^(double args[]) {
		return acosh(args[0]);
	}];
	
	[self registerFunctionWithName:@"atanh" argumentCount:1 implementation:^(double args[]) {
		return atanh(args[0]);
	}];
	
	
	[self registerFunctionWithName:@"coth" argumentCount:1 implementation:^(double args[]) {
		return cosh(args[0])/sinh(args[0]);
	}];
	
	[self registerFunctionWithName:@"sech" argumentCount:1 implementation:^(double args[]) {
		return 1/cosh(args[0]);
	}];
	
	[self registerFunctionWithName:@"csch" argumentCount:1 implementation:^(double args[]) {
		return 1/sinh(args[0]);
	}];
	
	
	// Logaritms
	
	[self registerFunctionWithName:@"ln" argumentCount:1 implementation:^(double args[]) {
		return log(args[0]);
	}];
	
	[self registerFunctionWithName:@"lg" argumentCount:1 implementation:^(double args[]) {
		return log10(args[0]);
	}];
	
	[self registerFunctionWithName:@"lb" argumentCount:1 implementation:^(double args[]) {
		return log2(args[0]);
	}];
	
	[self registerFunctionWithName:@"log" argumentCount:2 implementation:^(double args[]) {
		return log(args[0]) / log(args[1]);
	}];
}

+ (void)registerFunctionWithName:(NSString*)name argumentCount:(NSUInteger)numArgs implementation:(double(^)(double args[]))imp {
	[AKFunctionImplementations setObject:[[imp copy] autorelease] forKey:name];
	[AKFunctionArgumentCounts setObject:[NSNumber numberWithInteger:numArgs] forKey:name];
}


+ (NSSet *)validFunctions {
	return [NSSet setWithArray:[AKFunctionImplementations allKeys]];
}


+ (BOOL)functionIsValid:(NSString *)f {
	return [[self validFunctions] containsObject:f];
}



+ (id)expressionWithFunction:(NSString *)f {
	return [[[self alloc] initWithFunction:f] autorelease];
}


- (id)initWithFunction:(NSString *)f {
	[super init];
	self.functionName = f;
	self.arguments = nil;
	return self;
}


- (id)initWithFunction:(NSString *)f arguments:(NSArray *)args {
	self = [self initWithFunction:f];
	self.arguments = args;
	return self;
}


- (NSUInteger)numberOfWantedArguments {
	return [[AKFunctionArgumentCounts objectForKey:functionName] integerValue];
}


- (AKExpression*)evaluateWithDefinitions:(NSDictionary*)defs {
	NSMutableArray *evaluatedArgs = [NSMutableArray array];
	for(AKExpression *expr in arguments) [evaluatedArgs addObject:[expr evaluateWithDefinitions:defs]];
	double args[[arguments count]];
	
	int i=0;
	for(AKExpression *expr in evaluatedArgs) {
		if(!expr.constant) 
			return [[[[self class] alloc] initWithFunction:functionName arguments:evaluatedArgs] autorelease];
		args[i++] = [(AKConstantExpression*)expr value];
	}
	
	double(^imp)(double args[]) = [AKFunctionImplementations objectForKey:functionName];
	return [[[AKConstantExpression alloc] initWithValue:imp(args)] autorelease];
}


- (NSString *)description {
	return [NSString stringWithFormat:@"%@(%@)", functionName, [arguments componentsJoinedByString:@", "]];
}

@end
