int i = 11+5*3-3;                                   //四则运算

int m = i < 20 ? (4+9):(i+5);
//三目表达式

i > 20 ? (i =20) :(i);
//三目表达式和赋值表达式结合

NSLog(@"m is %@ i is:%@", m,i);

id dict = [NSMutableDictionary new];
//oc 调用
dict[@"good"] = @"I'm in the dict";
//字典下标语法糖
NSLog(@"dict[good] is:%@",dict[@"good"]);
if(5--)
{
    int i = 11;
    NSLog(@"QBDF: is :%@",i);
}else
{
    i = 20;
}

for(int i = 0 ;i < 20;i++)
{
    for(int m = 0 ;m < 4;m++)
    {
        NSLog(@"m is:%@",m);
    }
}
//测试c 方法
double a = 12.3455;
NSLog(@"a is :%@",a);
NSLog(@"ftof(a,2) is:%@",ftof(a,2));
NSLog(@"ftoa(a,3) is:%@",ftoa(a,3));
NSLog(@"ftof(a) is:%@",ftof(a));
NSLog(@"ftoa(a) is:%@",ftoa(a));
NSLog(@"ceil(a) is:%@",ceil(a));
NSLog(@"floor(a) is:%@",floor(a));
NSLog(@"abs(a) is:%@",abs(a));
NSLog(@"sqrt(a) is:%@",sqrt(a));
NSLog(@"log(a) is:%@",log(a));
NSLog(@"log10(a) is:%@",log10(a));
NSLog(@"pow(a,2) is:%@",pow(a,2));
NSLog(@"pow(10,3) is:%@",pow(10,3));
//测试取地址符号

NSLog(@"currentVersion:%@",__QBDFVM_VERSION__);
i = 0;
BOOL theBool = NO;
CGRect rect = CGRectMake(0,0,0,0);
id theobja = [TestShareInstance shareInstance];

[theobja needSpecialNSInt:&i];
NSLog(@"the i  value is:%@",i);

[theobja needSpecialBOOLPoint:&theBool];
NSLog(@"the BOOL value is:%@",theBool);

[theobja needSpecialCGRect:&rect];
NSLog(@"the rect value is:%@",rect);


