//
//  QBDFScriptMainDefine.m
//  TestQBDFScript
//
//  Created by fatboyli on 2017/6/9.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBDFScriptMainDefine.h"

int __QBDF_ERROR__(NSString *msg)
{
    NSLog(@"!!ERROR!! %@",msg);
    NSCAssert(0, msg);//
    return 0;
}
