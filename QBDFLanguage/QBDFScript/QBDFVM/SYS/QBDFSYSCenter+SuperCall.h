//
//  QBDFSYSCenter+SuperCall.h
//  TestQBDFScript
//
//  Created by fatboyli on 2017/8/4.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "QBDFSYSCenter.h"

@interface QBDFSYSCenter (SuperCall)
//非常重要的方法
- (id)readCallSuperClassWithKey:(NSString *)key;
- (void)updateCallSuperClassWithKey:(NSString *)key value:(id)value;
- (void)deleteCallSuperClassWithKey:(NSString *)key;
@end
