//
//  QBDFScriptInterpreter.m
//  QBDFScript
//
//  Created by fatboyli on 2017/5/14.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "QBDFScriptInterpreter.h"


#import "QBDFScriptMainDefine.h"
#import "QBDFTKProcess.h"
#import "QBDFVarTypeHelper.h"



NSDictionary                         *QBDF_OPER_DESC;

////
@interface QBDFScriptInterpreter()
{
    QBDFToken                   *_currentToken;
    QBDFToken                   *_lastToken;
    QBDFToken                   *_frontToken;
    BOOL                        _isERROR;
}
@property(nonatomic ,strong) NSMutableArray         *tokenArrays;
@property(nonatomic ,strong)NSMutableArray          *backupTokens ;
@property(nonatomic ,strong) NSMutableArray         *cmdLines ;
@end

@interface QBDFScriptInterpreter(BlkInterPreter)
- (NSArray *)QBDF_TranslateFunctionBody:(NSMutableArray *)tokens;
@end




#define SET_ERROR_YES \
_isERROR = YES;

#define IF_ERROR_RETURN_VOID \
if(_isERROR){return;}


#define IF_ERROR_RETURN_NIL \
if(_isERROR){return nil;}


#define __QBDF_INTERPRETER_ERROR( msg ) \
__QBDF_ERROR__(msg); \
SET_ERROR_YES

///////////////////////////////////////////////////////////////////////////////////////
@implementation QBDFScriptInterpreter

- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self _initOPERDESC];
        });
        
    }
    return self;
}
- (void)_initOPERDESC
{
    
#ifndef MIX_QBDF_CODE
#define OPER_DESC(type) \
@(type):@""#type
    
#else
#define OPER_DESC(type) \
@(type):@""
    
#endif
    QBDF_OPER_DESC = @{
                       
                       OPER_DESC(oper_begin),
                       //size
                       OPER_DESC(oper_plus),
                       OPER_DESC(oper_minus),
                       OPER_DESC(oper_multiply),
                       OPER_DESC(oper_divide),
                       OPER_DESC(oper_mod),
                       OPER_DESC(oper_power),
                       OPER_DESC(oper_positive),
                       OPER_DESC(oper_negative),
                       //关系
                       OPER_DESC(oper_lt),
                       OPER_DESC(oper_gt),
                       OPER_DESC(oper_eq),
                       OPER_DESC(oper_ne),
                       OPER_DESC(oper_le),
                       OPER_DESC(oper_ge),
                       OPER_DESC(oper_inc),
                       OPER_DESC(oper_Dec),
                       OPER_DESC(oper_and),
                       OPER_DESC(oper_or),
                       OPER_DESC(oper_not),
                       OPER_DESC(oper_arrow),
                       
                       //类型
                       OPER_DESC(oper_identify),
                       OPER_DESC(oper_value_string),
                       OPER_DESC(oper_value_num),
                       OPER_DESC(oper_value_double),
                       OPER_DESC(oper_assignment),
                       
                       //关键字
                       OPER_DESC(oper_kw_if),
                       OPER_DESC(oper_kw_else),
                       OPER_DESC(oper_kw_while),
                       OPER_DESC(oper_kw_for),
                       OPER_DESC(oper_kw_return),
                       OPER_DESC(oper_kw_break),
                       OPER_DESC(oper_kw_continue),
                       OPER_DESC(oper_kw_let),
                       OPER_DESC(oper_kw_struct),
                       
                       OPER_DESC(oper_kw_intface),
                       OPER_DESC(oper_kw_end),
                       OPER_DESC(oper_kw_propt),
                       OPER_DESC(oper_kw_implemt),
                       
                       
                       OPER_DESC(oper_over)
                       };
}

-(BOOL) ifmatch:(int) type
{
    if(_currentToken->tokenType == type)
    {
        [self match:type];
        return YES;
    }else{
        return NO;
    }
}

-(void) match:(int) type
{
    if([self.tokenArrays count] > 0)
    {
        QBDFToken *token = [self.tokenArrays firstObject];
        if(token->tokenType == type)
        {
            _lastToken = token;
            [self.tokenArrays removeObjectAtIndex:0];
            _currentToken = [self loadCurrenToken];
            if([self.tokenArrays count] > 1)
            {
                _frontToken = self.tokenArrays[1];
            }
            
        }else
        {
            __QBDF_INTERPRETER_ERROR(([NSString stringWithFormat:@"TokenType is not match:expect %ld[%@] <---> get:%ld[%@]",(long)type,QBDF_OPER_DESC[@(type)],(long)token->tokenType,QBDF_OPER_DESC[@((long)token->tokenType)?:@"UNKNOW"]]));
    
        }
    }else{
            __QBDF_INTERPRETER_ERROR(@"need token tyoen");
        
    }
}


- (void)addCMD:(NSMutableDictionary *)dict
{
    dict[CMD_LINE] =@([self.cmdLines count]);
    [self.cmdLines addObject:dict];
}


-(QBDFToken *)loadCurrenToken
{
    if([self.tokenArrays count] >0)
    {
        QBDFToken *token = [self.tokenArrays firstObject];
        return token;
    }else{
        return nil;
    }
}

-(NSString*)dataTojsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

#pragma mark -vardec




- (BOOL)_isCurrentTokenVarDec
{
    if(_currentToken->tokenType != oper_identify)
    {
        if(_currentToken->tokenType == oper_kw_struct) //说明是一个struct ，struct，有可能是struct定义，还有可能是struct变量声明
        {
            if([self.tokenArrays count] >= 3)
            {
                QBDFToken *nextNextToken = self.tokenArrays[2];
                if(nextNextToken->tokenType == oper_identify || nextNextToken->tokenType == oper_multiply) //identify 是变量声明，如果是'{' 那么就是struct定义
                {
                    return YES;
                }else{
                    return NO;
                }
            }else
            {
                return NO;
            }
        }else{
            return NO;
        }
    }else
    {
        BOOL isBaseType =  [QBDFVarTypeHelper isVarDefineTokenName:_currentToken->tokenName];
        if(isBaseType)
        {
            return YES;
        }else
        {
            //当前这个是identify ，下一个是* 下一个是* 在下一个是identify ，在下一个是，；
            if([self.tokenArrays count] > 4)
            {
                QBDFToken *nextOneToken = self.tokenArrays[1];
                QBDFToken *nextTwoToken = self.tokenArrays[2];
                QBDFToken *nextThreeToken = self.tokenArrays[3];
                if(nextOneToken->tokenType == oper_multiply) //如果当前的是UIView *这种
                {
                    if(nextTwoToken->tokenType == oper_multiply)//UIView **
                    {
                        return YES;
                    }else if(nextTwoToken->tokenType == oper_identify) //UIView *theView;
                    {
                        if(nextThreeToken->tokenType == ',' || nextThreeToken->tokenType == ';' || nextThreeToken->tokenType == oper_assignment)
                        {
                            return YES;
                        }
                    }else
                    {
                        return NO;
                    }
                }else
                {
                    return NO;
                }
            }
            
            
            return NO;
        }
    }
 
}

//变量或者类声明

- (void) _QBDF_DELC
{
 
    NSString *baseType = @"";
    NSString *subType = @"";
    NSDictionary *dict = [self _getVarTypeFromCurrentToken];
    baseType = dict[CMD_VARI_TYPE_SPEC];
    subType = dict[CMD_VARI_DEC_SUBTYPE_SPEC];
    if(!baseType || baseType.length ==0)
    {
        __QBDF_INTERPRETER_ERROR(([NSString stringWithFormat:@"%@ 变量类型不支持 在%@行",_currentToken->tokenName,@(_currentToken->lineNumber)]));
        IF_ERROR_RETURN_VOID
    }
    BOOL isFUN = NO;
    while(_currentToken->tokenType != ';')
    {
        
            if(_currentToken->tokenType == '(')
            {
                isFUN = YES;
                [self _QBDF_FUNDELCWITHRETTYPE:baseType subType:subType];
                break; //函数定义不支持一次定义多个
                
            }else
            {
                NSMutableDictionary *cmddict = [NSMutableDictionary new];
                cmddict[CMD_TYEP] = CMD_TYPE_VARDEF;
                cmddict[CMD_VARI_TYPE_SPEC] = baseType;
                cmddict[CMD_VARI_DEC_SUBTYPE_SPEC] = subType;

                if(_currentToken->tokenType != oper_identify)
                {
                    __QBDF_INTERPRETER_ERROR(([NSString stringWithFormat:@"变量声明需要 标识符，在%ld行",(long)_currentToken->lineNumber]));
                    IF_ERROR_RETURN_VOID
                }
                cmddict[CMD_VARI_DEC_NAME] = _currentToken->tokenName;
                [self addCMD:cmddict];
                if(_frontToken->tokenType == oper_assignment)
                {
                    [self _QBDF_EXP];
                }else
                {
                    [self match:oper_identify];
                }
                if(_currentToken->tokenType == ',')
                {
                    [self match:','];
                }
            }
    }
    if(isFUN)
    {
        [self ifmatch:';'];
    }else{
        [self match:';'];

    }
}

