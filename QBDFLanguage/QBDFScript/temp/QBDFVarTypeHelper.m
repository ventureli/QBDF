//
//  QBDFVarTypeHelper.m
//  TestQBDFScript
//
//  Created by fatboyli on 2017/8/9.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "QBDFVarTypeHelper.h"
#import "QBDFScriptMainDefine.h"
#import <UIKit/UIKit.h>
#import "QBDFNil.h"
ffi_type ffi_qbdfrect;
ffi_type ffi_qbdfsize;
ffi_type ffi_qbdfpoint;
ffi_type ffi_qbdfrange;
ffi_type ffi_qbdfedgeInsert;

@implementation QBDFVarTypeHelper

+ (BOOL)isVarDefineTokenName:(NSString *)tokenName
{
    NSArray *types = [[self class] _QBDFSupportVarDecTypes];
    if([types containsObject:tokenName])
    {
        return YES;
    }else{
        return NO;
    }
    
}

+ (NSArray *)_QBDFSupportVarDecTypes
{
    static NSArray *theTypesArray = nil;
    if(!theTypesArray)
    {
        theTypesArray = @[
                          @"char",
                          @"unsigned char",
                          @"short",
                          @"unsigned short",
                          @"int",
                          @"unsigned int",
                          @"long",
                          @"unsigned long",
                          @"long long",
                          @"unsigned long long",
                          @"float",
                          @"double",
                          @"BOOL",
                          @"NSInteger",
                          @"NSUInteger",
                          @"CGFloat",
                          @"void",
                          @"CGSize",
                          @"CGPoint",
                          @"CGRect",
                          @"NSRange",
                          @"UIEdgeInsets",
                          @"id",
                          @"SEL",
                          ];
    }
    return theTypesArray;
}

+ (NSString *)QBDFSupportVarDecTypeCode:(NSString *)type
{
    static NSDictionary *theTypesDict= nil;
    if(!theTypesDict)
    {
        theTypesDict = @{
                          @"char":QBDF_VAR_DECTYPE_CHAR,
                          @"unsigned char":QBDF_VAR_DECTYPE_UNCHAR,
                          @"short":QBDF_VAR_DECTYPE_SHORT,
                          @"unsigned short":QBDF_VAR_DECTYPE_UNSHORT,
                          @"int":QBDF_VAR_DECTYPE_INT,
                          @"unsigned int":QBDF_VAR_DECTYPE_UNINT,
                          @"long":QBDF_VAR_DECTYPE_LONG,
                          @"unsigned long":QBDF_VAR_DECTYPE_UNLONG,
                          @"long long":QBDF_VAR_DECTYPE_LONGLONG,
                          @"unsigned long long":QBDF_VAR_DECTYPE_UNLONGLONG,
                          @"float":QBDF_VAR_DECTYPE_FLOAT,
                          @"double":QBDF_VAR_DECTYPE_DOUBLE,
                          @"BOOL":QBDF_VAR_DECTYPE_BOOL,
                          @"NSInteger":QBDF_VAR_DECTYPE_NSINTEGER,
                          @"NSUInteger":QBDF_VAR_DECTYPE_NSUINTEGER,
                          @"CGFloat":QBDF_VAR_DECTYPE_CGFLOAT,
                          @"void":QBDF_VAR_DECTYPE_VOID,
                          @"CGSize":QBDF_VAR_DECTYPE_CGSIZE,
                          @"CGPoint":QBDF_VAR_DECTYPE_CGPOINT,
                          @"CGRect":QBDF_VAR_DECTYPE_CGRECT,
                          @"NSRange":QBDF_VAR_DECTYPE_NSRANGE,
                          @"UIEdgeInsets":QBDF_VAR_DECTYPE_UIEDEGEINSETS,
                          @"id":QBDF_VAR_DECTYPE_ID,
                          @"SEL":QBDF_VAR_DECTYPE_SEL,
                          };
    }
    return theTypesDict[type];
}

+ (void)unAddrUpdatePointValueByPoint:(void *)ptr subType:(NSString *)subTpe value:(id)value name:(NSString *)name
{
    
    if(ptr == NULL || ptr == nil)
    {
        return;
    }
    if([QBDF_VAR_DECTYPE_ID isEqualToString:subTpe])
    {
        id theValue = (__bridge_transfer id)(*((void **)ptr));
        *((void **)ptr) =  (__bridge_retained void *)value;
        
    }else if([QBDF_VAR_DECTYPE_SEL isEqualToString:subTpe])
    {
        id theValue = (__bridge_transfer id)(*((void **)ptr));
        *((void **)ptr) =  (__bridge_retained void *)value;
    }else
    {
        [[self class] updatePointValueByPoint:ptr index:0 subType:subTpe value:value name:name];
    }
}

