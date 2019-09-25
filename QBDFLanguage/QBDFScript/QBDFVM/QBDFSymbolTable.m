//
//  QBDFSymbolTable.m
//  QBDFScript
//
//  Created by fatboyli on 2017/5/19.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "QBDFSymbolTable.h"
#import "QBDFScriptMainDefine.h"
//fhb类型
#import "QBDFOCCALLCenter.h"
#import <UIKit/UIKit.h>
#import "QBDFSymbolTableItem.h"
#import "QBDFSymbolTableContent.h"

#import "QBDFSymbolTableItem.h"
#import "QBDFSymbolTableIdentifyItem.h"

//标识符Item


@interface QBDFSymbolTable()

@property(nonatomic ,strong)NSMutableArray<QBDFSymbolTableContent *>              *symbolTableStack;   //基础
@property(nonatomic ,strong)NSMutableDictionary<NSString *, id>                   *tmpVarMap;   //基础

@end

@implementation QBDFSymbolTable

- (instancetype)init{
    self = [super init];
    if(self)
    {
        self.symbolTableStack = [NSMutableArray new];
        [self.symbolTableStack insertObject:[QBDFSymbolTableContent new] atIndex:0]; //这个一个base 基本
        self.tmpVarMap = [NSMutableDictionary new];
    }
    return self;
}

//- (void)initBaseContent:(QBDFSymbolTableContent *)content
//{
////    [content addIdentifySymbolWithName:@"nil" varType:CMD_EXP_OPERANDTYPE_ID ptrdeep:0 value:[QBDFNil new]];
////    [content addIdentifySymbolWithName:@"NULL" varType:CMD_EXP_OPERANDTYPE_ID ptrdeep:0 value:[NSNull null]];
////    [content addIdentifySymbolWithName:@"YES" varType:CMD_EXP_OPERANDTYPE_NUM ptrdeep:0 value:@(1)];
////    [content addIdentifySymbolWithName:@"NO" varType:CMD_EXP_OPERANDTYPE_NUM ptrdeep:0 value:@(0)];
////    [content addIdentifySymbolWithName:QBDF_VERS_KEY varType:CMD_EXP_OPERANDTYPE_NUM ptrdeep:0 value:@(QBDF_VERSION)];
////    [content addIdentifySymbolWithName:QBHD_VERS_KEY varType:CMD_EXP_OPERANDTYPE_NUM ptrdeep:0 value:@(6.01)];
//
//}

- (QBDFSymbolTableContent *)_topSymbolTable
{
    if([self.symbolTableStack count] > 0)
    {
        return self.symbolTableStack[0];
    }else
    {
        __QBDF_ERROR__([NSString stringWithFormat:@"no fu hao bia"]);
        
        return nil;
    }
}

- (QBDFSymbolTableItem *)_getSymbolItemByName:(NSString *)name
{
    for(int i = 0 ;i < [_symbolTableStack count];i ++) //从栈顶开始找如果找到了就执行
    {
        QBDFSymbolTableContent *content =  _symbolTableStack[i];
        QBDFSymbolTableItem *item = [content _getSymbolItemByName:name];
        if(item)
        {
            return item;
        }
    }
    
    QBDFSymbolTableContent *content = [[self class] theBaseContent];//从baseContent中寻找
    QBDFSymbolTableItem *item =  [content _getSymbolItemByName:name];
    if(item)
    {
        return item;
    }
    
    return nil;
}



- (void)_deleteSymbItemByName:(NSString *)name
{
    for(int i = 0 ;i < [_symbolTableStack count];i ++) //从栈顶开始找如果找到了就执行
    {
        QBDFSymbolTableContent *content =  _symbolTableStack[i];
        QBDFSymbolTableItem *item = [content _getSymbolItemByName:name];
        if(item)
        {
            [content _deleteSymbItemByName:name];
            break;
        }
    }
}

//fuhao push
- (void)pushSymbolTable
{
    QBDFSymbolTableContent *tableContent =  [QBDFSymbolTableContent new];
    [self.symbolTableStack insertObject:tableContent atIndex:0];
}

- (void)popSymbolTable
{
    if([self.symbolTableStack count] >1)
    {
        [self.symbolTableStack removeObjectAtIndex:0];
    }else
    {
        __QBDF_ERROR__([NSString stringWithFormat:@"fuhao pop失败"]);
        
    }
}


