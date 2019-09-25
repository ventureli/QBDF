//
//  QBDFVMContext.m
//  QBDFScript
//
//  Created by fatboyli on 2017/5/18.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "QBDFVMContext.h"
#import "QBDFSymbolTable.h"
#import "QBDFCFUNCenter.h"
#import "QBDFOCCALLCenter.h"
#import "QBDFBLkTool.h"
#import "QBDFSYSCenter.h"
#import "QBDFSYSCenter+QBDFStruct.h"
#import "QBDFStruct.h"
///////////////////////////////////////////
@interface QBDFVMContext()
{
    int                 PC;         //PC指针，代表当前程序运行的下一条指针的运行方式
    id                  contextRet;
    id                  contextRetBaseType;
    int                 contextRetPtrDeep;
}

@property(nonatomic ,strong)QBDFSymbolTable                  *symbolTable;    //基础表 //从基础表上可以衍生下一
@end



@implementation QBDFVMContext


#define QBDF_EVL_STATUS(code , msg)   \
@{@"ret":@(code),@"msg":msg}

#define QBDF_EVL_STATUS_SUCCESS QBDF_EVL_STATUS(QBDFVMStatusInvalidCodes,@"代码不是有效中间代码序列")
#define QBDF_EVL_STATUS_INVALIDECODES QBDF_EVL_STATUS(QBDFVMStatusInvalidCodes,@"SUCCESS")
#define TEMPVARNAME(line)  [NSString stringWithFormat:@"$_tmp_%ld",(long)line]
//NSString 类型可以通过ISEQUAL 判断的



#pragma mark -QBVM Factory
- (instancetype)init{
    NSAssert(0, @"cannot init QBDFVMContent please user createxxx factory method instead");
    return nil;
}

- (instancetype)_initB
{
    self =  [super init];
    if(self)
    {
        self.symbolTable = [[QBDFSymbolTable alloc] init];
    }
    return self;
}

+ (instancetype)createDefaultContextWithSymbol:(NSDictionary *)symbols codes:(NSArray *)code//函数递归真是一个牛皮的东西，不得不说啊
{
    QBDFVMContext *instance = [[QBDFVMContext alloc] _initB];
    
    NSArray *keys = [symbols allKeys];
    for(int i = 0 ;i < [keys count] ;i ++)
    {
        NSString *key =keys[i];
        id value = symbols[key];
        [instance.symbolTable addIdentifySymbolWithName:key varType:QBDF_VAR_DECTYPE_ID subType:QBDF_VAR_DECTYPE_NOSUB value:value];//
    }
    
    
    [instance _QBDF_EVAL:code];
    return instance;
}


//建立一个block 或者函数调用的context

+ (instancetype)createBlkCallContextWithNode:(NSDictionary *)node superFrame:(NSArray *)frame args:(NSArray *)args
{
    QBDFVMContext *instance = [[QBDFVMContext alloc] _initB];
    
    NSArray *cmds = READNODEVALUE(node, CMD_FUN_CMD);
    NSArray *argDEC = READNODEVALUE(node,CMD_FUN_ARG); //形参
    
    //添加变量定义
    if([argDEC count] != [args count])
    {
        __QBDF_ERROR__([NSString stringWithFormat:@"声明参数格式和实际参数不一样"]);
        
        return instance;
    }
    [instance _addBaseSymbolItemWithSymbStack:frame];
    for(NSInteger i = 0;i < [argDEC count];i++)
    {
        NSDictionary *argDecNode = argDEC[i];
        NSString *name = [READNODEVALUE(argDecNode, CMD_FUN_ARG_NAME) description];
        id baseType = READNODEVALUE(argDecNode, CMD_FUN_ARG_BASETYPE);
        id subType = READNODEVALUE(argDecNode, CMD_FUN_ARG_SUBTYPE);
        id value = args[i];
        [instance.symbolTable addIdentifySymbolWithName:name varType:baseType subType:[subType description] value:value];
    }
    
    [instance _QBDF_EVAL:cmds];
    return instance;
}

+ (instancetype)createOCMTHDCallContextWithNode:(NSDictionary *)node
                                     superFrame:(NSArray *)frame
                                           args:(NSArray *)args
                                           sel:(SEL)sel
                                         target:(id)target
{
    QBDFVMContext *instance = [[QBDFVMContext alloc] _initB];
    
    NSArray *cmd = READNODEVALUE(node, CMD_CLSIMP_MTHODCMD);
    NSArray *xingCan = READNODEVALUE(node, CMD_CLSIMP_MTHODXINGCAN);
    BOOL isclass = [READNODEVALUE(node, CMD_CLSIMP_MTHODISCLS) boolValue];
    [instance _addBaseSymbolItemWithSymbStack:frame];
    for(NSInteger i = 0;i < [xingCan count];i++)
    {
        NSDictionary *argDecNode = xingCan[i];
        NSString *name = [READNODEVALUE(argDecNode, CMD_FUN_ARG_NAME) description];
        id baseType = READNODEVALUE(argDecNode, CMD_FUN_ARG_BASETYPE);
        id subType =READNODEVALUE(argDecNode, CMD_FUN_ARG_SUBTYPE);
 
        id value = args[i];
        [instance.symbolTable addIdentifySymbolWithName:name varType:baseType subType: subType value:value];
    }
    //设置self
    
    if(!isclass)
    {
        NSString *selName = NSStringFromSelector(sel);
        if([selName isEqualToString:@"dealloc"])
        {
            [instance.symbolTable addIdentifySymbolWithName:@"self" varType:QBDF_VAR_DECTYPE_ID subType:QBDF_VAR_DECTYPE_NOSUB];
            [instance.symbolTable updateIdentifyAssignValueWithName:@"self" value:target];
            
            QBDFSuprWrapepr *wrapper = [[QBDFSuprWrapepr alloc] initWithAssignTarget:target];
            [instance.symbolTable addIdentifySymbolWithName:@"super" varType:QBDF_VAR_DECTYPE_ID subType:QBDF_VAR_DECTYPE_NOSUB];
            [instance.symbolTable updateIdentifyValueWithName:@"super" value:wrapper]; //TODOFix heree
            
            
        }else
        {
            
            [instance.symbolTable addIdentifySymbolWithName:@"self" varType:QBDF_VAR_DECTYPE_ID subType:QBDF_VAR_DECTYPE_NOSUB];
            [instance.symbolTable updateIdentifyValueWithName:@"self" value:target];
            
            QBDFSuprWrapepr *wrapper = [[QBDFSuprWrapepr alloc] initWithAssignTarget:target];
            [instance.symbolTable addIdentifySymbolWithName:@"super" varType:QBDF_VAR_DECTYPE_ID subType:QBDF_VAR_DECTYPE_NOSUB];
            [instance.symbolTable updateIdentifyValueWithName:@"super" value:wrapper]; //TODOFix heree
            
        }
        //设置super //super 就是一个super obj 处理
        
        
    }
    //设置cmd
    [instance _QBDF_EVAL:cmd];
    return instance;
}


- (id)readRETValue
{
    return self->contextRet;
}

#pragma mark - Symbol

- (void)_addBaseSymbolItemWithSymbStack:(NSArray *)array
{
    [self.symbolTable addBaseSymbolWithSymbStack:array];
}



- (void)deleteVari:(NSString *)key
{
    [self.symbolTable deleteVari:key];
}

- (id)readSymbValue:(NSString *)key
{
  return  [self.symbolTable readIdentifyValueByName:key];
}