+ (id)readUnAddrPointValueByPoint:(void *)ptr subType:(NSString *)subTpe  name:(NSString *)name
{
    if(ptr == NULL || ptr == nil)
    {
        return nil;
    }
    
    if([QBDF_VAR_DECTYPE_ID isEqualToString:subTpe])
    {
        void **newptr = (void **)ptr;
        id theValue = (__bridge id)(*newptr);
        return theValue;
    }else if([QBDF_VAR_DECTYPE_SEL isEqualToString:subTpe])
    {
        void **newptr = (void **)ptr;
        id theValue = (__bridge id)(*newptr);
        return theValue;
    }else if([QBDF_VAR_DECTYPE_VOID isEqualToString:subTpe])
        
    {
        int *p = (int *)ptr;
        return @(*p);
    }else if([QBDF_VAR_DECTYPE_POINT isEqualToString:subTpe])
    {
        void **newptr = (void **)ptr;
        return [NSValue valueWithPointer:*newptr];
    }else
    {
        return [[self class] readPointValueByPoint:ptr index:0 subType:subTpe name:name];
    }
}



+ (void)updatePointValueByPoint:(void *)ptr index:(int)index subType:(NSString *)subTpe value:(id)value name:(NSString *)name
{
    if(ptr == NULL || ptr == nil)
    {
        return;
    }
    
    #define UNADDR_UPDATE_INDEX_CASE(subtypestr,realtype,thesel)   \
    else if([subTpe isEqualToString:subtypestr]) \
    { \
        if([value respondsToSelector:@selector(thesel)])\
        {   \
            *(((realtype *)ptr) +index) = [value thesel];    \
        }else{\
            __QBDF_ERROR__([NSString stringWithFormat:@"指针%@更新数值不符合",name]); \
        }\
    }
    if(0){}
    UNADDR_UPDATE_INDEX_CASE(QBDF_VAR_DECTYPE_CHAR , char , charValue)
    UNADDR_UPDATE_INDEX_CASE(QBDF_VAR_DECTYPE_UNCHAR , unsigned char , unsignedCharValue)
    UNADDR_UPDATE_INDEX_CASE(QBDF_VAR_DECTYPE_SHORT , short, shortValue)
    UNADDR_UPDATE_INDEX_CASE(QBDF_VAR_DECTYPE_UNSHORT , unsigned short, unsignedShortValue)
    UNADDR_UPDATE_INDEX_CASE(QBDF_VAR_DECTYPE_INT , int, intValue)
    UNADDR_UPDATE_INDEX_CASE(QBDF_VAR_DECTYPE_UNINT , unsigned int, unsignedIntValue)
    UNADDR_UPDATE_INDEX_CASE(QBDF_VAR_DECTYPE_LONG , long, longValue)
    UNADDR_UPDATE_INDEX_CASE(QBDF_VAR_DECTYPE_UNLONG , unsigned long, unsignedLongValue)
    UNADDR_UPDATE_INDEX_CASE(QBDF_VAR_DECTYPE_LONGLONG ,long long, longLongValue)
    UNADDR_UPDATE_INDEX_CASE(QBDF_VAR_DECTYPE_UNLONGLONG ,unsigned long long, unsignedLongLongValue)
    UNADDR_UPDATE_INDEX_CASE(QBDF_VAR_DECTYPE_FLOAT ,float, floatValue)
    UNADDR_UPDATE_INDEX_CASE(QBDF_VAR_DECTYPE_DOUBLE ,double, doubleValue)
    UNADDR_UPDATE_INDEX_CASE(QBDF_VAR_DECTYPE_BOOL ,BOOL, boolValue)
    UNADDR_UPDATE_INDEX_CASE(QBDF_VAR_DECTYPE_NSINTEGER ,NSInteger, integerValue)
    UNADDR_UPDATE_INDEX_CASE(QBDF_VAR_DECTYPE_NSUINTEGER ,NSUInteger, unsignedIntegerValue)
    UNADDR_UPDATE_INDEX_CASE(QBDF_VAR_DECTYPE_CGSIZE ,CGSize, CGSizeValue)
    UNADDR_UPDATE_INDEX_CASE(QBDF_VAR_DECTYPE_CGPOINT ,CGPoint, CGPointValue)
    UNADDR_UPDATE_INDEX_CASE(QBDF_VAR_DECTYPE_CGRECT ,CGRect, CGRectValue)
    UNADDR_UPDATE_INDEX_CASE(QBDF_VAR_DECTYPE_NSRANGE ,NSRange, rangeValue)
    UNADDR_UPDATE_INDEX_CASE(QBDF_VAR_DECTYPE_UIEDEGEINSETS ,UIEdgeInsets, UIEdgeInsetsValue)
#if CGFLOAT_IS_DOUBLE
    UNADDR_UPDATE_INDEX_CASE(QBDF_VAR_DECTYPE_CGFLOAT ,double, doubleValue)
#else
    UNADDR_UPDATE_INDEX_CASE(QBDF_VAR_DECTYPE_CGFLOAT ,float, floatValue)
#endif
    else if([QBDF_VAR_DECTYPE_ID isEqualToString:subTpe])
    {
        __QBDF_ERROR__(@"id **类型不能时申请和操作数组");
        
    }else if([QBDF_VAR_DECTYPE_SEL isEqualToString:subTpe])
    {
        
        __QBDF_ERROR__(@"id **类型不能时申请和操作数组");
    }else if([QBDF_VAR_DECTYPE_POINT isEqualToString:subTpe])
    {
        *(((void **)ptr +index)) = [value pointerValue];
    }
}
+ (id)readPointValueByPoint:(void *)ptr index:(int)index subType:(NSString *)subTpe  name:(NSString *)name
{
    if(ptr == NULL || ptr == nil)
    {
        return nil;
    }
    
    #define UNADDR_READ_INDEX_CASEA(subtypestr,realtype)   \
    else if([subTpe isEqualToString:subtypestr]) \
    { \
        realtype val = *(((realtype *)ptr +index)); \
        return @(val); \
    }
        
    #define UNADDR_READ_INDEX_CASEB(subtypestr,realtype,thesel)   \
    else if([subTpe isEqualToString:subtypestr]) \
    { \
    realtype val = *(((realtype *)ptr +index)); \
    return [NSValue thesel:val]; \
    }
    
    if(0){}
    UNADDR_READ_INDEX_CASEA(QBDF_VAR_DECTYPE_CHAR , char )
    UNADDR_READ_INDEX_CASEA(QBDF_VAR_DECTYPE_UNCHAR , unsigned char )
    UNADDR_READ_INDEX_CASEA(QBDF_VAR_DECTYPE_SHORT , short)
    UNADDR_READ_INDEX_CASEA(QBDF_VAR_DECTYPE_UNSHORT , unsigned short)
    UNADDR_READ_INDEX_CASEA(QBDF_VAR_DECTYPE_INT , int)
    UNADDR_READ_INDEX_CASEA(QBDF_VAR_DECTYPE_UNINT , unsigned int)
    UNADDR_READ_INDEX_CASEA(QBDF_VAR_DECTYPE_LONG , long)
    UNADDR_READ_INDEX_CASEA(QBDF_VAR_DECTYPE_UNLONG , unsigned long)
    UNADDR_READ_INDEX_CASEA(QBDF_VAR_DECTYPE_LONGLONG ,long long)
    UNADDR_READ_INDEX_CASEA(QBDF_VAR_DECTYPE_UNLONGLONG ,unsigned long long)
    UNADDR_READ_INDEX_CASEA(QBDF_VAR_DECTYPE_FLOAT ,float)
    UNADDR_READ_INDEX_CASEA(QBDF_VAR_DECTYPE_DOUBLE ,double)
    UNADDR_READ_INDEX_CASEA(QBDF_VAR_DECTYPE_BOOL ,BOOL)
    UNADDR_READ_INDEX_CASEA(QBDF_VAR_DECTYPE_NSINTEGER ,NSInteger)
    UNADDR_READ_INDEX_CASEA(QBDF_VAR_DECTYPE_NSUINTEGER ,NSUInteger)
    UNADDR_READ_INDEX_CASEB(QBDF_VAR_DECTYPE_CGSIZE ,CGSize, valueWithCGSize)
    UNADDR_READ_INDEX_CASEB(QBDF_VAR_DECTYPE_CGPOINT ,CGPoint, valueWithCGPoint)
    UNADDR_READ_INDEX_CASEB(QBDF_VAR_DECTYPE_CGRECT ,CGRect, valueWithCGRect)
    UNADDR_READ_INDEX_CASEB(QBDF_VAR_DECTYPE_NSRANGE ,NSRange, valueWithRange)
    UNADDR_READ_INDEX_CASEB(QBDF_VAR_DECTYPE_UIEDEGEINSETS ,UIEdgeInsets,valueWithUIEdgeInsets)
#if CGFLOAT_IS_DOUBLE
    UNADDR_READ_INDEX_CASEA(QBDF_VAR_DECTYPE_CGFLOAT ,double)
#else
    UNADDR_READ_INDEX_CASEA(QBDF_VAR_DECTYPE_CGFLOAT ,float)
#endif
    else if([QBDF_VAR_DECTYPE_VOID isEqualToString:subTpe])
        
    {
        int *p = (int *)ptr;
        return @(*(p+index));
    }else if([QBDF_VAR_DECTYPE_POINT isEqualToString:subTpe])
    {
        void **newptr = (void **)ptr;
        return [NSValue valueWithPointer:*(newptr + index)];
    }
    return nil;
}


