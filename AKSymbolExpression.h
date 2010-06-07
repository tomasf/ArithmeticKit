//
//  AKSymbolExpression.h
//  Math
//
//  Created by Tomas Franzén on 2010-05-18.
//  Copyright 2010 Lighthead Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AKExpression.h"

@interface AKSymbolExpression : AKExpression {
	NSString *symbol;
}

@property(copy) NSString *symbol;

+ (void)defineGlobalSymbol:(NSString*)name value:(AKExpression*)v;

+ (id)expressionWithSymbol:(NSString*)s;
- (id)initWithSymbol:(NSString*)s;

@end