#pragma mark - QBDF

- (QBDF_EVAL_STATUES)_QBDF_EVAL:(NSArray *)codes
{
    if(![codes isKindOfClass:[NSArray class]])
    {
        return QBDF_EVL_STATUS(QBDFVMStatusInvalidCodes,@"代码不是有效中间代码序列");
    }
    if( [codes count] == 0)
    {
        return QBDF_EVL_STATUS(QBDFVMStatusInvalidCodes,@"空代码");
    }
    
    PC = 0;
    while (PC < [codes count])
    {
        QBDF_CMD cmd =  codes[PC];
        if(ISCMDTPYE(cmd, CMD_TYPE_VARDEF))
        {
            [self _QBDF_VARDEF:cmd];
            PC++;
        }else if(ISCMDTPYE(cmd, CMD_TYPE_ENT))
        {
            [self _QBDF_ENT:cmd];
            PC++;
            
        }else if(ISCMDTPYE(cmd, CMD_TYPE_LEV))
        {
            [self _QBDF_LEV:cmd];
            PC ++;
            
        }else if(ISCMDTPYE(cmd, CMD_TYPE_JZ))
        {
            int value = [self _QBDF_JZ:cmd];
            PC = value;
            
        }else if(ISCMDTPYE(cmd, CMD_TYPE_JMP))
        {
            int value = [self _QBDF_JMP:cmd];
            PC = value;
            
        }else if(ISCMDTPYE(cmd, CMD_TYPE_EXP))
        {
            [self _QBDF_EXP:cmd];
            PC ++;
            
        }else if(ISCMDTPYE(cmd, CMD_TYPE_EXT)) //JUST EXT
        {
            break;
        
        }else if(ISCMDTPYE(cmd, CMD_TYPE_RET))
        {
            id res =  [self _QBDF_RET:cmd];
            self->contextRet = res;            //读取返回值
            break;
        
        }else if(ISCMDTPYE(cmd, CMD_TYPE_BLKDEC))
        {
            [self _QBDF_BLKDEC:cmd];
            PC ++;
            
        }else if(ISCMDTPYE(cmd, CMD_TYPE_CLSDEC))
        {
            [self _QBDF_CLSDEC:cmd];
            PC ++;
        }else if(ISCMDTPYE(cmd, CMD_TYPE_CLSIMP))
        {
            [self _QBDF_CLSIMP:cmd];
            PC ++;
        }else if(ISCMDTPYE(cmd, CMD_TYPE_STUCTDEC))
        {
            [self _QBDF_STRUCTDEC:cmd];
            PC ++;
        }else
        {
//            NSAssert(0, @"暂不支持当前指令");
            
            __QBDF_ERROR__([NSString stringWithFormat:@"暂不支持当前指令%@",cmd]);
            
        }
    }
    return QBDF_EVL_STATUS_INVALIDECODES;
}


#pragma mark - VM MainLogic
                 
- (void)_QBDF_STRUCTDEC:(QBDF_CMD)cmd
{
//    NSString *structName = READNODEVALUE(cmd, CMD_EXP_NODE_LEFTOPERAND);
//    NSArray  *elements   = READNODEVALUE(cmd, CMD_EXP_NODE_RIGHTOPERAND);
//    NSLog(@"elements :%@",elements);
    [[QBDFSYSCenter shareInstance] registerStructByCmd:cmd];
}

- (void)_QBDF_CLSDEC:(QBDF_CMD)cmd
{
    //NSLog(@"the cmd is:%@",cmd);
    NSString *clsName = READCMDVALUE(cmd, CMD_CLSD_NAME);
    NSArray *props = READCMDVALUE(cmd, CMD_CLSD_PROPTYS);
    NSArray *protos = READCMDVALUE(cmd, CMD_CLSD_PROTOLS);
    NSString *supName = READCMDVALUE(cmd, CMD_CLSD_SUPNAME)?:@"NSObject";
    [[QBDFSYSCenter shareInstance] decCLSWithName:clsName supName:supName procals:protos proptys:props];
    
}

- (void)_QBDF_CLSIMP:(QBDF_CMD)cmd
{
    NSString *clsName = READNODEVALUE(cmd, CMD_CLSIMP_NAME);
    NSArray *method = READNODEVALUE(cmd, CMD_CLSIMP_MTHD);
    [[QBDFSYSCenter shareInstance] impCLSWithName:clsName methods:method];
    //NSLog(@"the cmd is:%@",cmd);
}

- (int)_QBDF_VARDEF:(QBDF_CMD)cmd
{
    NSString *varName = READCMDVALUE(cmd,CMD_VARI_DEC_NAME);
    NSString *varType = READCMDVALUE(cmd,CMD_VARI_TYPE_SPEC); 
    NSString *varsubType = [READCMDVALUE(cmd,CMD_VARI_DEC_SUBTYPE_SPEC) description];
    if([varType isEqualToString:QBDF_VAR_DECTYPE_STRUCT])  //sturct 转为ID类型
    {
        NSString *StructName = varsubType;
        QBDFStructDefine *define  =[[QBDFSYSCenter shareInstance] readStructDefine:StructName];
        if(define)
        {
            QBDFStruct *value = [QBDFStruct getInstanceWithDefine:define args:nil];
            return [self.symbolTable addIdentifySymbolWithName:varName varType:QBDF_VAR_DECTYPE_ID subType:varsubType value:value];
        }else
        {
            return [self.symbolTable addIdentifySymbolWithName:varName varType:QBDF_VAR_DECTYPE_ID subType:varsubType];
        }
        
    }else{
        return [self.symbolTable addIdentifySymbolWithName:varName varType:varType subType:varsubType];
    }
    
}

- (void)_QBDF_ENT:(QBDF_CMD)cmd
{
    //TODO:add some print msg
    [self.symbolTable pushSymbolTable];
    
}
- (void)_QBDF_LEV:(QBDF_CMD)cmd
{
    [self.symbolTable popSymbolTable];
    
}

- (BOOL)_BOOLByValue:(id)value
{
    if([value isKindOfClass:[NSNumber class]])
    {
        if(strcmp([value objCType], "c") == 0 && ![value boolValue])
        {
            return NO;
        }else{
            if([value integerValue] == 0)
            {
                return NO;
            }else{
                return YES;
            }
        }
        
    }else{
        if([value isKindOfClass:[QBDFNil class]])
        {
            return NO;
        }else if([value isKindOfClass:[NSNull class]])
            
        {
            return NO;
            
        }else{
            return YES;
        }
    }
}

- (int)_QBDF_JZ:(QBDF_CMD)cmd  //为0 跳转
{
    //TODO read expression
    //先默认都是0
      int targetPC = (int)[READCMDVALUE(cmd, CMD_JP_TARGET_LINE) integerValue];
      int conditionline = (int)[READCMDVALUE(cmd, CMD_JP_CONDITION) integerValue];
      if(conditionline >= 0)
      {
          __QBDF_ERROR__([NSString stringWithFormat:@"跳转语句条件表达式无法找到"]);
          return PC + 1;
      }else
      {
          int varLine = PC + conditionline;
          NSString *tempVarName =  TEMPVARNAME(varLine);
          id value = [self.symbolTable readTmpVarWithName:tempVarName];
          if([self _BOOLByValue:value])
          {
              return PC +1;
          }else{
              return targetPC;
          }
      }
    return PC +1;
}

