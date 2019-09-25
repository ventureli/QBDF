//
//  QBDFMethodSignature.h
//
//  Created by fatboyli on 17/5/22.
//  Copyright © 2017年 fatboyli. All rights reserved.
//


#import <Foundation/Foundation.h>



//FFI_EXTERN ffi_type ffi_type_cgrect;

@interface QBDFMthdSign : NSObject



@property (nonatomic, readonly) NSString *types;
@property (nonatomic, readonly) NSArray *argumentTypes;
@property (nonatomic, readonly) NSString *returnType;

- (instancetype)initWithRetBaseType:(NSString *)retBaseType retSubType:(NSString *)retSubType argtyps:(NSArray *)decArray;

@end
