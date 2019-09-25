//
//  QBDFVMContext.h
//  QBDFScript
//
//  Created by fatboyli on 2017/5/18.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QBDFScriptMainDefine.h"

/**
 * QBDFVM运行上下文：真正执行代码的类
 */

@interface QBDFVMContext : NSObject
{
    
}


/**
 * 建立VM上下文
 * @return 上下文对象
 */
+ (instancetype)createDefaultContextWithSymbol:(NSDictionary *)symbols codes:(NSArray *)code;

/*
 * 建立VM上下文
 * @return 上下文对象
 */
+ (instancetype)createBlkCallContextWithNode:(NSDictionary *)node superFrame:(NSArray *)frame args:(NSArray *)args;

- (NSArray *)needCopyOfFrameInfo;
- (id)readRETValue;

- (void)deleteVari:(NSString *)key;

- (id)readSymbValue:(NSString *)key;

/**
 * VM执行一段中间代码
 * @param codes 代码
 * @return 返回状态
 */
@end

@interface QBDFVMContext(funcall)

+ (id)QBDF_RunBlkWithNode:(NSDictionary *)node args:(NSArray *)args frameInfo:(NSArray *)frameInfo;

+ (id)QBDF_RUNOCMTHDWithNode:(NSDictionary *)node args:(NSArray *)args  sel:(SEL)sel target:(id)target;
@end
