//
//  ViewControllerShareView.m
//  TestQBDFScript
//
//  Created by fatboyli on 2017/5/31.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "ViewControllerShareView.h"
#import "QBDFScriptInterpreter.h"
#import "QBDFVM.h"

@interface testDelView : UIView

@end
@implementation testDelView

- (void)dealloc
{
    NSLog(@"dealloc");
}

@end

@interface mycell : UICollectionViewCell

@end

@implementation mycell

- (instancetype)initWithFrame:(CGRect)frame
{
    self =  [super initWithFrame:frame];
    if(self)
    {
//        static NSArray *code = nil;
//        if(!code)
//        {
//            
//            NSString *theStr = [[NSBundle mainBundle] pathForResource:@"res/source_mulicall" ofType:@"m"];
//            QBDFScriptInterpreter *interpreter = [[QBDFScriptInterpreter alloc] init];
//            code =  [interpreter QBDF_TranslateWithFile:theStr]; //编译
//        }
//        [[QBDFVM shareInstance] evalCode:code withInitEnvVar:@{@"baseView":self}];
//        UIImageView *imageView;
//
    
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            
//            id data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://pic1.nipic.com/2009-02-09/200929180899_2.jpg"]];
//            id image = [UIImage imageWithData:data];
//            
//            
//        });
    }
   
    return self;
}

- (void)dealloc
{
    NSLog(@"my cell dealloc");
}

@end

@implementation testBaseViewB

- (instancetype)initWithFrame:(CGRect)frame
{
    
    NSLog(@"native befor testBaseViewB initWithFrame");
    self = [super initWithFrame:frame];
    NSLog(@"native after testBaseViewB initWithFrame");
    return self;
    
}
@end

@implementation testBaseViewC

- (instancetype)initWithFrame:(CGRect)frame
{
    
    NSLog(@"native before testBaseViewC initWithFrame");
    self = [super initWithFrame:frame];
    NSLog(@"native after testBaseViewC initWithFrame");
    return self;
    
}
@end

@implementation testSELMethodCls
- (void)testA:(SEL)theA
{
    NSLog(@"testA: the sel is:%@",NSStringFromSelector(theA));
    NSLog(@"call sel");
    [self performSelector:theA];
    NSLog(@"testA:call over");
    int a = 10;
    [self testM:&a];
}
- (void)testD:(SEL)theA
{
    NSLog(@"testD: sel is:%@",NSStringFromSelector(theA));
    NSLog(@"call sel");
    [self performSelector:theA];
    NSLog(@"testD: over");
}
- (void)testM:(int *)theA
{
    NSLog(@"testM: sel is:%@",NSStringFromSelector(theA));
    NSLog(@"call sel");
    NSLog(@"testM: over");
}

- (void)dealloc
{
    NSLog(@"this is olddealoc");
}

@end

@implementation testBaseView
 - (instancetype)initWithFrame:(CGRect)frame
{
    NSLog(@"native befor testBaseView initWithFrame");
    self = [super initWithFrame:frame];
    NSLog(@"native after testBaseView initWithFrame");
    return self;
    
}


- (void)dealloc
{
    NSLog(@"testBaseView dealloc");
}

@end

@interface mySumply : UICollectionReusableView

@end

@implementation mySumply

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self setBackgroundColor:[UIColor purpleColor]];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.bounds.size.width/2.0, self.bounds.size.height)];
        label.font = [UIFont systemFontOfSize:40];
        label.textColor =[UIColor blackColor];
        label.text = @"good";
        label.textAlignment = 1;
        [self addSubview:label];
    }
    return self;
}

@end

@interface ViewControllerShareView()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UICollectionView *collViewView;
    UICollectionViewLayout *layout;
}
@end
@implementation ViewControllerShareView


- (instancetype)initWithFrame:(CGRect)frame
{
    
    self =  [super initWithFrame:frame];
    [self setupUI];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, 100, 30)];
    [btn setBackgroundColor:[UIColor redColor]];
    
    [self addSubview:btn];
    [btn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
//    UIView *baseView = [[testBaseView alloc] initWithFrame:CGRectZero];

    
    return self;
}

- (void)onClick:(id)sen
{
    [self->collViewView removeFromSuperview];
    self->collViewView = nil;
    self->layout = nil;
    
}

