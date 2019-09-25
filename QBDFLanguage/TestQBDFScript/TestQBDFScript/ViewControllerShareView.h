//
//  ViewControllerShareView.h
//  TestQBDFScript
//
//  Created by fatboyli on 2017/5/31.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef  struct myStruct
{
    int c;              //4         //4
    CGSize size;        //16        //8
    double b;           //8         //8
    CGRect rect;        //32        //16
    int d;              //4
    
}MYStruct;

typedef  struct myStructB
{
    int a;
    int b;
    
}MYStructB;


@interface testBaseView : UIView

@end

@interface testBaseViewB : testBaseView

@end
@interface testBaseViewC : testBaseViewB



@end

@interface testSELMethodCls : UIView

- (void)testA:(SEL)theA;

@end



@interface ViewControllerShareView : UIView{
    int good;
    NSString *bad;
    CGFloat f1;
    NSInteger   b;
    BOOL        c;
}
+(instancetype)shareInstance;
- (void)needBlockParams:(NSString *)name block:(void (^)(int a ,int b ))block;
- (void)testOverrider;
- (void)setupUI;
- (MYStruct)getMyStruct;
@end