- (void)_QBDF_STRUCTDEC
{
    [self match:oper_kw_struct];
    if(_currentToken->tokenType == oper_identify)
    {
        NSString *structName = _currentToken->tokenName;
        [self match:oper_identify];
        [self match:'{'];
        NSMutableArray *elements = [NSMutableArray new];
        while (_currentToken->tokenType != '}')
        {
            
            NSDictionary *dict = [self _getVarTypeFromCurrentToken];
            
            
            NSString *elementName = _currentToken->tokenName;
            [self match:_currentToken->tokenType];
            [self match:';'];
            NSMutableDictionary *muteDict = [NSMutableDictionary new];
            muteDict[CMD_VARI_TYPE_SPEC] = dict[CMD_VARI_TYPE_SPEC];
            muteDict[CMD_VARI_DEC_SUBTYPE_SPEC] = dict[CMD_VARI_DEC_SUBTYPE_SPEC];
            muteDict[CMD_VARI_DEC_NAME] = elementName;
            [elements addObject:muteDict];
            if(_isERROR)
            {
                return;
            }
        }
        [self match:'}'];
        
        
        NSMutableDictionary *rootDict = [NSMutableDictionary new];
        rootDict[CMD_TYEP] = CMD_TYPE_STUCTDEC;
        rootDict[CMD_EXP_NODE_LEFTOPERAND] = structName;
        rootDict[CMD_EXP_NODE_RIGHTOPERAND] = elements;
        [self addCMD:rootDict];
        
    }else
    {
        __QBDF_INTERPRETER_ERROR(([NSString stringWithFormat:@"在%@行 定义struct 失败",@(_currentToken->lineNumber)]));
        IF_ERROR_RETURN_VOID
    }
}

- (void)_QBDF_FUNDELCWITHRETTYPE:(id)retBaseType subType:(id)retsubType
{
    [self match:'('];
    if(_currentToken->tokenType == '^') //block
    {
        
        [self match:'^'];
        if(_currentToken->tokenType != oper_identify)
        {
            __QBDF_INTERPRETER_ERROR(([NSString stringWithFormat:@"block 定义错误，未找到block 名字，在%ld行",(long)_currentToken->lineNumber]));
            IF_ERROR_RETURN_VOID
            
        }
        NSString *blockName = _currentToken->tokenName;
        [self match:oper_identify];
        [self match:')'];
        NSArray *parms = [self _QBDF_FUN_PARMS];
        NSArray *codes = [self _QBDF_FUN_BODY];
        NSDictionary *retTypes = @{CMD_FUN_RET_BASETYPE:retBaseType,CMD_FUN_RET_SUBTYPE:retsubType};
        NSMutableDictionary *cmd = [self _createBlockDelcNode:blockName params:parms codes:codes ret:retTypes];
        [self addCMD:cmd];
        
    }else
    {
        __QBDF_INTERPRETER_ERROR(([NSString stringWithFormat:@"暂不支持除了block外其他的函数定义方式，在%ld行",(long)_currentToken->lineNumber]));
        IF_ERROR_RETURN_VOID
        return;
        
    }
}

- (NSMutableDictionary *)_createBlockDelcNode:(NSString *)name params:(NSArray *)params codes:(NSArray *)codes ret:(NSDictionary *)ret
{
    NSMutableDictionary *newRootNode = [NSMutableDictionary new];
    newRootNode[CMD_TYEP] = CMD_TYPE_BLKDEC;
    newRootNode[CMD_FUN_ARG] = params?:@[];
    newRootNode[CMD_FUN_NAME] = name;
    newRootNode[CMD_FUN_CMD] = codes?:@[];
    newRootNode[CMD_FUN_RET] = ret?:@{};

    return newRootNode;
    
}


- (NSArray *)_QBDF_FUN_BODY
{
    NSArray *resCodes;
    
    //新建一个新的，开始解释这里的内容
    QBDFScriptInterpreter *subInterPreter = [QBDFScriptInterpreter new];
    resCodes = [subInterPreter QBDF_TranslateFunctionBody:self.tokenArrays];
    _currentToken = subInterPreter->_currentToken;
    _frontToken = subInterPreter->_frontToken;
    _lastToken = subInterPreter->_lastToken;
    return resCodes;
}



- (NSArray *)_QBDF_FUN_PARMS
{
    [self match:'('];

    int params;
    params = 0;
    NSMutableArray *parmsArray = [NSMutableArray new];
    while (_currentToken->tokenType != ')') {
        
        NSMutableDictionary *typeDict = [self _getVarTypeFromCurrentToken];
        if (_isERROR)
        {
            return nil;
        }
        NSString *baseType = typeDict[CMD_VARI_TYPE_SPEC];
        NSString *subType  = typeDict[CMD_VARI_DEC_SUBTYPE_SPEC];;
        
        if (_currentToken->tokenType != oper_identify)
        {
            __QBDF_INTERPRETER_ERROR(([NSString stringWithFormat:@"block/函数 参数解析失败,在%ld行",(long)_currentToken->lineNumber]));
            IF_ERROR_RETURN_NIL
        }
        
        NSString *parName = _currentToken->tokenName;
        NSMutableDictionary *mutableDict = [NSMutableDictionary new];
        mutableDict[CMD_FUN_ARG_BASETYPE] = baseType;
        mutableDict[CMD_FUN_ARG_SUBTYPE] = subType;
        mutableDict[CMD_FUN_ARG_NAME] = parName;
        [parmsArray addObject:mutableDict];
        [self match:oper_identify];
        if (_currentToken->tokenType == ',') {
            [self match:','];
        }
    }
    [self match:')']; //开始处理这个
    return parmsArray;
}

#pragma mark -expression

- (void) _QBDF_EXP
{
    
    NSDictionary *dict = [self _QBDF_EXP_IMP];
    //这里进行逆波兰表达式的转换
    if(dict)
    {
        
        NSMutableDictionary *mutableDict = [NSMutableDictionary new];
        mutableDict[CMD_TYEP] = CMD_TYPE_EXP;
        mutableDict[CMD_EXP_TREE] = dict;
        [self addCMD:mutableDict];
        
    }
}

- (NSMutableDictionary *)_QBDF_EXP_RETCODE
{
    NSDictionary *dict = [self _QBDF_EXP_IMP];
    //这里进行逆波兰表达式的转换
    if(dict)
    {
        
        NSMutableDictionary *mutableDict = [NSMutableDictionary new];
        mutableDict[CMD_TYEP] = CMD_TYPE_EXP;
        mutableDict[CMD_EXP_TREE] = dict;
        return mutableDict;
        
    }
    return nil;
}
- (NSDictionary *)_QBDF_EXP_IMP
{
    if(_currentToken->tokenType == ';')
    {
        [self match:';'];
        return nil;
    }else{
        return [self _QBDF_EXP_Assign];
    }
    return nil;
}

- (NSDictionary *)_QBDF_EXP_Assign
{
    NSDictionary *leftNode = [self _QBDF_EXP_Conditional];
    if(_currentToken->tokenType == oper_assignment) //赋值语句只支持 ‘=’ 暂不支持 += -+ *= /= %= ...
    {
        int type = _currentToken->tokenType;
        [self match:type];
        NSDictionary *rightDict = [self _QBDF_EXP_Assign];
        NSMutableDictionary *newRootNode = [self _createEXPOperatorNode:type left:leftNode right:rightDict thridNode:nil];
 
        return newRootNode;
        
    }else  //要不把他放这里 //要不就放在post
    {
        return leftNode;
    }
}

- (NSDictionary *)_QBDF_EXP_Conditional
{
    NSDictionary *leftNode = [self _QBDF_EXP_LOGIC_OR];
    if(_currentToken->tokenType == '?')
    {
        
        int type = _currentToken->tokenType;
        [self match:'?'];
        NSDictionary *firstNode = [self _QBDF_EXP_Assign];
        if(_currentToken->tokenType != ':') //error
        {
            __QBDF_INTERPRETER_ERROR(([NSString stringWithFormat:@"ERROR 在三目表达式中缺少:符号,在%ld行",(long)_currentToken->lineNumber]));
            IF_ERROR_RETURN_NIL
        }
        [self match:':'];
        NSDictionary *secodeNode = [self _QBDF_EXP_Assign];
        NSMutableDictionary *newRootNode = [self _createEXPOperatorNode:type left:leftNode right:firstNode thridNode:secodeNode];
        return newRootNode;
        
    }else{
        return leftNode;
    }
}

