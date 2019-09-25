
@interface TestNewVARClass : NSObject
@property(nonatomic ,assign)int      intA;
@property(nonatomic ,assign)double      doubleB;
@property(nonatomic ,assign)unsigned short      shortA;
@property(nonatomic ,assign)CGRect      rectC;
@property(nonatomic ,strong)NSString *  theName;
@property(nonatomic ,strong)UIView *    theView;
@end

@implementation TestNewVARClass
- (void)readTheView:(UIView *)theView name:(NSString *)name
{
    NSLog(@"theView is:%@, name is:%@",theView,name);
    self.theView = theView;
    self.theName = name;
}
- (NSString *)description
{
    return
    [NSString stringWithFormat:@"intA:%@\ndoubleB:%@\nshortA:%@\nrectC:%@\ntheName:%@\ntheView:%@\n",self.intA,self.doubleB,self.shortA,self.rectC,self.theName,self.theView];
}

- (void)setTheName:(NSString *)theName
{
    [self ORIGsetTheName:theName];
    NSLog(@"set hteName");
}

@end

TestNewVARClass *thenewClass = [TestNewVARClass new];
thenewClass.intA = 10;
thenewClass.doubleB = 10.11;
thenewClass.shortA = 34;
[thenewClass readTheView:nil  name:@"hello wenqiangli"];
NSLog(@"%@",thenewClass);


