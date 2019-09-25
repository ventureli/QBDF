//
//  QBDFCFUNCenter+QBDFFunction.h
//  TestQBDFScript
//
//  Created by fatboyli on 2017/7/31.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "QBDFCFUNCenter.h"

@interface QBDFCFUNCenter (QBDFFunction)
- (BOOL)QBDFSPECFunctionModuleRespondToFunName:(NSString *)name;
- (id)__QBDF_CallQBDFSPECFunction:(NSString *)name args:(NSArray *)args baseContext:(id)context;

@end