- (NSDictionary *)_QBDF_EXP_LOGIC_OR
{
    NSDictionary *leftNode = [self _QBDF_EXP_LOGIC_AND];
    if(_currentToken->tokenType == oper_or)
    {
        
        int type = _currentToken->tokenType;
        [self match:oper_or];
        NSDictionary *rightNode = [self _QBDF_EXP_LOGIC_AND];
        
        NSMutableArray *operands = [NSMutableArray new];
        [operands addObject:leftNode];
        [operands addObject:rightNode];
        
        NSMutableDictionary *newRootNode = [self _createEXPOperatorNode:type left:operands right:nil thridNode:nil];
        while(_currentToken->tokenType == oper_or)
        {
            [self match:oper_or];
            NSDictionary *newNode = [self _QBDF_EXP_LOGIC_AND];
            [operands addObject:newNode];
        }
        return newRootNode;
    }else
    {
        return leftNode;
    }
}
- (NSDictionary *)_QBDF_EXP_LOGIC_AND
{
   NSDictionary *leftNode = [self _QBDF_EXP_INCLUSIVE_OR];
    if(_currentToken->tokenType == oper_and)
    {
        int type = _currentToken->tokenType;
        [self match:oper_and];
        NSDictionary *rightNode = [self _QBDF_EXP_INCLUSIVE_OR];
       
        NSMutableArray *operands = [NSMutableArray new];
        [operands addObject:leftNode];
        [operands addObject:rightNode];
        
        NSMutableDictionary *newRootNode = [self _createEXPOperatorNode:type left:operands right:nil thridNode:nil];
        while (_currentToken->tokenType == oper_and)
        {
            [self match:oper_and];
            NSDictionary *newnode = [self _QBDF_EXP_INCLUSIVE_OR];
            [operands addObject:newnode];
        }
        return newRootNode;
        
    }
    else
    {
        return leftNode;
    }
}
- (NSDictionary *)_QBDF_EXP_INCLUSIVE_OR //|
{
    NSDictionary *leftNode = [self _QBDF_EXP_EXCLUSIVE_OR];
    if(_currentToken->tokenType == '|'  ///  ==
       )
    {
        
        int type = _currentToken->tokenType;
        [self match:'|'];
        NSDictionary *rightNode = [self _QBDF_EXP_EXCLUSIVE_OR];
        
        NSMutableArray *operands = [NSMutableArray new];
        [operands addObject:leftNode];
        [operands addObject:rightNode];
        
        while (_currentToken->tokenType == '|')
        {
            [self match:'|'];
            NSDictionary *newnode = [self _QBDF_EXP_EXCLUSIVE_OR];
            [operands addObject:newnode];
        }
        NSMutableDictionary *newRootNode = [self _createEXPOperatorNode:type left:operands right:nil thridNode:nil];
        return newRootNode;
    }else
    {
        return leftNode;
    }
}

- (NSDictionary *)_QBDF_EXP_EXCLUSIVE_OR //^
{
    NSDictionary *leftNode = [self _QBDF_EXP_AND];
    if(_currentToken->tokenType == '^'  ///  ==
       )
    {
        int type = _currentToken->tokenType;
        [self match:'^'];
        NSDictionary *rightNode = [self _QBDF_EXP_AND];
        
        NSMutableArray *operands = [NSMutableArray new];
        [operands addObject:leftNode];
        [operands addObject:rightNode];
        
        while (_currentToken->tokenType == '^')
        {
            [self match:'^'];
            NSDictionary *newnode = [self _QBDF_EXP_AND];
            [operands addObject:newnode];
        }
        NSMutableDictionary *newRootNode = [self _createEXPOperatorNode:type left:operands right:nil thridNode:nil];
        return newRootNode;
        
    }else
    {
        return leftNode;
    }
}
- (NSDictionary *)_QBDF_EXP_AND //^
{
    NSDictionary *leftNode = [self _QBDF_EXP_Equality];
    if(_currentToken->tokenType == '&'  ///  ==
       )
    {
        int type = _currentToken->tokenType;
        [self match:'&'];
        NSDictionary *rightNode = [self _QBDF_EXP_Equality];
        
        NSMutableArray *operands = [NSMutableArray new];
        [operands addObject:leftNode];
        [operands addObject:rightNode];
        
        while (_currentToken->tokenType == '&')
        {
            [self match:'&'];
            NSDictionary *newnode = [self _QBDF_EXP_Equality];
            [operands addObject:newnode];
        }
        NSMutableDictionary *newRootNode = [self _createEXPOperatorNode:type left:operands right:nil thridNode:nil];
        return newRootNode;
        
    }else
    {
        return leftNode;
    }
}




- (NSDictionary *)_QBDF_EXP_Equality
{
    NSDictionary *leftNode = [self _QBDF_EXP_Relationl];
    if(_currentToken->tokenType == oper_eq  ///  ==
      ||_currentToken->tokenType == oper_ne ///  !=
     )
    {
        int type = _currentToken->tokenType;
        [self match:_currentToken->tokenType];
        NSDictionary *rightNode = [self _QBDF_EXP_Relationl];
        NSMutableDictionary *newRootNode = [self _createEXPOperatorNode:type left:leftNode right:rightNode thridNode:nil];
        return newRootNode;
        
    }else
    {
        return leftNode;
    }
}

- (NSDictionary *)_QBDF_EXP_Relationl
{
   NSDictionary *leftNode =  [self _QBDF_EXP_AddAtive];
    if(_currentToken->tokenType == oper_le
       ||_currentToken->tokenType == oper_lt
       ||_currentToken->tokenType == oper_ge
       ||_currentToken->tokenType == oper_gt
       
      )
    {
        int type = _currentToken->tokenType;
        [self match:_currentToken->tokenType];
        NSDictionary *rightNode = [self _QBDF_EXP_AddAtive];
        NSMutableDictionary *newRootNode = [self _createEXPOperatorNode:type left:leftNode right:rightNode thridNode:nil];
        return newRootNode;
    }else
    {
        return leftNode;
    }
}

- (NSDictionary *)_QBDF_EXP_AddAtive //+ -
{
   NSDictionary *leftNode =  [self _QBDF_EXP_Mulitiplicative];
   while( _currentToken->tokenType == oper_plus
      ||_currentToken->tokenType == oper_minus
      )
   {
       int type = _currentToken->tokenType;
       
       [self match:_currentToken->tokenType];
       NSDictionary *rightNode = [self _QBDF_EXP_Mulitiplicative];
       NSMutableDictionary *newRootNode = [self _createEXPOperatorNode:type left:leftNode right:rightNode thridNode:nil];
       leftNode = newRootNode;
       
   }
   return leftNode;
   
}

- (NSDictionary *)_QBDF_EXP_Mulitiplicative //* / %
{
    NSDictionary *leftNode =[self _QBDF_EXP_Unary];
    while(_currentToken->tokenType == oper_multiply
       || _currentToken->tokenType == oper_divide
       || _currentToken->tokenType == oper_mod
      )
    {
        int type = _currentToken->tokenType;
        [self match:_currentToken->tokenType];
        NSDictionary *rightNode = [self _QBDF_EXP_Unary];
        NSMutableDictionary *newRootNode = [self _createEXPOperatorNode:type left:leftNode right:rightNode thridNode:nil];
        leftNode =  newRootNode;
    }
    return leftNode;
    
    
}

- (NSDictionary *)_QBDF_EXP_Unary
{
    //前缀单目操作符
    if(
       _currentToken->tokenType == oper_multiply        //* 取值
       || _currentToken->tokenType == '&'               //* 取地址
       ||   _currentToken->tokenType == '!'             //*  单目操作符目前支持 * ,& ,!
      )
    {
        int type = _currentToken->tokenType;
        if(type == oper_multiply)
        {
            type = oper_unaddr;
        }else if(type == '&')
        {
            type = oper_addr;
        }
        [self match:_currentToken->tokenType];
        NSDictionary *left = [self _QBDF_EXP_Unary];
        NSMutableDictionary *newRootNode =[self _createEXPOperatorNode:type left:left right:nil thridNode:nil];
        return newRootNode;
        
    }else //这里应该是一个
    {
       return [self _QBDF_EXP_Postfix];
    }
    return nil;
}


/*
 postfix-expression:
	(identifier | constant | string | "(" expression ")" | [identify OCArglist] 
 "[" expression "]"             |
 "(" assignment-expression% ")" |
 "." identifier                 |
 "->" identifier                |
 "++"                           |
 "--"
 "^(assignment-expression){}"   | block 作为一个独立的结构不单独解析了，代码放在外面
 )*
 OCArglist:
    identify | (_QBDF_EXP_Postfix:expression)*
 
 */
