
@interface TestDeallocClass : NSObject

@end

@implementation TestDeallocClass

- (void)dealloc
{
    NSLog(@"this is dealloc");
}

@end

TestDeallocClass *obj = [TestDeallocClass new];
NSLog(@"the obj is:%@",obj);
