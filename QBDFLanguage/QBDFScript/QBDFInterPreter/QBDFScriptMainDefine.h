//
//  QBDFScriptMainDefine.h
//  QBDFScript
//
//  Created by fatboyli on 2017/5/14.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef QBDFScriptMainDefine_h
#define QBDFScriptMainDefine_h


//#define QBDF_NOTMIX_CODE

#ifdef QBDF_NOTMIX_CODE

#define CMD_LINE                                @"cmdLine"
#define CMD_TYEP                                @"cmdType"
#define CMD_LEFTOPER                            @"leftOper"
#define CMD_RIGHTOPER                           @"rightoper"


#define CMD_VARI_TYPE_SPEC                      @"vari_dec_type_spec"
#define CMD_VARI_DEC_SUBTYPE_SPEC               @"vari_dec_sub_type_spec"

#define CMD_VARI_DEC_NAME                       @"vari_dec_name"

//JMP
#define CMD_JP_CONDITION                        @"jump_condition"
#define CMD_JP_TARGET_LINE                      @"jump_target_line"
#define CMD_JP_NEED_SYNCLIST                    @"jump_target_line_needSyncList"
#define CMD_BOOKMARK                            @"jump_bookMark"

//expression define
#define CMD_EXP_TREE                            @"exp_tree"

#define CMD_EXP_NODE_TYPE                       @"type"
#define CMD_EXP_NODE_TYPEVAL_OPERATOR           @"operator"
#define CMD_EXP_NODE_TYPEVAL_OPERAND            @"operand"
#define CMD_EXP_NODE_TYPEVAL_CCALL              @"CCALL"
#define CMD_EXP_NODE_TYPEVAL_OCCALL             @"OCALL"

#define CMD_EXP_NODE_OPERATORTYPE               @"operatortype"
#define CMD_EXP_NODE_OPERANDTYPE                @"operandtype"

#define CMD_EXP_NODE_OPERAND_VALUE_BASETYPE     @"valbaseType"
#define CMD_EXP_NODE_OPERAND_VALUE_SUBTYPE      @"valSubType"

//BLOCK or FUNC

#define CMD_EXP_NEEDTMPVAR                      @"needtmpvar"

#define CMD_EXP_NODE_OPERATORDESC               @"operatordesc"
#define CMD_EXP_NODE_LEFTOPERAND                @"left-operand"
#define CMD_EXP_NODE_RIGHTOPERAND               @"right-operand"
#define CMD_EXP_NODE_THIRDOPERAND               @"third-operand"

//这几个key 不能改，其余的都可以 要改也可以，吧block那个也改掉，否则block不完备

#define CMD_EXP_OPERANDTYPE_BIAOSHIFU           @"biaoshifu" //变量
#define CMD_EXP_OPERANDTYPE_YUASHIZHI           @"yuanshizhi" //变量

#define CMD_EXP_RET_TARGETLINE                  @"ret_target_line"
//cls


#define CMD_FUN_ARG                             @"arg"
#define CMD_FUN_RET                             @"ret"
#define CMD_FUN_CMD                             @"cmds"
#define CMD_FUN_NAME                            @"funname"

#define CMD_FUN_ARG_BASETYPE                    @"arg_type_dec"
#define CMD_FUN_ARG_SUBTYPE                     @"arg_subtype_dec"
#define CMD_FUN_ARG_NAME                        @"arg_name"


#define CMD_FUN_RET_BASETYPE                    @"ret_baseType"
#define CMD_FUN_RET_SUBTYPE                     @"ret_subType"