- (NSDictionary *)_QBDF_EXP_Postfix
{
    NSDictionary *leftNode;
    if(_currentToken->tokenType == '(') //(括号表达式)
    {
        [self match:'('];
        NSDictionary *dict = [self _QBDF_EXP_Assign];
        [self match:')'];
        leftNode =  dict;
    }else
    {
        if(_currentToken->tokenType == '[' && _lastToken->tokenType != oper_identify) //这里需要修改以后 是一个OC函数调用
        {
          leftNode = [self _QBDF_EXP_OBJCCALL];
            
        }else if(_currentToken->tokenType == '^')
        {
            __QBDF_INTERPRETER_ERROR(([NSString stringWithFormat:@"暂不支持匿名block 请定义一个新的block,在%ld行",(long)_currentToken->lineNumber]));
            IF_ERROR_RETURN_NIL
           
        }else
        {
           leftNode =  [self _QBDF_EXP_Atomic];
        }
    }
    //struct的取值和数组下标操作
    
    if(_currentToken->tokenType == '[' || _currentToken->tokenType == '.'|| _currentToken->tokenType ==oper_arrow) //取值和去地址操作
    {
        
        while (_currentToken->tokenType == '[' || _currentToken->tokenType == '.' || _currentToken->tokenType ==oper_arrow)
        {
            if(_currentToken->tokenType == '[' )
            {
                [self match:'['];
                NSDictionary *indexDict = [self _QBDF_EXP_Assign];
                if(_currentToken->tokenType != ']')
                {
                    __QBDF_INTERPRETER_ERROR(([NSString stringWithFormat:@"missing ] when get arrayIndex,在%ld行",(long)_currentToken->lineNumber]));
                    IF_ERROR_RETURN_NIL

                }
                [self match:']'];
                NSMutableDictionary *newRootNode =[self _createEXPOperatorNode:'[' left:leftNode right:indexDict thridNode:nil];
                leftNode = newRootNode;
                
            }else if(_currentToken->tokenType == oper_arrow)
            {
                [self match:oper_arrow];
                if(_currentToken->tokenType != oper_identify)
                {
//                    NSAssert(0, @"");
                    __QBDF_INTERPRETER_ERROR(([NSString stringWithFormat:@"missing identify after -> operator,在%ld行",(long)_currentToken->lineNumber]));
                    IF_ERROR_RETURN_NIL

                }
            
                NSString *operandName = _currentToken->tokenName;
                NSMutableDictionary *newRootNode =[self _createEXPOperatorNode:oper_arrow left:leftNode right:operandName thridNode:nil];
                leftNode = newRootNode;
                [self match:_currentToken->tokenType];

            }else
            {
                
                [self match:'.'];
                
                if(_currentToken->tokenType != oper_identify)
                {
//                    NSAssert(0, @"");
                    __QBDF_INTERPRETER_ERROR(([NSString stringWithFormat:@"missing identify after . operator,在%ld行",(long)_currentToken->lineNumber]));
                    IF_ERROR_RETURN_NIL

                    
                }
                
                NSString *operandName = _currentToken->tokenName;
                
                NSMutableDictionary *newRootNode =[self _createEXPOperatorNode:'.' left:leftNode right:operandName thridNode:nil];
                leftNode = newRootNode;
                [self match:_currentToken->tokenType];

            }
        
        }
    }
    
  
    
    
    //自增 自减操作
    
    if(_currentToken->tokenType == oper_inc || _currentToken->tokenType == oper_Dec)
    {
        int i = 0;
        while (_currentToken->tokenType == oper_inc || _currentToken->tokenType == oper_Dec)
        {
            if(_currentToken->tokenType == oper_inc)
            {
                [self match:oper_inc];
                i ++;
            }else
            {
                [self match:oper_Dec];
                i --;
            }
        }
        if(i  != 0)
        {
            NSMutableDictionary *newRootNode =[self _createEXPOperatorNode:oper_inc left:leftNode right:@(i) thridNode:nil];
            leftNode = newRootNode;

        }
    }
    return leftNode;
}
//
//
//- (NSDictionary *)_QBDF_EXP_BLOCK
//{
//    
//    
//    return nil;
//}
//
//
//- (NSArray *)_QBDF_Translate_BlockDefine:(NSArray *)tokens
//{
//    return nil;
//}


- (NSDictionary *)_QBDF_EXP_Atomic
{
    if(_currentToken->tokenType == oper_identify) //一个单一的标识符
    {
        if(_frontToken->tokenType == '(') //CALL
        {
           return [self _QBDF_EXP_CCALL];
        }else
        {
            NSDictionary *leafNode = [self _createEXPOperAndNode:CMD_EXP_OPERANDTYPE_BIAOSHIFU valBaseType:QBDF_VAR_DECTYPE_NOSUB subType:QBDF_VAR_DECTYPE_UNKNOW left:_currentToken->tokenName right:nil thridNode:nil];
            [self match:_currentToken->tokenType];
            return leafNode;
        }
    }else
    {
        NSString *operandType = @"";
        if(_currentToken->tokenType ==oper_value_num
           ||_currentToken->tokenType ==oper_value_string
           ||_currentToken->tokenType ==oper_value_double
          )
        {
            NSDictionary *leafNode;
            if(_currentToken->tokenType == oper_value_num)
            {
                leafNode  = [self _createEXPOperAndNode:CMD_EXP_OPERANDTYPE_YUASHIZHI
                                            valBaseType:QBDF_VAR_DECTYPE_LONGLONG
                                                subType:QBDF_VAR_DECTYPE_NOSUB
                                                   left:_currentToken->tokenValue right:nil thridNode:nil];
            }else if(_currentToken->tokenType ==  oper_value_string)
            {
                leafNode  = [self _createEXPOperAndNode:CMD_EXP_OPERANDTYPE_YUASHIZHI
                                            valBaseType:QBDF_VAR_DECTYPE_ID
                                                subType:QBDF_VAR_DECTYPE_NOSUB
                                                   left:_currentToken->tokenValue right:nil thridNode:nil];
            }else if(_currentToken->tokenType ==  oper_value_double)
            {
                leafNode  = [self _createEXPOperAndNode:CMD_EXP_OPERANDTYPE_YUASHIZHI
                                            valBaseType:QBDF_VAR_DECTYPE_DOUBLE
                                                subType:QBDF_VAR_DECTYPE_NOSUB
                                                   left:_currentToken->tokenValue right:nil thridNode:nil];
            }
            [self match:_currentToken->tokenType];
            return leafNode;
        }else{
            
            __QBDF_INTERPRETER_ERROR(([NSString stringWithFormat:@"表达式解析失败在%ld 行 %@处",(long)_currentToken->lineNumber,_currentToken->tokenName]));
            IF_ERROR_RETURN_NIL
        }
        
    }
    
    return nil;
}



- (NSDictionary *)_QBDF_EXP_CCALL
{
    NSMutableDictionary *node = [NSMutableDictionary new];
    NSMutableArray *args = [NSMutableArray new];
    NSString *functionName = _currentToken->tokenName;
    node[CMD_EXP_NODE_TYPE] = CMD_EXP_NODE_TYPEVAL_CCALL;
    node[CMD_EXP_NODE_RIGHTOPERAND] = args;
    node[CMD_EXP_NODE_LEFTOPERAND] =  functionName;
    
    [self match:_currentToken->tokenType];
    [self match:'('];
    if([functionName isEqualToString:@"@selector"] ||[functionName isEqualToString:@"sizeof"] )
    {
        NSMutableString *theStr = [[NSMutableString alloc] init];
        while(_currentToken->tokenType != ')') //如果是一个没有参数的调用
        {
            [theStr appendString: [_currentToken->tokenName description]];
            [self match:_currentToken->tokenType];
        }
        
        if([functionName isEqualToString:@"sizeof"])
        {
            theStr =   [[QBDFVarTypeHelper QBDFSupportVarDecTypeCode:theStr] mutableCopy];
        }
        
        [args addObject:[self _createEXPOperAndNode:QBDF_VAR_DECTYPE_ID
                                        valBaseType:QBDF_VAR_DECTYPE_SEL
                                            subType:QBDF_VAR_DECTYPE_NOSUB
                                               left:theStr right:nil thridNode:nil]];
        
    }else
    {
        if(_currentToken->tokenType != ')') //如果是一个没有参数的调用
        {
            
            NSDictionary *firstArg = [self _QBDF_EXP_Assign]?:@{};
            [args  addObject:firstArg];
            while (_currentToken->tokenType == ',') {
                [self match:','];
                NSDictionary *newArg = [self _QBDF_EXP_Assign];
                [args  addObject:newArg];
            }
        }
    }
    [self match:')'];
    return node;
}

