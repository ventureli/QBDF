//
//  TestObjct.m
//  TestQBDFScript
//
//  Created by fatboyli on 2017/8/15.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "TestObjct.h"

@implementation TestObjtViewA


- (void)dealloc
{
    NSLog(@"TestObjtViewA dealloc");
}
@end

@implementation TestObjtViewB

- (void)dealloc
{
    NSLog(@"TestObjtViewB dealloc");
}
@end
//

@implementation TestObjct
+ (void)getCharPTR:(char *)theptr
{
    *theptr = 'A';
}
+ (void)getUNCharPTR:(unsigned char *)theptr
{
    
    *theptr = 'B';
}
+ (void)getShortPTR:(short *)theptr
{
    
    *theptr = -101;
}
+ (void)getUNShortPTR:(unsigned short *)theptr
{
    
    *theptr = 102;
}
+ (void)getLongPTR:(long *)theptr
{
    *theptr = -103;
}
+ (void)getUNLongPTR:(unsigned long *)theptr
{
    *theptr = 104;
}
+ (void)getLongLongPTR:(unsigned long *)theptr
{
    
    *theptr = 105;
}
+ (void)getUNLongLongPTR:(unsigned long long *)theptr
{
    *theptr = 106;
}
+ (void)getfloatPTR:(float *)theptr
{
    
    *theptr = 107.01;
}
+ (void)getDoublePTR:(double *)theptr
{
    *theptr = 108.03;
}
+ (void)getCGFloatPTR:(CGFloat *)theptr
{
    *theptr = 109.02;

}
+ (void)getNSIntergerPTR:(NSInteger *)theptr
{
    
    *theptr = 110;
}
+ (void)getNSUIntergerPTR:(NSUInteger *)theptr
{
    *theptr = 111;
}
+ (void)getVOIDPTR:(void *)theptr
{
    NSLog(@"the ptr is:%@",[NSValue valueWithPointer:theptr]);
}
+ (void)getCGSizePTR:(CGSize *)theptr
{
    *theptr = CGSizeMake(112, 345.0);
}
+ (void)getCGPointPTR:(CGPoint *)theptr
{
    
    *theptr = CGPointMake(113, 345.0);
}
+ (void)getCGRectPTR:(CGRect *)theptr
{
    
    *theptr = CGRectMake(114, 223, 222, 2222);//(113, 345.0);
}
+ (void)getNSRangePTR:(NSRange *)theptr
{
    *theptr = NSMakeRange(115, 45);//(114, 223, 222, 2222);
}
+ (void)getUIEdgeInsetsPTR:(UIEdgeInsets *)theptr
{
    *theptr = UIEdgeInsetsMake(116, 22, 333, 333);
}
+ (void)getUIViewPTR:(UIView **)theptr
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(117, 111, 333, 333)];
    *theptr = (__bridge UIView *)((__bridge_retained void *)view);
}


//--------------------------------

+ (void)newLongPtr:(long *)thetpr
{
    NSLog(@"befor the ptr is:%@",@(*thetpr));
    *thetpr = 1000;
    NSLog(@"after the ptr is:%@",@(*thetpr));
}

@end
