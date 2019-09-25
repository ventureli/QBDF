
//
//  QBDFNil.m
//  TestQBDFScript
//
//  Created by fatboyli on 2017/8/14.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "QBDFNil.h"

@implementation QBDFSuprWrapepr

- (instancetype)initWithTarget:(id)target
{
    self = [super init];
    if(self)
    {
        self.target = target;
    }
    return self;
}



- (instancetype)initWithAssignTarget:(id)target
{
    self = [super init];
    if(self)
    {
        self.isassign = YES;
        self.assignTarget = target;
    }
    return self;
}


@end


@implementation QBDFAssignWrapper


- (instancetype)initWithAssignTarget:(id)target
{
    self = [super init];
    if(self)
    {
        self.assignTarget = target;
    }
    return self;
}

@end

@implementation QBDFNil

- (char) charValue
{
    return 0;
}
- (unsigned char) unsignedCharValue
{
    return 0;
}
- (short) shortValue
{
    return 0;
}
- (unsigned short) unsignedShortValue
{
    return 0;
}
- (int) intValue
{
    return 0;
}
- (unsigned int) unsignedIntValue
{
    return 0;
}
- (long) longValue
{
    return 0;
}
- (unsigned long) unsignedLongValue
{
    return 0;
}
- (long long) longLongValue
{
    return 0;
}
- (unsigned long long) unsignedLongLongValue
{
    return 0;
}
- ( float) floatValue
{
    return 0;
}
- (double) doubleValue
{
    return 0;
}
- (BOOL) boolValue
{
    return NO;
}
- (NSInteger) integerValue
{
    return 0;
}
- (NSUInteger) unsignedIntegerValue
{
    return 0;
}
- ( NSString *)stringValue
{
    return nil;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return nil;
}

- (NSString *)description
{
    return @"nil<Create By QBDF>";
}

@end
