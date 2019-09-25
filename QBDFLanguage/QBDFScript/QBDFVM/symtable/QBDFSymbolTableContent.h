//
//  QBDFSymbolTableContent.h
//  TestQBDFScript
//
//  Created by fatboyli on 2017/8/10.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBDFSymbolTableItem.h"

@interface QBDFSymbolTableContent : NSObject
{
    
}
@property(nonatomic ,strong)NSMutableDictionary<NSString * ,QBDFSymbolTableItem *>                 *items;

- (int )addIdentifySymbolWithName:(NSString *)name varType:(NSString *)type subType:(NSString *)subType value:(id)value;
- (int )addIdentifySymbolWithName:(NSString *)name varType:(NSString *)type subType:(NSString *)subType;

- (void)addBlkWithName:(NSString *)name
                 nodes:(NSDictionary *)nodes;
- (QBDFSymbolTableItem *)_getSymbolItemByName:(NSString *)name;
- (void)_deleteSymbItemByName:(NSString *)name;
@end