- (void)setupUI
{
    NSLog(@"testBaseView:initWithFrame");
    UICollectionViewFlowLayout *lay = [[UICollectionViewFlowLayout alloc] init];
    
    UICollectionView *collctionView =  [[UICollectionView alloc] initWithFrame:CGRectMake(0, 100, self.bounds.size.width, self.bounds.size.height - 100) collectionViewLayout:lay];
    
    
    [collctionView setBackgroundColor:[UIColor orangeColor]];
    collctionView.autoresizingMask = 18;
    [collctionView registerClass:[mycell class] forCellWithReuseIdentifier:@"cell"]; //注册cell信息
    [collctionView registerClass:[mySumply class] forSupplementaryViewOfKind:@"UICollectionElementKindSectionHeader" withReuseIdentifier:@"header"];
    collctionView.delegate = self;
    collctionView.dataSource = self;
    collctionView.alwaysBounceVertical = YES;
      [self addSubview:collctionView];
    [collctionView reloadData];
    self->collViewView = collctionView;
    self->layout = lay;
    [lay invalidateLayout];
}

+(instancetype)shareInstance
{
    static ViewControllerShareView *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ViewControllerShareView alloc] initWithFrame:CGRectZero];
        instance->good = 20;
        instance->bad = @"bad";
        instance->f1 =34.5;
        instance->c = YES;
        
        
        NSMethodSignature *sig = [instance methodSignatureForSelector:@selector(getsize:)];
        NSLog(@"%@",sig);
    });
    return instance;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    mycell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    UIColor *color = [UIColor redColor];
    [cell setBackgroundColor:color];
    cell.layer.masksToBounds = YES;
    return cell;
}
- (CGFloat)collectionView:(nonnull UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}
- (CGFloat)collectionView:(nonnull UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(50  , 10, 50, 10);

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(self.bounds.size.width, 100);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if([kind isEqualToString:@"UICollectionElementKindSectionHeader"])
    {
        mySumply *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
        return headerView;
    }else
    {
        return nil;
    }
    
    UITapGestureRecognizer *tapGc = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self addGestureRecognizer:tapGc];
    
}

- (void)onTap:(id)gc
{

    
}



- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return  CGSizeMake(300 , 150);
}

//- (void)collectionView:(id)collectionView didSelectItemAtIndexPath:(id)indexPath
//{
//    id message = [NSString stringWithFormat:@"点击了:%@",indexPath.row];
//   id alertView = [[UIAlertView alloc] initWithTitle:@"点击" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:@"OK", nil];
//    [alertView show];
//}



- (void)needBlockParams:(NSString *)name block:(void (^)(int a ,int b ))block
{
    NSLog(@"没有返回值int 类型参数block start");
    if(block)
    {
        
        block(12,34);
    }
    NSLog(@"没有返回值int 类型参数block end");
 
    
}
- (void)needBlockParamsA:(NSString *)name block:(int  (^)(int a ,int b ))block
{
    
    NSLog(@"没有返回值int 类型参数block start");
    int res =  block(12,34);
    NSLog(@"res is:%ld",(long)res);
    NSLog(@"没有返回值int 类型参数block end");
    
}

- (void)needBlockParamsB:(NSString *)name block:(void (^)(id a ,id b ))block
{
    NSLog(@"没有返回值id 类型参数block start");
    block(@"fatboyli",@"good");
    NSLog(@"没有返回值id 类型参数block end");
}

- (void)needBlockParamsC:(NSString *)name block:(CGSize (^)(int a,CGSize b))block
{
    NSLog(@"有返回值CGSize 类型参数block start");
    CGSize size = block(12,CGSizeMake(10, 20));
    NSLog(@"res is:%@",[NSValue valueWithCGSize:size]);
    
    NSLog(@"有返回值CGSize 类型参数block end");
}
- (void)needBlockParamsD:(NSString *)name block:(CGRect (^)(CGRect a))block
{
    NSLog(@"有返回值CGrect 类型参数block start");
    CGRect res = block(CGRectMake(11, 222.2, 22, 44));
    NSLog(@"res is:%@",[NSValue valueWithCGRect:res]);
    
    NSLog(@"有返回值CGrect 类型参数block end");
}

