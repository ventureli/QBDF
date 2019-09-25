//
//  QBDFCFUNCenter+SYSBasicFunction.m
//  TestQBDFScript
//
//  Created by fatboyli on 2017/7/31.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "QBDFCFUNCenter+SYSBasicFunction.h"
#import "QBDFScriptMainDefine.h"
#import "QBDFBLkTool.h"
#import "QBDFVMContext.h"

@implementation QBDFCFUNCenter (SYSBasicFunction)

- (BOOL)SYSBasicFunctionModuleRespondToFunName:(NSString *)name
{
    NSString *selname = [NSString stringWithFormat:@"__QBDF_SYSBASIC_%@:baseContext:",name];
    SEL thesel = NSSelectorFromString(selname);
    if([self respondsToSelector:thesel])
    {
        return YES;
    }else{
        return NO;
    }
}

- (id)__QBDF_CallSYSBasicFunction:(NSString *)name args:(NSArray *)args  baseContext:(id)context
{
    NSString *selname = [NSString stringWithFormat:@"__QBDF_SYSBASIC_%@:baseContext:",name];
    SEL thesel = NSSelectorFromString(selname);
    
    
    if([self respondsToSelector:thesel])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [(id)self performSelector:thesel withObject:args withObject:context];
#pragma clang diagnostic pop
    }else{
        
        __QBDF_ERROR__([NSString stringWithFormat:@"Error 暂不支持：%@方法",name]);
    }
    return nil;
}
#pragma mark -
#pragma mark FUNCTION
- (id)__QBDF_SYSBASIC_NSLog:(NSArray *)args  baseContext:(id)context
{
    if([args count] == 0)
    {
        return nil ;
    }
    
    NSString *first = [args[0] description];
    NSArray *others = [args subarrayWithRange:NSMakeRange(1, [args count] - 1)];
    NSString *str = [[self class] stringWithFormat:first arguments:others];
    NSLog(@"%@",str);
    return nil;
}

- (id)__QBDF_SYSBASIC_dispatch_async_main:(NSArray *)args  baseContext:(id)context
{
    if([args count] != 1)
    {
        __QBDF_ERROR__(@"dispatch_async_main只有一个参数");
        return nil;
    }
    
    id arg = args[0];
    id frameinfo = [context needCopyOfFrameInfo];
    if([arg isKindOfClass:[QBDFBLkTool class]]) //这是一个内部blk
    {
        QBDFBLkTool *tool = arg ;
        dispatch_async(dispatch_get_main_queue(), ^{
            [QBDFVMContext QBDF_RunBlkWithNode:tool.node args:nil frameInfo:frameinfo];
        });
    }else{
        //外部传入的
    }
    return nil;
}

- (id)__QBDF_SYSBASIC_dispatch_sync_main:(NSArray *)args  baseContext:(id)context
{
 
    if([args count] != 1)
    {
        __QBDF_ERROR__(@"dispatch_sync_main只有一个参数");
        return nil;
    }
    
    id arg = args[0];
    id frameinfo = [context needCopyOfFrameInfo];
    if([arg isKindOfClass:[QBDFBLkTool class]]) //这是一个内部blk
    {
        QBDFBLkTool *tool = arg;
        dispatch_sync(dispatch_get_main_queue(), ^{
            [QBDFVMContext QBDF_RunBlkWithNode:tool.node args:nil frameInfo:frameinfo];
        });
    }else{
        //外部传入的
    }
    return nil;
}

- (id)__QBDF_SYSBASIC_dispatch_after:(NSArray *)args  baseContext:(id)context
{
 
    if([args count] != 2)
    {
        __QBDF_ERROR__(@"dispatch_after有且只有有一个参数");
        return nil;
    }
    
    double time = [args[0] doubleValue];
    id frameinfo = [context needCopyOfFrameInfo];
    id argnode = args[1];
    
    if([argnode isKindOfClass:[QBDFBLkTool class]]) //这是一个内部blk
    {
        QBDFBLkTool *tool = argnode;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [QBDFVMContext QBDF_RunBlkWithNode:tool.node args:nil frameInfo:frameinfo];
        });
        
    }else{
        //外部传入的
    }
    return nil;
}
- (id)__QBDF_SYSBASIC_dispatch_async_global_queue:(NSArray *)args  baseContext:(id)context
{
    if([args count] != 1)
    {
        __QBDF_ERROR__(@"dispatch_async_global_queue只有一个参数");
        return nil;
    }
    
    id arg = args[0];
    id frameinfo = [context needCopyOfFrameInfo];
    
    if([arg isKindOfClass:[QBDFBLkTool class]]) //这是一个内部blk
    {
        QBDFBLkTool *tool = arg;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [QBDFVMContext QBDF_RunBlkWithNode:tool.node args:nil frameInfo:frameinfo];
        });
    }else{
        //外部传入的
    }
    return nil;
}




- (id)__QBDF_SYSBASIC_NSStringFromClass:(NSArray *)args  baseContext:(id)context
{
    if([args count] != 1)
    {
        __QBDF_ERROR__(@"NSStringFromClass只有一个参数");
        return nil;
    }
    
    NSString * arg = [args[0] description];
    return arg;
}

- (id)__QBDF_SYSBASIC_NSClassFromString:(NSArray *)args  baseContext:(id)context
{
    if([args count] != 1)
    {
        __QBDF_ERROR__(@"NSClassFromString只有一个参数");
        return nil;
    }
    
    NSString * arg = [args[0] description];
    return NSClassFromString(arg);
}

- (id)__QBDF_SYSBASIC_NSStringFromSelector:(NSArray *)args  baseContext:(id)context
{
    if([args count] != 1)
    {
        __QBDF_ERROR__(@"NSStringFromSelector只有一个参数");
        return nil;
    }
    
    NSString * arg = [args[0] description];
    return arg;
}
- (id)__QBDF_SYSBASIC_malloc:(NSArray *)args  baseContext:(id)context
{
    if([args count] != 1)
    {
        __QBDF_ERROR__(@"NSStringFromSelector只有一个参数");
        return nil;
    }
    
    int size = [args[0] intValue];
    if(size ==0)
    {
        size = 1;
    }
    
    void *pt = malloc(size);
    
    return [NSValue valueWithPointer:pt];
}

- (id)__QBDF_SYSBASIC_free:(NSArray *)args  baseContext:(id)context
{
    if([args count] != 1)
    {
        __QBDF_ERROR__(@"NSStringFromSelector只有一个参数");
        return nil;
    }
    
    if([args[0] respondsToSelector:@selector(pointerValue)])
    {
        
        void *pt = [args[0] pointerValue];
        free(pt);
    }
    return nil;
}




//NSSelectorFromString(<#NSString * _Nonnull aSelectorName#>)
//NSStringFromClass(<#Class  _Nonnull __unsafe_unretained aClass#>)
//NSClassFromString(<#NSString * _Nonnull aClassName#>)
//NSStringFromSelector(<#SEL  _Nonnull aSelector#>)
@end