- (id)_QBDF_BLKDEC:(QBDF_CMD)cmd
{
    NSString  *name = [READCMDVALUE(cmd, CMD_FUN_NAME) description];
    [self.symbolTable addBlkWithName:name nodes:cmd];
    return [QBDFNil new];
}

- (id)_QBDF_RET:(QBDF_CMD)cmd
{
    int conditionline = (int)[READCMDVALUE(cmd, CMD_EXP_RET_TARGETLINE) integerValue];
    if(conditionline >= 0)
    {
        return [QBDFNil new];
    }else
    {
        int varLine = PC + conditionline;
        NSString *tempVarName =  TEMPVARNAME(varLine);
        id value = [self.symbolTable readTmpVarWithName:tempVarName];
        return value;
    }

}

- (int)_QBDF_JMP:(QBDF_CMD)cmd
{
    int targetPC = (int)[READCMDVALUE(cmd, CMD_JP_TARGET_LINE) integerValue];
    if (targetPC >0) {
        return targetPC;
    }else
    {
//        NSAssert(0, @"ERROR");
        
        __QBDF_ERROR__([NSString stringWithFormat:@"跳转ERROR"]);
    }
    return 1000000000;
}

#pragma mark - EXP
- (void)_QBDF_EXP:(QBDF_CMD)cmd
{
    NSDictionary *tree = READCMDVALUE(cmd, CMD_EXP_TREE);//读取语法树
    NSInteger needTMPVar = [READNODEVALUE(cmd, CMD_EXP_NEEDTMPVAR) integerValue];
    id returnValue = [self _QBDF_EXP_IMP:tree];
    if(needTMPVar != 1)
    {
        return;
    }
    if(returnValue) //TODO:FIX 取值
    {
        
        
        NSString *varName = TEMPVARNAME(PC);
        id value = nil;
        if([returnValue isKindOfClass:[NSDictionary class]]
           && [returnValue[CMD_EXP_NODE_TYPE] isEqual:CMD_EXP_NODE_TYPEVAL_OPERAND] //如果是操作室，直接去的操作数的填充临时变量
           )
        {
            //如果返回的是一个标识符
            value = [self _readOperandNodeVal:returnValue];
        }else
        {
            value = returnValue;
        }
        if(value)
        {
            
            [self.symbolTable updateTmpVarWithName:varName value:value];
            
        }
    }
}

- (id)_QBDF_EXP_IMP:(NSDictionary *)tree  //跟路径
{
    id nodeType = READNODEVALUE(tree, CMD_EXP_NODE_TYPE);
    if([nodeType isEqual:CMD_EXP_NODE_TYPEVAL_OPERAND]) //这是一个操作数
    {
        return [self _QBDF_EXP_OPERAND:tree];
    }else if([nodeType isEqual:CMD_EXP_NODE_TYPEVAL_OPERATOR])
    {
        return [self _QBDF_EXP_OPERATOR:tree];
        
    }else if([nodeType isEqual:CMD_EXP_NODE_TYPEVAL_OCCALL])
    {
        return [self _QBDF_EXP_OCCALL:tree];
    }else if([nodeType isEqual:CMD_EXP_NODE_TYPEVAL_CCALL])
    {
        return [self _QBDF_EXP_CCALL:tree];
    }
    return [QBDFNil new];
    
}



- (id)_QBDF_EXP_OPERATOR:(NSDictionary *)node
{
    int operatorType = (int)[READNODEVALUE(node, CMD_EXP_NODE_OPERATORTYPE) integerValue];
    id res = 0;
    switch (operatorType) {
        case oper_assignment:
        {
            int value = [self _QBDF_EXP_OPERATOR_Assign:node];
            res = @(value);
        }
        break;
        case oper_eq:
        case oper_ne:
        case oper_gt:
        case oper_ge:
        case oper_le:
        case oper_lt:
        {
            BOOL value = [self _QBDF_EXP_OPERATOR_Relational:node];
            res = @(value);
        }
            break;
        case oper_plus:
        case oper_minus:
        case oper_multiply:
        case oper_divide:
        case oper_mod:
        {
            id newLeafNode =  [self _QBDF_EXP_OPERATOR_Calc:node];
            res =  newLeafNode;
        }
            break;
        case oper_and:
        case oper_or:
        case oper_not:
        {
            int value =  [self _QBDF_EXP_OPERATOR_Logic:node];
            res = @(value);
            break;
        }
        case oper_inc:
        case oper_Dec:
        {
            id newLeafNode = [self _QBDF_EXP_OPERATOR_INC:node];
            res = newLeafNode;
        }
            break;
        case '.': //取值表达址
        {
            id newLeafNode = [self _QBDF_EXP_OPERATOR_DOT:node];
            res = newLeafNode;
        }
            break;
        case oper_arrow:
        {
            id newLeafNode = [self _QBDF_EXP_OPERATOR_ARROW:node];
            res = newLeafNode;
            break;
        }
        case '?': //三目表达式
        {
            id newLeafNode = [self _QBDF_EXP_OPERATOR_SANMU:node];
            res = newLeafNode;
            break;
        }
        case oper_addr:
        {
            id newLeafNode = [self _QBDF_EXP_OPERATOR_ADDR:node];
            res = newLeafNode;
        }
        break;
        case oper_unaddr:
        {
            id newnewLeafNode = [self _QBDF_EXP_OPERATOR_UNADDR:node];
            res = newnewLeafNode;
        }
        break;
        case '[':
        {
            id newLeafNode = [self _QBDF_EXP_OPERATOR_SUBINDEX:node];
            res = newLeafNode;
            break;
        }
        case '|':
        case '^':
        case '&':
        {
            id newLeafNode = [self _QBDF_EXP_OPERATOR_BITOperator:node];
            res = newLeafNode;
            break;
        }
        default:
        {
            __QBDF_ERROR__([NSString stringWithFormat:@"不支持的操作符类型%@",@(operatorType)]);
        }
            break;
    }
    return res;
}