- (void)needBlockParamsE:(NSString *)name block:(NSRange (^)(NSRange a))block
{
    NSLog(@"有返回值CGrect 类型参数block start");
    NSRange size = block(NSMakeRange(33, 44));
    NSLog(@"res is:%@",[NSValue valueWithRange:size]);
    
    NSLog(@"有返回值CGrect 类型参数block end");
}

- (void)needBlockParamsF:(NSString *)name block:(UIEdgeInsets (^)(UIEdgeInsets a))block
{
    NSLog(@"有返回值UIEdigeInsert 类型参数block start");
    if(block)
    {
        
        UIEdgeInsets size = block(UIEdgeInsetsMake(222, 333, 444, 555));
        NSLog(@"res is:%@",[NSValue valueWithUIEdgeInsets:size]);
        
    }
    
    NSLog(@"有返回值UIEdigeInsert 类型参数block end");
}


- (void)needBlockParamsG:(void (^)(BOOL finish))block
{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [NSThread sleepForTimeInterval:1.0];
        block(YES);
        
        [NSThread sleepForTimeInterval:1.0];
        block(YES);
    });
    NSLog(@"bad");
}



- (void)needSpecialIntPoint:(int *)pint
{
    *pint = 100;
  
}
- (void)needSpecialNSIntPoint:(NSInteger *)pint
{
    *pint = 1001;

}
- (void)needSpecialLongPoint:(long *)pint
{
    *pint = 1002;
}
 
- (void)needSpecialBOOLPoint:(BOOL *)pint
{
    *pint = YES;
}

- (void)needSpecialCGRect:(CGRect *)prect
{
    *prect = CGRectMake(100, 1001, 1002, 1004);

}

- (void)needSpecialCGPoint:(CGPoint *)ppoint
{
    *ppoint = CGPointMake(200, 2001);//, 1002, 1004);

}
- (void)needSpecialUIEdgeInser:(UIEdgeInsets *)pinsert
{
    *pinsert = UIEdgeInsetsMake(2222, 333, 4444, 555);//(200, 2001);//, 1002, 1004);
    
}
- (void)needSpecialID:(id *)theStr
{
    *theStr = @"this is fatboyli new str";//(200, 2001);//, 1002, 1004);
    
}
- (void)needSpecialView:(UIView * *)theView
{
     NSLog(@"inner theView is %@",*theView);
    id newView = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        *theView =(__bridge UIView *)((__bridge  void *)newView);
        NSLog(@"inner theView is %@",*theView);
    });
}

- (BOOL)haveBool:(BOOL)thegood
{
    return !thegood;
}

- (CGRect)getsize:(CGSize)frame{
    return self.frame;
}


- (MYStruct)getMyStruct
{
    MYStruct theres;
    theres.rect = CGRectMake(10, 12, 34, 45);
    theres.size = CGSizeMake(10.1, 20.2);
    theres.b = 20;
    theres.c = 0;
    theres.d = 30;
    NSLog(@"the size is:%@",@(sizeof(MYStruct)));
    return theres;
}

- (void)neeMyStructPara:(MYStruct)thePara
{
    NSLog(@"the Para.c is:%@",@(thePara.c));
    NSLog(@"the Para.d is:%@",@(thePara.d));
    NSLog(@"the Para.b is:%@",@(thePara.b));
}

- (void)needUIOffset:(UIOffset )offset
{
    NSLog(@"the offset is:%@ --- %@",@(offset.horizontal), @(offset.vertical) );
}
- (void)needUIOffsetB:(UIOffset )offset
{
    NSLog(@"the offset is:%@ --- %@",@(offset.horizontal), @(offset.vertical) );
}

- (void)callReturnOffsetFun
{
    UIOffset offset = [self returnOffset];
    NSLog(@"the offset is:%@ --- %@",@(offset.horizontal), @(offset.vertical) );

}
- (UIOffset)returnOffset
{
    return   UIOffsetMake(20, 50);
    
}


- (MYStruct)neeMyStruct
{
    MYStruct theres;
    theres.rect = CGRectMake(10, 12, 34, 45);
    theres.size = CGSizeMake(10.1, 20.2);
    theres.b = 20;
    theres.c = 0;
    theres.d = 30;
    return theres;
}


- (void)testOverrider
{
//    NSLog(@"this is the good ");
}

@end
