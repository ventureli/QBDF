//
//  QBDFCFUNCenter+CGStructFunction.h
//  TestQBDFScript
//
//  Created by fatboyli on 2017/7/28.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "QBDFCFUNCenter.h"
#import <UIKit/UIKit.h>
@interface QBDFCFUNCenter (CGStructFunction)

- (BOOL)CGStructFunctionModuleRespondToFunName:(NSString *)name;
- (id)__QBDF_CallCGStructCFunction:(NSString *)name args:(NSArray *)args;
@end
