//
//  QBDFSymbolTableIdentifyItem.h
//  TestQBDFScript
//
//  Created by fatboyli on 2017/8/10.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

//
#import "QBDFSymbolTableItem.h"

@interface QBDFSymbolTableIdentifyItem : QBDFSymbolTableItem
@property(nonatomic ,copy)NSString                      *decBaseType;
@property(nonatomic ,copy)NSString                      *decSubType;

- (id)getValuePtr;
- (id)getIDTypeValue;
- (void)updateByIDTypeValue:(id)value;
@end


#define QBDF_IDENTIFY_CRETATECLASS(name)        \
@interface QBDFSymbolTableIdentifyItem_##name : QBDFSymbolTableIdentifyItem\
@end

QBDF_IDENTIFY_CRETATECLASS(Char)
QBDF_IDENTIFY_CRETATECLASS(UnsingedChar)
QBDF_IDENTIFY_CRETATECLASS(Short)
QBDF_IDENTIFY_CRETATECLASS(UnsignedShort)
QBDF_IDENTIFY_CRETATECLASS(Int)
QBDF_IDENTIFY_CRETATECLASS(UnsignedInt)
QBDF_IDENTIFY_CRETATECLASS(Long)
QBDF_IDENTIFY_CRETATECLASS(UnsignedLong)
QBDF_IDENTIFY_CRETATECLASS(LongLong)
QBDF_IDENTIFY_CRETATECLASS(UnsignedLongLong)
QBDF_IDENTIFY_CRETATECLASS(Float)
QBDF_IDENTIFY_CRETATECLASS(Double)
QBDF_IDENTIFY_CRETATECLASS(BOOL)
QBDF_IDENTIFY_CRETATECLASS(NSInteger)
QBDF_IDENTIFY_CRETATECLASS(NSUInteger)
QBDF_IDENTIFY_CRETATECLASS(CGFloat)

QBDF_IDENTIFY_CRETATECLASS(CGSize)
QBDF_IDENTIFY_CRETATECLASS(CGPoint)
QBDF_IDENTIFY_CRETATECLASS(CGRect)
QBDF_IDENTIFY_CRETATECLASS(NSRange)
QBDF_IDENTIFY_CRETATECLASS(UIEdgeInsets)

@interface QBDFSymbolTableIdentifyItem_ID : QBDFSymbolTableIdentifyItem
{
    
    void **_theconvertPTR;
    void **_thePTR;
}
@property(nonatomic ,assign)BOOL                    isAssign;
@property(nonatomic ,strong)id                      value;
@property(nonatomic ,assign)id                      assignValue;

- (void)updateByAssignIDTypeValue:(id)value;
@end
@interface QBDFSymbolTableIdentifyItem_SEL : QBDFSymbolTableIdentifyItem

@end

@interface QBDFSymbolTableIdentifyItem_Point : QBDFSymbolTableIdentifyItem //指针
{
    
    void **_thePTR;
}
@property(nonatomic ,assign)void                    *Ptr;


- (void)unaddrUpdatePointValue:(id)value;
- (id)readUnaddrIDValue;

- (void)updateValueByIndex:(int)index value:(id)value;
- (id)readValueByIndex:(int)index;
@end



