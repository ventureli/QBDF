//
//  QBDFSYSCenter+QBDFStruct.m
//  TestQBDFScript
//
//  Created by fatboyli on 2017/8/4.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "QBDFSYSCenter+QBDFStruct.h"
#import <UIKit/UIKit.h>
#import "QBDFStruct.h"
#import "QBDFVarTypeHelper.h"

@implementation QBDFStructDefine

- (void)setElements:(NSArray<NSMutableDictionary *> *)elements
{
    _elements = elements;
    [self updateSize];
}


- (void)updateSize
{
    int totalsize = 0;
    int maxSize = 0;
    NSDictionary *sizeDict =[QBDFVarTypeHelper typeSizeDict];
    for(int i = 0 ;i < [self.elements count] ;i ++)
    {
        NSMutableDictionary *dict = self.elements[i] ;
        NSString *type = [dict[STRUCT_KEY_ELEMENT_BASE_TYPE] description];
        if(type && sizeDict[type])
        {
            int size = [sizeDict[type] intValue];
            
            int specialModeSize  = [QBDFVarTypeHelper specialOffSetValue:type];
            if(specialModeSize > maxSize)
            {
                maxSize = specialModeSize;
            }
            
            if(totalsize % specialModeSize == 0)
            {
                dict[STRUCT_KEY_ELEMENTOFFSET] = @(totalsize);
                dict[STRUCT_KEY_ELEMENTSIZE] = @(size);
            }else
            {
            
                int mode = totalsize % specialModeSize;
                int space = specialModeSize - mode;
                totalsize += space;
                dict[STRUCT_KEY_ELEMENTOFFSET] = @(totalsize);
                dict[STRUCT_KEY_ELEMENTSIZE] = @(size);
            }
            totalsize += size;
            
            
        }else
        {
            __QBDF_ERROR__([NSString stringWithFormat:@"struct (%@) 定义种使用了不能支持的变量类型",self.structName?:@""]);
        }
    }
    if(maxSize > 0 &&  totalsize % maxSize != 0)
    {
        int mode = totalsize % maxSize;
        int space = maxSize - mode;
        totalsize += space;
    }
    
    self.totalSize = totalsize;
}


@end


@implementation QBDFSYSCenter (QBDFStruct)

- (void)registerStructByCmd:(NSDictionary *)cmd
{
    NSString *structName = READNODEVALUE(cmd, CMD_EXP_NODE_LEFTOPERAND);
    if(!structName || self.registerStructDict[structName]) //如果为空或者注册过来，就干掉
    {
        return;
    }
    
    NSArray *elements = READNODEVALUE(cmd, CMD_EXP_NODE_RIGHTOPERAND);
    
    NSMutableArray *newElements = [NSMutableArray new];;
    for(int i = 0 ; i < [elements count]; i ++)
    {
        NSDictionary *theDict = elements[i];
        NSString *basetype = READNODEVALUE(theDict, CMD_VARI_TYPE_SPEC);
        NSString *subtype = READNODEVALUE(theDict, CMD_VARI_DEC_SUBTYPE_SPEC);
        NSString *name = READNODEVALUE(theDict, CMD_VARI_DEC_NAME);
        if(name.length > 0 && basetype.length >0)
        {
            [newElements addObject:[@{STRUCT_KEY_ELEMENT_BASE_TYPE:basetype,STRUCT_KEY_ELEMENTNAME:name,STRUCT_KEY_ELEMENT_SUB_TYPE:subtype?:QBDF_VAR_DECTYPE_NOSUB} mutableCopy] ];
        }
    }
    
    QBDFStructDefine *define = [QBDFStructDefine new];
    define.structName = structName;
    define.elements = newElements;
    self.registerStructDict[structName] = define;
    
    
}
- (QBDFStructDefine *)readStructDefine:(NSString *)structName
{
    @synchronized (self) {
        if(self.registerStructDict[structName])
        {
            return self.registerStructDict[structName];
        }
        return nil;

    }
}

+ (NSString *)extractStructName:(NSString *)typeEncodeString
{
    NSArray *array = [typeEncodeString componentsSeparatedByString:@"="];
    NSString *typeString = array[0];
    int firstValidIndex = 0;
    for (int i = 0; i< typeString.length; i++) {
        char c = [typeString characterAtIndex:i];
        if (c == '{' || c=='_') {
            firstValidIndex++;
        }else {
            break;
        }
    }
    return [typeString substringFromIndex:firstValidIndex];
}
+ (id )getStructArgumentWithType:(const char *)theTypeStr inv:(NSInvocation *)inv index:(NSInteger) index
{
    NSString *str = [NSString stringWithUTF8String:theTypeStr];
    if(str.length == 0)
    {
        __QBDF_ERROR__(@"cannot extract Struct from ");
    }
    
    NSString *structName = [QBDFSYSCenter extractStructName:str];
    #define QBDF_INV_ARG_NORMALSTRUCT_CASE(_type, _methodName) \
    else if ([structName rangeOfString:@#_type].location != NSNotFound) {    \
    _type tempResultSet;   \
    [inv getArgument:&tempResultSet atIndex:index]; \
    return [NSValue _methodName:tempResultSet];\
    }
    if(0){}
    QBDF_INV_ARG_NORMALSTRUCT_CASE(CGRect, valueWithCGRect)
    QBDF_INV_ARG_NORMALSTRUCT_CASE(CGPoint, valueWithCGPoint)
    QBDF_INV_ARG_NORMALSTRUCT_CASE(CGSize, valueWithCGSize)
    QBDF_INV_ARG_NORMALSTRUCT_CASE(NSRange, valueWithRange)
    QBDF_INV_ARG_NORMALSTRUCT_CASE(UIEdgeInsets, valueWithUIEdgeInsets)
    else
    {
      QBDFStructDefine *define =  [[QBDFSYSCenter shareInstance] readStructDefine:structName];
      if(define)
      {
          int size = define.totalSize;
          void *ret = malloc(size);
          [inv getArgument:ret atIndex:index];
          QBDFStruct * theobj = [QBDFStruct getInstanceWithData:ret theDefine:define];
          free(ret);
          return theobj;
      }
    }
    return nil;
}

@end
