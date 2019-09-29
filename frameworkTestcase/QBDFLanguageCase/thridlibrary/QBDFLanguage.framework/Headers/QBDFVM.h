//
//  QBDFVM.h
//  QBDFScript
//
//  Created by fatboyli on 2017/5/17.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import <Foundation/Foundation.h>




@interface QBDFVM : NSObject

+ (instancetype)shareInstance;
- (id)evalCode:(NSArray *)code withInitEnvVar:(NSDictionary *)dict;
- (id)evalCode:(NSArray *)code withInitEnvVar:(NSDictionary *)dict withReadDict:(NSMutableDictionary *)dict;



//设置环境变量
- (void)setQBDFENV:(id)val  forKey:(NSString *)key;
- (id)getQBDFENV:(NSString *)key;

- (void)setQBDFUserDefault:(id)val  forKey:(NSString *)key;
- (id)getQBDFUserDefault:(NSString *)key;


- (void)setQBDFValue:(id)value forKey:(NSString *)key;
- (id)getQBDFValue:(NSString *)key;
@end
