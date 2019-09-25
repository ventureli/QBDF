//
//  QBDFCFUNCenter+CommonStruct.m
//  TestQBDFScript
//
//  Created by fatboyli on 2017/8/7.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "QBDFCFUNCenter+CommonStruct.h"
#import "QBDFSYSCenter+QBDFStruct.h"
#import "QBDFStruct.h"

@implementation QBDFCFUNCenter (CommonStruct)
- (BOOL)QBDFCommonStructModuleRespondToFunName:(NSString *)name
{
    QBDFStructDefine *define  =[[QBDFSYSCenter shareInstance] readStructDefine:name];
    if(define)
    {
        return YES;
    }else{
        return NO;
    }
}
- (id)__QBDF_CallCommonStructFunction:(NSString *)name args:(NSArray *)args baseContext:(id)context
{
    QBDFStructDefine *define  =[[QBDFSYSCenter shareInstance] readStructDefine:name];
    if(define)
    {
        
        if([args count] == 0 || [args count] == [define.elements count]) //可以是0个参数，也可以是全部赋值
        {
            QBDFStruct *theRes = [QBDFStruct getInstanceWithDefine:define args:args];
            
            return theRes;
        }else
        {
            __QBDF_ERROR__([NSString stringWithFormat:@"结构题%@的初始化方法需要0个或者%@个参数",name,@([define.elements count])]);
        }
        
    }else
    {
        __QBDF_ERROR__([NSString stringWithFormat:@"暂不支持：%@方法",name]);
        
    }
    return nil;

}
@end
