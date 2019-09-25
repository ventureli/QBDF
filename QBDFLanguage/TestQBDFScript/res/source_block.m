

//id a = UIEdgeInsetsMake(100  , 50, 50, 50);
//double top = a.top;
//NSLog(@"top is %@ a is:%@",top,a);
//UIEdgeInsets b = UIEdgeInsetsMake(10  , 5, 50.2, 5.0);
//NSLog(@"top is %@ ",b.left);


int (^testblock)(int a,int b)
{
    return a+b;
}

NSLog(@"a is:%@",testblock(12,34));

UIEdgeInsets (^blockF)(UIEdgeInsets a)
{
    NSLog(@"in block a is%@ b is:%@ ",a ,@"b");
    id frame =     UIEdgeInsetsMake(10  , 5, 50.2, 5.0);       //基本c方法使用,目前支持这几个常用的
    return frame;
}

id theobja =[ViewControllerShareView shareInstance];  //基本的objc 调用
[theobja needBlockParamsF:@"fatboyli" block:NULL];


void (^blockdis)()
{
    int m =10;
    while(m >0)
    {
        [NSThread sleepForTimeInterval:1];
        NSLog(@"dispatchA m is:%@",m);
        m --;
    }
    
}

dispatch_async_main(blockdis);
dispatch_after(3,blockdis);
dispatch_async_global_queue(blockdis);


NSRange (^blockE)(NSRange a)
{
    NSLog(@"in block a is%@ b is:%@ ",a);
    id range =     NSMakeRange(100, 8);       //基本c方法使用,目前支持这几个常用的
    return range;

}
CGSize (^blockC)(int a , CGSize b)
{
    NSLog(@"in block a is%@ b is:%@ ",a ,b);
    id frame =     CGRectMake(200, 5.00, 600, 200);       //基本c方法使用,目前支持这几个常用的
    return frame.size;
}
CGRect (^blockD)(CGRect a)
{
    NSLog(@"in block a is%@ b is:%@ ",a ,@"b");
    id frame =     CGRectMake(200, 500, 600, 200);       //基本c方法使用,目前支持这几个常用的
    return frame;
}


[theobja needBlockParams:@"fatboyli" block:NULL];
[theobja needBlockParamsC:@"fatboyli" block:blockC];
[theobja needBlockParamsD:@"fatboyli" block:blockD];
[theobja needBlockParamsE:@"fatboyli" block:blockE];

void (^blockdisb)()
{
    int m =15;
    while(m >0)
    {
        [NSThread sleepForTimeInterval:0.1];
        NSLog(@"dispatchB m is:%@",m);
        m --;
        if(m < 3)
        {
            break;
        }
    }
}
dispatch_async_global_queue(blockdisb);
dispatch_after(3,blockdisb);
NSLog(@"over");

int waia = 10;
void (^blockdnew)()
{
    int m =10;
    while(m >0)
    {
        [NSThread sleepForTimeInterval:0.2];

        NSLog(@"dispatchA m is:%@ waia is:%@",m,waia);
        m --;
    }
    waia = 30;
    NSLog(@"over");

}
blockdnew();
dispatch_async_main(blockdnew);