- (void)unaddrUpdatePointIdentifyWithName:(NSString *)name value:(id)val
{
    QBDFSymbolTableIdentifyItem *item = (QBDFSymbolTableIdentifyItem *)[self _getSymbolItemByName:name];
    if(item)
    {
        
        if([item isKindOfClass:[QBDFSymbolTableIdentifyItem_Point class]])
        {
            [((QBDFSymbolTableIdentifyItem_Point *)item) unaddrUpdatePointValue:val];
        }else{
             __QBDF_ERROR__([NSString stringWithFormat:@"标识符%@不是指针类型",name]);
        }
    }else
    {
        //        NSAssert(0, @"未命名标识符%@",name);
        __QBDF_ERROR__([NSString stringWithFormat:@"未命名标识符%@",name]);
        
    }

}

- (void)updateIdentifyAssignValueWithName:(NSString *)name value:(id)val //类型
{
    
    QBDFSymbolTableIdentifyItem *item = (QBDFSymbolTableIdentifyItem *)[self _getSymbolItemByName:name];
    if(item)
    {
        
        if([item isKindOfClass:[QBDFSymbolTableIdentifyItem_ID class]])
        {
            ((QBDFSymbolTableIdentifyItem_ID *)item).isAssign = YES;
            [((QBDFSymbolTableIdentifyItem_ID *)item) updateByAssignIDTypeValue:val];
        }else{
            [item updateByIDTypeValue:val];
        }
    }else
    {
        //        NSAssert(0, @"未命名标识符%@",name);
        __QBDF_ERROR__([NSString stringWithFormat:@"未命名标识符%@",name]);
        
    }
}

//更新的数值
- (void)updateIdentifyValueWithName:(NSString *)name value:(id)val //类型
{
    
    QBDFSymbolTableIdentifyItem *item = (QBDFSymbolTableIdentifyItem *)[self _getSymbolItemByName:name];
    if([item isKindOfClass:[QBDFSymbolTableIdentifyItem class]])
    {
        [item updateByIDTypeValue:val];
        
    }else
    {
        __QBDF_ERROR__([NSString stringWithFormat:@"未命名标识符%@",name]);
    }
    
}

////读取下标和[@"good"]字典变量
//- (id)readArrayOrDictValue:(id)target key:(id)name
//{
//    if([target isKindOfClass:[NSDictionary class]])
//    {
////        NSLog(@"dict");
//        if(name)
//        {
//            return target[name];
//        }
//
//    }else if([target isKindOfClass:[NSArray class]])
//    {
//        if(name)
//        {
//            if([((NSArray *)target) count] > [name integerValue])
//            {
//                return target[[name integerValue]];
//            }
//        }
//
//    }else
//    {
//
////        NSAssert(0, @"中括号表达式用于左值的时候，只能是可变数组和可变字典");
//        __QBDF_ERROR__(@"中括号表达式用于左值的时候，只能是可变数组和可变字典");
//
//
//    }
//    return nil;
//}
////更新下标和[@"good"]字典变量
//- (void)updateArrayOrDictValue:(id)target key:(id )name value:(id)value
//{
//    if([target isKindOfClass:[NSMutableDictionary class]])
//    {
//        if(name)
//        {
//            target[name] = value;
//        }
//
//    }else if([target isKindOfClass:[NSMutableArray class]])
//    {
//        if(name)
//        {
//            target[[name integerValue]] = value;
//        }
//
//    }else
//    {
//        __QBDF_ERROR__(@"中括号表达式用于左值的时候，只能是可变数组和可变字典");
//    }
//}