+ (NSString *)typeElemenNameOfType:(NSString *)type
{
    
    #define QBDF_TYPEELEMENTNAME_CASE(typecode , realTYPE) \
    else if([type isEqualToString:typecode])    \
    {   \
        return [NSString stringWithFormat:@"%@%ld",[NSString stringWithUTF8String:@encode(realTYPE)],sizeof(realTYPE)];\
    }\

        if(0){}
        QBDF_TYPEELEMENTNAME_CASE(QBDF_VAR_DECTYPE_CHAR , char )
        QBDF_TYPEELEMENTNAME_CASE(QBDF_VAR_DECTYPE_UNCHAR , unsigned char )
        QBDF_TYPEELEMENTNAME_CASE(QBDF_VAR_DECTYPE_SHORT , short)
        QBDF_TYPEELEMENTNAME_CASE(QBDF_VAR_DECTYPE_UNSHORT , unsigned short)
        QBDF_TYPEELEMENTNAME_CASE(QBDF_VAR_DECTYPE_INT , int)
        QBDF_TYPEELEMENTNAME_CASE(QBDF_VAR_DECTYPE_UNINT , unsigned int)
        QBDF_TYPEELEMENTNAME_CASE(QBDF_VAR_DECTYPE_LONG , long)
        QBDF_TYPEELEMENTNAME_CASE(QBDF_VAR_DECTYPE_UNLONG , unsigned long)
        QBDF_TYPEELEMENTNAME_CASE(QBDF_VAR_DECTYPE_LONGLONG ,long long)
        QBDF_TYPEELEMENTNAME_CASE(QBDF_VAR_DECTYPE_UNLONGLONG ,unsigned long long)
        QBDF_TYPEELEMENTNAME_CASE(QBDF_VAR_DECTYPE_FLOAT ,float)
        QBDF_TYPEELEMENTNAME_CASE(QBDF_VAR_DECTYPE_DOUBLE ,double)
        QBDF_TYPEELEMENTNAME_CASE(QBDF_VAR_DECTYPE_BOOL ,BOOL)
        QBDF_TYPEELEMENTNAME_CASE(QBDF_VAR_DECTYPE_NSINTEGER ,NSInteger)
        QBDF_TYPEELEMENTNAME_CASE(QBDF_VAR_DECTYPE_NSUINTEGER ,NSUInteger)
        QBDF_TYPEELEMENTNAME_CASE(QBDF_VAR_DECTYPE_CGSIZE ,CGSize)
        QBDF_TYPEELEMENTNAME_CASE(QBDF_VAR_DECTYPE_CGPOINT ,CGPoint)
        QBDF_TYPEELEMENTNAME_CASE(QBDF_VAR_DECTYPE_CGRECT ,CGRect)
        QBDF_TYPEELEMENTNAME_CASE(QBDF_VAR_DECTYPE_NSRANGE ,NSRange)
        QBDF_TYPEELEMENTNAME_CASE(QBDF_VAR_DECTYPE_UIEDEGEINSETS ,UIEdgeInsets)
        QBDF_TYPEELEMENTNAME_CASE(QBDF_VAR_DECTYPE_FLOAT ,CGFloat)
        QBDF_TYPEELEMENTNAME_CASE(QBDF_VAR_DECTYPE_ID, id)
        QBDF_TYPEELEMENTNAME_CASE(QBDF_VAR_DECTYPE_SEL, SEL)
        QBDF_TYPEELEMENTNAME_CASE(QBDF_VAR_DECTYPE_POINT, void *)
        else{
            return [NSString stringWithFormat:@"%@%ld",[NSString stringWithUTF8String:@encode(id)],sizeof(id)];
        }
}
+ (NSString *)typeElemenNameWithoutLengthOfType:(NSString *)type
{
    
    #define QBDF_TYPEELEMENTNAME_CASEB(typecode , realTYPE) \
    else if([type isEqualToString:typecode])    \
    {   \
    return [NSString stringWithFormat:@"%@",[NSString stringWithUTF8String:@encode(realTYPE)]];\
    }\

    if(0){}
    QBDF_TYPEELEMENTNAME_CASEB(QBDF_VAR_DECTYPE_CHAR , char )
    QBDF_TYPEELEMENTNAME_CASEB(QBDF_VAR_DECTYPE_UNCHAR , unsigned char )
    QBDF_TYPEELEMENTNAME_CASEB(QBDF_VAR_DECTYPE_SHORT , short)
    QBDF_TYPEELEMENTNAME_CASEB(QBDF_VAR_DECTYPE_UNSHORT , unsigned short)
    QBDF_TYPEELEMENTNAME_CASEB(QBDF_VAR_DECTYPE_INT , int)
    QBDF_TYPEELEMENTNAME_CASEB(QBDF_VAR_DECTYPE_UNINT , unsigned int)
    QBDF_TYPEELEMENTNAME_CASEB(QBDF_VAR_DECTYPE_LONG , long)
    QBDF_TYPEELEMENTNAME_CASEB(QBDF_VAR_DECTYPE_UNLONG , unsigned long)
    QBDF_TYPEELEMENTNAME_CASEB(QBDF_VAR_DECTYPE_LONGLONG ,long long)
    QBDF_TYPEELEMENTNAME_CASEB(QBDF_VAR_DECTYPE_UNLONGLONG ,unsigned long long)
    QBDF_TYPEELEMENTNAME_CASEB(QBDF_VAR_DECTYPE_FLOAT ,float)
    QBDF_TYPEELEMENTNAME_CASEB(QBDF_VAR_DECTYPE_DOUBLE ,double)
    QBDF_TYPEELEMENTNAME_CASEB(QBDF_VAR_DECTYPE_BOOL ,BOOL)
    QBDF_TYPEELEMENTNAME_CASEB(QBDF_VAR_DECTYPE_NSINTEGER ,NSInteger)
    QBDF_TYPEELEMENTNAME_CASEB(QBDF_VAR_DECTYPE_NSUINTEGER ,NSUInteger)
    QBDF_TYPEELEMENTNAME_CASEB(QBDF_VAR_DECTYPE_CGSIZE ,CGSize)
    QBDF_TYPEELEMENTNAME_CASEB(QBDF_VAR_DECTYPE_CGPOINT ,CGPoint)
    QBDF_TYPEELEMENTNAME_CASEB(QBDF_VAR_DECTYPE_CGRECT ,CGRect)
    QBDF_TYPEELEMENTNAME_CASEB(QBDF_VAR_DECTYPE_NSRANGE ,NSRange)
    QBDF_TYPEELEMENTNAME_CASEB(QBDF_VAR_DECTYPE_UIEDEGEINSETS ,UIEdgeInsets)
    QBDF_TYPEELEMENTNAME_CASEB(QBDF_VAR_DECTYPE_FLOAT ,CGFloat)
    QBDF_TYPEELEMENTNAME_CASEB(QBDF_VAR_DECTYPE_ID, id)
    QBDF_TYPEELEMENTNAME_CASEB(QBDF_VAR_DECTYPE_SEL, SEL)
    QBDF_TYPEELEMENTNAME_CASEB(QBDF_VAR_DECTYPE_POINT, void *)
    else{
        return [NSString stringWithFormat:@"%@",[NSString stringWithUTF8String:@encode(id)]];
    }
}