#define QBDF_VAR_DECTYPE_CHAR                   @"char"
#define QBDF_VAR_DECTYPE_UNCHAR                 @"unsigned char"
#define QBDF_VAR_DECTYPE_SHORT                  @"short"
#define QBDF_VAR_DECTYPE_UNSHORT                @"unsigned short"
#define QBDF_VAR_DECTYPE_INT                    @"int"
#define QBDF_VAR_DECTYPE_UNINT                  @"unsigned int"
#define QBDF_VAR_DECTYPE_LONG                   @"long"
#define QBDF_VAR_DECTYPE_UNLONG                 @"unsigned long"
#define QBDF_VAR_DECTYPE_LONGLONG               @"long long"
#define QBDF_VAR_DECTYPE_UNLONGLONG             @"unsigned long long"
#define QBDF_VAR_DECTYPE_FLOAT                  @"float"
#define QBDF_VAR_DECTYPE_DOUBLE                 @"double"
#define QBDF_VAR_DECTYPE_BOOL                   @"BOOL"
#define QBDF_VAR_DECTYPE_NSINTEGER              @"NSInteger"
#define QBDF_VAR_DECTYPE_NSUINTEGER             @"NSUInteger"
#define QBDF_VAR_DECTYPE_CGFLOAT                @"CGFloat"
#define QBDF_VAR_DECTYPE_VOID                   @"void"
#define QBDF_VAR_DECTYPE_CGSIZE                 @"CGSize"
#define QBDF_VAR_DECTYPE_CGRECT                 @"CGRect"
#define QBDF_VAR_DECTYPE_NSRANGE                @"NSRange"
#define QBDF_VAR_DECTYPE_CGPOINT                @"CGPoint"
#define QBDF_VAR_DECTYPE_UIEDEGEINSETS          @"UIEdgeInsets"
#define QBDF_VAR_DECTYPE_ID                     @"id"
#define QBDF_VAR_DECTYPE_SEL                    @"SEL"
#define QBDF_VAR_DECTYPE_POINT                  @"point"        //指针

#define QBDF_VAR_DECTYPE_STRUCT                 @"struct"        //指针

#define QBDF_VAR_DECTYPE_UNKNOW                 @"unknow"        //指针
#define QBDF_VAR_DECTYPE_NOSUB                  @""        //指针
//ret
#define CMD_CLSD_NAME                           @"clsName"
#define CMD_CLSD_SUPNAME                        @"supName"
#define CMD_CLSD_PROTOLS                        @"protocls"
#define CMD_CLSD_PROPTYS                        @"propertys"

#define CMD_CLSD_PROPTY_NAME                    @"propName"
#define CMD_CLSD_PROPTY_BASETYPE                @"propBASETYPE"
#define CMD_CLSD_PROPTY_SUBTYPE                 @"propSUBTYPE"
#define CMD_CLSD_PROPTY_OWNERDEC                @"propOwnerdec"



//

#define CMD_CLSIMP_NAME                         @"clsName"
#define CMD_CLSIMP_MTHD                         @"mthd"

#define CMD_CLSIMP_MTHODSEL                     @"sel"
#define CMD_CLSIMP_MTHODRET                     @"ret"
#define CMD_CLSIMP_MTHODXINGCAN                 @"xingcan"
#define CMD_CLSIMP_MTHODISCLS                   @"iscls"
#define CMD_CLSIMP_MTHODCMD                     @"cmds"



/////////////////////////////////////////
//CMD 支持的指令
#define CMD_TYPE_VARDEF                         @"VD"      //变量定义
#define CMD_TYPE_EXP                            @"EXP"     //表达式
#define CMD_TYPE_JZ                             @"JZ"      //为0跳转
#define CMD_TYPE_JMP                            @"JMP"     //无条件跳转
#define CMD_TYPE_EXT                            @"EXT"     //推出
#define CMD_TYPE_RET                            @"RET"     //RETURN
#define CMD_TYPE_ENT                            @"ENT"     //进入子域
#define CMD_TYPE_LEV                            @"LEV"     //退出子域
#define CMD_TYPE_BLKDEC                         @"BLKD"    //block 定义
#define CMD_TYPE_CLSDEC                         @"CLSD"    //类定义
#define CMD_TYPE_CLSIMP                         @"CLSIMP"  //类实现
#define CMD_TYPE_STUCTDEC                       @"STRUCTDEC"     //代表弹出生成新的Frame


#else


#define CMD_LINE                                @"1001"
#define CMD_TYEP                                @"1002"
#define CMD_LEFTOPER                            @"1003"
#define CMD_RIGHTOPER                           @"1004"


#define CMD_VARI_TYPE_SPEC                      @"1005"
#define CMD_VARI_DEC_SUBTYPE_SPEC               @"1006"

#define CMD_VARI_DEC_NAME                       @"1007"

//JMP
#define CMD_JP_CONDITION                        @"1008"
#define CMD_JP_TARGET_LINE                      @"1009"
#define CMD_JP_NEED_SYNCLIST                    @"1010"
#define CMD_BOOKMARK                            @"1011"

//expression define
#define CMD_EXP_TREE                            @"2001"

#define CMD_EXP_NODE_TYPE                       @"2002"
#define CMD_EXP_NODE_TYPEVAL_OPERATOR           @"2003"
#define CMD_EXP_NODE_TYPEVAL_OPERAND            @"2004"
#define CMD_EXP_NODE_TYPEVAL_CCALL              @"2005"
#define CMD_EXP_NODE_TYPEVAL_OCCALL             @"2006"