- (void)updateValueByBracket:(NSString *)varName key:(id)key value:(id)value
{
    QBDFSymbolTableItem *item = (QBDFSymbolTableItem *)[self _getSymbolItemByName:varName];
    if([item isKindOfClass:[QBDFSymbolTableIdentifyItem_ID class]])
    {
        id targetValue = [(QBDFSymbolTableIdentifyItem_ID *)item getIDTypeValue];
        [[QBDFOCCALLCenter shareInstance] updateArrayOrDictValue:targetValue key:key value:value];
    }else if([item isKindOfClass:[QBDFSymbolTableIdentifyItem_Point class]])
    {
        QBDFSymbolTableIdentifyItem_Point *point =( QBDFSymbolTableIdentifyItem_Point*)item;
        [point updateValueByIndex:[key intValue] value:value];//:<#(id)#>
    }else{
        __QBDF_ERROR__([NSString stringWithFormat:@"未命名标识符%@",varName]);
        return;
        
    }
    
    
}
- (id)readValueByBracket:(NSString *)varName key:(id)key
{
    QBDFSymbolTableItem *item = (QBDFSymbolTableItem *)[self _getSymbolItemByName:varName];
    if([item isKindOfClass:[QBDFSymbolTableIdentifyItem_ID class]])
    {
        id targetValue = [(QBDFSymbolTableIdentifyItem_ID *)item getIDTypeValue];
        return [[QBDFOCCALLCenter shareInstance] readArrayOrDictValue:targetValue key:key];
    }else if([item isKindOfClass:[QBDFSymbolTableIdentifyItem_Point class]])
    {
        QBDFSymbolTableIdentifyItem_Point *point =( QBDFSymbolTableIdentifyItem_Point*)item;
        return [point readValueByIndex:[key intValue]];
    }else{
        __QBDF_ERROR__([NSString stringWithFormat:@"未命名标识符%@",varName]);
        return [QBDFNil new];
        
    }

}
//读取
- (id)readIdentifyValueByName:(NSString *)name
{
    QBDFSymbolTableItem *item = (QBDFSymbolTableItem *)[self _getSymbolItemByName:name];
    if([item isKindOfClass:[QBDFSymbolTableIdentifyItem class]])
    {
      return [((QBDFSymbolTableIdentifyItem *)item) getIDTypeValue];
        
    }else if([item isKindOfClass:[QBDFSymbolTableBLKItem class]])
    {
        return ((QBDFSymbolTableBLKItem *)item).nodes;
    }else
    {
        __QBDF_ERROR__([NSString stringWithFormat:@"未命名标识符%@",name]);
        
        return [QBDFNil new];
    }
}
//判断是否有这个符号
- (BOOL)haveIdentifyWithName:(NSString *)name
{
    if((![name isKindOfClass:[NSString class]]) || name.length == 0)
    {
        return NO;
    }
    QBDFSymbolTableItem *item = [self _getSymbolItemByName:name];
    if([item isKindOfClass:[QBDFSymbolTableIdentifyItem class]])
    {
        return YES;
    }else{
        return NO;
    }
}
//- (id)readIdentifyDecTypeByName:(NSString *)name
//{
//    QBDFSymbolTableIdentifyItem *item = (QBDFSymbolTableIdentifyItem *)[self _getSymbolItemByName:name];
//    if([item isKindOfClass:[QBDFSymbolTableIdentifyItem class]])
//    {
//        return item.decType;
//    }else { //TODO:Fix heree
//        __QBDF_ERROR__([NSString stringWithFormat:@"未命名标识符%@",name]);
//        
//        return nil;
//    }
//}

- (id)readIdentifyAddressByName:(NSString *)name
{
    QBDFSymbolTableIdentifyItem *item = (QBDFSymbolTableIdentifyItem *)[self _getSymbolItemByName:name];
    if([item isKindOfClass:[QBDFSymbolTableIdentifyItem class]])
    {
        return [item getValuePtr];
    }else {  
        __QBDF_ERROR__([NSString stringWithFormat:@"未命名标识符%@",name]);
        return nil;
    }
    return NULL;
}

- (id)readIdentifyValueByUnAddressByName:(NSString *)name
{
    QBDFSymbolTableIdentifyItem *item = (QBDFSymbolTableIdentifyItem *)[self _getSymbolItemByName:name];
    if([item isKindOfClass:[QBDFSymbolTableIdentifyItem_Point class]])
    {
        return  [((QBDFSymbolTableIdentifyItem_Point *)item)  readUnaddrIDValue];
    }else {
        __QBDF_ERROR__([NSString stringWithFormat:@"未命名标识符%@",name]);
        return nil;
    }
    return NULL;

}

- (QBDFIdentifyType)readIdentifyType:(NSString *)name
{
    QBDFSymbolTableIdentifyItem *item = (QBDFSymbolTableIdentifyItem *)[self _getSymbolItemByName:name];
    if([item isKindOfClass:[QBDFSymbolTableBLKItem class]])
    {
        return QBDFIdentifyTypeBLK;
    }else if([item isKindOfClass:[QBDFSymbolTableIdentifyItem class]])
    {
        
        return QBDFIdentifyTypeVari;
    }else{
        return QBDFIdentifyTypeUnKnow;
        
    }

}
//添加符号变量
- (int )addIdentifySymbolWithName:(NSString *)name varType:(NSString *)type subType:(NSString *)subType
{
    [[self _topSymbolTable] addIdentifySymbolWithName:name varType:type  subType:subType];
    return 0;
}

- (int)addIdentifySymbolWithName:(NSString *)name varType:(NSString *)type subType:(NSString *)subType value:(id)value
{
    [[self _topSymbolTable] addIdentifySymbolWithName:name varType:type subType:subType value:value];
    return 0;
}