+ (NSDictionary *)typeSizeDict
{
    static NSMutableDictionary *theDict = nil;
    
    if(!theDict)
    {
        theDict = [NSMutableDictionary new];
#define STRUCT_ELEMENT_TYPE(type,realType)  \
theDict[type] = @(sizeof(realType));
        
        STRUCT_ELEMENT_TYPE(QBDF_VAR_DECTYPE_CHAR,char)
        STRUCT_ELEMENT_TYPE(QBDF_VAR_DECTYPE_UNCHAR,unsigned char)
        STRUCT_ELEMENT_TYPE(QBDF_VAR_DECTYPE_SHORT,short)
        STRUCT_ELEMENT_TYPE(QBDF_VAR_DECTYPE_UNSHORT,unsigned short)
        STRUCT_ELEMENT_TYPE(QBDF_VAR_DECTYPE_INT,int)
        STRUCT_ELEMENT_TYPE(QBDF_VAR_DECTYPE_UNINT,unsigned int)
        STRUCT_ELEMENT_TYPE(QBDF_VAR_DECTYPE_LONG,long)
        STRUCT_ELEMENT_TYPE(QBDF_VAR_DECTYPE_UNLONG,unsigned long)
        STRUCT_ELEMENT_TYPE(QBDF_VAR_DECTYPE_LONGLONG,long long)
        STRUCT_ELEMENT_TYPE(QBDF_VAR_DECTYPE_UNLONGLONG,unsigned long long)
        STRUCT_ELEMENT_TYPE(QBDF_VAR_DECTYPE_FLOAT,float)
        STRUCT_ELEMENT_TYPE(QBDF_VAR_DECTYPE_DOUBLE,double)
        STRUCT_ELEMENT_TYPE(QBDF_VAR_DECTYPE_BOOL,BOOL)
        STRUCT_ELEMENT_TYPE(QBDF_VAR_DECTYPE_NSINTEGER,NSInteger)
        STRUCT_ELEMENT_TYPE(QBDF_VAR_DECTYPE_NSUINTEGER,NSUInteger)
        STRUCT_ELEMENT_TYPE(QBDF_VAR_DECTYPE_CGFLOAT,CGFloat)
        
        STRUCT_ELEMENT_TYPE(QBDF_VAR_DECTYPE_ID,id)
        STRUCT_ELEMENT_TYPE(QBDF_VAR_DECTYPE_CGSIZE,CGSize)
        STRUCT_ELEMENT_TYPE(QBDF_VAR_DECTYPE_CGPOINT,CGPoint)
        STRUCT_ELEMENT_TYPE(QBDF_VAR_DECTYPE_CGRECT,CGRect)
        STRUCT_ELEMENT_TYPE(QBDF_VAR_DECTYPE_NSRANGE,NSRange)
        STRUCT_ELEMENT_TYPE(QBDF_VAR_DECTYPE_UIEDEGEINSETS,UIEdgeInsets)
        STRUCT_ELEMENT_TYPE(QBDF_VAR_DECTYPE_SEL,SEL)
        STRUCT_ELEMENT_TYPE(QBDF_VAR_DECTYPE_POINT,void *)
        
    }
    
    return theDict;
}


