//
//  QBDFBLkTool.h
//  TestQBDFScript
//
//  Created by fatboyli on 2017/6/4.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBDFMthdSign.h"
@interface QBDFBLkTool : NSObject
{
    

}

@property(nonatomic ,strong) NSDictionary            *node;
@property(nonatomic ,strong) NSArray                 *frameStack;
@property(nonatomic ,strong) QBDFMthdSign            *sign;

+ (id)createBLKWithNode:(NSDictionary *)ndoe;
- (void *)blockPtr;


@end


