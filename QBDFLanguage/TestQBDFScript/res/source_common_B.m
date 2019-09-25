//unsigned long long c;
//int         d;
//c = 30;
//unsigned long long *cptr;
//cptr = &c;
//*cptr = 50;
//
//SEL theSEL = @selector(initWithFrame:name:);
//
//NSLog(@"theSEL is:%@",theSEL);
//d = *cptr;
//
//NSLog(@"d is:%@",d);
//d = d + 100;
//NSLog(@"c is:%@",c);
//NSLog(@"d is:%@",d);
//NSLog(@"cptr is:%@",cptr);
//NSLog(@"%@",CGRectZero);
//NSLog(@"%@",CGPointZero);
//NSLog(@"%@",CGSizeZero);
//void (^block)(CGFloat first , int * b)
//{
//    NSLog(@"inblock first is:%@",first);
//    *b = 30;
//}
//int a = 10;
//block(11.1 , &a);
//NSLog(@"a is:%@",a);


struct myStructB
{
    //4
    NSInteger *pint;
    int c;
    CGSize size;
    double b;
    CGRect rect;
    int d;
    
};

@interface testNewVersionClass : NSObject
@end
@implementation testNewVersionClass

- (void)readIntPoint:(CGFloat *)p
{
    NSLog(@"the thearg is %@",*p);

    CGFloat *newp = p;
    *newp = 130.2;
    
    NSLog(@"the thearg is %@",*p);
}

@end
id var   =  [testNewVersionClass new];
CGFloat thearg = 9;
CGFloat *pthearg = &thearg;
[var readIntPoint:&thearg];
NSLog(@"the thearg is %@",thearg);


