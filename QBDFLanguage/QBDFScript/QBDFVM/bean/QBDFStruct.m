//
//  QBDFStruct.m
//  TestQBDFScript
//
//  Created by fatboyli on 2017/8/4.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "QBDFStruct.h"
#import "QBDFSYSCenter+QBDFStruct.h"
#import <UIKit/UIKit.h>
#import "QBDFOCCALLCenter.h"
#import "QBDFVarTypeHelper.h"
@interface QBDFStruct()
@property(nonatomic ,strong)QBDFStructDefine    *typeDefine;
@property(nonatomic ,strong)NSMutableDictionary        *ValueDict;
@end

@implementation QBDFStruct


- (instancetype)init
{
    self =  [super init];
    if(self)
    {
        self.ValueDict = [NSMutableDictionary new];
        self.typeDefine = nil;
    }
    return self;
}

- (int)memSize
{
    if(self.typeDefine)
    {
        return self.typeDefine.totalSize;
    }
    return 0;
}
- (NSString *)structName
{
    
    if(self.typeDefine)
    {
        return self.typeDefine.structName;
    }
    return @"UNKNOW";
}
- (id)readProperty:(NSString *)key
{
    return self.ValueDict[key];
}

- (void)setProperty:(NSString *)key value:(NSString *)value
{
    if(!key)
    {
        return;
    }
    if(value)
    {
        self.ValueDict[key] = value;
    }else
    {
        NSString *types = [self getTypeOfElelementName:key];
        id defaultValue = [QBDFVarTypeHelper defaultValueOfType:types];
        self.ValueDict[key] = defaultValue;

    }
}

- (NSString *)getTypeOfElelementName:(NSString *)name
{
    for(int i = 0 ;i < [self.typeDefine.elements count]; i ++)
    {
        NSDictionary *dict = self.typeDefine.elements[i];
        if([dict[STRUCT_KEY_ELEMENTNAME] isEqualToString:name])
        {
            return dict[STRUCT_KEY_ELEMENT_BASE_TYPE];
        }
    }
    return nil;
}

+ (void)updatePropertyWithMutableDict:(NSMutableDictionary *)muteDict type:(NSString *)thetype name:(NSString *)name value:(id)obj
{
    #define STRUCT_ARG_CASE(type,theSEL)\
    else if([thetype isEqualToString:type])    \
    {   \
        if([obj respondsToSelector:@selector(theSEL)]) \
        {\
            [muteDict setObject:obj forKey:name];    \
        }else \
        {\
            __QBDF_ERROR__([ NSString stringWithFormat:@"struct: 参数错误%@", name]); \
            id defaultOBJ = [QBDFVarTypeHelper defaultValueOfType:thetype];  \
            [muteDict setObject:defaultOBJ forKey:name];    \
        }   \
    }\

    
    if(0){}
    STRUCT_ARG_CASE(QBDF_VAR_DECTYPE_CHAR,charValue)
    STRUCT_ARG_CASE(QBDF_VAR_DECTYPE_UNCHAR,unsignedCharValue)
    STRUCT_ARG_CASE(QBDF_VAR_DECTYPE_SHORT,shortValue)
    STRUCT_ARG_CASE(QBDF_VAR_DECTYPE_UNSHORT,unsignedShortValue)
    STRUCT_ARG_CASE(QBDF_VAR_DECTYPE_INT,intValue)
    STRUCT_ARG_CASE(QBDF_VAR_DECTYPE_UNINT,unsignedIntValue)
    STRUCT_ARG_CASE(QBDF_VAR_DECTYPE_LONG,longValue)
    STRUCT_ARG_CASE(QBDF_VAR_DECTYPE_UNLONG,unsignedLongValue)
    STRUCT_ARG_CASE(QBDF_VAR_DECTYPE_LONGLONG,longLongValue)
    STRUCT_ARG_CASE(QBDF_VAR_DECTYPE_UNLONGLONG,unsignedLongLongValue)
    STRUCT_ARG_CASE(QBDF_VAR_DECTYPE_FLOAT,floatValue)
    STRUCT_ARG_CASE(QBDF_VAR_DECTYPE_DOUBLE,doubleValue)
    STRUCT_ARG_CASE(QBDF_VAR_DECTYPE_BOOL,boolValue)
    STRUCT_ARG_CASE(QBDF_VAR_DECTYPE_NSINTEGER,integerValue)
    STRUCT_ARG_CASE(QBDF_VAR_DECTYPE_NSUINTEGER,unsignedIntegerValue)
    STRUCT_ARG_CASE(QBDF_VAR_DECTYPE_CGSIZE,CGSizeValue)
    STRUCT_ARG_CASE(QBDF_VAR_DECTYPE_CGPOINT,CGPointValue)
    STRUCT_ARG_CASE(QBDF_VAR_DECTYPE_CGRECT,CGRectValue)
    STRUCT_ARG_CASE(QBDF_VAR_DECTYPE_NSRANGE,rangeValue)
    STRUCT_ARG_CASE(QBDF_VAR_DECTYPE_UIEDEGEINSETS,UIEdgeInsetsValue)
    #if CGFLOAT_IS_DOUBLE
    STRUCT_ARG_CASE(QBDF_VAR_DECTYPE_CGFLOAT,doubleValue)
    #else
    STRUCT_ARG_CASE(QBDF_VAR_DECTYPE_CGFLOAT,floatValue)
    #endif
    else if([thetype isEqualToString:QBDF_VAR_DECTYPE_ID])
    {
        [muteDict setObject:obj forKey:name];
    }else if([thetype isEqualToString:QBDF_VAR_DECTYPE_SEL]
             ||[thetype isEqualToString:QBDF_VAR_DECTYPE_POINT]
             )
    {
        [muteDict setObject:obj forKey:name];
    }
    return;

}



