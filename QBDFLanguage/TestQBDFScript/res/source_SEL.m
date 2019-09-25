

@implementation testSELMethodCls

- (void)testB
{
    NSLog(@"int the fun testB");
}

- (void)testC
{
    [self testA:@selector(testB)];
    [self testD:@selector(testB)];
    [self testE:@selector(testB)];
}

- (void)testD:(SEL)thesel
{
    [self ORIGtestD:thesel];
    NSLog(@"----------");
    NSLog(@"newtheD sel is:%@",NSStringFromSelector(thesel));
    NSLog(@"call sel");
    [self performSelector:thesel];
    NSLog(@"newtheD over");

}

-(void)testE:(SEL)thesel
{
    NSLog(@"newtheE sel is:%@",NSStringFromSelector(thesel));
    NSLog(@"call sel");
    [self performSelector:thesel];
    NSLog(@"newtheE over");
    
}
- (void)testF:(id)the
{
    NSLog(@"good");
}

- (void)testM:(id)a
{
    
    NSLog(@"the is is:%@",a);
    
}
@end
id theobj = [testSELMethodCls new];
[theobj testC];
id thesel = @selector(@"intitwithFrame:name:");
NSLog(@"the sel is:%@",thesel);
thesel = @selector(intitwithFrame:name:count:lala:);
NSLog(@"the sel is:%@",thesel);
