//
//  QBDFSymbolTableItem.h
//  TestQBDFScript
//
//  Created by fatboyli on 2017/8/10.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class QBDFSymbolTableIdentifyItem;
@class QBDFSymbolTableBLKItem;
@interface QBDFSymbolTableItemFactory : NSObject

+ (QBDFSymbolTableIdentifyItem *)createIdentifyItemWithDecBaseType:(NSString *)baseType decSubType:(NSString *)subType;

+ (QBDFSymbolTableBLKItem *)createBlokItemWithName:(NSString *)name nodes:(id)nodes;

@end


@interface QBDFSymbolTableItem : NSObject

@property(nonatomic ,copy)NSString                  *name;

@end


@interface QBDFSymbolTableBLKItem : QBDFSymbolTableItem
@property(nonatomic ,strong)id                           nodes;
@end