- (id)_QBDF_EXP_OPERATOR_UNADDR:(NSDictionary *)node
{
    NSDictionary *leftRootNode = READNODEVALUE(node, CMD_EXP_NODE_LEFTOPERAND);
    id leftleafNode= [self _QBDF_EXP_IMP:leftRootNode];
    if(!leftleafNode)
    {
        __QBDF_ERROR__([NSString stringWithFormat:@"error 取地址操作符操作符应该有操作数"]);
    }
    if(ISNODEVALUE_EQUAL(leftleafNode,CMD_EXP_NODE_TYPE,CMD_EXP_NODE_TYPEVAL_OPERAND)
       && ISNODEVALUE_EQUAL(leftleafNode,CMD_EXP_NODE_OPERANDTYPE,CMD_EXP_OPERANDTYPE_BIAOSHIFU))
        
    {
        
        NSString *name = READNODEVALUE(leftleafNode, CMD_EXP_NODE_LEFTOPERAND);
        id value = [self.symbolTable readIdentifyValueByUnAddressByName:name];
        return [self _createEXPOperAndNode:CMD_EXP_OPERANDTYPE_YUASHIZHI
                               valBaseType:QBDF_VAR_DECTYPE_ID
                                   subType:QBDF_VAR_DECTYPE_NOSUB
                                      left:value
                                     right:nil
                                 thridNode:nil];
        
    }else
    {
        __QBDF_ERROR__([NSString stringWithFormat:@"error 取地址只能应用于标识符"]);
    }
    
    return nil;
}
- (id)_QBDF_EXP_OPERATOR_ADDR:(NSDictionary *)node
{
    NSDictionary *leftRootNode = READNODEVALUE(node, CMD_EXP_NODE_LEFTOPERAND);
    id leftleafNode= [self _QBDF_EXP_IMP:leftRootNode];
    if(!leftleafNode)
    {
        __QBDF_ERROR__([NSString stringWithFormat:@"error 取地址操作符操作符应该有操作数"]);
    }
    if(ISNODEVALUE_EQUAL(leftleafNode,CMD_EXP_NODE_TYPE,CMD_EXP_NODE_TYPEVAL_OPERAND)
       && ISNODEVALUE_EQUAL(leftleafNode,CMD_EXP_NODE_OPERANDTYPE,CMD_EXP_OPERANDTYPE_BIAOSHIFU))

    {
    
        NSString *name = READNODEVALUE(leftleafNode, CMD_EXP_NODE_LEFTOPERAND);
        id value = [self.symbolTable readIdentifyAddressByName:name];
        return [self _createEXPOperAndNode:CMD_EXP_OPERANDTYPE_YUASHIZHI
                               valBaseType:QBDF_VAR_DECTYPE_ID
                                   subType:QBDF_VAR_DECTYPE_NOSUB
                                      left:value
                                     right:nil
                                 thridNode:nil];
        
    }else
    {
        __QBDF_ERROR__([NSString stringWithFormat:@"error 取地址只能应用于标识符"]);
    }
    
    return nil;

}

- (id)_QBDF_EXP_OPERATOR_INC:(NSDictionary *)node
{
    NSDictionary *leftRootNode = READNODEVALUE(node, CMD_EXP_NODE_LEFTOPERAND);
    id leftleafNode= [self _QBDF_EXP_IMP:leftRootNode];
    if(!leftleafNode)
    {
//        NSAssert(0, @"error 递增递减操作符应该有操作数");
        
        __QBDF_ERROR__([NSString stringWithFormat:@"error 递增递减操作符应该有操作数"]);
    }
    
    int incvalue = (int)[READNODEVALUE(node, CMD_EXP_NODE_RIGHTOPERAND) integerValue];
    
    if(ISNODEVALUE_EQUAL(leftleafNode, CMD_EXP_NODE_TYPE, CMD_EXP_NODE_TYPEVAL_OPERAND)
       &&ISNODEVALUE_EQUAL(leftleafNode, CMD_EXP_NODE_OPERANDTYPE, CMD_EXP_OPERANDTYPE_BIAOSHIFU) //如果是一个标识符
       )
    {
        id value = [self _readOperandNodeVal:leftleafNode];
        double newValue = [value doubleValue] +incvalue;
        id varName = READNODEVALUE(leftleafNode,CMD_EXP_NODE_LEFTOPERAND);
        [self.symbolTable updateIdentifyValueWithName:varName value:@(newValue)];
        return leftleafNode;
    }else //是一个操作数 //操作数就直接取吧
    {
        id varValue = [self _readOperandNodeVal:leftleafNode];;
        //justoperand num or double
        NSMutableDictionary *muteNode = leftleafNode;
        
//        if([muteNode isKindOfClass:[NSMutableDictionary class]])
//        {
//            ;
//        }else
//        {
        muteNode = [leftleafNode mutableCopy];
//        }
        muteNode[CMD_EXP_NODE_LEFTOPERAND] = @([varValue doubleValue] +incvalue);
        return muteNode;
    }
    
    return leftleafNode;
}

- (id)_QBDF_EXP_OPERATOR_SUBINDEX:(NSDictionary *)node
{
    NSDictionary *leftRootNode = READNODEVALUE(node, CMD_EXP_NODE_LEFTOPERAND);
    id leftleafNode= [self _QBDF_EXP_IMP:leftRootNode];
    id resValue = nil;
    if(!leftleafNode)
    {
//        NSAssert(0, @"[号语法没有取到响应的变量和数据");
        
        __QBDF_ERROR__([NSString stringWithFormat:@"[号语法没有取到响应的变量和数据"]);
        
    }else{
        id value = [self _readOperandNodeVal:leftleafNode];
        id right = [self _QBDF_EXP_IMP: READNODEVALUE(node, CMD_EXP_NODE_RIGHTOPERAND)];
        id rightvalue = [self _readOperandNodeVal:right];
        if([READNODEVALUE(leftleafNode, CMD_EXP_NODE_OPERANDTYPE) isEqualToString:CMD_EXP_OPERANDTYPE_BIAOSHIFU])
        {
            NSString *targetIdentifyName = READNODEVALUE(leftleafNode, CMD_EXP_NODE_LEFTOPERAND);
           resValue= [self.symbolTable readValueByBracket:targetIdentifyName key:rightvalue];
        }else
        {
            resValue =  [[QBDFOCCALLCenter shareInstance] readArrayOrDictValue:value key:rightvalue];
        }
        
    }
    if(resValue)
    {
        return [self _createEXPOperAndNode:CMD_EXP_OPERANDTYPE_YUASHIZHI
                               valBaseType:QBDF_VAR_DECTYPE_ID
                                   subType:QBDF_VAR_DECTYPE_NOSUB
                                      left:resValue
                                     right:nil
                                 thridNode:nil];
    }else
    {
        return [QBDFNil new];
    }

}

- (id)_QBDF_EXP_OPERATOR_SANMU:(NSDictionary *)node
{
    NSDictionary *leftRootNode = READNODEVALUE(node, CMD_EXP_NODE_LEFTOPERAND);
    NSDictionary *rightRootNode = READNODEVALUE(node, CMD_EXP_NODE_RIGHTOPERAND);
    NSDictionary *thirdRootNode = READNODEVALUE(node, CMD_EXP_NODE_THIRDOPERAND);
    //left condition right:first third:second
    id leftLeafNode = [self _QBDF_EXP_IMP:leftRootNode];
    id value = [self _readOperandNodeVal:leftLeafNode] ;
    if([self _BOOLByValue:value])
    {
        
        id rightLeafNode = [self _QBDF_EXP_IMP:rightRootNode];
        return rightLeafNode;
    }else{
        id thirdleaf = [self _QBDF_EXP_IMP:thirdRootNode];
        return thirdleaf;
        
    }
    return [QBDFNil new];
}

