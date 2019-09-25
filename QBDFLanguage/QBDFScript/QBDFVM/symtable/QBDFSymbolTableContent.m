//
//  QBDFSymbolTableContent.m
//  TestQBDFScript
//
//  Created by fatboyli on 2017/8/10.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "QBDFSymbolTableContent.h"
#import "QBDFScriptMainDefine.h"
#import "QBDFSymbolTableIdentifyItem.h"
@implementation QBDFSymbolTableContent


- (instancetype)init{
    self = [super init];
    if(self)
    {
        self->_items = [NSMutableDictionary new];
    }
    return self;
}



- (int )addIdentifySymbolWithName:(NSString *)name varType:(NSString *)baseType subType:(NSString *)subType value:(id)value
{
    QBDFSymbolTableIdentifyItem *item = [QBDFSymbolTableItemFactory createIdentifyItemWithDecBaseType:baseType decSubType:subType];
    item.name = name;
    item.decBaseType = baseType;
    item.decSubType  = subType;
    if(self.items[name])
    {
        __QBDF_ERROR__([NSString stringWithFormat:@"变量 [ %@ ]在同一作用域内重复定义 ",name]);
    }
    [item updateByIDTypeValue:value];
    self.items[name] = item;//添加
    return 0;
}

- (int )addIdentifySymbolWithName:(NSString *)name varType:(NSString *)type subType:(NSString *)subType
{
    [self addIdentifySymbolWithName:name varType:type subType:subType value:nil];
    return 0;
}


- (QBDFSymbolTableItem *)_getSymbolItemByName:(NSString *)name
{
    if(!name || (name.length == 0))
    {
        return nil;
    }
    return self.items[name];
}

- (void)_deleteSymbItemByName:(NSString *)name
{
    if(!name || (name.length == 0))
    {
        return ;
    }
    return [self.items removeObjectForKey:name];
}


- (void)addBlkWithName:(NSString *)name
                 nodes:(NSDictionary *)nodes
{
    
    QBDFSymbolTableBLKItem *item = [QBDFSymbolTableItemFactory createBlokItemWithName:name nodes:nodes];
  
    
    if(name.length ==0)
    {
        
        __QBDF_ERROR__([NSString stringWithFormat:@"变量名字为空 %@",@""]);
        return;
    }
    if(self.items[name])
    {
        //        NSAssert(0, @"变量 [ %@ ]在同一作用域内重复定义 ",name);
        __QBDF_ERROR__([NSString stringWithFormat:@"变量 [ %@ ]在同一作用域内重复定义 ",name]);
        
        return;
    }
    self.items[name] = item;//添加
    
    return;
}



@end
