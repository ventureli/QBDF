id theobja =[ViewControllerShareView shareInstance];  //基本的objc 调用
struct myStruct
{
    int c;
    CGSize size;
    double b;
    CGRect rect;
    int d;              //4
};

struct UIOffset {
    CGFloat horizontal;
    CGFloat vertical;
}

@implementation ViewControllerShareView

- (void)needUIOffsetB:(id)offset
{
    NSLog(@"the offset is:%@",offset);
}

- (id)returnOffset
{
    NSLog(@"call heeree");
    return UIOffset(10000,3333.3);
}

@end

id b = [theobja getMyStruct];
id c = myStruct();
c.c = 20;
c.b = 34.4;
c.d = 34.4;
c.size = CGSizeMake(11,22);
c.rect = CGRectMake(11,22,33,44);

NSLog(@"c is is:%@",c);
NSLog(@"b is is:%@",b);

id e = myStruct(12,CGSizeMake(11,22),22.2,CGRectMake(0,2,3,4),33);
NSLog(@"e is is:%@",e);

[theobja neeMyStructPara:c];


id theOffset = UIOffset(12,34.3);
[theobja needUIOffset:theOffset];
[theobja needUIOffsetB:theOffset];
[theobja callReturnOffsetFun];






