//
//  QBDFSymbolTable.h
//  QBDFScript
//
//  Created by fatboyli on 2017/5/19.
//  Copyright © 2017年 fatboyli. All rights reserved.
//


//整个符号表重构与2017/8/10

#import <Foundation/Foundation.h>
/**
 * fuhaobiao：QBDF的
 */


typedef enum
{
    QBDFIdentifyTypeVari = 0,
    QBDFIdentifyTypeBLK,
    QBDFIdentifyTypeUnKnow,
}QBDFIdentifyType;

@interface QBDFSymbolTable : NSObject
//表入栈
- (void)pushSymbolTable;
//表出栈
- (void)popSymbolTable;
//和identify相关
//添加新的fuhao
- (int)addIdentifySymbolWithName:(NSString *)name varType:(NSString *)type subType:(NSString *)subType;
- (int)addIdentifySymbolWithName:(NSString *)name varType:(NSString *)type subType:(NSString *)ptrdeep value:(id)value;
//更新新的fuhao
- (void)updateIdentifyValueWithName:(NSString *)name value:(id)val;
- (void)updateIdentifyAssignValueWithName:(NSString *)name value:(id)val;//类型;
- (void)unaddrUpdatePointIdentifyWithName:(NSString *)name value:(id)val;//类型;

- (id)readValueByBracket:(NSString *)varName key:(id)key;

- (void)updateValueByBracket:(NSString *)varName key:(id)key value:(id)value;



- (id)readIdentifyValueByUnAddressByName:(NSString *)name;
//读取fuhao的值
- (id)readIdentifyValueByName:(NSString *)name;
//判断是否有这个fuhao
- (BOOL)haveIdentifyWithName:(NSString *)name;
//去地址fuhao
- (id)readIdentifyAddressByName:(NSString *)name;
//存储行号代表的中间变量
- (void)updateTmpVarWithName:(NSString *)name value:(id)value;
//读取临时行号代表的中间变量
- (id)readTmpVarWithName:(NSString *)name;
- (QBDFIdentifyType)readIdentifyType:(NSString *)name;
//和fun相关
//添加block和函数指针
- (int)addBlkWithName:(NSString *)name
                nodes:(NSDictionary *)nodes;
- (id)getBlkByName:(NSString *)name;
- (NSArray *)copySymbolsForBlkCall;
- (void)addBaseSymbolWithSymbStack:(NSArray *)array;
- (void)deleteVari:(NSString *)key;
@end

