//
//  QBDFCFUNCenter+MathFunction.h
//  TestQBDFScript
//
//  Created by fatboyli on 2017/7/31.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "QBDFCFUNCenter.h"

@interface QBDFCFUNCenter (MathFunction)
- (BOOL)MathFunctionModuleRespondToFunName:(NSString *)name;

- (id)__QBDF_CallMathFunction:(NSString *)name args:(NSArray *)args;
@end