#define CMD_EXP_NODE_OPERATORTYPE               @"2007"
#define CMD_EXP_NODE_OPERANDTYPE                @"2008"

#define CMD_EXP_NODE_OPERAND_VALUE_BASETYPE     @"2009"
#define CMD_EXP_NODE_OPERAND_VALUE_SUBTYPE      @"2010"

//BLOCK or FUNC

#define CMD_EXP_NEEDTMPVAR                      @"2011"

#define CMD_EXP_NODE_OPERATORDESC               @"2012"
#define CMD_EXP_NODE_LEFTOPERAND                @"2013"
#define CMD_EXP_NODE_RIGHTOPERAND               @"2014"
#define CMD_EXP_NODE_THIRDOPERAND               @"2015"


#define CMD_EXP_OPERANDTYPE_BIAOSHIFU           @"2016" //变量
#define CMD_EXP_OPERANDTYPE_YUASHIZHI           @"2017" //变量

#define CMD_EXP_RET_TARGETLINE                  @"2018"

#define CMD_FUN_ARG                             @"3001"
#define CMD_FUN_RET                             @"3002"
#define CMD_FUN_CMD                             @"3003"
#define CMD_FUN_NAME                            @"3004"

#define CMD_FUN_ARG_BASETYPE                    @"3005"
#define CMD_FUN_ARG_SUBTYPE                     @"3006"
#define CMD_FUN_ARG_NAME                        @"3007"


#define CMD_FUN_RET_BASETYPE                    @"3008"
#define CMD_FUN_RET_SUBTYPE                     @"3009"


//这几个key 不能改，其余的都可以 要改也可以，吧block那个也改掉，否则block不完备


#define QBDF_VAR_DECTYPE_CHAR                   @"4001"
#define QBDF_VAR_DECTYPE_UNCHAR                 @"4002"
#define QBDF_VAR_DECTYPE_SHORT                  @"4003"
#define QBDF_VAR_DECTYPE_UNSHORT                @"4004"
#define QBDF_VAR_DECTYPE_INT                    @"4005"
#define QBDF_VAR_DECTYPE_UNINT                  @"4006"
#define QBDF_VAR_DECTYPE_LONG                   @"4007"
#define QBDF_VAR_DECTYPE_UNLONG                 @"4008"
#define QBDF_VAR_DECTYPE_LONGLONG               @"4009"
#define QBDF_VAR_DECTYPE_UNLONGLONG             @"4010"
#define QBDF_VAR_DECTYPE_FLOAT                  @"4011"
#define QBDF_VAR_DECTYPE_DOUBLE                 @"4012"
#define QBDF_VAR_DECTYPE_BOOL                   @"4013"
#define QBDF_VAR_DECTYPE_NSINTEGER              @"4014"
#define QBDF_VAR_DECTYPE_NSUINTEGER             @"4015"
#define QBDF_VAR_DECTYPE_CGFLOAT                @"4016"
#define QBDF_VAR_DECTYPE_VOID                   @"4017"
#define QBDF_VAR_DECTYPE_CGSIZE                 @"4018"
#define QBDF_VAR_DECTYPE_CGRECT                 @"4019"
#define QBDF_VAR_DECTYPE_NSRANGE                @"4020"
#define QBDF_VAR_DECTYPE_CGPOINT                @"4021"
#define QBDF_VAR_DECTYPE_UIEDEGEINSETS          @"4022"
#define QBDF_VAR_DECTYPE_ID                     @"4023"
#define QBDF_VAR_DECTYPE_SEL                    @"4024"
#define QBDF_VAR_DECTYPE_POINT                  @"4025"        //指针

#define QBDF_VAR_DECTYPE_STRUCT                 @"4026"        //指针

#define QBDF_VAR_DECTYPE_UNKNOW                 @"4027"        //指针
#define QBDF_VAR_DECTYPE_NOSUB                  @""        //指针
//ret
//cls

#define CMD_CLSD_NAME                           @"5001"
#define CMD_CLSD_SUPNAME                        @"5002"
#define CMD_CLSD_PROTOLS                        @"5003"
#define CMD_CLSD_PROPTYS                        @"5004"

#define CMD_CLSD_PROPTY_NAME                    @"5005"
#define CMD_CLSD_PROPTY_BASETYPE                @"5006"
#define CMD_CLSD_PROPTY_SUBTYPE                 @"5007"
#define CMD_CLSD_PROPTY_OWNERDEC                @"5008"



