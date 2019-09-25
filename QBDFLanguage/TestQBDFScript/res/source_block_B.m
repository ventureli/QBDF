
//CGSize (^blockC)(int a , CGSize b)
//{
//    NSLog(@"in block a is%@ b is:%@ ",a ,b);
//    id frame =     CGRectMake(200, 5.00, 600, 200);       //基本c方法使用,目前支持这几个常用的
//    return frame.size;
//}
//
//
//blockC(10,CGSizeZero);
//id theobja =[ViewControllerShareView shareInstance];  //基本的objc 调用
//[theobja needBlockParamsC:@"fatboyli" block:blockC];
//
//
//NSInteger (^fixIntBlock)(NSInteger *theptr)
//{
//    *theptr = 1001;
//}
//
//NSInteger a = 20;
//fixIntBlock(&a);
//NSLog(@"a is:%@",a);


CGRect rect;

NSInteger (^fixCGRectBlock)(CGRect *theptr)
{
    *theptr = CGRectMake(11,22,33,44);
}

fixCGRectBlock(&rect);
NSLog(@"rect is:%@",rect);



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
