
id theobja =[ViewControllerShareView shareInstance];  //基本的objc 调用
int i = 0;
BOOL theBool = NO;
CGRect rect = CGRectMake(0,0,0,0);
CGPoint point = CGPointMake(0,0);
UIEdgeInsets   inserts = UIEdgeInsetsMake(0, 0, 0, 0);
id str = @"";

id theName = __QBDF_GETUSERDEFAULT__(@"the Name");
NSLog(@"theName:%@",theName);


id view = [UIView new];
__QBDF_SETENV__(@"name",@"fatboyli");

NSLog(@"the view value is:%@",view);
[theobja needSpecialView:&view];
NSLog(@"the view value is:%@",view);

void (^blockB)()
{
    NSLog(@"the view value is:%@",view);
}
dispatch_after(1.0,blockB);


[theobja needSpecialIntPoint:&i];
NSLog(@"the i  value is:%@",i);

[theobja needSpecialNSIntPoint:&i];
NSLog(@"the i  value is:%@",i);

[theobja needSpecialLongPoint:&i];
NSLog(@"the i  value is:%@",i);

[theobja needSpecialBOOLPoint:&theBool];
NSLog(@"the BOOL value is:%@",theBool);

[theobja needSpecialCGRect:&rect];
NSLog(@"the rect value is:%@",rect);

[theobja needSpecialCGPoint:&point];
NSLog(@"the point value is:%@",point);

[theobja needSpecialUIEdgeInser:&inserts];
NSLog(@"the inserts value is:%@",inserts);

[theobja needSpecialID:&str];
NSLog(@"the str value is:%@",str);

id name = __QBDF_GETENV__(@"name");
NSLog(@"the name is:%@",name);
__QBDF_SETUSERDEFAULT__(@"the Name",@"this is ");
if(theBool)
{
NSLog(@"this is good");
}
