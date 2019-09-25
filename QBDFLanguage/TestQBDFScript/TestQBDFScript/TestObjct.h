//
//  TestObjct.h
//  TestQBDFScript
//
//  Created by fatboyli on 2017/8/15.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TestObjtViewA : UIView

@end
@interface TestObjtViewB : UIView

@end

@interface TestObjct : NSObject

+ (void)getCharPTR:(char *)theptr;
+ (void)getUNCharPTR:(unsigned char *)theptr;
+ (void)getShortPTR:(short *)theptr;
+ (void)getUNShortPTR:(unsigned short *)theptr;
+ (void)getLongPTR:(long *)theptr;
+ (void)getUNLongPTR:(unsigned long *)theptr;
+ (void)getLongLongPTR:(unsigned long *)theptr;
+ (void)getUNLongLongPTR:(unsigned long long *)theptr;
+ (void)getfloatPTR:(float *)theptr;
+ (void)getDoublePTR:(double *)theptr;
+ (void)getCGFloatPTR:(CGFloat *)theptr;
+ (void)getNSIntergerPTR:(NSInteger *)theptr;
+ (void)getNSUIntergerPTR:(NSUInteger *)theptr;
+ (void)getVOIDPTR:(void *)theptr;
+ (void)getCGSizePTR:(CGSize *)theptr;
+ (void)getCGPointPTR:(CGPoint *)theptr;
+ (void)getCGRectPTR:(CGRect *)theptr;
+ (void)getNSRangePTR:(NSRange *)theptr;
+ (void)getUIEdgeInsetsPTR:(UIEdgeInsets *)theptr;
+ (void)getUIViewPTR:(UIView **)theptr;


+ (void)newLongPtr:(long *)thetpr;

@end
