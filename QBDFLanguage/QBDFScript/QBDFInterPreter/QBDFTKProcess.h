//
//  QBDFTKProcess.h
//  TestQBDFScript
//
//  Created by fatboyli on 2017/6/6.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface  identifier : NSObject  //符号//废弃
{
@public
    int             token;
    NSString        *name;
    int             class;
    int             type;
    int             value;
    int             Bclass;
    int             Btype;
    id              Bvalue;
    int             line;
}
@end


@interface  QBDFToken : NSObject  //单词
{
@public
    int tokenType;
    NSString *tokenName;
    id tokenValue;
    int lineNumber;
    
}

@end



@interface QBDFTKProcess : NSObject
- (NSArray *) QBDF_AnalysisTokens;

- (instancetype)initWithString:(NSString *)str;
@end
