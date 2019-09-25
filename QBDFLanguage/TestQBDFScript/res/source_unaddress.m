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

id theView = [[TestObjtViewA alloc] initWithFrame:CGRectZero];


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

char * p_ch = &ch;
unsigned char * p_chB = &chB;
short * p_sh = &sh;
unsigned short *p_shB = &shB;
long *p_lon = &lon;
unsigned long *p_lonB = &lonB;
long long *p_ll = &ll;
unsigned long long *p_llb = &llb;

float *p_flo = &flo;
double *p_dou = &dou;
NSInteger *p_inte = &inte;
NSUInteger *p_inteB = &inteB;

CGFloat *p_cgflo = &cgflo;
CGSize *p_theSize = &theSize;
CGPoint *p_thePoint = &thePoint;
CGRect *p_theRect = &theRect;
NSRange *p_theRange = &theRange;
UIEdgeInsets   *p_inserts = &inserts;
id *p_theView = &theView;

*p_ch = 'A';
*p_chB = 'B';
*p_sh = 0 - 1001;
*p_shB = 1002;
*p_lon = 1003;
*p_lonB = 1004;
*p_ll = 0 - 1005;
*p_llb = 1006;
*p_flo = 1007.11;
*p_dou = 1008.221;
*p_inte = 1009;
*p_inteB = 1010;

*p_cgflo = 1011.11;
*p_theSize = CGSizeMake(1012,222);
*p_thePoint = CGPointMake(1013,333);
*p_theRect = CGRectMake(1014,333,1,22);
*p_theRange = NSMakeRange(1015,1016);
*p_inserts = UIEdgeInsetsMake(1017,0,0,0);


NSLog(@"theView is:%@",*p_theView);
id newview =[[TestObjtViewB alloc] initWithFrame:CGRectMake(1018,22,33,44)];
*p_theView = &newview ;

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
NSLog(@"theView is:%@",*p_theView);
