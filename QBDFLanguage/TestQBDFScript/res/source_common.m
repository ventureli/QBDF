//



CGRect rect = CGRectMake(0,0,1000,2000);
CGRect rect2 = CGRectMake(0,0,1000,2000);
CGPoint point = CGPointMake(23,4500);
CGSize size = CGSizeMake(200,300);
NSRange range = NSMakeRange(12,23);
UIEdgeInsets insert = UIEdgeInsetsMake(23,33,44,2);
NSLog(@"\n rect:%@\n rect2:%@ point:%@ \n size:%@\n range:%@ insert:%@",rect,rect2,point,size,range,insert);

BOOL good = CGRectContainsPoint(rect ,point);
NSLog(@"good is:%@",good);
if(good)
{
    NSLog(@"%@ 包含：%@",rect,point);
}else
{
    NSLog(@"%@ 不包含：%@",rect,point);
}

good = CGRectContainsRect(rect ,rect2);
if(good)
{
    NSLog(@"%@ 包含：%@",rect,rect2);
}else
{
    NSLog(@"%@ 不包含：%@",rect,rect2);
}
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


int *aa,b,c;

NSString *str =@"this is firstLine
this is secod Line";

void (^block)()
{
    
}



