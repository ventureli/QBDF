//
//  QBDFSymbolTableItem.m
//  TestQBDFScript
//
//  Created by fatboyli on 2017/8/10.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "QBDFSymbolTableItem.h"
#import "QBDFScriptMainDefine.h"
#import "QBDFSymbolTableIdentifyItem.h"


@interface QBDFSymbolTableItemFactory()
@end

@implementation QBDFSymbolTableItemFactory
+ (QBDFSymbolTableIdentifyItem *)createIdentifyItemWithDecBaseType:(NSString *)baseType decSubType:(NSString *)subType
{
    #define QBDFTOSTR(x) @""#x""
    #define CREATEIDENTIFYFACTORY_CASE(type,clsSuffix) \
    else if([baseType isEqualToString:type]) \
    {   \
        QBDFSymbolTableIdentifyItem *item =[NSClassFromString(QBDFTOSTR(QBDFSymbolTableIdentifyItem_##clsSuffix)) new];    \
        item.decBaseType = baseType;    \
        item.decSubType = subType;  \
        return item;\
    }    \
        
    
//    QBDF_IDENTIFY_CRETATECLASS(Char)
//    QBDF_IDENTIFY_CRETATECLASS(UnsingedChar)
//    QBDF_IDENTIFY_CRETATECLASS(Short)
//    QBDF_IDENTIFY_CRETATECLASS(UnsignedShort)
//    QBDF_IDENTIFY_CRETATECLASS(Int)
//    QBDF_IDENTIFY_CRETATECLASS(UnsignedInt)
//    QBDF_IDENTIFY_CRETATECLASS(Long)
//    QBDF_IDENTIFY_CRETATECLASS(UnsignedLong)
//    QBDF_IDENTIFY_CRETATECLASS(LongLong)
//    QBDF_IDENTIFY_CRETATECLASS(UnsignedLongLong)
//    QBDF_IDENTIFY_CRETATECLASS(Float)
//    QBDF_IDENTIFY_CRETATECLASS(Double)
//    QBDF_IDENTIFY_CRETATECLASS(BOOL)
//    QBDF_IDENTIFY_CRETATECLASS(NSInteger)
//    QBDF_IDENTIFY_CRETATECLASS(NSUInteger)
//    QBDF_IDENTIFY_CRETATECLASS(CGFloat)
//    
//    QBDF_IDENTIFY_CRETATECLASS(CGSize)
//    QBDF_IDENTIFY_CRETATECLASS(CGPoint)
//    QBDF_IDENTIFY_CRETATECLASS(CGRect)
//    QBDF_IDENTIFY_CRETATECLASS(NSRange)
//    QBDF_IDENTIFY_CRETATECLASS(UIEdgeInsets)
    if(0){}
    CREATEIDENTIFYFACTORY_CASE(QBDF_VAR_DECTYPE_CHAR,Char)
    CREATEIDENTIFYFACTORY_CASE(QBDF_VAR_DECTYPE_UNCHAR,UnsingedChar)
    CREATEIDENTIFYFACTORY_CASE(QBDF_VAR_DECTYPE_SHORT,Short)
    CREATEIDENTIFYFACTORY_CASE(QBDF_VAR_DECTYPE_UNSHORT,UnsignedShort)
    CREATEIDENTIFYFACTORY_CASE(QBDF_VAR_DECTYPE_INT,Int)
    CREATEIDENTIFYFACTORY_CASE(QBDF_VAR_DECTYPE_UNINT,UnsignedInt)
    CREATEIDENTIFYFACTORY_CASE(QBDF_VAR_DECTYPE_LONG,Long)
    CREATEIDENTIFYFACTORY_CASE(QBDF_VAR_DECTYPE_UNLONG,UnsignedLong)
    CREATEIDENTIFYFACTORY_CASE(QBDF_VAR_DECTYPE_LONGLONG,LongLong)
    CREATEIDENTIFYFACTORY_CASE(QBDF_VAR_DECTYPE_UNLONGLONG,UnsignedLongLong)
    CREATEIDENTIFYFACTORY_CASE(QBDF_VAR_DECTYPE_FLOAT,Float)
    CREATEIDENTIFYFACTORY_CASE(QBDF_VAR_DECTYPE_DOUBLE,Double)
    CREATEIDENTIFYFACTORY_CASE(QBDF_VAR_DECTYPE_BOOL,BOOL)
    CREATEIDENTIFYFACTORY_CASE(QBDF_VAR_DECTYPE_NSINTEGER,NSInteger)
    CREATEIDENTIFYFACTORY_CASE(QBDF_VAR_DECTYPE_NSUINTEGER,NSUInteger)
    CREATEIDENTIFYFACTORY_CASE(QBDF_VAR_DECTYPE_CGFLOAT,CGFloat)
    
    CREATEIDENTIFYFACTORY_CASE(QBDF_VAR_DECTYPE_CGSIZE,CGSize)
    CREATEIDENTIFYFACTORY_CASE(QBDF_VAR_DECTYPE_CGPOINT,CGPoint)
    CREATEIDENTIFYFACTORY_CASE(QBDF_VAR_DECTYPE_CGRECT,CGRect)
    CREATEIDENTIFYFACTORY_CASE(QBDF_VAR_DECTYPE_NSRANGE,NSRange)
    CREATEIDENTIFYFACTORY_CASE(QBDF_VAR_DECTYPE_UIEDEGEINSETS,UIEdgeInsets)
    else if([baseType isEqualToString:QBDF_VAR_DECTYPE_ID])
    {
        QBDFSymbolTableIdentifyItem *item =[QBDFSymbolTableIdentifyItem_ID new];
        item.decBaseType = baseType;
        item.decSubType = subType;
        return item;
    }else if([baseType isEqualToString:QBDF_VAR_DECTYPE_SEL])
    {
        QBDFSymbolTableIdentifyItem_SEL *item =[QBDFSymbolTableIdentifyItem_SEL new];
        item.decBaseType = baseType;
        item.decSubType = subType;
        return item;
    }else if([baseType isEqualToString:QBDF_VAR_DECTYPE_POINT])
    {
        QBDFSymbolTableIdentifyItem_Point *item =[QBDFSymbolTableIdentifyItem_Point new];
        item.decBaseType = baseType;
        item.decSubType = subType;
        item.Ptr = NULL;
        return item;
        
    }else{
        QBDFSymbolTableIdentifyItem *item =[QBDFSymbolTableIdentifyItem_ID new];
        item.decBaseType = baseType;
        item.decSubType = subType;
        return item;
    }
    
    
}

+ (QBDFSymbolTableBLKItem *)createBlokItemWithName:(NSString *)name nodes:(id)nodes
{
    QBDFSymbolTableBLKItem *item = [QBDFSymbolTableBLKItem new];
    item.name = name;
    item.nodes = nodes;
    return item;
}

@end



@implementation QBDFSymbolTableItem

@end

@implementation QBDFSymbolTableBLKItem
@end