+ (instancetype)getInstanceWithDefine:(QBDFStructDefine * )define args:(NSArray *)args
{
    QBDFStruct *theres = [QBDFStruct new];
    theres.typeDefine  =  define;
    NSArray *elements = define.elements;
    NSMutableDictionary *muteDict = [NSMutableDictionary new];
    theres.ValueDict = muteDict;
    for(int i = 0 ;i < [elements  count];i ++)
    {
        NSDictionary *tmpDict = elements[i];
        NSString *thetype = tmpDict[STRUCT_KEY_ELEMENT_BASE_TYPE];
        NSString *name = tmpDict[STRUCT_KEY_ELEMENTNAME];
        
        if(i < [args count])
        {
            
            id obj = args[i];
            if(thetype)
            {
                [[self class] updatePropertyWithMutableDict:muteDict type:thetype name:name  value:obj];
            }else{
                __QBDF_ERROR__([NSString stringWithFormat:@"struct (%@) 定义种使用了不能支持的变量类型",define.structName?:@""]);
            }
            
        }else
        {
            id defaultValue = [QBDFVarTypeHelper defaultValueOfType:thetype];
            [muteDict setObject:defaultValue forKey:name];
            
        }
    }
    
    return theres;
    
}




+ (instancetype)getInstanceWithData:(void *)data theDefine:(QBDFStructDefine *)define
{
    QBDFStruct *theres = [QBDFStruct new];
    theres.typeDefine  =  define;
    NSArray *elements = define.elements;
    NSMutableDictionary *muteDict = [NSMutableDictionary new];
    for(int i = 0 ;i < [elements  count];i ++)
    {
        NSDictionary *tmpDict = elements[i];
        NSString *thetype = tmpDict[STRUCT_KEY_ELEMENT_BASE_TYPE];
        NSString *name = tmpDict[STRUCT_KEY_ELEMENTNAME];
        int offset = [tmpDict[STRUCT_KEY_ELEMENTOFFSET] intValue];
        int size = [tmpDict[STRUCT_KEY_ELEMENTSIZE] intValue];

        if(thetype)
        {
            
            #define STRUCT_READDATA_CASE(type,realType)\
            else if([thetype isEqualToString:type])    \
            {   \
                realType *val = malloc(size);   \
                memcpy(val, data + offset, size);   \
                [muteDict setObject:@(*val) forKey:name];    \
                free(val);      \
            }
            
            #define STRUCT_READDATA_CASE_B(type,realType,selector)\
            else if([thetype isEqualToString:type])    \
            {   \
            size_t size = sizeof(realType); \
            realType *val = malloc(size);   \
            memcpy(val, data + offset, size);   \
            [muteDict setObject: [NSValue selector:(*val)] forKey:name];    \
            free(val);      \
            }
           
            if(0){}
            STRUCT_READDATA_CASE(QBDF_VAR_DECTYPE_CHAR,char)
            STRUCT_READDATA_CASE(QBDF_VAR_DECTYPE_UNCHAR,unsigned char)
            STRUCT_READDATA_CASE(QBDF_VAR_DECTYPE_SHORT,short)
            STRUCT_READDATA_CASE(QBDF_VAR_DECTYPE_UNSHORT,unsigned short)
            STRUCT_READDATA_CASE(QBDF_VAR_DECTYPE_INT,int)
            STRUCT_READDATA_CASE(QBDF_VAR_DECTYPE_UNINT,unsigned int)
            STRUCT_READDATA_CASE(QBDF_VAR_DECTYPE_LONG,long)
            STRUCT_READDATA_CASE(QBDF_VAR_DECTYPE_UNLONG,unsigned long)
            STRUCT_READDATA_CASE(QBDF_VAR_DECTYPE_LONGLONG,long long)
            STRUCT_READDATA_CASE(QBDF_VAR_DECTYPE_UNLONGLONG,unsigned long long)
            STRUCT_READDATA_CASE(QBDF_VAR_DECTYPE_FLOAT,float)
            STRUCT_READDATA_CASE(QBDF_VAR_DECTYPE_DOUBLE,double)
            STRUCT_READDATA_CASE(QBDF_VAR_DECTYPE_BOOL,BOOL)
            STRUCT_READDATA_CASE(QBDF_VAR_DECTYPE_NSINTEGER,NSInteger)
            STRUCT_READDATA_CASE(QBDF_VAR_DECTYPE_NSUINTEGER,NSUInteger)
            STRUCT_READDATA_CASE(QBDF_VAR_DECTYPE_CGFLOAT,CGFloat)
            STRUCT_READDATA_CASE_B(QBDF_VAR_DECTYPE_CGSIZE,CGSize,valueWithCGSize)
            STRUCT_READDATA_CASE_B(QBDF_VAR_DECTYPE_CGPOINT,CGPoint,valueWithCGPoint)
            STRUCT_READDATA_CASE_B(QBDF_VAR_DECTYPE_CGRECT,CGRect,valueWithCGRect)
            STRUCT_READDATA_CASE_B(QBDF_VAR_DECTYPE_NSRANGE,NSRange,valueWithRange)
            STRUCT_READDATA_CASE_B(QBDF_VAR_DECTYPE_UIEDEGEINSETS,UIEdgeInsets,valueWithUIEdgeInsets)
            else if([thetype isEqualToString:QBDF_VAR_DECTYPE_ID])
            {
                size_t size = sizeof(id);
                void *val = malloc(size);
                memcpy(val, data + offset, size);
                [muteDict setObject: ((__bridge id)val) forKey:name];
                offset += size;
                break;
            }else if([thetype isEqualToString:QBDF_VAR_DECTYPE_SEL])
            {
                size_t size = sizeof(SEL);
                void *val = malloc(size);
                memcpy(val, data + offset, size);
                SEL sel = * ((SEL *)val);
                [muteDict setObject: NSStringFromSelector(sel) forKey:name];
                offset += size;
            }else if([thetype isEqualToString:QBDF_VAR_DECTYPE_POINT])
            {
                size_t size = sizeof(void *);
                void *val = malloc(size);
                memcpy(val, data + offset, size);
                void *value = * ((void * *)val);
                [muteDict setObject: [NSValue valueWithPointer:value] forKey:name];
                offset += size;
            }
            
        }else{
            __QBDF_ERROR__([NSString stringWithFormat:@"struct (%@) 定义种使用了不能支持的变量类型",define.structName?:@""]);
        }
        
    }
    
    theres.ValueDict = muteDict;
    return theres;
}