+ (int)sizeofTypeWithTypeCode:(NSString *)code
{
    NSDictionary *sizeDict =[QBDFVarTypeHelper typeSizeDict];
    return [sizeDict[code]  intValue];
}




//https://en.wikipedia.org/wiki/Data_structure_alignment#x86
+ (int)specialOffSetValue:(NSString *)type
{
    
    static NSDictionary *area32 =nil;
    static NSDictionary *area64 =nil;
    if(sizeof(CGSize) == 8) //32
    {
        if(!area32)
        {
            area32 = @{
                       @"char":@(1),
                       @"unsignedchar":@(1),
                       @"short":@(2),
                       @"unsignedshort":@(2),
                       @"BOOL":@(sizeof(BOOL)),
                       };
        }
        if(area32[type])
        {
            return [area32[type] intValue];
        }else{
            return 4;
        }
        
    }else{
        if(!area64)
        {
            area64 = @{
                       @"char":@(1),
                       @"unsignedchar":@(1),
                       @"short":@(2),
                       @"unsignedshort":@(2),
                       @"long":@(2),
                       @"longlong":@(2),
                       @"double":@(2),
                       };
        }
        if(area64[type])
        {
            return [area64[type] intValue];
        }else
        {
            NSDictionary *sizeDict = [[self class] typeSizeDict];;
            if([type isEqualToString:@"CGSize"]
               || [type isEqualToString:@"CGPoint"]
               || [type isEqualToString:@"CGRect"]
               || [type isEqualToString:@"UIEdgeInsets"]
               
               )
            {
                return sizeof(CGFloat);
            }else if([type isEqualToString:@"NSRange"])
            {
                return sizeof(NSUInteger);
            }else
            {
                int value = [sizeDict[type] intValue];;
                if(value == 0)
                {
                    value = 8;
                }
                return value;
            }
        }
    }
}

