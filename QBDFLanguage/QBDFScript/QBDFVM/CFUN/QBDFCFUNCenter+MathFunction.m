//
//  QBDFCFUNCenter+MathFunction.m
//  TestQBDFScript
//
//  Created by fatboyli on 2017/7/31.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "QBDFCFUNCenter+MathFunction.h"
#import "QBDFScriptMainDefine.h"
@implementation QBDFCFUNCenter (MathFunction)

- (BOOL)MathFunctionModuleRespondToFunName:(NSString *)name
{
    NSString *selname = [NSString stringWithFormat:@"__QBDF_MATH_%@:",name];
    SEL thesel = NSSelectorFromString(selname);
    if([self respondsToSelector:thesel])
    {
        return YES;
    }else{
        return NO;
    }
    
}

- (id)__QBDF_CallMathFunction:(NSString *)name args:(NSArray *)args
{
    NSString *selname = [NSString stringWithFormat:@"__QBDF_MATH_%@:",name];
    SEL thesel = NSSelectorFromString(selname);
    
    
    if([self respondsToSelector:thesel])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [(id)self performSelector:thesel withObject:args];
#pragma clang diagnostic pop
    }else{
        
        __QBDF_ERROR__([NSString stringWithFormat:@"Error 暂不支持：%@方法",name]);
    }
    return nil;
}
- (id)__QBDF_MATH_ftoa:(NSArray *)args
{
    if([args count] == 1)
    {
        
        double value = [args[0] doubleValue];
        return [NSString stringWithFormat:@"%@" , @(value)];
    }else if([args count] == 2)
    {
        double value = [args[0] doubleValue];
        NSInteger dotCount = [args[1] integerValue];
        NSString *format = [NSString stringWithFormat:@"%%.%ldf",(long)dotCount];
        return [NSString stringWithFormat:format , value];
        
    }else{
        __QBDF_ERROR__([NSString stringWithFormat:@"atof  参数个数为1或2"]);
        
    }
    return nil;
}


- (id)__QBDF_MATH_ftof:(NSArray *)args
{
    if([args count] == 1)
    {
        
        double value = [args[0] doubleValue];
        return @(value);
    }else if([args count] == 2)
    {
        double value = [args[0] doubleValue];
        NSInteger dotCount = [args[1] integerValue];
        NSString *format = [NSString stringWithFormat:@"%%.%ldf",(long)dotCount];
        return @([[NSString stringWithFormat:format , value] doubleValue]);
        
    }else{
        __QBDF_ERROR__([NSString stringWithFormat:@"foto  参数个数为1或2"]);
        
    }
    return nil;
    
}


- (id)__QBDF_MATH_ceil:(NSArray *)args
{
    if([args count] == 1)
    {
        
        double value = [args[0] doubleValue];
        return @(ceil(value));
    }else{
        __QBDF_ERROR__([NSString stringWithFormat:@"ceil  参数个数为1"]);
        
    }
    return nil;
}


- (id)__QBDF_MATH_floor:(NSArray *)args
{
    if([args count] == 1)
    {
        double value = [args[0] doubleValue];
        return @(floor(value));
    }else{
        __QBDF_ERROR__([NSString stringWithFormat:@"floor  参数个数为1"]);
        
    }
    return nil;
}


- (id)__QBDF_MATH_abs:(NSArray *)args
{
    if([args count] == 1)
    {
        double value = [args[0] doubleValue];
        return @(ABS(value));
    }else{
        __QBDF_ERROR__([NSString stringWithFormat:@"%@  参数个数为1",@"abs"]);
        
    }
    return nil;
    
}


- (id)__QBDF_MATH_sqrt:(NSArray *)args
{
    if([args count] == 1)
    {
        double value = [args[0] doubleValue];
        return @(sqrt(value));
    }else{
        __QBDF_ERROR__([NSString stringWithFormat:@"%@  参数个数为1",@"sqrt"]);
        
    }
    return nil;
}


- (id)__QBDF_MATH_log:(NSArray *)args
{
    if([args count] == 1)
    {
        double value = [args[0] doubleValue];
        return @(log(value));
    }else{
        __QBDF_ERROR__([NSString stringWithFormat:@"%@  参数个数为1",@"log"]);
        
    }
    return nil;
}

- (id)__QBDF_MATH_log10:(NSArray *)args
{
    if([args count] == 1)
    {
        double value = [args[0] doubleValue];
        return @(log10(value));
    }else{
        __QBDF_ERROR__([NSString stringWithFormat:@"%@  参数个数为1",@"log10"]);
        
    }
    return nil;
}

- (id)__QBDF_MATH_pow:(NSArray *)args
{

    if([args count] == 2)
    {
        double valueX = [args[0] doubleValue];
        double valueY = [args[1] doubleValue];
        return @(pow(valueX, valueY));
    }else{
        __QBDF_ERROR__([NSString stringWithFormat:@"%@  参数个数为2",@"pow"]);
        
    }
    return nil;

}

@end
