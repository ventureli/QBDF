//
//  QBDFStruct.h
//  TestQBDFScript
//
//  Created by fatboyli on 2017/8/4.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBDFStruct : NSObject

- (int)memSize;
- (NSString *)structName;

+ (instancetype)getInstanceWithData:(void *)data theDefine:(id )define;
+ (instancetype)getInstanceWithDefine:(id )define args:(NSArray *)args;

- (void)getMemStructData:(void *)data;

- (id)readProperty:(NSString *)key;
- (void)setProperty:(NSString *)key value:(NSString *)value;

@end
