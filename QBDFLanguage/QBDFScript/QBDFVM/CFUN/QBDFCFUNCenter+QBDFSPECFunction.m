//
//  QBDFCFUNCenter+QBDFFunction.m
//  TestQBDFScript
//
//  Created by fatboyli on 2017/7/31.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "QBDFCFUNCenter+QBDFSPECFunction.h"
#import "QBDFScriptMainDefine.h"
#import "QBDFVM.h"
#import "QBDFVMContext.h"
@implementation QBDFCFUNCenter (QBDFFunction)
- (BOOL)QBDFSPECFunctionModuleRespondToFunName:(NSString *)name
{
    NSString *selname = [NSString stringWithFormat:@"__QBDF_QBDFSPEC_%@:baseContext:",name];
    SEL thesel = NSSelectorFromString(selname);
    if([self respondsToSelector:thesel])
    {
        return YES;
    }else{
        return NO;
    }
}
- (id)__QBDF_CallQBDFSPECFunction:(NSString *)name args:(NSArray *)args baseContext:(id)context
{
    NSString *selname = [NSString stringWithFormat:@"__QBDF_QBDFSPEC_%@:baseContext:",name];
    SEL thesel = NSSelectorFromString(selname);
    
    
    if([self respondsToSelector:thesel])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [(id)self performSelector:thesel withObject:args withObject:context];
#pragma clang diagnostic pop
    }else
    {
        
        __QBDF_ERROR__([NSString stringWithFormat:@"Error 暂不支持：%@方法",name]);
    }
    return nil;
}


- (id)__QBDF_SYSBASIC___QBDF_SETENV__:(NSArray *)args  baseContext:(id)context
{
    if([args count] == 2)
    {
        NSString *key = [args[0] description];
        id value = args[1];
        [[QBDFVM shareInstance] setQBDFENV:value forKey:key];
    }else{
        __QBDF_ERROR__([NSString stringWithFormat:@"Error !%@方法参数个数不对",@"__QBDF_SETENV__"]);
        
    }
    return nil;
}
- (id)__QBDF_SYSBASIC___QBDF_GETENV__:(NSArray *)args  baseContext:(id)context
{
    
    if([args count] == 1)
    {
        NSString *argName = args[0];
        return [[QBDFVM shareInstance] getQBDFENV:argName];
    }
    return nil;
}

- (id)__QBDF_SYSBASIC___QBDF_FREE__:(NSArray *)args  baseContext:(id)context
{
 
    if([args count] == 1)
    {
        NSString *argName = args[0];
        [context deleteVari:argName];
    }else
    {
        __QBDF_ERROR__([NSString stringWithFormat:@"Error !%@方法参数个数不对",@"__QBDF_FREE__"]);
    }
    return nil;
}

- (id)__QBDF_SYSBASIC___QBDF_SETUSERDEFAULT__:(NSArray *)args  baseContext:(id)context
{
    if([args count] == 2)
    {
        NSString *key = [args[0] description];
        id value = args[1];
        [[QBDFVM shareInstance] setQBDFUserDefault:value forKey:key];
    }else{
        __QBDF_ERROR__([NSString stringWithFormat:@"Error !%@方法参数个数不对",@"__QBDF_SETUSERDEFAULT__"]);
        
    }
    return nil;
}


- (id)__QBDF_SYSBASIC___QBDF_GETUSERDEFAULT__:(NSArray *)args  baseContext:(id)context
{
    if([args count] == 1)
    {
        NSString *argName = args[0];
        return [[QBDFVM shareInstance] getQBDFUserDefault:argName];
    }
    return nil;
}




@end
