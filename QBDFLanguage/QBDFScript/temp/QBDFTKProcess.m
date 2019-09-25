//
//  QBDFTKProcess.m
//  TestQBDFScript
//
//  Created by fatboyli on 2017/6/6.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "QBDFTKProcess.h"
#import "QBDFScriptInterpreter.h"

#import "QBDFScriptMainDefine.h"
@implementation identifier
@end
@implementation QBDFToken

@end

///////////////////////
@interface QBDFTKProcess()
{
        NSInteger                    SRCLENGTH ;
    
        NSString                    *OLDSRC,*SRC;
}
@property(nonatomic ,strong)NSMutableArray *tokenArrays;
@end

@implementation QBDFTKProcess


- (instancetype)init
{
//    NSAssert(0, @"不能初始化QBDFTokProcess 请用initWithString");
    __QBDF_ERROR__([NSString stringWithFormat:@"不能初始化QBDFTokProcess 请用initWithString"]);
    
    return nil;
}

- (instancetype)initWithString:(NSString *)str
{
    self =  [super init];
    if(self)
    {
        self.tokenArrays = [NSMutableArray new];
        self->SRC = str;
        self->SRCLENGTH = str.length;
    }
    return self;
}

- (QBDFToken *)_QBDF_FixIdentify:(QBDFToken *)token
{
    #define FIX_IDENTIFY_if(name,type) \
    if([token->tokenName isEqualToString:name])\
    {   \
    token->tokenType = type;\
    }
    #define FIX_IDENTIFY_elseif(name,type) \
    else if([token->tokenName isEqualToString:name])\
    {   \
    token->tokenType = type;\
    }
    
    FIX_IDENTIFY_if(@"if", oper_kw_if)
    FIX_IDENTIFY_elseif(@"else", oper_kw_else)
    FIX_IDENTIFY_elseif(@"while", oper_kw_while)
    FIX_IDENTIFY_elseif(@"for", oper_kw_for)
    FIX_IDENTIFY_elseif(@"return", oper_kw_return)
    FIX_IDENTIFY_elseif(@"break", oper_kw_break)
    FIX_IDENTIFY_elseif(@"continue", oper_kw_continue)
    FIX_IDENTIFY_elseif(@"let", oper_kw_let)
    FIX_IDENTIFY_elseif(@"@interface", oper_kw_intface)
    FIX_IDENTIFY_elseif(@"@property", oper_kw_propt)
    FIX_IDENTIFY_elseif(@"@end", oper_kw_end)
    FIX_IDENTIFY_elseif(@"@implementation", oper_kw_implemt)
    FIX_IDENTIFY_elseif(@"struct", oper_kw_struct)
    
    return token;
}

- (void)_addTokenWithType:(int)type name:(NSString *)name value:(id)tokenValue line:(int)line
{
    QBDFToken *token = [[QBDFToken alloc] init];
    token->tokenType = type;
    token->tokenName = name;
    token->tokenValue = tokenValue;
    token->lineNumber = line;
    if(token->tokenType == oper_identify)
    {
        token = [self _QBDF_FixIdentify:token];
        token = [self _QBDF_FixIdentiyForMuliWordTypeDefine:token];
        
    }
    [self.tokenArrays addObject:token];
}

