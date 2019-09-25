//
//  QBDFMethodSignature.m
//
//  Created by fatboyli on 17/5/22.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "QBDFMthdSign.h"
#import <UIKit/UIKit.h>
#import "QBDFScriptMainDefine.h"
#import "QBDFMthdSign.h"
#import "QBDFVMContext.h"
#import <UIKit/UIKit.h>
#import "QBDFOCCALLCenter.h"
#import "QBDFVarTypeHelper.h"
#import "QBDFNil.h"





@implementation QBDFMthdSign {
    NSString *_typeNames;
    NSArray  *_argumentTypes;
    NSString *_returnType;
    NSString *_types;
    
    NSString *_DEC_RetBaseType;
    NSString *_DEC_RetSUBType;
    NSArray  *_DEC_ARGSTypes;
    BOOL _isBlock;
}


- (instancetype)initWithRetBaseType:(NSString *)retBaseType retSubType:(NSString *)retSubType argtyps:(NSArray *)decArray
{
    self = [super init];
    
    if (self)
    {
        _isBlock = YES;
        _DEC_ARGSTypes = decArray;
        _DEC_RetBaseType = retBaseType;
        _DEC_RetSUBType = retSubType;
        [self initTypes];
    }
    return self;
}

- (void)initTypes
{
   
    NSMutableString *encodeStr = [NSMutableString new];
    
    NSString *returnEndoce =[QBDFVarTypeHelper typeElemenNameOfType:_DEC_RetBaseType];
    _returnType = [QBDFVarTypeHelper typeElemenNameWithoutLengthOfType:_DEC_RetBaseType]; //不用个数了
    [encodeStr appendString:returnEndoce];
    NSMutableArray *argTypes = [NSMutableArray new];
    if (_isBlock)
    {
        [encodeStr appendString:@"@?0"];
        [argTypes addObject:@"@?"];
    }

    for (NSInteger i = 0; i < _DEC_ARGSTypes.count; i++)
    {
        NSDictionary *dict = _DEC_ARGSTypes[i];
        NSString *baseTypeStr =  dict[CMD_FUN_ARG_BASETYPE];
//        NSString *SUBTypeStr =  dict[CMD_FUN_ARG_SUBTYPE];
        NSString *encode = [QBDFVarTypeHelper typeElemenNameOfType:baseTypeStr];
        [encodeStr appendString:encode];
        [argTypes addObject:[QBDFVarTypeHelper typeElemenNameWithoutLengthOfType:baseTypeStr]];
        
    }
    _types = encodeStr;
    _argumentTypes = argTypes;
}

- (NSArray *)argumentTypes
{
    return _argumentTypes;
}

 

- (NSString *)types
{
    return _types;
}

- (NSString *)returnType
{
    return _returnType;
}

@end
