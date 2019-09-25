int i = 3;
int j = 4;
int d = i | j;
int E = i ^ 7;
int F = 15 & 7;
NSLog(@"d is:%@",d);
NSLog(@"e is:%@",E);
NSLog(@"f is:%@",F);
int a = 0;
for(int i = 1;i < 10;i++)
{
    a = a ^ i;
}
for(int i = 0;i < 9;i++)
{
    a = a ^ i;
}
NSLog(@"a is:%@",a);
NSLog(@"1 |2 | 8  is:%@",1|2|8);
NSLog(@"1 & 3 & 7  is:%@",1 & 3 & 7);
NSLog(@"1 ^ 3 ^ 7  is:%@",1 ^ 3 ^ 7);


