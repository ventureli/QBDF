struct myStruct
{
    int c;
    CGSize size;
    double b;
    CGRect rect;
    int d;
}


UIView *theView;
UIButton *btn;
NSObject *theobjct;
theView = [[UIView alloc] initWithFrame:CGRectMake(0,0,0,0)];
NSLog(@"theView is%@",theView);
struct myStruct theStruct;
theStruct.c = 100;
theStruct.b = 10.0;
struct myStruct *pstruct;           //结构体指针
pstruct = &theStruct;
NSLog(@"thestruct is:%@",theStruct);
NSLog(@"thestruct is:%@",*pstruct);
int a = 10;
int d = 20;
if(a*d > 0)
{
    NSLog(@"a *b > 0");
}



