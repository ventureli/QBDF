//
//  QBDFSYSCenter.h
//  TestQBDFScript
//
//  Created by fatboyli on 2017/6/6.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import <Foundation/Foundation.h>




NSDictionary *QBDFGetNodeOfClassNameHierachy(NSString *clsName , NSString *selName);
NSString *getSuperCallKeyNameBySelName(NSString *selName);

@interface QBDFSYSCenter : NSObject
@property(nonatomic ,strong)NSMutableDictionary * callSuperClassMethod;
@property(nonatomic ,strong)NSMutableDictionary * registerStructDict;
+(instancetype)shareInstance;


- (int)decCLSWithName:(NSString *)name
              supName:(NSString *)supName
              procals:(NSArray *)potocs
              proptys:(NSArray *)proptys;

- (int)impCLSWithName:(NSString *)name
              methods:(NSArray *)mthds;
+ (NSDictionary *)nodeOfClsName:(NSString *)name sel:(NSString *)sel;
+ (BOOL)haveOverrideMethod:(NSString *)className selname:(NSString *)selcName;


@end
