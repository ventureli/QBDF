//
//  QBDFCFUNCenter+CGStructFunction.m
//  TestQBDFScript
//
//  Created by fatboyli on 2017/7/28.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "QBDFCFUNCenter+CGStructFunction.h"
#import "QBDFScriptMainDefine.h"
#import <objc/runtime.h>
#import <stdarg.h>
#import <UIKit/UIKit.h>
#import "QBDFBLkTool.h"
#import "QBDFVMContext.h"
#import "QBDFVM.h"
#import "QBDFOCCALLCenter.h"
#import <math.h>

@implementation QBDFCFUNCenter (CGStructFunction)

- (BOOL)CGStructFunctionModuleRespondToFunName:(NSString *)name
{
    NSString *selname = [NSString stringWithFormat:@"__QBDF_STRUCT_%@:",name];
    SEL thesel = NSSelectorFromString(selname);
    
    
    if([self respondsToSelector:thesel])
    {
        return YES;
    }else{
        return NO;
    }
}

- (id)__QBDF_CallCGStructCFunction:(NSString *)name args:(NSArray *)args
{
    
    NSString *selname = [NSString stringWithFormat:@"__QBDF_STRUCT_%@:",name];
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

- (id)__QBDF_STRUCT_CGRectMake:(NSArray *)args
{
    if([args count]==4)
    {
        CGFloat arg0 = [args[0] doubleValue];
        CGFloat arg1 = [args[1] doubleValue];
        CGFloat arg2 = [args[2] doubleValue];
        CGFloat arg3 = [args[3] doubleValue];
        NSValue *value = [NSValue valueWithCGRect:CGRectMake(arg0, arg1, arg2, arg3)];
        return value;
        
    }else{
        __QBDF_ERROR__(@" CGRectMake args count error");
        
    }
    return nil;
}

- (id)__QBDF_STRUCT_CGSizeMake:(NSArray *)args
{
    if([args count]==2)
    {
        CGFloat arg0 = [args[0] doubleValue];
        CGFloat arg1 = [args[1] doubleValue];
        NSValue *value = [NSValue valueWithCGSize:CGSizeMake(arg0, arg1)];
        return value;
        
    }else{
        __QBDF_ERROR__(@"Error CGSize args count error");
        
    }
    return nil;
}

- (id)__QBDF_STRUCT_CGPointMake:(NSArray *)args
{
    if([args count]==2)
    {
        CGFloat arg0 = [args[0] doubleValue];
        CGFloat arg1 = [args[1] doubleValue];
        NSValue *value = [NSValue valueWithCGPoint:CGPointMake(arg0, arg1)];
        return value;
        
    }else{
        __QBDF_ERROR__(@"Error CGPoint args count error");
        
    }
    return nil;
}

- (id)__QBDF_STRUCT_NSMakeRange:(NSArray *)args
{
    if([args count]==2)
    {
        CGFloat arg0 = [args[0] doubleValue];
        CGFloat arg1 = [args[1] doubleValue];
        NSValue *value = [NSValue valueWithRange:NSMakeRange(arg0, arg1)];
        return value;
        
    }else{
        __QBDF_ERROR__(@"Error NSMakeRange args count error");
        
    }
    
    return nil;
}

- (id)__QBDF_STRUCT_UIEdgeInsetsMake:(NSArray *)args
{
    if([args count]==4)
    {
        CGFloat arg0 = [args[0] doubleValue];
        CGFloat arg1 = [args[1] doubleValue];
        CGFloat arg2 = [args[2] doubleValue];
        CGFloat arg3 = [args[3] doubleValue];
        NSValue *value = [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(arg0, arg1, arg2, arg3)];
        return value;
        
    }else{
        __QBDF_ERROR__(@"Error UIEdgeInsetsMake args count error");
        
    }
    return nil;
}

- (id)__QBDF_STRUCT_CGRectContainsPoint:(NSArray *)args
{
    if([args count]==2)
    {
        CGRect arg0 = [args[0] CGRectValue];
        CGPoint arg1 = [args[1] CGPointValue];
        return @(CGRectContainsPoint(arg0, arg1));
        
        
    }else{
        __QBDF_ERROR__(@"Error CGRectContainsPoint args count error need(2)");
        
    }

    return @(NO);
}

- (id)__QBDF_STRUCT_CGRectContainsRect:(NSArray *)args
{
    if([args count]==2)
    {
        CGRect arg0 = [args[0] CGRectValue];
        CGRect arg1 = [args[1] CGRectValue];
        return @(CGRectContainsRect(arg0, arg1));
        
    }else{
        __QBDF_ERROR__(@"Error CGRectContainsRect args count error need(2)");
        
    }
    
    return @(NO);
}

@end
