//
//  QBDFSymbolTableIdentifyItem.m
//  TestQBDFScript
//
//  Created by fatboyli on 2017/8/10.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "QBDFSymbolTableIdentifyItem.h"
#import "QBDFScriptMainDefine.h"
#import <UIKit/UIKit.h>
#import "QBDFVarTypeHelper.h"
@interface QBDFSymbolTableIdentifyItem()
@end
@implementation QBDFSymbolTableIdentifyItem

- (id)getValuePtr
{
    return NULL;
}
- (id)getIDTypeValue
{
    return nil;
}
- (void)updateByIDTypeValue:(id)value
{
    
}

@end
#define QBDF_IDENTIFY_IMPCLASS(name,_type,thesel)      \
@interface QBDFSymbolTableIdentifyItem_##name()        \
{   \
  _type  _value; \
}   \
@end    \
@implementation QBDFSymbolTableIdentifyItem_##name\
- (id)getValuePtr   \
{   \
    return [NSValue valueWithPointer:&_value];\
}   \
- (id)getIDTypeValue    \
{\
   return @(_value);\
}\
- (void)updateByIDTypeValue:(id)newvalue\
{\
    if([newvalue respondsToSelector:@selector(thesel)])    \
    {   \
        _value = [newvalue  thesel]; \
    }   \
}\
@end

#define QBDF_IDENTIFY_IMPCLASSSTRUCT(name,_type,selA, selB,selBprefix)      \
@interface QBDFSymbolTableIdentifyItem_##name()        \
{   \
_type  _value; \
}   \
@end    \
@implementation QBDFSymbolTableIdentifyItem_##name\
- (id)getValuePtr   \
{   \
    return [NSValue valueWithPointer:&_value];\
}   \
- (id)getIDTypeValue    \
{\
    return [NSValue selA:_value];\
}\
- (void)updateByIDTypeValue:(id)newvalue\
{\
        NSString *types =  [NSString stringWithCString:[newvalue objCType]?:"" encoding:NSUTF8StringEncoding];\
        if([types hasPrefix:@"{"#selBprefix@""])\
        {   \
            _value = [newvalue  selB]; \
        }   \
}\
@end


QBDF_IDENTIFY_IMPCLASS(Char , char , charValue)
QBDF_IDENTIFY_IMPCLASS(UnsingedChar, unsigned char, unsignedCharValue)
QBDF_IDENTIFY_IMPCLASS(Short,short , shortValue)
QBDF_IDENTIFY_IMPCLASS(UnsignedShort , unsigned short , unsignedShortValue)
QBDF_IDENTIFY_IMPCLASS(Int , int ,intValue)
QBDF_IDENTIFY_IMPCLASS(UnsignedInt, unsigned int , unsignedIntValue)
QBDF_IDENTIFY_IMPCLASS(Long , long , longValue)
QBDF_IDENTIFY_IMPCLASS(UnsignedLong , unsigned long ,unsignedLongValue)
QBDF_IDENTIFY_IMPCLASS(LongLong, long long ,longLongValue)
QBDF_IDENTIFY_IMPCLASS(UnsignedLongLong , unsigned long long ,unsignedLongLongValue)
QBDF_IDENTIFY_IMPCLASS(Float, float ,floatValue)
QBDF_IDENTIFY_IMPCLASS(Double, double ,doubleValue)
QBDF_IDENTIFY_IMPCLASS(BOOL, BOOL ,boolValue)
QBDF_IDENTIFY_IMPCLASS(NSInteger , NSInteger ,integerValue)
QBDF_IDENTIFY_IMPCLASS(NSUInteger, NSUInteger ,unsignedIntegerValue)

#if CGFLOAT_IS_DOUBLE
QBDF_IDENTIFY_IMPCLASS(CGFloat,double,doubleValue)
#else
QBDF_IDENTIFY_IMPCLASS(CGFloat,float,floatValue)
#endif
QBDF_IDENTIFY_IMPCLASSSTRUCT(CGSize,CGSize,valueWithCGSize , CGSizeValue,CGSize)
QBDF_IDENTIFY_IMPCLASSSTRUCT(CGPoint,CGPoint,valueWithCGPoint, CGPointValue,CGPoint)
QBDF_IDENTIFY_IMPCLASSSTRUCT(CGRect,CGRect,valueWithCGRect,CGRectValue,CGRect)
QBDF_IDENTIFY_IMPCLASSSTRUCT(NSRange,NSRange, valueWithRange,rangeValue,_NSRange)
QBDF_IDENTIFY_IMPCLASSSTRUCT(UIEdgeInsets,UIEdgeInsets,valueWithUIEdgeInsets,UIEdgeInsetsValue,UIEdgeInsets)



@implementation QBDFSymbolTableIdentifyItem_ID
- (id)getValuePtr
{
    if(self.isAssign)
    {
        
        return [NSValue valueWithPointer:&_assignValue];
        
    }else{
        return [NSValue valueWithPointer:&_value];
    }
}
- (id)getIDTypeValue
{
    if(self.isAssign)
    {
        return self.assignValue;
    }else
    {
        return self.value;
    }
}
- (void)updateByIDTypeValue:(id)value
{
    _value = value;
    self.isAssign = NO;
}
- (void)updateByAssignIDTypeValue:(id)value
{
    self.isAssign = YES;
    _assignValue = value;
}
 
@end

@interface QBDFSymbolTableIdentifyItem_SEL()
{
    NSString *_value;
}
@end
@implementation QBDFSymbolTableIdentifyItem_SEL

- (id)getValuePtr
{
    return [NSValue valueWithPointer:NULL];
}
- (id)getIDTypeValue
{
    return _value;
}
- (void)updateByIDTypeValue:(id)value
{
    _value = [value description];
}
@end
@implementation QBDFSymbolTableIdentifyItem_Point  //指针
- (instancetype)init
{
    self =  [super init];
    if(self)
    {
        self.Ptr = NULL;
    }
    return self;
}
- (id)getValuePtr
{
    
//    void **ptr =&_Ptr;
//    _thePTR = ptr;
    return [NSValue valueWithPointer:&_Ptr];

}
- (id)getIDTypeValue
{
    return [NSValue valueWithPointer:self.Ptr];
}
- (void)updateByIDTypeValue:(id)value
{
    if([value respondsToSelector:@selector(pointerValue)])
    {
        
        self.Ptr =  [value pointerValue];
    }else
    {
        self.Ptr = NULL;
    }
}
- (void)unaddrUpdatePointValue:(id)value
{
    [QBDFVarTypeHelper unAddrUpdatePointValueByPoint:self.Ptr subType:self.decSubType value:value name:self.name];
}

- (id)readUnaddrIDValue
{
    return   [QBDFVarTypeHelper readUnAddrPointValueByPoint:self.Ptr subType:self.decSubType  name:self.name];
    
}

- (void)updateValueByIndex:(int)index value:(id)value
{
    [QBDFVarTypeHelper updatePointValueByPoint:self.Ptr index:index subType:self.decSubType value:value name:self.name];
}
- (id)readValueByIndex:(int)index
{
    
    return [QBDFVarTypeHelper readPointValueByPoint:self.Ptr index:index subType:self.decSubType name:self.name];
}

    

@end
