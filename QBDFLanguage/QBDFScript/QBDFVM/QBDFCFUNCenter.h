//
//  QBDFCFUNCenter.h
//  QBDFScript
//
//  Created by fatboyli on 17/5/22.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBDFCFUNCenter : NSObject

+(instancetype)shareInstance;

- (id)runCFunctionWithName:(NSString *)name args:(NSArray*)args  baseContext:(id)context;

+ (NSString *) stringWithFormat: (NSString *) format arguments: (NSArray *) arguments;

@end