- (NSDictionary *)_QBDF_EXP_OBJCCALL
{
    [self match:'['];
    //target
    NSDictionary *objNode = [self _QBDF_EXP_Postfix];
    NSMutableString *selectorStr = [[NSMutableString alloc] init];
    NSMutableArray *args = [NSMutableArray new];
    if([self _validOBJCSelectToken:_currentToken])
    {
        while ([self _validOBJCSelectToken:_currentToken])
        {
            [selectorStr appendString:_currentToken->tokenName];
            [self match:_currentToken->tokenType];
            
            if(_currentToken->tokenType == ':')
            {
                [self match:':'];
                [selectorStr appendString:@":"];
                NSDictionary *argDict = [self _QBDF_EXP_Assign];
                [args addObject:argDict];
                if(_currentToken->tokenType == ',') //说明这是一个可变参数的对象
                {
                    while (_currentToken->tokenType !=']') {
                        [self match:','];
                        NSDictionary *argDict = [self _QBDF_EXP_Assign];
                        [args addObject:argDict];
                        
                    }
                }
            }
        }
    }else
    {
//        NSAssert(0, @"OBJC CALL 语法错误");
        __QBDF_INTERPRETER_ERROR(([NSString stringWithFormat:@"OBJC CALL 语法错误在%ld 行 ",(long)_currentToken->lineNumber]));
        IF_ERROR_RETURN_NIL
    }
    
    NSMutableDictionary *newRootNode = [NSMutableDictionary new];
    newRootNode[CMD_EXP_NODE_TYPE] = CMD_EXP_NODE_TYPEVAL_OCCALL;
    newRootNode[CMD_EXP_NODE_LEFTOPERAND] = objNode;
    newRootNode[CMD_EXP_NODE_RIGHTOPERAND] = selectorStr;
    newRootNode[CMD_EXP_NODE_THIRDOPERAND] = args;
    [self match:']'];
    return newRootNode;
}

- (NSMutableDictionary *)_createEXPOperatorNode:(int)type left:(id)leftnode right:(id)rightNode thridNode:(id)thirdNode
{
    NSMutableDictionary *newRootNode = [NSMutableDictionary new];
    newRootNode[CMD_EXP_NODE_TYPE] = CMD_EXP_NODE_TYPEVAL_OPERATOR;
    newRootNode[CMD_EXP_NODE_OPERATORTYPE] = @(type);
  //  newRootNode[CMD_EXP_NODE_OPERATORDESC] = QBDF_OPER_DESC[newRootNode[CMD_EXP_NODE_OPERATORTYPE]]?:@"UNKNOW";
    if(leftnode)
    {
        newRootNode[CMD_EXP_NODE_LEFTOPERAND] = leftnode;
    }
    if(rightNode)
    {
        newRootNode[CMD_EXP_NODE_RIGHTOPERAND] = rightNode;
    }
    if(thirdNode)
    {
        newRootNode[CMD_EXP_NODE_THIRDOPERAND] = thirdNode;
    }
    return newRootNode;
}


- (NSMutableDictionary *)_createEXPOperAndNode:(id)type valBaseType:(id)baseType subType:(id)subType left:(id)leftnode right:(id)rightNode thridNode:(id)thirdNode
{
    NSMutableDictionary *newRootNode = [NSMutableDictionary new];
    newRootNode[CMD_EXP_NODE_TYPE] = CMD_EXP_NODE_TYPEVAL_OPERAND;
    newRootNode[CMD_EXP_NODE_OPERANDTYPE] = type;
    newRootNode[CMD_EXP_NODE_OPERAND_VALUE_BASETYPE] = baseType;
    newRootNode[CMD_EXP_NODE_OPERAND_VALUE_SUBTYPE] = subType;
    if(leftnode)
    {
        newRootNode[CMD_EXP_NODE_LEFTOPERAND] = leftnode;
    }
    if(rightNode)
    {
        newRootNode[CMD_EXP_NODE_RIGHTOPERAND] = rightNode;
    }
    if(thirdNode)
    {
        newRootNode[CMD_EXP_NODE_THIRDOPERAND] = thirdNode;
    }
    return newRootNode;
}


- (BOOL)_validOBJCSelectToken:(QBDFToken *)token
{
    if(token->tokenType == oper_identify
//       ||token->tokenType == oper_kw_id  //对雨[ call: id:  if: while:xxx] 这种调用也得支持啊，靠，先支持一个id吧
//       ||token->tokenType == oper_kw_int  //对雨[ call: id:  if: while:xxx] 这种调用也得支持啊，靠，先支持一个id吧
//       ||token->tokenType == oper_kw_double  //对雨[ call: id:  if: while:xxx] 这种调用也得支持啊，靠，先支持一个id吧
       ||token->tokenType == oper_kw_if  //对雨[ call: id:  if: while:xxx] 这种调用也得支持啊，靠，先支持一个id吧
       ||token->tokenType == oper_kw_while  //对雨[ call: id:  if: while:xxx] 这种调用也得支持啊，靠，先支持一个id吧
       
       )
    {
        return YES;
    }else
    {
        return NO;
    }
}

    

#pragma mark - satementl


- (void)setLastCMDNeedTmp
{
    if([self.cmdLines count] >0)
    {
        NSMutableDictionary *connode = [self.cmdLines lastObject];
        connode[CMD_EXP_NEEDTMPVAR] = @(1);
    }
}

