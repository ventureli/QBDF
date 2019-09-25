@interface mysubView:testBaseView

@end

@implementation mysubView

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

id b = [mysubView new];
NSLog(@"b is:%@",b);