+ (id)defaultValueOfType:(NSString *)thetype
{
#define STRUCT_ARG_DEFAULTCASE(type,defaultvalue)\
else if([thetype isEqualToString:type])    \
{   \
return defaultvalue;\
}
    if(0){}
    STRUCT_ARG_DEFAULTCASE(QBDF_VAR_DECTYPE_CHAR,@(0))
    STRUCT_ARG_DEFAULTCASE(QBDF_VAR_DECTYPE_UNCHAR,@(0))
    STRUCT_ARG_DEFAULTCASE(QBDF_VAR_DECTYPE_SHORT,@(0))
    STRUCT_ARG_DEFAULTCASE(QBDF_VAR_DECTYPE_UNSHORT,@(0))
    STRUCT_ARG_DEFAULTCASE(QBDF_VAR_DECTYPE_INT,@(0))
    STRUCT_ARG_DEFAULTCASE(QBDF_VAR_DECTYPE_UNINT,@(0))
    STRUCT_ARG_DEFAULTCASE(QBDF_VAR_DECTYPE_LONG,@(0))
    STRUCT_ARG_DEFAULTCASE(QBDF_VAR_DECTYPE_UNLONG,@(0))
    STRUCT_ARG_DEFAULTCASE(QBDF_VAR_DECTYPE_LONGLONG,@(0))
    STRUCT_ARG_DEFAULTCASE(QBDF_VAR_DECTYPE_UNLONGLONG,@(0))
    STRUCT_ARG_DEFAULTCASE(QBDF_VAR_DECTYPE_FLOAT,@(0))
    STRUCT_ARG_DEFAULTCASE(QBDF_VAR_DECTYPE_DOUBLE,@(0))
    STRUCT_ARG_DEFAULTCASE(QBDF_VAR_DECTYPE_BOOL,@(NO))
    STRUCT_ARG_DEFAULTCASE(QBDF_VAR_DECTYPE_NSINTEGER,@(0))
    STRUCT_ARG_DEFAULTCASE(QBDF_VAR_DECTYPE_NSUINTEGER,@(0))
    STRUCT_ARG_DEFAULTCASE(QBDF_VAR_DECTYPE_CGFLOAT,@(0))
    STRUCT_ARG_DEFAULTCASE(QBDF_VAR_DECTYPE_CGSIZE,[NSValue valueWithCGSize:CGSizeZero])
    STRUCT_ARG_DEFAULTCASE(QBDF_VAR_DECTYPE_CGPOINT,[NSValue valueWithCGPoint:CGPointZero])
    STRUCT_ARG_DEFAULTCASE(QBDF_VAR_DECTYPE_CGRECT,[NSValue valueWithCGRect:CGRectZero])
    STRUCT_ARG_DEFAULTCASE(QBDF_VAR_DECTYPE_NSRANGE,[NSValue valueWithRange:NSMakeRange(0, 0)])
    STRUCT_ARG_DEFAULTCASE(QBDF_VAR_DECTYPE_UIEDEGEINSETS,[NSValue valueWithUIEdgeInsets:UIEdgeInsetsZero])
    else if([thetype isEqualToString:QBDF_VAR_DECTYPE_ID])
    {
        return [QBDFNil new];
        
    }else if([thetype isEqualToString:QBDF_VAR_DECTYPE_SEL])
    {
        return @"";
        
    }else if([thetype isEqualToString:QBDF_VAR_DECTYPE_POINT])
    {
        return [NSValue valueWithPointer:NULL];
        
    }
    
    return [QBDFNil new];
    
}



