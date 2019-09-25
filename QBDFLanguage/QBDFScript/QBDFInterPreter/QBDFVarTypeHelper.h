//
//  QBDFVarTypeHelper.h
//  TestQBDFScript
//
//  Created by fatboyli on 2017/8/9.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ffi.h"

@interface QBDFVarTypeHelper : NSObject

+ (BOOL)isVarDefineTokenName:(NSString *)tokenName;
+ (NSString *)QBDFSupportVarDecTypeCode:(NSString *)type;
+ (void)unAddrUpdatePointValueByPoint:(void *)ptr subType:(NSString *)subTpe value:(id)value name:(NSString *)name;
+ (id)readUnAddrPointValueByPoint:(void *)ptr subType:(NSString *)subTpe  name:(NSString *)name;

+ (void)updatePointValueByPoint:(void *)ptr index:(int)index subType:(NSString *)subTpe value:(id)value name:(NSString *)name;
+ (id)readPointValueByPoint:(void *)ptr index:(int)index subType:(NSString *)subTpe  name:(NSString *)name;




+ (NSString *)typeElemenNameOfType:(NSString *)type;

+ (NSString *)typeElemenNameWithoutLengthOfType:(NSString *)type;

//for struct
+ (NSDictionary *)typeSizeDict;
+ (int)specialOffSetValue:(NSString *)type;
+ (id)defaultValueOfType:(NSString *)thetype;


+ (int)sizeofTypeWithTypeCode:(NSString *)code;

//ffi
+ (ffi_type *)ffiTypeWithEncodingChar:(NSString *)c;

@end