- (QBDFToken *)_QBDF_FixIdentiyForMuliWordTypeDefine:(QBDFToken *)token
{
    
    static NSArray *canBeAfterunsigned = nil;
    if(!canBeAfterunsigned)
    {
      canBeAfterunsigned =@[@"char",@"short",@"int",@"long"];
      
    }
    QBDFToken *lastToken = [self.tokenArrays lastObject];
    if(!lastToken || lastToken->tokenType ==  oper_begin)
    {
        return token;
    }
    if(token->tokenType == oper_identify)
    {
        if(lastToken->tokenType == oper_identify && [lastToken->tokenName isEqualToString:@"unsigned"] && [canBeAfterunsigned containsObject:token->tokenName])
        {
            token->tokenName = [NSString stringWithFormat:@"unsigned %@",token->tokenName]; //移掉一个，直接添加这个
            [self.tokenArrays removeObject:lastToken];
        }else{
            
            if(lastToken->tokenType == oper_identify
               && ([lastToken->tokenName isEqualToString:@"long"] || [lastToken->tokenName isEqualToString:@"unsigned long"])
               && [token->tokenName isEqualToString:@"long"])
            {
                token->tokenName = [NSString stringWithFormat:@"%@ %@",lastToken->tokenName,token->tokenName]; //移掉一个，直接添加这个
                [self.tokenArrays removeObject:lastToken];
                
            }    
        }
        
    }
    
    return token;
//    STRUCT_ELEMENT_TYPE(@"char",char)
//    STRUCT_ELEMENT_TYPE(@"unsigned char",unsigned char)
//    STRUCT_ELEMENT_TYPE(@"short",short)
//    STRUCT_ELEMENT_TYPE(@"unsigned short",unsigned short)
//    STRUCT_ELEMENT_TYPE(@"int",int)
//    STRUCT_ELEMENT_TYPE(@"unsigned int",unsigned int)
//    STRUCT_ELEMENT_TYPE(@"long",long)
//    STRUCT_ELEMENT_TYPE(@"unsigned long",unsigned long)
//    STRUCT_ELEMENT_TYPE(@"long long",long long)
//    STRUCT_ELEMENT_TYPE(@"unsigned long long",unsigned long long)
//    STRUCT_ELEMENT_TYPE(@"float",float)
//    STRUCT_ELEMENT_TYPE(@"double",double)
//    STRUCT_ELEMENT_TYPE(@"BOOL",BOOL)
//    STRUCT_ELEMENT_TYPE(@"NSInteger",NSInteger)
//    STRUCT_ELEMENT_TYPE(@"NSUInteger",NSUInteger)
//    STRUCT_ELEMENT_TYPE(@"CGFloat",CGFloat)
//    
}
- (NSArray *) QBDF_AnalysisTokens
{
    if(!self.tokenArrays)
    {
        self.tokenArrays = [NSMutableArray new];
    }else{
        [self.tokenArrays removeAllObjects];
    }
    
    [self _addTokenWithType:oper_begin name:@"oper_begin" value:nil line:-1];
    int CURINDX = 0;
    int line = 0;                   // line number
    
    while(CURINDX < SRCLENGTH)
    {
        unichar curChar =  [SRC characterAtIndex:CURINDX];
        if(curChar == 0) //end \0
        {
            break;
        }else if (curChar == '\n')
        {
            ++line;
            CURINDX ++;
        }else if(curChar == '#')
        {
            CURINDX = CURINDX +1;
            while (CURINDX < SRCLENGTH  && [SRC characterAtIndex:CURINDX] != '\n') {
                CURINDX ++; //过滤掉谁
            }
        }else if (curChar == '/') //清除注释
        {
            int nextIndex = CURINDX +1;
            if ( nextIndex < SRCLENGTH && [SRC characterAtIndex:nextIndex]== '/') {
                // skip comments
                CURINDX = nextIndex +1;
                while (CURINDX < SRCLENGTH  && [SRC characterAtIndex:CURINDX] != '\n') {
                    CURINDX ++; //过滤掉谁
                }
            } else
            {
                [self _addTokenWithType:oper_divide name:@"/" value:nil line:line];
                CURINDX = CURINDX +1;
                
                
            }
        }else if (curChar >= '0' && curChar <= '9')
        {       //支持目前只支持10进的用法 不支持开头是0的做法
            long  token_val = curChar - '0';
            int nextIndex = CURINDX +1;
            while ( [SRC characterAtIndex:nextIndex] != 0 && (([SRC characterAtIndex:nextIndex] >= '0' && [SRC characterAtIndex:nextIndex]<= '9' )))
            {
                token_val = token_val *10 + ([SRC characterAtIndex:nextIndex] - '0');
                nextIndex +=1;
            }
            if([SRC characterAtIndex:nextIndex] != '.')
            {
                [self _addTokenWithType:oper_value_num name:[SRC substringWithRange:NSMakeRange(CURINDX, nextIndex - CURINDX)] value:@(token_val) line:line];
                
                CURINDX = nextIndex;
            }else{
                double doubleVal = token_val + 0.0;
                nextIndex +=1;
                double distance = 10;
                while ([SRC characterAtIndex:nextIndex] != 0 && (([SRC characterAtIndex:nextIndex] >= '0' && [SRC characterAtIndex:nextIndex]<= '9' )))
                {
                    doubleVal = doubleVal+ ([SRC characterAtIndex:nextIndex] - '0')/distance;
                    nextIndex +=1;
                    distance = distance *10;
                }
                [self _addTokenWithType:oper_value_double name:[SRC substringWithRange:NSMakeRange(CURINDX, nextIndex - CURINDX)] value:@(doubleVal) line:line];
                CURINDX = nextIndex;
                
            }
            
        }else if ((curChar >= 'a' && curChar <= 'z') || (curChar >= 'A' && curChar <= 'Z') || (curChar == '_')) //这是一个标识符
        {
            
            int nextIndex = CURINDX +1;
           // int hash = curChar;
            
            while ( ([SRC characterAtIndex:nextIndex] >= 'a' && [SRC characterAtIndex:nextIndex] <= 'z')
                   || ([SRC characterAtIndex:nextIndex] >= 'A' && [SRC characterAtIndex:nextIndex] <= 'Z')
                   || ([SRC characterAtIndex:nextIndex] >= '0' && [SRC characterAtIndex:nextIndex] <= '9')
                   || ([SRC characterAtIndex:nextIndex] == '_')
                   )
            {
                nextIndex +=1;
            }
            
            [self _addTokenWithType:oper_identify name:[SRC substringWithRange:NSMakeRange(CURINDX, nextIndex - CURINDX)] value:nil line:line];
            CURINDX = nextIndex;
            
        }else if(curChar == '@' )
        {
            int nextIndex = CURINDX +1;
            if ([SRC characterAtIndex:nextIndex]  == '"')
            {
                NSMutableString *theStr = [[NSMutableString alloc] initWithString:@""];
                //匹配字符串
                nextIndex += 1;
                unichar nextChar = [SRC characterAtIndex:nextIndex];
                while (nextChar != 0 && nextChar != '"' )
                {
                    if (nextChar == '\\') { //转义直接跳过一个
                        nextIndex +=1;
                        nextChar = [SRC characterAtIndex:nextIndex];
                        if(nextChar != 0)
                        {
                            if(nextChar == 'n')
                            {
                                [theStr appendString:@"\n"];
                            }else if(nextChar == 't')
                            {
                                [theStr appendString:@"\t"];
                            }else if(nextChar == '"')
                            {
                                
                                [theStr appendString:@"\""];
                            }else if(nextChar == '\'')
                            {
                                [theStr appendString:@"'"];
                            }
                            
                        }
                        nextIndex +=1;
                        nextChar = [SRC characterAtIndex:nextIndex];
                        
                    }else
                    {
                        if(nextChar == '\n')
                        {
                            ++line;
                        }
                        [theStr appendString:[NSString stringWithFormat:@"%C",nextChar]];
                        nextIndex +=1;
                        nextChar = [SRC characterAtIndex:nextIndex];
                    }
                    
                }
                nextIndex +=1;
                [self _addTokenWithType:oper_value_string name:theStr value:theStr line:line];
                CURINDX = nextIndex;
                
            }else
            {
                //如果@后面不是一个“ 那代表着时一个@类型的关键字
                
                int nextChar =[SRC characterAtIndex:nextIndex];
                if((nextChar >= 'a' && nextChar <= 'z') || (nextChar >= 'A' && nextChar <= 'Z') || (nextChar == '_'))//读取关键字
                {
                    nextIndex +=1;
                    while ( ([SRC characterAtIndex:nextIndex] >= 'a' && [SRC characterAtIndex:nextIndex] <= 'z')
                           || ([SRC characterAtIndex:nextIndex] >= 'A' && [SRC characterAtIndex:nextIndex] <= 'Z')
                           || ([SRC characterAtIndex:nextIndex] >= '0' && [SRC characterAtIndex:nextIndex] <= '9')
                           || ([SRC characterAtIndex:nextIndex] == '_')
                           )
                    {
                        nextIndex +=1;
                    }
                    
                    [self _addTokenWithType:oper_identify name:[SRC substringWithRange:NSMakeRange(CURINDX, nextIndex - CURINDX)] value:nil line:line];
                    
                    CURINDX = nextIndex;
                    
                    
                }else
                {
                    __QBDF_ERROR__([NSString stringWithFormat:@"cannot analysis the token after @"]);
                    return @[];
                    
                }

            }
            
            
        }else if(curChar == '\'')
        {
            int nextIndex = CURINDX +1;
            int nextChar =[SRC characterAtIndex:nextIndex];
            nextIndex ++;
            int nextNextChar =[SRC characterAtIndex:nextIndex];
            
            if(nextNextChar != '\'')
            {
                __QBDF_ERROR__([NSString stringWithFormat:@"char dec must have only one char"]);
                return @[];
            }else{
                [self _addTokenWithType:oper_value_num name:[SRC substringWithRange:NSMakeRange(CURINDX+1, 1)] value:@(nextChar) line:line];
                CURINDX = nextIndex +1;
            }
        }
        else if (curChar == '=') {
            // parse '==' and '='
            int nextIndex = CURINDX +1;
            
            if ([SRC characterAtIndex:nextIndex]  == '=') {
                [self _addTokenWithType:oper_eq name:@"==" value:nil line:line];
                CURINDX = nextIndex +1;
            } else
            {
                [self _addTokenWithType:oper_assignment name:@"=" value:nil line:line];
                CURINDX = nextIndex;
                
            }
        }
        else if (curChar == '+') {
            int nextIndex = CURINDX +1;
            if ([SRC characterAtIndex:nextIndex]  == '+') {
                
                CURINDX = nextIndex +1;
                [self _addTokenWithType:oper_inc name:@"++" value:nil line:line];
                
            } else
            {
                [self _addTokenWithType:oper_plus name:@"+" value:nil line:line];
                CURINDX = nextIndex;
                
            }
            
        }
        else if (curChar == '-') {
            int nextIndex = CURINDX +1;
            if ([SRC characterAtIndex:nextIndex]  == '-') {
                
                CURINDX = nextIndex +1;
                [self _addTokenWithType:oper_Dec name:@"--" value:nil line:line];
            }else if ([SRC characterAtIndex:nextIndex]  == '>') {
                
                CURINDX = nextIndex +1;
                [self _addTokenWithType:oper_arrow name:@"->" value:nil line:line];
            } else
            {
                CURINDX = nextIndex;
                [self _addTokenWithType:oper_minus name:@"-" value:nil line:line];
                
            }
            
        }
        else if (curChar == '!') {
            // parse '!='
            int nextIndex = CURINDX +1;
            if ([SRC characterAtIndex:nextIndex]  == '=')
            {
                [self _addTokenWithType:oper_ne name:@"!=" value:nil line:line];
                CURINDX = nextIndex +1;
                
            }else
            {
                [self _addTokenWithType:'!' name:@"!" value:nil line:line];
                CURINDX = nextIndex;
            }
        }
        else if (curChar == '<') {
            // parse '<='or '<'
            int nextIndex = CURINDX +1;
            if ([SRC characterAtIndex:nextIndex]  == '=')
            {
                [self _addTokenWithType:oper_le name:@"<=" value:nil line:line];
                CURINDX = nextIndex +1;
            } else
            {
                [self _addTokenWithType:oper_lt name:@"<" value:nil line:line];
                CURINDX = nextIndex;
                
            }
        }
        else if (curChar == '>') {
            // parse '>=' or '>'
            int nextIndex = CURINDX +1;
            if ([SRC characterAtIndex:nextIndex]  == '=')
            {
                [self _addTokenWithType:oper_ge name:@">=" value:nil line:line];
                CURINDX = nextIndex +1;
            } else
            {
                [self _addTokenWithType:oper_gt name:@">" value:nil line:line];
                CURINDX = nextIndex;
                
            }
        }
        else if (curChar == '|') {
            // parse '||' //不支持 位操作
            int nextIndex = CURINDX +1;
            if ([SRC characterAtIndex:nextIndex]  == '|') {
                [self _addTokenWithType:oper_or name:@"||" value:nil line:line];
                CURINDX = nextIndex +1;
            }else{
                [self _addTokenWithType:'|' name:@"|" value:nil line:line];
                CURINDX = nextIndex;
            }
        }
        else if (curChar == '&') {
            // parse '&' and '&&'
            int nextIndex = CURINDX +1;
            if ([SRC characterAtIndex:nextIndex]  == '&')
            {
                [self _addTokenWithType:oper_and name:@"&&" value:nil line:line];
                CURINDX = nextIndex +1;
            }else
            {
                [self _addTokenWithType:'&' name:@"&" value:nil line:line];
                CURINDX = nextIndex;
            }
            
        }
        else if (curChar == '%') {
            [self _addTokenWithType:oper_mod name:@"%" value:nil line:line];
            CURINDX += 1;
            
        }
        else if (curChar == '*') {
            CURINDX += 1;
            [self _addTokenWithType:oper_multiply name:@"*" value:nil line:line];
        }
        else if ( curChar == ';'
                 || curChar == '{'
                 || curChar == '}'
                 || curChar == ')'
                 || curChar == '('
                 || curChar == '['
                 || curChar == ']'
                 || curChar == ','
                 || curChar == '.'
                 || curChar == ':'
                 || curChar == '?'
                 || curChar == '^'
                 ) {
            [self _addTokenWithType:curChar name:[SRC substringWithRange:NSMakeRange(CURINDX, 1)] value:nil line:line];
            CURINDX += 1;
        }else if(curChar == ' ' || curChar == '\t')
        {
            CURINDX ++;
        }
        else
        {
            //            assert(0, );
//            NSLog(@"cannot process the char %c at line %ld",curChar,(long)line);
            __QBDF_ERROR__([NSString stringWithFormat:@"cannot process the char at line %ld",(long)line]);
            return @[];
            
        }
    }
    [self _addTokenWithType:oper_over name:@"oper_over" value:nil line:line+1];
    [self _addTokenWithType:oper_over name:@"oper_over" value:nil line:line+1];
    return self.tokenArrays;
}



@end