+ (void)initffi_qbdfRange
{
    if(sizeof(NSRange) == 16)
    {
        ffi_type * *tm_type_elements = malloc(sizeof(ffi_type) *3);
        ffi_qbdfrange.size = ffi_qbdfrange.alignment = 0;
        ffi_qbdfrange.type = FFI_TYPE_STRUCT;
        ffi_qbdfrange.elements = tm_type_elements;
        tm_type_elements[0] = &ffi_type_ulong;
        tm_type_elements[1] = &ffi_type_ulong;
        tm_type_elements[2] = NULL;
        
    }else{
        ffi_type * *tm_type_elements = malloc(sizeof(ffi_type) *3);
        ffi_qbdfrange.size = ffi_qbdfrange.alignment = 0;
        ffi_qbdfrange.type = FFI_TYPE_STRUCT;
        ffi_qbdfrange.elements = tm_type_elements;
        tm_type_elements[0] = &ffi_type_uint;
        tm_type_elements[1] = &ffi_type_uint;
        tm_type_elements[2] = NULL;
    }
}

+ (void)initffi_qbdfrect
{
    if(sizeof(CGRect) == 32)
    {
        ffi_type * *tm_type_elements = malloc(sizeof(ffi_type) *5);
        ffi_qbdfrect.size = ffi_qbdfrange.alignment = 0;
        ffi_qbdfrect.type = FFI_TYPE_STRUCT;
        ffi_qbdfrect.elements = tm_type_elements;
        tm_type_elements[0] = &ffi_type_double;
        tm_type_elements[1] = &ffi_type_double;
        tm_type_elements[2] = &ffi_type_double;
        tm_type_elements[3] = &ffi_type_double;
        tm_type_elements[4] = NULL;
    }else
    {
        ffi_type * *tm_type_elements = malloc(sizeof(ffi_type) *5);
        ffi_qbdfrect.size = ffi_qbdfrange.alignment = 0;
        ffi_qbdfrect.type = FFI_TYPE_STRUCT;
        ffi_qbdfrect.elements = tm_type_elements;
        tm_type_elements[0] = &ffi_type_float;
        tm_type_elements[1] = &ffi_type_float;
        tm_type_elements[2] = &ffi_type_float;
        tm_type_elements[3] = &ffi_type_float;
        tm_type_elements[4] = NULL;
        
    }
}

