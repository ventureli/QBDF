//
//  QBDFCFUNCenter+SYSBasicFunction.h
//  TestQBDFScript
//
//  Created by fatboyli on 2017/7/31.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "QBDFCFUNCenter.h"

@interface QBDFCFUNCenter (SYSBasicFunction)

- (BOOL)SYSBasicFunctionModuleRespondToFunName:(NSString *)name;

- (id)__QBDF_CallSYSBasicFunction:(NSString *)name args:(NSArray *)args baseContext:(id)context;
@end
