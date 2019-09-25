@interface TestViewB:UIView

@property(nonatomic ,strong)id      labeD;
@end

@implementation TestViewB

- (id)initWithFrame:(CGRect)frame
{
    self =  [super initWithFrame:frame];
    id dec =[[NSThread currentThread] description];
    NSLog(@"%@ testViewB initwithFrame",dec);
    [[self class] classM];
    [self sayHello];
    
    
    return self;
}
+ (void)classM
{
    
    id dec =[[NSThread currentThread] description];
    NSLog(@"%@ this is the B Class Method",dec);
}
- (void)sayHello
{
    id dec =[[NSThread currentThread] description];
    NSLog(@"%@  TestViewB sayHello",dec);
}

@end




@interface TestViewC : TestViewB

@end
@implementation TestViewC

- (id)initWithFrame:(CGRect)frame
{
    self =  [super initWithFrame:frame];
    
    id dec =[[NSThread currentThread] description];
    NSLog(@" %@  TESTC initWithFrame",dec);
    return self;
}
- (void)sayHello
{
//    [super sayHello];
    id dec =[[NSThread currentThread] description];
    NSLog(@"%@ TestViewC sayHello", dec);
}
+ (void)classM
{
    id dec =[[NSThread currentThread] description];
    NSLog(@"%@ this is the C Class Method",dec);
}

@end

@interface TestViewD : TestViewC

@end
@implementation TestViewD


- (id)initWithFrame:(CGRect)frame
{
    self =  [super initWithFrame:frame];
    id dec =[[NSThread currentThread] description];
    
    NSLog(@"%@ TESTD initWithFrame",dec);
    return self;
}
- (void)sayHello
{
    [super sayHello];
    id dec =[[NSThread currentThread] description];
    
    NSLog(@"%@ TestViewD sayHello",dec);
}
+ (void)classM
{
    id dec =[[NSThread currentThread] description];
    
    NSLog(@"%@ this is the D Class Method",dec);
}
@end
int i = 0;
void (^block)()
{
    
//   [NSThread sleepForTimeInterval:2];
    id b = [[TestViewD alloc] initWithFrame:CGRectMake(10,10,20,20)];
    id dec =[[NSThread currentThread] description];
    
    NSLog(@"%@ over",dec);
}
block();
while(i < 300)
{
    dispatch_async_global_queue(block);
    
    i ++;
}