+ (void)initffi_cgsizeAndcgPoint
{
    if(sizeof(CGSize) == 16)
    {
        
        ffi_type * *tm_type_elements = malloc(sizeof(ffi_type) *3);
        
        ffi_qbdfsize.size = ffi_qbdfrange.alignment = 0;
        ffi_qbdfsize.type = FFI_TYPE_STRUCT;
        ffi_qbdfsize.elements = tm_type_elements;
        
        tm_type_elements[0] = &ffi_type_double;
        tm_type_elements[1] = &ffi_type_double;
        tm_type_elements[2] = NULL;
        
        ffi_qbdfpoint.size = ffi_qbdfrange.alignment = 0;
        ffi_qbdfpoint.type = FFI_TYPE_STRUCT;
        ffi_qbdfpoint.elements = tm_type_elements;
    }else{
        
        
        ffi_type * *tm_type_elements = malloc(sizeof(ffi_type) *3);
        ffi_qbdfsize.size = ffi_qbdfrange.alignment = 0;
        ffi_qbdfsize.type = FFI_TYPE_STRUCT;
        ffi_qbdfsize.elements = tm_type_elements;
        
        tm_type_elements[0] = &ffi_type_float;
        tm_type_elements[1] = &ffi_type_float;
        tm_type_elements[2] = NULL;
        
        
        ffi_qbdfpoint.size = ffi_qbdfrange.alignment = 0;
        ffi_qbdfpoint.type = FFI_TYPE_STRUCT;
        ffi_qbdfpoint.elements = tm_type_elements;
        
    }
}


+ (void)initffi_uiedgeinsert
{
    if(sizeof(UIEdgeInsets) == 16)
    {
        ffi_type * *tm_type_elements = malloc(sizeof(ffi_type) *5);
        ffi_qbdfedgeInsert.size = ffi_qbdfrange.alignment = 0;
        ffi_qbdfedgeInsert.type = FFI_TYPE_STRUCT;
        ffi_qbdfedgeInsert.elements = tm_type_elements;
        
        tm_type_elements[0] = &ffi_type_float;
        tm_type_elements[1] = &ffi_type_float;
        tm_type_elements[2] = &ffi_type_float;
        tm_type_elements[3] = &ffi_type_float;
        tm_type_elements[4] = NULL;
    }else
    {
        ffi_type * *tm_type_elements = malloc(sizeof(ffi_type) *5);
        ffi_qbdfedgeInsert.size = ffi_qbdfrange.alignment = 0;
        ffi_qbdfedgeInsert.type = FFI_TYPE_STRUCT;
        ffi_qbdfedgeInsert.elements = tm_type_elements;
        
        tm_type_elements[0] = &ffi_type_double;
        tm_type_elements[1] = &ffi_type_double;
        tm_type_elements[2] = &ffi_type_double;
        tm_type_elements[3] = &ffi_type_double;
        tm_type_elements[4] = NULL;
        
    }
    
}


#pragma mark - class methods

+ (ffi_type *)ffiTypeWithEncodingChar:(NSString *)cStr
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [[self class] initffi_qbdfRange];
        [[self class] initffi_cgsizeAndcgPoint];
        [[self class] initffi_qbdfrect];
        [[self class]  initffi_uiedgeinsert];
        
    });
    
    if([cStr isEqualToString: [NSString stringWithUTF8String:@encode(CGSize)]])
    {
        return &ffi_qbdfsize;
    }else if([cStr isEqualToString: [NSString stringWithUTF8String:@encode(CGPoint)]])
    {
        return &ffi_qbdfpoint;
    }else if([cStr isEqualToString: [NSString stringWithUTF8String:@encode(CGRect)]])
    {
        return &ffi_qbdfrect;
    }else if([cStr isEqualToString: [NSString stringWithUTF8String:@encode(NSRange)]])
    {
        return &ffi_qbdfrange;
    }else if([cStr isEqualToString: [NSString stringWithUTF8String:@encode(UIEdgeInsets)]])
    {
        return &ffi_qbdfedgeInsert;
    }
    
    unichar thechar;
    if(cStr.length == 0)
    {
        thechar = 'v';
    }else{
        thechar =[cStr characterAtIndex:0];
        
    }
    switch (thechar) {
        case 'v':
            return &ffi_type_void;
        case 'c':
            return &ffi_type_schar;
        case 'C':
            return &ffi_type_uchar;
        case 's':
            return &ffi_type_sshort;
        case 'S':
            return &ffi_type_ushort;
        case 'i':
            return &ffi_type_sint;
        case 'I':
            return &ffi_type_uint;
        case 'l':
            return &ffi_type_slong;
        case 'L':
            return &ffi_type_ulong;
        case 'q':
            return &ffi_type_sint64;
        case 'Q':
            return &ffi_type_uint64;
        case 'f':
            return &ffi_type_float;
        case 'd':
            return &ffi_type_double;
        case 'B':
            return &ffi_type_uint8;
        case '^':
            return &ffi_type_pointer;
        case '@':
            return &ffi_type_pointer;
        case '#':
            return &ffi_type_pointer;
    }
    
    return NULL;
}


@end
