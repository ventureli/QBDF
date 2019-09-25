
char ch = '2';
unsigned char chB = '3';
short sh = 4;
unsigned short shB = 5;
long lon = 6;
unsigned long lonB = 7;
long long ll = 8;
unsigned long long llb = 9;

float flo = 10.1;
double dou = 11.1;
NSInteger inte = 13;
NSUInteger inteB = 14;

CGFloat cgflo = 12.1;
CGSize theSize = CGSizeMake(13,14);
CGPoint thePoint = CGPointMake(14,15);
CGRect theRect = CGRectMake(15,16,17,18);
NSRange theRange = NSMakeRange(16,18);
UIEdgeInsets   inserts = UIEdgeInsetsMake(17, 19, 20, 21);

id theView = [[UIView alloc] initWithFrame:CGRectZero];


NSLog(@"char is:%@",ch);
NSLog(@"unsigned char is:%@",chB);
NSLog(@"short is:%@",sh);
NSLog(@"unsigned short is:%@",shB);
NSLog(@"long is:%@",lon);
NSLog(@"unsigned long is:%@",lonB);
NSLog(@"long long is:%@",ll);
NSLog(@"unsigned long long is:%@",llb);
NSLog(@"float is:%@",flo);
NSLog(@"double is:%@",dou);
NSLog(@"NSInteger is:%@",inte);
NSLog(@"NSUInteger is:%@",inteB);

NSLog(@"CGFloat is:%@",cgflo);
NSLog(@"CGSize is:%@",theSize);
NSLog(@"CGPoint is:%@",thePoint);
NSLog(@"CGRect is:%@",theRect);
NSLog(@"NSRange is:%@",theRange);
NSLog(@"UIEdgeInsets is:%@",inserts);
NSLog(@"theView is:%@",theView);


NSLog(@"---------------------------");

[TestObjct getCharPTR:&ch];
[TestObjct getUNCharPTR:&chB];
[TestObjct getShortPTR:&sh];
[TestObjct getUNShortPTR:&shB];
[TestObjct getLongPTR:&lon];
[TestObjct getUNLongPTR:&lonB];

[TestObjct getLongLongPTR:&ll];
[TestObjct getUNLongLongPTR:&llb];
[TestObjct getfloatPTR:&flo];
[TestObjct getDoublePTR:&dou];
[TestObjct getCGFloatPTR:&cgflo];

[TestObjct getNSIntergerPTR:&inte];
[TestObjct getNSUIntergerPTR:&inteB];
[TestObjct getCGSizePTR:&theSize];
[TestObjct getCGPointPTR:&thePoint];
[TestObjct getCGRectPTR:&theRect];
[TestObjct getNSRangePTR:&theRange];
[TestObjct getUIEdgeInsetsPTR:&inserts];
[TestObjct getVOIDPTR:&inserts];
[TestObjct getUIViewPTR:&theView];



NSLog(@"char is:%@",ch);
NSLog(@"unsigned char is:%@",chB);
NSLog(@"short is:%@",sh);
NSLog(@"unsigned short is:%@",shB);
NSLog(@"long is:%@",lon);
NSLog(@"unsigned long is:%@",lonB);
NSLog(@"long long is:%@",ll);
NSLog(@"unsigned long long is:%@",llb);
NSLog(@"float is:%@",flo);
NSLog(@"double is:%@",dou);
NSLog(@"NSInteger is:%@",inte);
NSLog(@"NSUInteger is:%@",inteB);
NSLog(@"CGFloat is:%@",cgflo);
NSLog(@"CGSize is:%@",theSize);
NSLog(@"CGPoint is:%@",thePoint);
NSLog(@"CGRect is:%@",theRect);
NSLog(@"NSRange is:%@",theRange);
NSLog(@"UIEdgeInsets is:%@",inserts);
NSLog(@"theView is:%@",theView);

long thenewl =345;
[TestObjct newLongPtr:&thenewl];

@implementation TestObjct
+ (void)newLongPtr:(long *)theptr
{
    NSLog(@"this is the new Longptr");
    *theptr = 4567;
}
@end

[TestObjct newLongPtr:&thenewl];
NSLog(@"thenewl is:%@",thenewl);