- (void)getMemStructData:(void *)data
{
    for(int i = 0 ;i < [self.typeDefine.elements  count];i ++)
    {
        NSDictionary *tmpDict = self.typeDefine.elements[i];
        NSString *thetype = tmpDict[STRUCT_KEY_ELEMENT_BASE_TYPE];
        NSString *name = tmpDict[STRUCT_KEY_ELEMENTNAME];
        int offset = [tmpDict[STRUCT_KEY_ELEMENTOFFSET] intValue];
        int size = [tmpDict[STRUCT_KEY_ELEMENTSIZE] intValue];
        id obj = self.ValueDict[name];
        
        #define STRUCT_MEM_CASE(typestr,realtype,thesel) \
        else if([thetype isEqualToString:typestr])   \
        {       \
            if([obj respondsToSelector:@selector(thesel)]){ \
                realtype val = [obj thesel];   \
                memcpy(data + offset, &val, size);  \
            }   \
        }
        
        
        if(0){}
        STRUCT_MEM_CASE(QBDF_VAR_DECTYPE_CHAR,char,charValue)
        STRUCT_MEM_CASE(QBDF_VAR_DECTYPE_UNCHAR, unsigned char,unsignedCharValue)
        STRUCT_MEM_CASE(QBDF_VAR_DECTYPE_SHORT,short,shortValue)
        STRUCT_MEM_CASE(QBDF_VAR_DECTYPE_UNSHORT, unsigned short,unsignedShortValue)
        STRUCT_MEM_CASE(QBDF_VAR_DECTYPE_INT,int,intValue)
        STRUCT_MEM_CASE(QBDF_VAR_DECTYPE_UNINT,unsigned int,unsignedIntValue)
        STRUCT_MEM_CASE(QBDF_VAR_DECTYPE_LONG,long,longValue)
        STRUCT_MEM_CASE(QBDF_VAR_DECTYPE_UNLONG,unsigned long,unsignedLongValue)
        STRUCT_MEM_CASE(QBDF_VAR_DECTYPE_LONGLONG, long long,longLongValue)
        STRUCT_MEM_CASE(QBDF_VAR_DECTYPE_UNLONGLONG, unsigned long long,unsignedLongLongValue)
        STRUCT_MEM_CASE(QBDF_VAR_DECTYPE_FLOAT,float ,floatValue)
        STRUCT_MEM_CASE(QBDF_VAR_DECTYPE_DOUBLE,double,doubleValue)
        STRUCT_MEM_CASE(QBDF_VAR_DECTYPE_BOOL,BOOL,boolValue)
        STRUCT_MEM_CASE(QBDF_VAR_DECTYPE_NSINTEGER,NSInteger,integerValue)
        STRUCT_MEM_CASE(QBDF_VAR_DECTYPE_NSUINTEGER,NSUInteger,unsignedIntegerValue)
        STRUCT_MEM_CASE(QBDF_VAR_DECTYPE_CGSIZE,CGSize,CGSizeValue)
        STRUCT_MEM_CASE(QBDF_VAR_DECTYPE_CGPOINT,CGPoint,CGPointValue)
        STRUCT_MEM_CASE(QBDF_VAR_DECTYPE_CGRECT,CGRect,CGRectValue)
        STRUCT_MEM_CASE(QBDF_VAR_DECTYPE_NSRANGE,NSRange,rangeValue)
        STRUCT_MEM_CASE(QBDF_VAR_DECTYPE_UIEDEGEINSETS,UIEdgeInsets,UIEdgeInsetsValue)
        #if CGFLOAT_IS_DOUBLE
        STRUCT_MEM_CASE(QBDF_VAR_DECTYPE_CGFLOAT,double,doubleValue)
        #else
        STRUCT_MEM_CASE(QBDF_VAR_DECTYPE_CGFLOAT,float,floatValue)
        #endif
        else if([thetype isEqualToString:QBDF_VAR_DECTYPE_ID])
        {
           
            void *val = (__bridge void *)obj;
            memcpy(data + offset, &val, size); //这里应该有一个是struct类型的处理
            
        } else if([thetype isEqualToString:QBDF_VAR_DECTYPE_POINT])
        {
            
            NSString *str = [NSString stringWithUTF8String:[obj objCType]];
            if([str hasPrefix:@"*"]
               ||[str hasPrefix:@"^"]
               )
            {
                
                void *val = [obj pointerValue];
                memcpy(data + offset, &val, size);
            }else
            {
                void *val = (__bridge void *)obj;
                memcpy(data + offset, &val, size);
            }
        }
        else{
            __QBDF_ERROR__([NSString stringWithFormat:@"struct (%@) 定义种使用了不能支持的变量类型",[self structName]?:@""]);
        }
        
    }

}
- (NSString *)description
{
    NSMutableString *str = [[NSMutableString alloc] initWithString:self.typeDefine.structName];
    [str appendString:[self.ValueDict description]];
    return str;
}

@end