- (id)_QBDF_EXP_OPERATOR_ARROW:(NSDictionary *)node
{
    NSDictionary *leftRootNode = READNODEVALUE(node, CMD_EXP_NODE_LEFTOPERAND);
    id leftleafNode= [self _QBDF_EXP_IMP:leftRootNode];
    id resValue = nil;
    if(!leftleafNode)
    {
//        NSAssert(0, @"->号语法没有取到响应的变量和数据");
        __QBDF_ERROR__([NSString stringWithFormat:@"->号语法没有取到响应的变量和数据"]);
        
    }else{
        id value = [self _readOperandNodeVal:leftleafNode];
        NSString *properName  = READNODEVALUE(node, CMD_EXP_NODE_RIGHTOPERAND);
        resValue =  [[QBDFOCCALLCenter shareInstance] readIvarValueWithTarget:value propertName:properName];
    }
    if(resValue)
    {
//        return [self _createNewIdOperandByValue:resValue];
        return [self _createEXPOperAndNode:CMD_EXP_OPERANDTYPE_YUASHIZHI
                               valBaseType:QBDF_VAR_DECTYPE_ID
                                   subType:QBDF_VAR_DECTYPE_NOSUB
                                      left:resValue
                                     right:nil
                                 thridNode:nil];
    }else
    {
        return [QBDFNil new];;
    }
}
- (id)_QBDF_EXP_OPERATOR_DOT:(NSDictionary *)node
{
    NSDictionary *leftRootNode = READNODEVALUE(node, CMD_EXP_NODE_LEFTOPERAND);
    id leftleafNode= [self _QBDF_EXP_IMP:leftRootNode];
    id resValue = nil;
    if(!leftleafNode)
    {
//        NSAssert(0, @"点号语法没有取到响应的变量和数据");
        
        __QBDF_ERROR__([NSString stringWithFormat:@"点号语法没有取到响应的变量和数据"]);

    }else{
        id value = [self _readOperandNodeVal:leftleafNode];
        NSString *properName  = READNODEVALUE(node, CMD_EXP_NODE_RIGHTOPERAND);
        resValue =  [[QBDFOCCALLCenter shareInstance] readPropertyValueWithTarget:value propertName:properName];
    }
    if(resValue)
    {
//        return [self _createNewIdOperandByValue:resValue];
        return [self _createEXPOperAndNode:CMD_EXP_OPERANDTYPE_YUASHIZHI
                               valBaseType:QBDF_VAR_DECTYPE_ID
                                   subType:QBDF_VAR_DECTYPE_NOSUB
                                      left:resValue
                                     right:nil
                                 thridNode:nil];
    }else{
        
        return [QBDFNil new];
   
    }
}


- (int)_QBDF_EXP_OPERATOR_LEFTOperatorASSIGN:(NSDictionary *)node
{
    NSDictionary *targetNode = READNODEVALUE(node, CMD_EXP_NODE_LEFTOPERAND);
    
    NSDictionary *rightNode = [self _QBDF_EXP_IMP:READNODEVALUE(node, CMD_EXP_NODE_RIGHTOPERAND)];
    id value  = [self _readOperandNodeVal:rightNode]; //right value
    
    NSDictionary *targetLeafNode = [self _QBDF_EXP_IMP:READNODEVALUE(targetNode, CMD_EXP_NODE_LEFTOPERAND)];
    id tarvalue = [self _readOperandNodeVal:targetLeafNode];
    
    if(ISNODEVALUE_EQUAL(targetNode, CMD_EXP_NODE_OPERATORTYPE, @(oper_arrow))) //arrrow
    {
        NSString *varName;
        if([READNODEVALUE(targetNode, CMD_EXP_NODE_RIGHTOPERAND) isKindOfClass:[NSString class]])
        {
            varName = [READNODEVALUE(targetNode, CMD_EXP_NODE_RIGHTOPERAND) description];
        }
        [[QBDFOCCALLCenter shareInstance] updateIvarValueWithTarget:tarvalue propertName:varName value:value];
        
    }else if(ISNODEVALUE_EQUAL(targetNode, CMD_EXP_NODE_OPERATORTYPE, @('.')))  // . 符号
    {
        NSString *varName;
        if([READNODEVALUE(targetNode, CMD_EXP_NODE_RIGHTOPERAND) isKindOfClass:[NSString class]])
        {
            varName = [READNODEVALUE(targetNode, CMD_EXP_NODE_RIGHTOPERAND) description];
        }
        [[QBDFOCCALLCenter shareInstance] updatePropertyValueWithTarget:tarvalue propertName:varName value:value];
        
    }else if(ISNODEVALUE_EQUAL(targetNode, CMD_EXP_NODE_OPERATORTYPE, @('[')))  // . 符号
    {
        
        NSDictionary *varNode = READNODEVALUE(targetNode, CMD_EXP_NODE_RIGHTOPERAND);
        NSString *varName = [self _readOperandNodeVal:varNode];
        
        if([READNODEVALUE(targetLeafNode,CMD_EXP_NODE_OPERANDTYPE) isEqual:CMD_EXP_OPERANDTYPE_BIAOSHIFU])
        {
            
            id targetIdentifyName = READNODEVALUE(targetLeafNode, CMD_EXP_NODE_LEFTOPERAND);
            [self.symbolTable updateValueByBracket:targetIdentifyName key:varName value:value];
            
        }else{
            
            [[QBDFOCCALLCenter shareInstance] updateArrayOrDictValue:tarvalue key:varName value:value];
            
        }
        
    }else if(ISNODEVALUE_EQUAL(targetNode, CMD_EXP_NODE_OPERATORTYPE, @(oper_unaddr)))
    {
       // [[QBDFOCCALLCenter shareInstance] updateAddrByValue:tarvalue key:varName value:value];
        NSString *identifyName = READNODEVALUE(targetLeafNode, CMD_EXP_NODE_LEFTOPERAND);
        [self.symbolTable unaddrUpdatePointIdentifyWithName:identifyName value:value];//
    
    }else
     {
         __QBDF_ERROR__([NSString stringWithFormat:@"error or not support ["]);
         
         return -1;
     }
       
    
    return 1;
}

- (int)_QBDF_EXP_OPERATOR_Assign:(NSDictionary *)node
{
    //assign表达式结果都是1
    NSDictionary *leftNode = READNODEVALUE(node, CMD_EXP_NODE_LEFTOPERAND);
    if(ISNODEVALUE_EQUAL(leftNode, CMD_EXP_NODE_TYPE, CMD_EXP_NODE_TYPEVAL_OPERATOR)
     
       ) //这是一个操作数
    {
        [self _QBDF_EXP_OPERATOR_LEFTOperatorASSIGN:node];
        
    }else{
        NSDictionary *leftleafNode = [self _QBDF_EXP_IMP:READNODEVALUE(node, CMD_EXP_NODE_LEFTOPERAND)];
        if(ISNODEVALUE_EQUAL(leftleafNode,CMD_EXP_NODE_TYPE,CMD_EXP_NODE_TYPEVAL_OPERAND)
           && ISNODEVALUE_EQUAL(leftleafNode,CMD_EXP_NODE_OPERANDTYPE,CMD_EXP_OPERANDTYPE_BIAOSHIFU))
        {
            NSString *varName = READNODEVALUE(leftleafNode, CMD_EXP_NODE_LEFTOPERAND);
            NSDictionary *rightNode = [self _QBDF_EXP_IMP:READNODEVALUE(node, CMD_EXP_NODE_RIGHTOPERAND)];
            id value  = [self _readOperandNodeVal:rightNode];
            [self.symbolTable updateIdentifyValueWithName:varName value:value];
            
        }else
        {
//            NSAssert(0, @"赋值表达式左部变量必须是标识符");
            __QBDF_ERROR__([NSString stringWithFormat:@"赋值表达式左部变量必须是标识符"]);

            return 0;
        }

    }
    return 1;
    
}

