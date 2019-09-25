//
//  QBDFCFUNCenter+CommonStruct.h
//  TestQBDFScript
//
//  Created by fatboyli on 2017/8/7.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "QBDFCFUNCenter.h"

@interface QBDFCFUNCenter (CommonStruct)
- (BOOL)QBDFCommonStructModuleRespondToFunName:(NSString *)name;
- (id)__QBDF_CallCommonStructFunction:(NSString *)name args:(NSArray *)args baseContext:(id)context;

@end
