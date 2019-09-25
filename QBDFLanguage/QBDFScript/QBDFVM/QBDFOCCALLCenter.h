//
//  QBDFOCCALLCenter.h
//  QBDFScript
//
//  Created by fatboyli on 17/5/22.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBDFNil.h"

@interface QBDFOCCALLCenter : NSObject
+(instancetype)shareInstance;
//运行实例方法
- (id)runInstanceMethodOfTargetName:(id)target sel:(NSString *)sel args:(NSArray *)arg;
//读取属性
- (id)readPropertyValueWithTarget:(id)taget propertName:(NSString *)name;
//更新属性
- (void)updatePropertyValueWithTarget:(id)taget propertName:(NSString *)name value:(id)value;
//读取变量
- (id)readIvarValueWithTarget:(id)target propertName:(NSString *)name;
//更新变量
- (void)updateIvarValueWithTarget:(id)taget propertName:(NSString *)name value:(id)value;

//读取下标和[@"good"]字典变量
- (id)readArrayOrDictValue:(id)target key:(NSString *)key;
//更新下标和[@"good"]字典变量
- (void)updateArrayOrDictValue:(id)target key:(id)key value:(id)value;


- (id)callBLKWithblk:(id)blk args:(NSArray *)args;
@end