- (id)_QBDF_EXP_OPERATOR_Calc:(NSDictionary *)node
{
    NSDictionary *leftRootNode = READNODEVALUE(node, CMD_EXP_NODE_LEFTOPERAND);
    NSDictionary *rightRootNode = READNODEVALUE(node, CMD_EXP_NODE_RIGHTOPERAND);
    if(!leftRootNode || !rightRootNode )
    {
        __QBDF_ERROR__([NSString stringWithFormat:@"操作符需要两个操作数"]);

        return 0;
    }else{
        id leftleafNode= [self _QBDF_EXP_IMP:leftRootNode];
        id rightleafNode= [self _QBDF_EXP_IMP:rightRootNode];
        id leftvalue = [self _readOperandNodeVal:leftleafNode];
        id rightvalue = [self _readOperandNodeVal:rightleafNode];
        int operatorType = (int)[READNODEVALUE(node, CMD_EXP_NODE_OPERATORTYPE) integerValue];
        
        switch (operatorType) {
            case oper_plus:
            {
                double newValue = [leftvalue doubleValue] + [rightvalue doubleValue];
                return [self _createEXPOperAndNode:CMD_EXP_OPERANDTYPE_YUASHIZHI
                                       valBaseType:QBDF_VAR_DECTYPE_DOUBLE
                                           subType:QBDF_VAR_DECTYPE_NOSUB
                                              left:@(newValue)
                                             right:nil
                                         thridNode:nil];
            }
                break;
            case oper_minus:
            {
                double newValue = [leftvalue doubleValue] - [rightvalue doubleValue];
                return [self _createEXPOperAndNode:CMD_EXP_OPERANDTYPE_YUASHIZHI
                                       valBaseType:QBDF_VAR_DECTYPE_DOUBLE
                                           subType:QBDF_VAR_DECTYPE_NOSUB
                                              left:@(newValue)
                                             right:nil
                                         thridNode:nil];
            }
                break;
            case oper_multiply:
            {
                double newValue = [leftvalue doubleValue] * [rightvalue doubleValue];
                return [self _createEXPOperAndNode:CMD_EXP_OPERANDTYPE_YUASHIZHI
                                       valBaseType:QBDF_VAR_DECTYPE_DOUBLE
                                           subType:QBDF_VAR_DECTYPE_NOSUB
                                              left:@(newValue)
                                             right:nil
                                         thridNode:nil];
            }
                break;
            case oper_divide:{
                double newValue = [leftvalue doubleValue] / [rightvalue doubleValue];
                return [self _createEXPOperAndNode:CMD_EXP_OPERANDTYPE_YUASHIZHI
                                       valBaseType:QBDF_VAR_DECTYPE_DOUBLE
                                           subType:QBDF_VAR_DECTYPE_NOSUB
                                              left:@(newValue)
                                             right:nil
                                         thridNode:nil];
            }
            break;
            case oper_mod:
            {
                NSInteger newValue = [leftvalue integerValue] % [rightvalue integerValue];
                return [self _createEXPOperAndNode:CMD_EXP_OPERANDTYPE_YUASHIZHI
                                       valBaseType:QBDF_VAR_DECTYPE_DOUBLE
                                           subType:QBDF_VAR_DECTYPE_NOSUB
                                              left:@(newValue)
                                             right:nil
                                         thridNode:nil];
            }
                break;
                
            default:
                break;
        }
        
    }
    return [QBDFNil new];
}
- (id) _QBDF_EXP_OPERATOR_BITOperator:(NSDictionary *)node
{
    NSArray *subnodes = READNODEVALUE(node, CMD_EXP_NODE_LEFTOPERAND);
    if(!subnodes || (![subnodes isKindOfClass:[NSArray class]])  || ([subnodes count] ==0))
    {
        __QBDF_ERROR__([NSString stringWithFormat:@"逻辑 | 操作符至少有一个操作数"]);
        return @(0);
    }else
    {
        int operType = (int)[READNODEVALUE(node,CMD_EXP_NODE_OPERATORTYPE) integerValue];
    
        long long res = 0;
        for(int i = 0 ;i < [subnodes count];i++)
        {
            NSDictionary *tmpNode = subnodes[i];
            NSDictionary *tmpLeaf = [self _QBDF_EXP_IMP:tmpNode];
            long long value = [[self _readOperandNodeVal:tmpLeaf]  longLongValue];
            if (i == 0) {
                res = value;
            }else{
                if(operType == '|')
                {
                    res = res | value;
                }else if(operType == '^')
                {
                    res = res ^ value;
                }else if(operType == '&')
                {
                    
                    res = res & value;
                }
            }
       
           
            
        }
        
        return [self _createEXPOperAndNode:CMD_EXP_OPERANDTYPE_YUASHIZHI
                               valBaseType:QBDF_VAR_DECTYPE_LONGLONG
                                   subType:QBDF_VAR_DECTYPE_NOSUB
                                      left:@(res)
                                     right:nil
                                 thridNode:nil];
        
    }
}


- (int)_QBDF_EXP_OPERATOR_Logic:(NSDictionary *)node
{
    
    NSArray *subnodes = READNODEVALUE(node, CMD_EXP_NODE_LEFTOPERAND);
    if(!subnodes || (![subnodes isKindOfClass:[NSArray class]])  || ([subnodes count] ==0))
    {
        __QBDF_ERROR__([NSString stringWithFormat:@"逻辑操作符至少有一个操作数"]);
        return 0;
    }else
    {
        int operType = (int)[READNODEVALUE(node,CMD_EXP_NODE_OPERATORTYPE) integerValue];
        if(operType == oper_not)
        {
            NSDictionary *firstNode = subnodes[1];
            NSDictionary *leafNode = [self _QBDF_EXP_IMP:firstNode];
            id value = [self _readOperandNodeVal:leafNode];
            if([value integerValue] == 0)
            {
                return 1;
            }else
            {
                return 0;
            }
            
        }else if(operType == oper_or)
        {
            for(int i = 0 ;i < [subnodes count];i++)
            {
                NSDictionary *tmpNode = subnodes[i];
                NSDictionary *tmpLeaf = [self _QBDF_EXP_IMP:tmpNode];
                id value = [self _readOperandNodeVal:tmpLeaf];
                if([value integerValue] == 1)
                {
                    return 1;
                }
                
            }
            return 0;
            
        }else if(operType == oper_and)
        {
            for(int i = 0 ;i < [subnodes count];i++)
            {
                NSDictionary *tmpNode = subnodes[i];
                NSDictionary *tmpLeaf = [self _QBDF_EXP_IMP:tmpNode];
                id value = [self _readOperandNodeVal:tmpLeaf];
                if([value integerValue] == 0)
                {
                    return 0;
                }
                
            }
            return 1;
        }else
        {
//            NSAssert(0,@"暂时还不能处理逻辑标示符%ld",(long)operType);
            __QBDF_ERROR__([NSString stringWithFormat:@"暂时还不能处理逻辑标示符%ld",(long)operType]);

        }
    }
    
    return 0;
}