//

#define CMD_CLSIMP_NAME                         @"5009"
#define CMD_CLSIMP_MTHD                         @"5010"

#define CMD_CLSIMP_MTHODSEL                     @"5011"
#define CMD_CLSIMP_MTHODRET                     @"5012"
#define CMD_CLSIMP_MTHODXINGCAN                 @"5013"
#define CMD_CLSIMP_MTHODISCLS                   @"5014"
#define CMD_CLSIMP_MTHODCMD                     @"5015"



/////////////////////////////////////////
//CMD 支持的指令
#define CMD_TYPE_VARDEF                         @"9001"      //变量定义
#define CMD_TYPE_EXP                            @"9002"     //表达式
#define CMD_TYPE_JZ                             @"9003"      //为0跳转
#define CMD_TYPE_JMP                            @"9004"     //无条件跳转
#define CMD_TYPE_EXT                            @"9005"     //推出
#define CMD_TYPE_RET                            @"9006"     //RETURN
#define CMD_TYPE_ENT                            @"9007"     //进入子域
#define CMD_TYPE_LEV                            @"9008"     //退出子域
#define CMD_TYPE_BLKDEC                         @"9009"    //block 定义
#define CMD_TYPE_CLSDEC                         @"9010"    //类定义
#define CMD_TYPE_CLSIMP                         @"9011"  //类实现
#define CMD_TYPE_STUCTDEC                       @"9012"     //代表弹出生成新的Frame

#endif








typedef enum {
    /* 算数运算 */    
    oper_begin = 128,   // 栈底
    oper_plus,          // 加
    oper_minus,         // 减
    oper_multiply,      // 乘
    oper_divide,        // 除
    oper_mod,           // 模
    oper_power,         // 幂
    oper_positive,      // 正号
    oper_negative,      // 负号
    /* 关系运算 */
    oper_lt,            // 小于 <
    oper_gt,            // 大于 >
    oper_eq,            // 等于
    oper_ne,            // 不等于
    oper_le,            // 不大于 <=
    oper_ge,            // 不小于 >=
    oper_inc,           //++
    oper_Dec,           //--
    oper_arrow,           //->
    
    oper_addr,           //->
    oper_unaddr,           //->
    /* 赋值 */
    oper_assignment,    // 赋值 += -+ ^+ /= 这种暂不支持
    /* 逻辑运算 */
    oper_and,               // 且
    oper_or,                // 或
    oper_not,               // 非
    
    //标识符类型
    oper_value_string,           // String
    oper_value_num,              // Num
    oper_value_double,           // double
    
    oper_identify,         // 符号
    
    //关键字
    oper_kw_while,         // while
    oper_kw_for,           // for
    oper_kw_if,            // if
    oper_kw_else,          // else
    oper_kw_return,        // return
    oper_kw_break,         // break
    oper_kw_continue,      //continue
    
    oper_kw_let,           //let
    oper_kw_struct,        //struct
    oper_kw_intface,       //intface
    oper_kw_propt,         //propty
    oper_kw_end,           //end
    oper_kw_implemt,       //implementati
    oper_over              // 栈底
    
} operator_type;


//vm
typedef enum
{
    QBDFVMStatusSuccess = 0,
    QBDFVMStatusInvalidCodes,
    
}QBDFVMStatus;

#define QBDF_EVAL_STATUES            NSDictionary *
#define QBDF_CMD                     NSDictionary *
#define QBDF_MUCMD                   NSMutableDictionary *

extern NSDictionary                         *QBDF_OPER_DESC;
#define READCMDVALUE(cmd,type)   cmd[type]
#define READCMDTYPE(cmd)   READCMDVALUE(cmd,CMD_TYEP)

#define READNODEVALUE(node,type)   node[type]
#define ISNODEVALUE_EQUAL(node,type, value)   [node[type] isEqual:value]

#define ISCMDTPYE(cmd , type) ([READCMDTYPE(cmd) isEqual:type])



#define QBDF_VERSION         1.6
#define QBDF_VERS_KEY        @"__QBDFVM_VERSION__"
#define QBHD_VERS_KEY        @"__QBHD_VERSION__"

extern  NSString        *__QBDF_DECCLS_ONCE__;
extern  NSString        *__QBDF_IMPCLS_ONCE__;

int __QBDF_ERROR__(NSString *msg);

#endif /* QBDFScriptMainDefine_h */
