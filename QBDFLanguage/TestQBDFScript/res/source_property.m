@interface testPropertyCls:UIView

@property(nonatomic ,strong)id      intA;
@property(nonatomic ,strong)id      doubleB;
@property(nonatomic ,strong)id      rectC;
@property(nonatomic ,strong)id      stringD;
@property(nonatomic ,strong)id      arrayE;
@property(nonatomic ,strong)id      dictF;
@property(nonatomic ,strong)id      objG;
@end

@implementation testPropertyCls


@end

id obj = [testPropertyCls new];

obj.intA = 12;
obj.doubleB = 23.3;
obj.rectC = CGRectMake(0,2,3,44);
obj.stringD = @"this is a str
secondLine";
obj.arrayE  = [NSMutableArray new];
[obj.arrayE addObject:@"good"];
[obj.arrayE addObject:@"morning"];
[obj.arrayE addObject:@"hahha"];
NSLog(@"array is:%@",obj.arrayE);
obj.arrayE[0] = @"haha";
NSLog(@"array is:%@",obj.arrayE);
obj.dictF  = [NSMutableDictionary new];
obj.dictF[@"name"] = @"fatboyli"
obj.dictF[@"xing"] = @"li"
obj.objG = [UIView new];

NSLog(@"intA is:%@",obj.intA);
NSLog(@"doubleB is:%@",obj.doubleB);
NSLog(@"rectC is:%@",obj.rectC);
NSLog(@"stringD is:%@",obj.stringD);
NSLog(@"arrayE is:%@",obj.arrayE);
NSLog(@"dictF is:%@",obj.dictF);
NSLog(@"objG is:%@",obj.objG);