- (BOOL)_QBDF_EXP_OPERATOR_Relational:(NSDictionary *)node
{
    NSDictionary *leftOperand = [self _QBDF_EXP_IMP:READNODEVALUE(node, CMD_EXP_NODE_LEFTOPERAND)];
    NSDictionary *rightOperand = [self _QBDF_EXP_IMP:READNODEVALUE(node, CMD_EXP_NODE_RIGHTOPERAND)];
    if(!leftOperand || !rightOperand)
    {
//        NSAssert(0, @"关系操作符必须有两个有效的操作数");
        __QBDF_ERROR__([NSString stringWithFormat:@"关系操作符必须有两个有效的操作数"]);

        return 0;
    }else
    {
        
#define RECASE(type , res) \
case type: \
return res;\
break;
        
        NSNumber * leftValue = [self _readOperandNodeVal:leftOperand];
        NSNumber * rightValue = [self _readOperandNodeVal:rightOperand];
        if([leftValue isKindOfClass:[NSNumber class]] && [rightValue isKindOfClass:[NSNumber class]])
        {
            int operatorType = (int)[READNODEVALUE(node, CMD_EXP_NODE_OPERATORTYPE) integerValue];
            NSComparisonResult result =  [leftValue compare:rightValue];
            if(result == NSOrderedAscending) //left < righ
            {
                switch (operatorType){
                    RECASE(oper_gt,NO)
                    RECASE(oper_ge,NO)
                    RECASE(oper_lt,YES)
                    RECASE(oper_le,YES)
                    RECASE(oper_eq,NO)
                    RECASE(oper_ne,YES)
                }
            }else if (result == NSOrderedSame) //left ==right
            {
                
                switch (operatorType)
                {
                    RECASE(oper_gt,NO)
                    RECASE(oper_ge,YES)
                    RECASE(oper_lt,NO)
                    RECASE(oper_le,YES)
                    RECASE(oper_eq,YES)
                    RECASE(oper_ne,NO)
                }
                
            }else{ //left > right
                
                switch (operatorType)
                {
                    RECASE(oper_gt,YES)
                    RECASE(oper_ge,YES)
                    RECASE(oper_lt,NO)
                    RECASE(oper_le,NO)
                    RECASE(oper_eq,NO)
                    RECASE(oper_ne,YES)
                        
                }
            }
            
        }else
        {
            if([leftValue isEqual:rightValue])
            {
                return YES;
            }else{
                return NO;
            }
        }
    }
    return NO;
}


- (NSDictionary *)_readOperandNodeDetialVal:(NSDictionary *)node //有value ，有subType ，有baseTYpe
{
//    if(![node isKindOfClass:[NSDictionary class]])
//    {
//        return node;
//    }
//    NSAssert(ISNODEVALUE_EQUAL(node, CMD_EXP_NODE_TYPE, CMD_EXP_NODE_TYPEVAL_OPERAND), @"只有操作数节点才能取值");
//    
//    id operandType = READNODEVALUE(node, CMD_EXP_NODE_OPERANDTYPE);
//    if([operandType isEqual:CMD_EXP_OPERANDTYPE_BIAOSHIFU])
//    {
//        NSString *varName = READNODEVALUE(node, CMD_EXP_NODE_LEFTOPERAND);
//        id value  =  [self.symbolTable readIdentifyValueByName:varName];
//        return value;
//    }else
//    {
//        id value = READNODEVALUE(node, CMD_EXP_NODE_LEFTOPERAND);
//        return value;
//    }
    return  nil;
}

- (id)_readOperandNodeVal:(NSDictionary *)node
{
    if(![node isKindOfClass:[NSDictionary class]])
    {
        return node;
    }
    NSAssert(ISNODEVALUE_EQUAL(node, CMD_EXP_NODE_TYPE, CMD_EXP_NODE_TYPEVAL_OPERAND), @"只有操作数节点才能取值");
    
    id operandType = READNODEVALUE(node, CMD_EXP_NODE_OPERANDTYPE);
    if([operandType isEqual:CMD_EXP_OPERANDTYPE_BIAOSHIFU])
    {
        NSString *varName = READNODEVALUE(node, CMD_EXP_NODE_LEFTOPERAND);
        id value  =  [self.symbolTable readIdentifyValueByName:varName];
        return value;
    }else
    {
        id value = READNODEVALUE(node, CMD_EXP_NODE_LEFTOPERAND);
        return value;
    }
}
- (id)_QBDF_EXP_OPERAND:(NSDictionary *)node
{
    return node;
}
- (id)_QBDF_EXP_OCCALL:(NSDictionary *)node
{
    NSDictionary *targetNode = READNODEVALUE(node, CMD_EXP_NODE_LEFTOPERAND);
    NSDictionary *targetLeaf = [self _QBDF_EXP_IMP:targetNode];
    
    NSString *selName = [READNODEVALUE(node, CMD_EXP_NODE_RIGHTOPERAND) description];//右侧变量是SEL 这是VM的约定
    NSArray *args = READNODEVALUE(node, CMD_EXP_NODE_THIRDOPERAND);
    if(![args isKindOfClass:[NSArray class]])
    {
        args = nil;
    }
    args = [self _getLeafValueOfArray:args];
    id resValue = @{};
    
    if([targetLeaf isKindOfClass:[NSDictionary class]] &&ISNODEVALUE_EQUAL(targetLeaf,CMD_EXP_NODE_TYPE,CMD_EXP_NODE_TYPEVAL_OPERAND))
    {
        //如果是一个操作数
        
        if(ISNODEVALUE_EQUAL(targetLeaf,CMD_EXP_NODE_OPERANDTYPE,CMD_EXP_OPERANDTYPE_BIAOSHIFU))
        {
            //如果是一个Identify
            //判断是类方法还是 非类方法
            NSString *identifyName = READNODEVALUE(targetLeaf, CMD_EXP_NODE_LEFTOPERAND);
            if([self.symbolTable haveIdentifyWithName:identifyName]) //如果中有这个符号，优先认为是实例方法 //其实这里可以改造
            {
                id instance = [self.symbolTable readIdentifyValueByName:identifyName];
                resValue = [[QBDFOCCALLCenter shareInstance] runInstanceMethodOfTargetName:instance sel:selName args:args];
            }else
            {
                id instance = NSClassFromString(identifyName); //其实这里可以全用实例方法的
                if(instance)
                {
                    
                    resValue = [[QBDFOCCALLCenter shareInstance] runInstanceMethodOfTargetName:instance sel:selName args:args];
                    //                  resValue = [[QBDFOCCALLCenter shareInstance] runClassMethodOfClassName:identifyName sel:selName args:args];//这是一个类方法
                }else{
                    __QBDF_ERROR__([NSString stringWithFormat:@"%@ 既不是类也不是变量 在(%@)方法中",identifyName,selName?:@"未知方法"]);
                }
            }
        }else
        {
            //直接运行instance 方法
            id instance = READNODEVALUE(targetLeaf, CMD_EXP_NODE_LEFTOPERAND);
            resValue = [[QBDFOCCALLCenter shareInstance] runInstanceMethodOfTargetName:instance sel:selName args:args];
        }
    }else
    {
        //是一个值啊
        //直接运行instance 方法
        id instance = READNODEVALUE(node, CMD_EXP_NODE_LEFTOPERAND);
        resValue = [[QBDFOCCALLCenter shareInstance] runInstanceMethodOfTargetName:instance sel:selName args:args];
    }
    if(resValue)
    {
//        return [self _createNewIdOperandByValue:resValue];
        return [self _createEXPOperAndNode:CMD_EXP_OPERANDTYPE_YUASHIZHI
                               valBaseType:QBDF_VAR_DECTYPE_ID
                                   subType:QBDF_VAR_DECTYPE_NOSUB
                                      left:resValue
                                     right:nil
                                 thridNode:nil];
    }else
    {
        return [QBDFNil new];
    }

}


