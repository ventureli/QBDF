//
//  QBDFNil.h
//  TestQBDFScript
//
//  Created by fatboyli on 2017/8/14.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QBDFSuprWrapepr : NSObject
@property(nonatomic ,strong)id      target;
@property(nonatomic ,assign)BOOL    isassign;
@property(nonatomic ,assign)id      assignTarget;

- (instancetype)initWithTarget:(id)target;
- (instancetype)initWithAssignTarget:(id)target;

@end


@interface QBDFAssignWrapper : NSObject
@property(nonatomic ,assign)id      assignTarget;

- (instancetype)initWithAssignTarget:(id)target;

@end

@interface QBDFNil : NSObject
@property (readonly) char charValue;
@property (readonly) unsigned char unsignedCharValue;
@property (readonly) short shortValue;
@property (readonly) unsigned short unsignedShortValue;
@property (readonly) int intValue;
@property (readonly) unsigned int unsignedIntValue;
@property (readonly) long longValue;
@property (readonly) unsigned long unsignedLongValue;
@property (readonly) long long longLongValue;
@property (readonly) unsigned long long unsignedLongLongValue;
@property (readonly) float floatValue;
@property (readonly) double doubleValue;
@property (readonly) BOOL boolValue;
@property (readonly) NSInteger integerValue;
@property (readonly) NSUInteger unsignedIntegerValue;
@property (readonly, copy) NSString *stringValue;


@end
