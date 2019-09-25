@interface TestViewB:UIView

@property(nonatomic ,strong)id      thetext;
@end

@implementation TestViewB

- (id)initWithFrame:(CGRect)frame
{
    self =  [super initWithFrame:frame];
    
    return self;
}


- (id)getBool
{
    return [self getboolNO];
}

@end

id b = [TestViewB new];
b.thetext = @"this isthe class";
NSLog(@"b is:%@ b.thetext:%@",b,b.thetext);