- (void) _QBDF_Statement
{
    if(_currentToken->tokenType == oper_kw_if) //目前只支持 if for while
    {
        [self match:_currentToken->tokenType]; //eat if
        [self match:'('];
        [self _QBDF_EXP];
        [self match:')'];
        
        
        
        NSMutableDictionary *ifJMPDict =[@{CMD_TYEP:CMD_TYPE_JZ,CMD_JP_CONDITION:@(-1),CMD_JP_TARGET_LINE:@(-1),CMD_BOOKMARK:@"IF-OUT"} mutableCopy]; //-1 代表需要回填的
        [self setLastCMDNeedTmp];
        
        [self addCMD:ifJMPDict]; //must after
        
        NSMutableDictionary *IFENTDict =[@{CMD_TYEP:CMD_TYPE_ENT,CMD_BOOKMARK:@"IF-ENT"} mutableCopy]; //-1 代表需要回填的
        [self addCMD:IFENTDict];
        [self _QBDF_Statement];                                              //输入{ } statement 中的代码
        NSMutableDictionary *IFLEVDict =[@{CMD_TYEP:CMD_TYPE_LEV,CMD_BOOKMARK:@"IF-LEV"} mutableCopy]; //-1 代表需要回填的
        [self addCMD:IFLEVDict];
        
        if(_currentToken->tokenType == oper_kw_else
           )
        {
            NSMutableDictionary * elseDict =[@{CMD_TYEP:CMD_TYPE_JMP,CMD_JP_TARGET_LINE:@(-1),CMD_BOOKMARK:@"ELSE-OUT"} mutableCopy];
            [self addCMD:elseDict];
            ifJMPDict[CMD_JP_TARGET_LINE] = @([self.cmdLines count]);       //回填JZ 的targetLine的代码 直接跳进入else的代码块中偶
            [self match:_currentToken->tokenType]; //eat else
            NSMutableDictionary *ELSEENVDict =[@{CMD_TYEP:CMD_TYPE_ENT,CMD_BOOKMARK:@"ELSE-ENT"} mutableCopy]; //-1 代表需要回填的
            [self addCMD:ELSEENVDict];
            [self _QBDF_Statement];
            NSMutableDictionary *ELSELEVDict =[@{CMD_TYEP:CMD_TYPE_LEV,CMD_BOOKMARK:@"ELSE-LEV"} mutableCopy]; //-1 代表需要回填的
            [self addCMD:ELSELEVDict];
            
            elseDict[CMD_JP_TARGET_LINE] =@([self.cmdLines count]);         //回填JMP 的targetLine的代码 //直接跳过else的所有代码
            
        }else
        {
            ifJMPDict[CMD_JP_TARGET_LINE] = @([self.cmdLines count]);       //回填JZ 的targetLine的代码
            
        }
        
    }else if(_currentToken->tokenType == oper_kw_while)
    {
        [self match:_currentToken->tokenType]; //eat while
        NSInteger loopBegin = [self.cmdLines count];
        [self match:'('];
        [self _QBDF_EXP];
        [self match:')'];
        NSMutableDictionary *WhileJMPDictA =[@{CMD_TYEP:CMD_TYPE_JZ,CMD_JP_CONDITION:@(-1),CMD_JP_TARGET_LINE:@(-1),CMD_BOOKMARK:@"WHILE-OUT"} mutableCopy]; //-1 代表需要回填的
        [self setLastCMDNeedTmp];
        [self addCMD:WhileJMPDictA];
        
        
        NSMutableDictionary *WHILEENTDict =[@{CMD_TYEP:CMD_TYPE_ENT,CMD_BOOKMARK:@"WHILE-ENT"} mutableCopy]; //-1 代表需要回填的
        [self addCMD:WHILEENTDict];
        
        [self _QBDF_Statement];
        NSMutableDictionary *WHILELEVDict =[@{CMD_TYEP:CMD_TYPE_LEV,CMD_BOOKMARK:@"WHILE-LEV"} mutableCopy]; //-1 代表需要回填的
        [self addCMD:WHILELEVDict];
        
        NSMutableDictionary *loopJMPDict =[@{CMD_TYEP:CMD_TYPE_JMP,CMD_JP_TARGET_LINE:@(loopBegin),CMD_BOOKMARK:@"WHILE-LOOP"} mutableCopy]; //-1 代表需要回填的
        [self addCMD:loopJMPDict];
        
        WhileJMPDictA[CMD_JP_TARGET_LINE] = @([self.cmdLines count]);      //WHILE 回填跳转地址
        [self _syncJMPWithDict:WhileJMPDictA];
    }else if(_currentToken->tokenType == oper_kw_for)
    {
        [self match:oper_kw_for];
        [self match:'('];
        //判断初始值
        NSMutableDictionary *FORENTDictA =[@{CMD_TYEP:CMD_TYPE_ENT,CMD_BOOKMARK:@"FOR-ENTA" ,CMD_JP_TARGET_LINE:@(-1)} mutableCopy]; //-1 代表需要回填的
        [self addCMD:FORENTDictA];
        
        if(_currentToken->tokenType != ';')
        {
            if([self _isCurrentTokenVarDec])
            {
                [self _QBDF_DELC];
                [self ifmatch:';'];
            }else{
                
                [self _QBDF_EXP];
                [self match:';'];
                
            }
        }else{
            [self match:';'];
        }
        
        //条件
        NSMutableDictionary *ForJMPDictA = nil;
        NSInteger loopBegin = [self.cmdLines count];
        
        
        
        if(_currentToken->tokenType != ';')
        {
            [self _QBDF_EXP];
            ForJMPDictA =[@{CMD_TYEP:CMD_TYPE_JZ,CMD_JP_CONDITION:@(-1),CMD_JP_TARGET_LINE:@(-1),CMD_BOOKMARK:@"FOR-OUT"} mutableCopy]; //-1 代表需要回填的
            [self setLastCMDNeedTmp];
            
            [self addCMD:ForJMPDictA];
            
        }else{
        //如果是for(var i=1;;xxx){} 这种
        }
        [self match:';'];
        NSMutableDictionary *FORENTDictB =[@{CMD_TYEP:CMD_TYPE_ENT,CMD_BOOKMARK:@"FOR-ENT"} mutableCopy]; //-1 代表需要回填的
        [self addCMD:FORENTDictB];
        
        NSMutableDictionary *expCode = nil;
        if(_currentToken->tokenType != ')')
        {
           expCode =  [self _QBDF_EXP_RETCODE];
        }else{
            
        }
        [self match:')'];
        [self _QBDF_Statement];
        NSMutableDictionary *FORLEVDictB =[@{CMD_TYEP:CMD_TYPE_LEV,CMD_BOOKMARK:@"FOR-LEV"} mutableCopy]; //-1 代表需要回填的
        [self addCMD:FORLEVDictB];
        
        if(expCode)
        {
            [self addCMD:expCode];
        }
        
        NSMutableDictionary *loopJMPDict =[@{CMD_TYEP:CMD_TYPE_JMP,CMD_JP_TARGET_LINE:@(loopBegin),CMD_BOOKMARK:@"FOR-LOOP"} mutableCopy]; //-1 代表需要回填的
        [self addCMD:loopJMPDict];
        if(ForJMPDictA)
        {
            ForJMPDictA[CMD_JP_TARGET_LINE] = @([self.cmdLines count]);      //WHILE 回填跳转地址
        }
        FORENTDictA[CMD_JP_TARGET_LINE] = @([self.cmdLines count]);
        
        NSMutableDictionary *FORLEVDictA =[@{CMD_TYEP:CMD_TYPE_LEV,CMD_BOOKMARK:@"FOR-LEVA"} mutableCopy]; //-1 代表需要回填的
        [self addCMD:FORLEVDictA];
        
        [self _syncJMPWithDict:FORENTDictA];
        
        
        
        
        
    }else if(_currentToken->tokenType == '{')
    {
        [self match:'{'];
        while(_currentToken->tokenType != '}')
        {
            [self _QBDF_Statement];
            
        }
        [self match:'}'];
        
    }else if(_currentToken->tokenType == oper_kw_return )
    {
        
        NSMutableDictionary * levDict =[@{CMD_TYEP:CMD_TYPE_RET} mutableCopy];
        [self match:oper_kw_return]; //match return
        if(_currentToken->tokenType != ';')
        {
            levDict[CMD_EXP_RET_TARGETLINE] = @(-1);
            [self _QBDF_EXP];
            [self setLastCMDNeedTmp];
        }else{
            levDict[CMD_EXP_RET_TARGETLINE] = @(0);
            
        }
        [self addCMD:levDict];
        [self match:';'];
        
    }else if(_currentToken->tokenType == oper_kw_break)
    {
        [self match:oper_kw_break]; //match return
        NSMutableDictionary *breakJMPDict =[@{CMD_TYEP:CMD_TYPE_JMP,CMD_JP_TARGET_LINE:@(-1)} mutableCopy]; //-1 代表需要回填的
        [self addCMD:breakJMPDict];
        //TODO: 回溯找最近的一个while的跳出地址
        int valwhile = 0;
        int valfor = 0;
        for(long i = [self.cmdLines count] - 1;i >=0 ;i -- )
        {
            //
            NSMutableDictionary *dict = self.cmdLines[i];
            if([dict[CMD_BOOKMARK] isEqualToString:@"WHILE-LOOP"])
            {
                valwhile -= 1;
            }else if([dict[CMD_BOOKMARK] isEqualToString:@"WHILE-OUT"])
            {
                valwhile +=1;
            }
            
            if(valwhile == 1)
            {
                if(![dict[CMD_JP_NEED_SYNCLIST] isKindOfClass:[NSMutableArray class]])
                {
                   dict[CMD_JP_NEED_SYNCLIST] = [NSMutableArray new];
                }
                NSMutableArray *syncList =dict[CMD_JP_NEED_SYNCLIST];
                [syncList addObject:breakJMPDict[CMD_LINE]];
                break;
            }
            
            if([dict[CMD_BOOKMARK] isEqualToString:@"FOR-LEVA"])
            {
                valfor -=1;
                
            }
            if([dict[CMD_BOOKMARK] isEqualToString:@"FOR-ENTA"])
            {
                valfor +=1;
            }
            if(valfor == 1)
            {
                if(![dict[CMD_JP_NEED_SYNCLIST] isKindOfClass:[NSMutableArray class]])
                {
                    dict[CMD_JP_NEED_SYNCLIST] = [NSMutableArray new];
                }
                NSMutableArray *syncList =dict[CMD_JP_NEED_SYNCLIST];
                [syncList addObject:breakJMPDict[CMD_LINE]];
                break;
            }
            
        }
        if(valwhile != 1 && valfor != 1)
        {
           // NSAssert(0, @"");
            __QBDF_INTERPRETER_ERROR(([NSString stringWithFormat:@"break appear not in while / for -loop  %ld 行 ",(long)_currentToken->lineNumber]));
            IF_ERROR_RETURN_VOID
        }
        
        [self match:';'];
        
    }else if([self _isCurrentTokenVarDec])
    {
        [self _QBDF_DELC];
    }else
    {
        [self _QBDF_EXP];
        if(_currentToken->tokenType == ';')
        {
            
            [self match:';'];
        }
    }
}
- (void)_syncJMPWithDict:(NSDictionary *)dict
{
    NSArray *array = dict[CMD_JP_NEED_SYNCLIST];
    for(int i = 0 ; i < [array count] ;i ++)
    {
        NSInteger line = [array[i] integerValue];
        if(line < [self.cmdLines count])
        {
            NSMutableDictionary *jmpdict = self.cmdLines[line];
            if([jmpdict[CMD_TYEP] isEqualToString:CMD_TYPE_JMP])
            {
                jmpdict[CMD_JP_TARGET_LINE] = dict[CMD_JP_TARGET_LINE];
            }
        }
    }
}