- (id)_QBDF_EXP_CCALL:(NSDictionary *)node
{
    NSString *funName = READNODEVALUE(node, CMD_EXP_NODE_LEFTOPERAND) ;
    if(!funName || funName.length == 0)
    {
//        NSAssert(0,@"C方法调用必须要有方法名");
        __QBDF_ERROR__([NSString stringWithFormat:@"C方法调用必须要有方法名"]);

        return [QBDFNil new];
    }
   __autoreleasing NSArray *args = READNODEVALUE(node,CMD_EXP_NODE_RIGHTOPERAND);
    if([self _funJustNeedArgName:funName])
    {
        args = [self _getLeafNameOfArray:args];
    }else{
        args = [self _getLeafValueOfArray:args];
    }
    NSDictionary *dict = [self.symbolTable getBlkByName:funName];
    if(dict)
    {
       return [[self class] QBDF_RunBlkWithNode:dict args:args frameInfo:[self.symbolTable copySymbolsForBlkCall]];
    }else
    {
        BOOL have =  [self.symbolTable haveIdentifyWithName:funName]; //自己定义的block
        if(have)
        {
            id blk = [self.symbolTable readIdentifyValueByName:funName];
            return [[QBDFOCCALLCenter shareInstance] callBLKWithblk:blk args:args ];
        }else
        {
            return [[QBDFCFUNCenter shareInstance] runCFunctionWithName:funName args:args   baseContext:self
                    ];
        }
    }
    
}

- (BOOL)_funJustNeedArgName:(NSString *)funName
{
    NSArray *array = @[@"__QBDF_FREE__",@"@selector"];
    if([array containsObject:funName])
    {
        return YES;
    }else{
        return NO;
    }
    
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

////- (id)_createNewIdOperandByValue:(id)value
////{
////    NSMutableDictionary *newRootNode = [NSMutableDictionary new];
////    newRootNode[CMD_EXP_NODE_TYPE] = CMD_EXP_NODE_TYPEVAL_OPERAND;
//////    newRootNode[CMD_EXP_NODE_OPERANDTYPE] = CMD_EXP_OPERANDTYPE_ID;
////    newRootNode[CMD_EXP_NODE_OPERATORDESC] = CMD_EXP_NODE_TYPEVAL_OPERAND;
////    newRootNode[CMD_EXP_NODE_LEFTOPERAND] = value;    
////
////    return newRootNode;
////}
////- (id)_createNewIntOperandByValue:(int)value
////{
////    NSMutableDictionary *newRootNode = [NSMutableDictionary new];
////    newRootNode[CMD_EXP_NODE_TYPE] = CMD_EXP_NODE_TYPEVAL_OPERAND;
//////    newRootNode[CMD_EXP_NODE_OPERANDTYPE] = CMD_EXP_OPERANDTYPE_NUM;
////    newRootNode[CMD_EXP_NODE_OPERATORDESC] = CMD_EXP_NODE_TYPEVAL_OPERAND;
////    newRootNode[CMD_EXP_NODE_LEFTOPERAND] = @(value);
////    return newRootNode;
////}
////- (id)_createNewDoubleOperandByValue:(double)value
////{
////    NSMutableDictionary *newRootNode = [NSMutableDictionary new];
////    newRootNode[CMD_EXP_NODE_TYPE] = CMD_EXP_NODE_TYPEVAL_OPERAND;
//////    newRootNode[CMD_EXP_NODE_OPERANDTYPE] = CMD_EXP_OPERANDTYPE_DOUBLE;
////    newRootNode[CMD_EXP_NODE_OPERATORDESC] = CMD_EXP_NODE_TYPEVAL_OPERAND;
////    newRootNode[CMD_EXP_NODE_LEFTOPERAND] = @(value);
////    return newRootNode;
//}

- (NSArray *)_getLeafNameOfArray:(NSArray *)args
{
   __autoreleasing NSMutableArray *resArray = [NSMutableArray new];
    for(int i = 0; i < [args count];i++)
    {
        NSDictionary *node = args[i];
        id returnValue = [self _QBDF_EXP_IMP:node];
        if(returnValue) //TODO:FIX 取值
        {
            id value = nil;
            if([returnValue isKindOfClass:[NSDictionary class]] && [returnValue[CMD_EXP_NODE_TYPE] isEqual:CMD_EXP_NODE_TYPEVAL_OPERAND]
               )
            {
                //如果返回的是一个标识符
                NSString *operandType = READNODEVALUE(node, CMD_EXP_NODE_OPERANDTYPE);
                if([operandType isEqual:CMD_EXP_OPERANDTYPE_BIAOSHIFU])
                {
                    NSString *varName = READNODEVALUE(node, CMD_EXP_NODE_LEFTOPERAND);
                    value = varName;
                }else
                {
                    value = READNODEVALUE(node, CMD_EXP_NODE_LEFTOPERAND);
                    
                }
                
            }
            returnValue = value;
        }else{
            returnValue = [QBDFNil new];
        }
        
        [resArray addObject:returnValue?:@""];
    }
    return resArray;
}

- (NSArray *)_getLeafValueOfArray:(NSArray *)args
{
    NSMutableArray *resArray = [NSMutableArray new];
    for(int i = 0; i < [args count];i++)
    {
        NSDictionary *node = args[i];
        id returnValue = [self _QBDF_EXP_IMP:node];
        if(returnValue) //TODO:FIX 取值
        {
            id value = nil;
            if([returnValue isKindOfClass:[NSDictionary class]]
               && [returnValue[CMD_EXP_NODE_TYPE] isEqual:CMD_EXP_NODE_TYPEVAL_OPERAND] //如果是操作室，直接去的操作数的填充临时变量
               )
            {
                //如果返回的是一个标识符
                NSString *operandType = READNODEVALUE(node, CMD_EXP_NODE_OPERANDTYPE);
                if([operandType isEqual:CMD_EXP_OPERANDTYPE_BIAOSHIFU])
                {
                    
                    
                    NSString *varName = READNODEVALUE(node, CMD_EXP_NODE_LEFTOPERAND);
                    QBDFIdentifyType type =[self.symbolTable readIdentifyType:varName];
                    if( type == QBDFIdentifyTypeBLK)
                    {
                        NSDictionary * node  =  [self.symbolTable readIdentifyValueByName:varName];
                        __autoreleasing QBDFBLkTool *tool = [QBDFBLkTool createBLKWithNode:node];
                        tool.frameStack = [self.symbolTable copySymbolsForBlkCall];
                        value = tool;
                    }else
                    {
                        value = [self _readOperandNodeVal:returnValue];
                    }
                }else
                {
                    value = [self _readOperandNodeVal:returnValue];
                }
                
            }else
            {
                value = returnValue;
            }
            
            returnValue = value;
        }else{
            returnValue = [QBDFNil new];
        }
        
        [resArray addObject:returnValue?:[QBDFNil new]];
    }
    return resArray;
}


- (NSArray *)needCopyOfFrameInfo
{
    return [self.symbolTable copySymbolsForBlkCall];
}
- (void)dealloc
{
   // NSLog(@"QBDFSymbolTableContent dealloc");
}

#pragma mark -
@end


@implementation QBDFVMContext(funcall)

+ (id)QBDF_RunBlkWithNode:(NSDictionary *)node args:(NSArray *)args frameInfo:(NSArray *)frameInfo
{
    QBDFVMContext *newSubContext = [QBDFVMContext createBlkCallContextWithNode:node superFrame:frameInfo args:args]; //暂不支持捕获外部变量
    return [newSubContext readRETValue];
}

+ (id)QBDF_RUNOCMTHDWithNode:(NSDictionary *)node args:(NSArray *)args  sel:(SEL)sel target:(id)target
{
    QBDFVMContext *newSubContext = [QBDFVMContext createOCMTHDCallContextWithNode:node superFrame:nil args:args sel:sel target:target]; //暂不支持捕获外部变量
    return [newSubContext readRETValue];
}
@end
