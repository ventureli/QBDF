//
//  QBDFCFUNCenter.m
//  QBDFScript
//
//  Created by fatboyli on 17/5/22.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "QBDFCFUNCenter.h"
#import "QBDFScriptMainDefine.h"
#import <objc/runtime.h>
#import <stdarg.h>
#import <UIKit/UIKit.h>
#import "QBDFBLkTool.h"
#import "QBDFVMContext.h"
#import "QBDFVM.h"
#import "QBDFOCCALLCenter.h"
#import "QBDFVarTypeHelper.h"
#import <math.h>
#import "QBDFCFUNCenter+CGStructFunction.h"
#import "QBDFCFUNCenter+MathFunction.h"
#import "QBDFCFUNCenter+SYSBasicFunction.h"
#import "QBDFCFUNCenter+QBDFSPECFunction.h"
#import "QBDFCFUNCenter+CommonStruct.h"
@implementation QBDFCFUNCenter

+(instancetype)shareInstance
{
    static QBDFCFUNCenter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[QBDFCFUNCenter alloc] init];
        
    });
    return instance;
}

- (id)runCFunctionWithName:(NSString *)name args:(NSArray*)args baseContext:(id)context
{
    
    if([self SYSBasicFunctionModuleRespondToFunName:name])
    {
        return [self __QBDF_CallSYSBasicFunction:name args:args  baseContext:context];
        
    }else if([self CGStructFunctionModuleRespondToFunName:name])
    {
        return [self __QBDF_CallCGStructCFunction:name args:args];
        
    }else if([self MathFunctionModuleRespondToFunName:name])
    {
        return [self __QBDF_CallMathFunction:name args:args];
        
    }else if([self SYSBasicFunctionModuleRespondToFunName:name])
    {
        return [self __QBDF_CallSYSBasicFunction:name args:args   baseContext:context];
        
    }else if([self QBDFSPECFunctionModuleRespondToFunName:name])
    {
        return [self __QBDF_CallQBDFSPECFunction:name args:args baseContext:context];
        
    }else if([self QBDFCommonStructModuleRespondToFunName:name])
    {
        return  [self __QBDF_CallCommonStructFunction:name args:args baseContext:context];
        
    }else if([name isEqualToString:@"@selector"])
    {
        if([args count] == 0)
        {
            return nil ;
        }else{
            NSString *selname = [args[0] description];
            return selname;
        }
    }else if([name isEqualToString:@"sizeof"])
    {
        if([args count] == 0)
        {
            return nil ;
        }else{
            NSString *typeName = [args[0] description];
            int size = [QBDFVarTypeHelper sizeofTypeWithTypeCode:typeName];
            return @(size);
          //  return @([QBDFVarTypeHelper size]);
        }
    }
    else
    {
         __QBDF_ERROR__([NSString stringWithFormat:@"c 方法:%@不支持",name]);
    }
    return nil;
}
//解包
#define STRINGARGS(index) \
(arguments.count>index) ? ([[arguments objectAtIndex: index] isKindOfClass:[QBDFAssignWrapper class]] ?(((QBDFAssignWrapper *)[arguments objectAtIndex: index]).assignTarget): [arguments objectAtIndex: index]):nil

+ (NSString *) stringWithFormat: (NSString *) format arguments: (NSArray *) arguments
{
    return [NSString stringWithFormat: format ,
            STRINGARGS(0),
            STRINGARGS(1),
            STRINGARGS(2),
            STRINGARGS(3),
            STRINGARGS(4),
            STRINGARGS(5),
            STRINGARGS(6),
            STRINGARGS(7),
            STRINGARGS(8),
            STRINGARGS(9),
            STRINGARGS(10),
            STRINGARGS(11),
            STRINGARGS(12),
            STRINGARGS(13),
            STRINGARGS(14),
            STRINGARGS(15),
            STRINGARGS(16),
            STRINGARGS(17),
            STRINGARGS(18),
            STRINGARGS(19),
            STRINGARGS(20)
        ];
}
@end