- (void) _QBDF_globalTranslate
{
    QBDFToken *token = _currentToken;
    if(token->tokenType != oper_over)
    {
        if([self _isCurrentTokenVarDec])
        {
            [self _QBDF_DELC];
            
        }else if(token->tokenType == oper_kw_struct)
        {
            [self _QBDF_STRUCTDEC];
            
        }else if(token->tokenType== oper_kw_intface)
        {
            [self _QBDF_DELCClS];
            
        }else if(token->tokenType == oper_kw_implemt)
        {
            [self _QBDF_IMPCLS];
        }else if(
                 token->tokenType == oper_kw_if
                 ||token->tokenType == oper_kw_for
                 ||token->tokenType == oper_kw_while
                 )
        {
            [self _QBDF_Statement];
        }else
        {
            [self _QBDF_Statement];
        }

    }else if(_currentToken->tokenType == ';')
    {
        [self match:';'];
    }
    else
    {
        [self match:oper_over];
        return;
    
    }
}

- (void) _QBDF_Program
{
    [self match:oper_begin];
    while([self.tokenArrays count] >0)
    {
        if(_isERROR)
        {
            return;
        }
        [self _QBDF_globalTranslate];
    }
    [self addCMD:[@{CMD_TYEP:CMD_TYPE_EXT} mutableCopy]];
}

- (NSArray *) QBDF_TranslateWithFile:(NSString *)filePath
{
    NSString *strPath =  filePath;
   // NSLog(@"%@",strPath);
    NSString *str = [NSString stringWithContentsOfFile:strPath encoding:NSUTF8StringEncoding error:NULL];
    if(!str)
    {
        NSLog(@"文件不存在");
        return @[];
    }
    return [self QBDF_TranslateWithString:str];
}

- (NSArray *) QBDF_TranslateWithString:(NSString *)str
{
    _currentToken = nil;
    _lastToken = nil;
    _frontToken = nil;
    _isERROR = NO;
    
    self.tokenArrays = [NSMutableArray new];
    self.cmdLines = [NSMutableArray new];
    NSMutableString *mutestr = [[NSMutableString alloc] initWithString:str];
    [mutestr appendString:@"\0"];
    [mutestr appendString:@"\0"];
    
    NSString *SRC = [mutestr copy];
    QBDFTKProcess   *process = [[QBDFTKProcess alloc]  initWithString:SRC];
    self.tokenArrays = [[process QBDF_AnalysisTokens] mutableCopy];
    self.backupTokens = [self.tokenArrays mutableCopy];
    
    
//    for(int i = 0 ; i < [self.tokenArrays count];i++)
//    {
//        QBDFToken *token = self.tokenArrays[i];
//        NSLog(@"TKType:%@\t,%@,\trawStr:%@\tline:%ld,\tvalue %@,",@(token->tokenType),QBDF_OPER_DESC[@(token->tokenType)]?:@"UNKNOW",[token->tokenName description], (long)token->lineNumber,token->tokenValue);
//    }
    
    if([self.tokenArrays count] >0)
    {
        
        [self _QBDF_Program];
        if(_isERROR)
        {
            return @[];
        }
        return self.cmdLines;
   
    }else{
        return @[];
    }
}


#pragma mark - for cls

- (void)_QBDF_DELCClS
{
    [self match:oper_kw_intface];
    if(_currentToken->tokenType == oper_identify)
    {
        
        NSString *clsName = _currentToken->tokenName;
        NSString *superClassName;
        NSMutableArray *protocals = [NSMutableArray new];
        NSMutableArray *propertys = [NSMutableArray new];
        [self match:oper_identify];
        if ([self ifmatch:':'])
        {
            superClassName = _currentToken->tokenName;
            [self match:oper_identify];
        }else{
            superClassName = @"NSObject";//默认所有超类都是NSObject
        }
        if([self ifmatch:oper_lt]) //如果有协议<
        {
            while (_currentToken->tokenType != oper_gt) {
                
                NSString *protocolName = _currentToken->tokenName;
                [protocals addObject:protocolName];
                [self match:oper_identify];
                [self ifmatch:','];
            }
            
            [self match:oper_gt];
        }
        
        
        //这里解析属性{  }
        while(_currentToken->tokenType != oper_kw_end)
        {
            //解析属性
            [self match:oper_kw_propt];
            
            NSMutableArray *decArray = [NSMutableArray new];
            if([self ifmatch:'('])
            {
                while(_currentToken->tokenType != ')')
                {
                    NSString *tmpdec = _currentToken->tokenName;
                    [self match:oper_identify];
                    [decArray addObject:tmpdec];
                    
                    [self ifmatch:','];
                }
                [self match:')'];
            }
            
            NSDictionary *dict = [self _getVarTypeFromCurrentToken];
            NSString *baseType = dict[CMD_VARI_TYPE_SPEC];
            NSString *subType = dict[CMD_VARI_DEC_SUBTYPE_SPEC];
            
            //TODO:处理int * 这种，但是暂不支持
            if(_currentToken->tokenType == oper_identify)
            {
                NSString *name = _currentToken->tokenName;
                [propertys addObject:@{CMD_CLSD_PROPTY_BASETYPE:baseType,CMD_CLSD_PROPTY_SUBTYPE:subType?:@"",CMD_CLSD_PROPTY_NAME:name?:@"unknow",CMD_CLSD_PROPTY_OWNERDEC:decArray}];
                [self match:oper_identify];
                [self match:';'];
            }else{
                __QBDF_ERROR__([NSString stringWithFormat:@"定义属性出错 %ld 行 ",(long)_currentToken->lineNumber]);
                _isERROR = YES;
            }
            if(_isERROR)
            {
                break;
            }
            
        }
        //这里解析方法，但是不需要了
        [self match:oper_kw_end];
//        NSLog(@"cls %@",clsName);
        
        NSMutableDictionary *cmd = [NSMutableDictionary new];
        cmd[CMD_CLSD_NAME] = clsName;
        cmd[CMD_CLSD_SUPNAME] = superClassName;
        cmd[CMD_CLSD_PROTOLS] = protocals;
        cmd[CMD_CLSD_PROPTYS] = propertys;
        cmd[CMD_TYEP] = CMD_TYPE_CLSDEC;
        [self addCMD:cmd];
        
    }else
    {
//        NSAssert(0, @"interface 缺少类名");
        __QBDF_INTERPRETER_ERROR(([NSString stringWithFormat:@"interface 缺少类名 %ld 行",(long)_currentToken->lineNumber]));
        IF_ERROR_RETURN_VOID
        return;
    }
}

- (void)_QBDF_IMPCLS
{
    [self match:oper_kw_implemt];
    NSString *clsName = _currentToken->tokenName;
    NSMutableArray *mthods = [NSMutableArray new];
    [self match:oper_identify];
    while (_currentToken->tokenType != oper_kw_end)
    {
        if(_currentToken->tokenType == oper_minus
           || _currentToken->tokenType == oper_plus
           ) //减号//代表一个函数的开始
        {
            NSDictionary *methodDict = [self _QBDF_IMPCLS_MTHDDEC];
            [mthods addObject:methodDict];
        }else{
            __QBDF_INTERPRETER_ERROR(([NSString stringWithFormat: @"类实现种不能用 - + 之外开头的表达式 在 %@ 行",@(_currentToken->lineNumber)]));
            IF_ERROR_RETURN_VOID
            break;
        }
        
        if(_isERROR)
        {
            break;
        }
        
    }
    
    NSMutableDictionary *cmd = [NSMutableDictionary new];
    cmd[CMD_CLSIMP_NAME] = clsName;
    cmd[CMD_CLSIMP_MTHD] = mthods;
    cmd[CMD_TYEP] = CMD_TYPE_CLSIMP;
    [self addCMD:cmd];
    [self match:oper_kw_end];
    
}

