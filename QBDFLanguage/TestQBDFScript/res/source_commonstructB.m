
struct myStruct
{
    int c;
    CGSize size;
    double b;
    CGRect rect;
    int d;
}
struct myStruct a;
a.c = 100;
NSLog(@"a.c  is%@",a.c);
struct myStruct *b;
b = &a;
(*b).b = 110;

NSLog(@"b  is%@",*b);
NSLog(@"a  is%@",a);