//存储行号代表的中间变量
- (void)updateTmpVarWithName:(NSString *)name value:(id)value
{
    if(!name || !value)
    {
//        NSAssert(0, @"临时变量名字为空");
        
        __QBDF_ERROR__([NSString stringWithFormat:@"临时变量名字为空"]);
        
        return;
        
    }
    self.tmpVarMap[name] = value;
}

//读取临时行号代表的中间变量
- (id)readTmpVarWithName:(NSString *)name
{
    if((!name) || (![name isKindOfClass:[NSString class]]) || name.length == 0 || (!self.tmpVarMap[name]))
    {
//        NSAssert(0, @"临时变量不存在");
        
        __QBDF_ERROR__([NSString stringWithFormat:@"临时变量不存在"]);
    }
    return self.tmpVarMap[name];
}



- (int)addBlkWithName:(NSString *)name
                nodes:(NSDictionary *)nodes
{
    [[self _topSymbolTable] addBlkWithName:name nodes:nodes];
    return 0;
}
- (id)getBlkByName:(NSString *)name
{
    QBDFSymbolTableItem *item = (QBDFSymbolTableItem *)[self _getSymbolItemByName:name];
    if([item isKindOfClass:[QBDFSymbolTableBLKItem class]])
    {
        return ((QBDFSymbolTableBLKItem *)item).nodes;
    }else
    {
        return nil;
    }
    
}

- (NSArray *)copySymbolsForBlkCall
{
    if([self.symbolTableStack count] >0)
    {
        return [self.symbolTableStack copy];
   
    }else{
        return @[];
    }
}

- (void)addBaseSymbolWithSymbStack:(NSArray *)array//从最后一个追加
{
    if([array count] == 0)
    {
        return;
    }
 
//    for(int i = 0 ;i < [array count];i ++)  //全部插入
//    {
//        id currnetSymbContexnt = array[i];
//        [self.symbolTableStack addObject:currnetSymbContexnt];
//    }
    [self.symbolTableStack addObjectsFromArray:array];
   
}

- (void)dealloc
{
    //NSLog(@"QBDFSymbolTable dealloc");
    
}

- (void)deleteVari:(NSString *)name
{
    [self _deleteSymbItemByName:name];
}

+ (QBDFSymbolTableContent *)theBaseContent
{
    static QBDFSymbolTableContent *basecontent = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        basecontent = [QBDFSymbolTableContent new];
        [basecontent addIdentifySymbolWithName:@"nil" varType:QBDF_VAR_DECTYPE_ID subType:QBDF_VAR_DECTYPE_NOSUB value:[QBDFNil new]];
        [basecontent addIdentifySymbolWithName:@"NULL" varType:QBDF_VAR_DECTYPE_ID subType:QBDF_VAR_DECTYPE_NOSUB value:[NSNull null]];
  
        [basecontent addIdentifySymbolWithName:@"YES" varType:QBDF_VAR_DECTYPE_BOOL subType:QBDF_VAR_DECTYPE_NOSUB value:@(YES)];
        [basecontent addIdentifySymbolWithName:@"NO" varType:QBDF_VAR_DECTYPE_BOOL subType:QBDF_VAR_DECTYPE_NOSUB value:@(NO)];
        [basecontent addIdentifySymbolWithName:QBDF_VERS_KEY varType:QBDF_VAR_DECTYPE_FLOAT subType:QBDF_VAR_DECTYPE_NOSUB value:@(QBDF_VERSION)];
        [basecontent addIdentifySymbolWithName:@"CGRectZero" varType:QBDF_VAR_DECTYPE_CGRECT subType:QBDF_VAR_DECTYPE_NOSUB value:[NSValue valueWithCGRect:CGRectZero]];
        [basecontent addIdentifySymbolWithName:@"CGPointZero" varType:QBDF_VAR_DECTYPE_CGPOINT subType:QBDF_VAR_DECTYPE_NOSUB value:[NSValue valueWithCGPoint:CGPointZero]];
        [basecontent addIdentifySymbolWithName:@"CGSizeZero" varType:QBDF_VAR_DECTYPE_CGSIZE subType:QBDF_VAR_DECTYPE_NOSUB value:[NSValue valueWithCGSize:CGSizeZero]];
        [basecontent addIdentifySymbolWithName:@"UIEdgeInsetsZero" varType:QBDF_VAR_DECTYPE_UIEDEGEINSETS subType:QBDF_VAR_DECTYPE_NOSUB value:[NSValue valueWithUIEdgeInsets:UIEdgeInsetsZero]];
        
        
        
    });
    
    return basecontent;
    
}

@end