- (NSMutableDictionary *)_getVarTypeFromCurrentToken
{
    if(_currentToken->tokenType != oper_identify)
    {
        if(_currentToken->tokenType == oper_kw_struct) //说明是一个struct ，struct，有可能是struct定义，还有可能是struct变量声明
        {
            if([self.tokenArrays count] >= 2)
            {
                QBDFToken *nextToken = self.tokenArrays[1];
                [self match:oper_kw_struct];
                NSString *structname = nextToken->tokenName;
                NSString * baseType = QBDF_VAR_DECTYPE_STRUCT;
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:2];
                dict[CMD_VARI_TYPE_SPEC] = baseType;
                dict[CMD_VARI_DEC_SUBTYPE_SPEC] = structname;
                [self match:_currentToken->tokenType];
                
                if(_currentToken->tokenType == oper_multiply )
                {
                    dict[CMD_VARI_TYPE_SPEC] = QBDF_VAR_DECTYPE_POINT;
                    dict[CMD_VARI_DEC_SUBTYPE_SPEC] = QBDF_VAR_DECTYPE_ID;
                    [self match:_currentToken->tokenType];
                    
                }
                
                
                return dict;

            }
        }
        __QBDF_INTERPRETER_ERROR(([NSString stringWithFormat:@"%@行 %@处变量声明出错",@(_currentToken->lineNumber),_currentToken->tokenName]));
        IF_ERROR_RETURN_NIL
        return nil;
    }else
    {
        NSString * baseType = @"";
        NSString * subType = @"";
        NSString *tokenName =_currentToken->tokenName;
        baseType = [QBDFVarTypeHelper QBDFSupportVarDecTypeCode:tokenName];
        if(baseType && baseType.length >0)
        {
            [self match:_currentToken->tokenType];
            if(_currentToken->tokenType == oper_multiply)
            {
                [self match:oper_multiply];
                subType = baseType;
                baseType =QBDF_VAR_DECTYPE_POINT;
            }
            if(_currentToken->tokenType == oper_multiply )
            {
                __QBDF_INTERPRETER_ERROR(([NSString stringWithFormat:@"基本类型指针变量声明，目前只支持一颗星指针在%@行",@(_currentToken->lineNumber)]));
                IF_ERROR_RETURN_NIL
            }
            if(baseType.length == 0)
            {
                __QBDF_INTERPRETER_ERROR(([NSString stringWithFormat:@"变量类型%@声明在%@行暂不支持",tokenName,@(_currentToken->lineNumber)]));
                IF_ERROR_RETURN_NIL
            }
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:2];
            dict[CMD_VARI_TYPE_SPEC] = baseType;
            dict[CMD_VARI_DEC_SUBTYPE_SPEC] = subType;
            
            return dict;
        }else
        {
            //当前这个是identify ，下一个是* 下一个是* 在下一个是identify ，在下一个是，；
            if([self.tokenArrays count] > 4)
            {
                QBDFToken *nextOneToken = self.tokenArrays[1];
                QBDFToken *nextTwoToken = self.tokenArrays[2];
                if(nextOneToken->tokenType == oper_multiply) //如果当前的是UIView *这种
                {
                    if(nextTwoToken->tokenType == oper_multiply)//UIView **
                    {
                        [self match:oper_identify];
                        [self match:oper_multiply];
                        [self match:oper_multiply];
                        
                        subType = QBDF_VAR_DECTYPE_ID;
                        baseType =QBDF_VAR_DECTYPE_POINT;
                        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:2];
                        dict[CMD_VARI_TYPE_SPEC] = baseType;
                        dict[CMD_VARI_DEC_SUBTYPE_SPEC] = subType;
                        
                        return dict;
                        
                    }else
                    {
                        [self match:oper_identify];
                        [self match:oper_multiply];
                        subType = @"";
                        baseType =QBDF_VAR_DECTYPE_ID;
                        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:2];
                        dict[CMD_VARI_TYPE_SPEC] = baseType;
                        dict[CMD_VARI_DEC_SUBTYPE_SPEC] = subType;

                        return dict;
                    }
                }
            }
            
        }
       
    }
    __QBDF_INTERPRETER_ERROR(([NSString stringWithFormat:@"%@行 %@处变量声明出错",@(_currentToken->lineNumber),_currentToken->tokenName]));
    IF_ERROR_RETURN_NIL
    return nil;
    
    
}




- (NSDictionary *)_QBDF_IMPCLS_MTHDDEC
{
    
    BOOL isclsMethod = NO;
    if(_currentToken->tokenType == oper_minus)
    {
        
        [self match:oper_minus];//-
    }else{
        isclsMethod = YES;
        [self match:oper_plus];
    }
    
    id retBaseType = @"";
    id retSubType = @"";
    
    [self match:'('];
    NSMutableDictionary *retTypeDict = [self _getVarTypeFromCurrentToken];
    IF_ERROR_RETURN_NIL
    retBaseType = retTypeDict[CMD_VARI_TYPE_SPEC];
    retSubType = retTypeDict[CMD_VARI_DEC_SUBTYPE_SPEC];
    [self match:')'];
    NSString *baseName = _currentToken->tokenName;
    NSMutableArray *xingCans = [NSMutableArray new];
    [self match:oper_identify];
    NSMutableString *selname = [[NSMutableString alloc] initWithString:baseName];
    if([self ifmatch:':']) //由有参数
    {
        [self match:'('];
        
        NSString * firstArgBaseType = @"";
        NSString * firstArgSubType = @"";
        NSMutableDictionary *firstdict = [self _getVarTypeFromCurrentToken];
        IF_ERROR_RETURN_NIL
        
        firstArgBaseType = firstdict[CMD_VARI_TYPE_SPEC];
        firstArgSubType = firstdict[CMD_VARI_DEC_SUBTYPE_SPEC];
        [self match:')'];
        [selname appendString:@":"];
        
        //拿到第一个参数
        if([self _validOBJCSelectToken:_currentToken])
        {
            NSString *argdec = _currentToken->tokenName;
            [self match:_currentToken->tokenType];
            [xingCans addObject:@{CMD_FUN_ARG_NAME:argdec,CMD_FUN_ARG_BASETYPE:firstArgBaseType,CMD_FUN_ARG_SUBTYPE:firstArgSubType?:@""}]; //这是一个行参数名字
            while (_currentToken->tokenType != '{')
            {
                
                if([self _validOBJCSelectToken:_currentToken])
                {
                    NSString *tmpArgsel = _currentToken->tokenName;
                    [selname appendString:tmpArgsel];
                    [selname appendString:@":"];
                    [self match:_currentToken->tokenType];
                    [self match:':'];
                    [self match:'('];
                    
                    NSMutableDictionary *argdict = [self _getVarTypeFromCurrentToken];
                    IF_ERROR_RETURN_NIL
                    
                    
                    id argBasetype = @"";
                    id argSubType = @"";
                    argBasetype = argdict[CMD_VARI_TYPE_SPEC];
                    argSubType = argdict[CMD_VARI_DEC_SUBTYPE_SPEC];
                    [self match:')'];
                    NSString *tmpdecname = _currentToken->tokenName;
                    [self match:_currentToken->tokenType];
                    [xingCans addObject:@{CMD_FUN_ARG_NAME:tmpdecname,CMD_FUN_ARG_BASETYPE:argBasetype,CMD_FUN_ARG_SUBTYPE:argSubType?:@""}];
                
                }else
                {
                    __QBDF_INTERPRETER_ERROR(([NSString stringWithFormat:@"方法定义错误，包含kw或其他问题%ld 行",(long)_currentToken->lineNumber]));
                    IF_ERROR_RETURN_NIL
                }
            }
        }else{
                __QBDF_INTERPRETER_ERROR(([NSString stringWithFormat:@"方法定义错误，包含keyword或其他问题%ld 行",(long)_currentToken->lineNumber]));
                IF_ERROR_RETURN_NIL
            
        }
        
        //定义函数
        
        
    }
    
    NSArray *codes = [self _QBDF_FUN_BODY];
    NSMutableDictionary *cmd = [[NSMutableDictionary alloc] init];
    cmd[CMD_CLSIMP_MTHODCMD] = codes?:@[];
    cmd[CMD_CLSIMP_MTHODSEL] = selname;
    cmd[CMD_CLSIMP_MTHODXINGCAN] = xingCans;
    cmd[CMD_CLSIMP_MTHODRET] = @{CMD_FUN_RET_BASETYPE:retBaseType ,CMD_FUN_RET_SUBTYPE:retSubType?:@""};
    cmd[CMD_CLSIMP_MTHODISCLS] = @(isclsMethod);
    return cmd;
}



@end

@implementation QBDFScriptInterpreter(BlkInterPreter)

- (NSArray *)QBDF_TranslateFunctionBody:(NSMutableArray *)tokens
{
    
    self.tokenArrays = tokens;
    self.cmdLines = [NSMutableArray new];
    _currentToken = nil;
    _lastToken = nil;
    _frontToken = nil;
    if([_tokenArrays count] >0)
    {
        _currentToken = _tokenArrays[0];
    }
    if([_tokenArrays count] >1)
    {
        _frontToken = _tokenArrays[1];
    }
    [self match:'{'];
    while (_currentToken->tokenType != '}')
    {
        if(_isERROR)
        {
            return @[];
        }
        [self _QBDF_Statement];
    }
    [self match:'}'];
    return self.cmdLines;
}

@end
