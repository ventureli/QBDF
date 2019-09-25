//
//  QBDFScriptInterpreter.h
//  QBDFScript
//
//  Created by fatboyli on 2017/5/14.
//  Copyright © 2017年 fatboyli. All rights reserved.
//
#import <Foundation/Foundation.h>


@interface QBDFScriptInterpreter : NSObject

- (NSArray *) QBDF_TranslateWithFile:(NSString *)filePath;
- (NSArray *) QBDF_TranslateWithString:(NSString *)str;
@end

