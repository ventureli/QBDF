//
//  QBDFVM.m
//  QBDFScript
//
//  Created by fatboyli on 2017/5/17.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "QBDFVM.h"
#import "QBDFVMContext.h"

///////////////////

 NSString        *__QBDF_DECCLS_ONCE__ = @"__QBDF_DECCLS_ONCE__";
 NSString        *__QBDF_IMPCLS_ONCE__ = @"__QBDF_IMPCLS_ONCE__";





@interface QBDFVM()
{
    NSMutableDictionary            *_QBDFENV;
    
    NSMutableDictionary            *_HashStore;
    
}
@end

@implementation QBDFVM

- (instancetype)init{
    NSAssert(0, @"cannot init QBDFVM please use [QBDFVM shareInstance] instead");
    return nil;
}

- (instancetype)_initB
{
    self = [super init];
    if(self)
    {
        _QBDFENV = [NSMutableDictionary new];
        _HashStore = [NSMutableDictionary new];
        [self initENV];
    }
    return self;
}


- (void)initENV
{
    _QBDFENV[__QBDF_DECCLS_ONCE__] = @(1);
    _QBDFENV[__QBDF_IMPCLS_ONCE__] = @(1);
}



+ (instancetype)shareInstance
{
    static QBDFVM *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[QBDFVM alloc] _initB];
    });
    return instance;
}


- (id)evalCode:(NSArray *)code withInitEnvVar:(NSDictionary *)dict
{
    QBDFVMContext *context = [QBDFVMContext createDefaultContextWithSymbol:dict codes:code];
    return  [context readRETValue];

}

- (id)evalCode:(NSArray *)code withInitEnvVar:(NSDictionary *)dict withReadDict:(NSMutableDictionary *)readDict
{
    QBDFVMContext *context = [QBDFVMContext createDefaultContextWithSymbol:dict codes:code];
    NSArray *allkeys = [readDict allKeys];
    for(int i = 0 ;i < [allkeys count];i++)
    {
        NSString *key = allkeys[i];
        id value = [context readSymbValue:key];
        if(value)
        {
            readDict[key] = value;
        }
    }
    return [context readRETValue];
}


- (void)setQBDFENV:(id)val  forKey:(NSString *)key
{
    if(key)
    {
        _QBDFENV[key] = val;
    }
}
- (id)getQBDFENV:(NSString *)key
{
    if(key)
    {
        return _QBDFENV[key];
    }else{
        return nil;
    }
}

- (void)setQBDFUserDefault:(id)val  forKey:(NSString *)key
{
    NSUserDefaults *stand = [NSUserDefaults standardUserDefaults];
    if(key &&  val)
    {
        [stand setObject:val forKey:key];
    }
    [stand synchronize];
}

- (id)getQBDFUserDefault:(NSString *)key
{
    if(key)
    {
        NSUserDefaults *stand = [NSUserDefaults standardUserDefaults];
        id val = [stand objectForKey:key];
        return val;
    }
    return nil;

}


- (void)setQBDFValue:(id)value forKey:(NSString *)key
{
    if(key)
    {
        _HashStore[key] = value;
        
    }
}
- (id)getQBDFValue:(NSString *)key
{
    if(key)
    {
        return _HashStore[key];
   
    }else{
        return nil;
    }
}



@end
