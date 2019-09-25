//
//  QBDFSYSCenter+SuperCall.m
//  TestQBDFScript
//
//  Created by fatboyli on 2017/8/4.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "QBDFSYSCenter+SuperCall.h"

@implementation QBDFSYSCenter (SuperCall)
#pragma mark -forSuperCall
- (id)readCallSuperClassWithKey:(NSString *)key
{
    if(!key)
    {
        return nil;
    }
    @synchronized (self) {
        return self.callSuperClassMethod[key];
    }
}

- (void)deleteCallSuperClassWithKey:(NSString *)key
{
    if(!key)
    {
        return;
    }
    @synchronized (self) {
        return [self.callSuperClassMethod  removeObjectForKey:key];
    }
    
}
- (void)updateCallSuperClassWithKey:(NSString *)key value:(id)value
{
    if(!key)
    {
        return;
    }
    @synchronized (self)
    {
        self.callSuperClassMethod[key] = value?:@"";
    }
}

@end
