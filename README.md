# 工程说明

frameworkTestcase  文件夹是一个对打包成.framework 的QBDFLanguage 测试的工程。
QBDFLanguage/QBDFLanguage.xcodeproj 是framework 主工程，用于打包framework
QBDFLanguage/QBDFScript 是所有的源码
QBDFLanguage/TestQBDFScript 相当于Example 工程，可以用于开发源码，而后用QBDFLanguage.xcodeproj 进行SDK打包。暂时没做pods，大家有需要可以自己重新混淆后打包，所有人用一个SDK，风险太大。
经过测试，混淆后appstore是检测不出来的。

languagepack.sh 这是一个打包脚本，用于给模拟器和真机器的framework 合并成一个；


# QBDFLanguage

QBDF 是一个Object-C 语言的动态化框架，此解释器采用OC语言的.m 文件作为输入源代码，主要架构分为两个部分。
QBDFLanguage 语法解释器，生成中间代码  ，VLOC language 最大限度采用OC 语法，所以我们可以直接用.m 文件作为输入。
后端是QBDF虚拟机，针对中间代码在OC运行环境，进行运行。

先传一基于Framework 的DEMO，源代码设计比较乱了，整理下开源。

具体技术原理请参考我的博客。

# QBDF 语法1-基本类型和语句
>说明：
>VLOC language 最大程度的采用object-c语法，有小部分改动，比如block的定义，本文档不太完善，具体可以参看小胖给的示例工程
>语言特性：
>语法来自于OC，为面向对象和过程混合型语言，（同python，可以定义类，也可以在定义类前后写表达式和语句）见OC支持的例子

#有任何crash和bug，请联系ventureli：微信：996992850，万分感谢
##注释
单行注释//
多行注释/* */不支持
##变量类型 
>VLOC language 是弱类型的语言，所有的类型都可以用id来代表，另外可以像写原生OC那样写所有的OC类型
### id
通用变量类型:

```
id a = 12;
id b = [UIView new];
id c = CGRectMake(0,0,0,0);等等
```
注意：id 在大部分情况都能代表所有的类型，除了在block的声明和定义的时候，如果都用id代表，在传入系统内部函数的时候，可能会出错。所以建议在block定义的时候，id只代表 object-c中的id类型。
###字符串
本语言改进oc语言，自动支持多行字符串

```
id a = @"zero line
first line,
secondeline;
"
NSLog(@"a is %@",a);
```
###int
代表long ,int 整形变量

```
int b = 10;
NSLog(@"b is:%@",b);
//注意，因为是弱类型的语言，虚拟机内部全部用id类型代表变量，所以打印需要用@%代表任意类型
```
### double
```
double b = 10.0;
NSLog(@"b is:%@",b);
//注意，暂时无法使用%.2f 这种打印方式
```

###CGRect,CGPoint ,CGSize,NSRange,UIEdgeInsets
结构体类型

```
CGRect a = CGRectMake(1,22.33,44,55);
id frame = UIEdgeInsetsMake(10  , 5, 50.2, 5.0);      
NSLog(@"a is:%@",a);
...
```
###变量作用域
>同c语言一样，子作用域会覆盖父作用域的变量直到出了该作用域，产型新的作用域的有if，while，函数等，和c 语言一样
>注意这里又一个特殊情况，利用系统再带的__VLOC_FREE__函数处理后的变量就立即删除了，此时再用同名变量，将是父作用域的了

```
int i = 10;
if (2 >1)
{
    int i = 23;
    NSLog(@"i is %@",i); //i is 23
    
    __VLOC_FREE__(i); //强制虚拟机删除变量i（通常用于提前释放内存）
    NSLog(@"i is %@",i); //i is 10
}

NSLog(@"i is %@",i);    //i is 10
```

##变量类型
>具体内容请见QBDF 语法5全类型&全类型指针支持
>
##运算符
###普通运算符
虽运算符的支持比较完善，除了按位计算的运算符，c语言中的运算符都可以支持，列表如下：
`+` `-` `*` `/` `=` `%` `>` `<` `>=` `<=` `!=` `==` `++` `--` `&&` `||` `!` `()` `?:`
`-> 用语oc取成员变量`
`. 用于oc设置和获取变量`
注意:+= ,-= ,^ , |,& ，正负号暂不支持（符号可以用0 - x 代替） 


```
int i = 11+5*3-3;                                   //四则运算
int m = i < 20 ? (4+9):(i+5);
//三目表达式
i > 20 ? (i =20) :(i);
//三目表达式和赋值表达式结合
NSLog(@"m is %@ i is:%@", m,i);
id dict = [NSMutableDictionary new];
//oc 调用
dict[@"good"] = @"I'm in the dict";
//字典下标语法糖
if(5--)
{
    int i = 11;
    NSLog(@"VELOC: is :%@",i);
}else
{
    i = 20;
}
```
####支持'|','^','&'，三个运算符

```
int i = 3;
int j = 4;
int d = i | j;
int E = i ^ 7;
int F = 15 & 7;
NSLog(@"d is:%@",d);
NSLog(@"e is:%@",E);
NSLog(@"f is:%@",F);
int a = 0;
for(int i = 1;i < 10;i++)
{
    a = a ^ i;
}
for(int i = 0;i < 9;i++)
{
    a = a ^ i;
}
NSLog(@"a is:%@",a);
NSLog(@"1 |2 | 8  is:%@",1|2|8);
NSLog(@"1 & 3 & 7  is:%@",1 & 3 & 7);
NSLog(@"1 ^ 3 ^ 7  is:%@",1 ^ 3 ^ 7);
```

###取地址运算符
‘&’ 

```
i = 0;
BOOL theBool = NO;
CGRect rect = CGRectMake(0,0,0,0);
id theobja = [TestShareInstance shareInstance];

[theobja needSpecialNSInt:&i];
NSLog(@"the i  value is:%@",i);

[theobja needSpecialBOOLPoint:&theBool];
NSLog(@"the BOOL value is:%@",theBool);

[theobja needSpecialCGRect:&rect];
NSLog(@"the rect value is:%@",rect);

```

##控制语句
>目前控制语句只支持if和while，至于想用for的同学，要自己用while代替或者等下一个版本了。

### if
>if 支持，if(){}else{} 和if(){} 两种结构，暂不支持 if(){}else if(){}else if(){} else{}这种（如果需求强烈可以等下一个版本）

###while
>while 支持 break，暂不支持 continue，想用的同学要等下一个版本或者用if else 代替啦

### for(>=1.2 版本支持)
>for 支持break ，暂不支持continue
想用的同学要等下一个版本或者用if else 代替啦

```
int i = 10;
if(i < 10)
{
    int i = 11;
    NSLog(@"VLOC: is :%@",i);
}else
{
    i = 20;
}
NSLog(@"VLOC: is :%@",i);
int j = 10;
int k = 8;
//while 逻辑控制语法
while(j > 0)
{
    if( (j < 5 ||  j < 6) && k <= 8  )
    {
        //break 关键字实现
        break;
    }
    id str = @"good李文强fatboyli";
    NSLog(@"VLOC: j is:%@ str is:%@",j,str);
    j --;
    
}
for(int i = 0;i < 6;i ++)
{
    for(int j = 0 ; j < 3;j ++)
    {
        if(j > 1)
        {
            break;
        }
        NSLog(@"i is:%@ j is:%@",i,j);
    
    }
    if(i > 2)
    {
        break;
    }
    
}

for(int m = 0 ;m < 5;m++)
{
    int j = 0;
    NSLog(@" -----m is: %@-----",m);
    while (j < 10)
    {
        NSLog(@"j is:%@ ",j);
        j ++;
    }
    
}

```



# VLOC language 语法2-任意结构结构体调用

>VLOC 除了原生支持自带的CGRect，CGSize，CGPoint，NSrange，UIEdgeInserts 后，添加对任意结构体的支持。
>所不同的是，除了上面的几个系统内置的结构体，其余结构体类型，需要在VLOC的脚本再定义一次和内部结构体一样的类型。

####定义

```
struct myStruct
{    
    int c;
    CGSize size;
    double b;
    CGRect rect;
    int d;              //4   
};

```
####初始化和赋值
```
//方案一
id c = myStruct();
c.c = 20;
c.b = 34.4;
c.d = 34.4;
//方案2
id e = myStruct(12,CGSizeMake(11,22),22.2,CGRectMake(0,2,3,4),33);
```

#### 打印
```
NSLog(@"e is is:%@",e);
```
```
//结果如下
2017-08-07 17:45:53.123 TestVLOCScript[9784:13403349] e is is:myStruct{
    b = "22.2";
    c = 12;
    d = 33;
    rect = "NSRect: {{0, 2}, {3, 4}}";
    size = "NSSize: {11, 22}";
}

```
#### 和OC native 代码进行调用

e.g 系统内部有一个Struct 为UIOffset（UIKit库中）代码如下

```
typedef struct UIOffset {
    CGFloat horizontal, vertical; // specify amount to offset a position, positive for right or down, negative for left or up
} UIOffset;
```

这个struct 不再我们支持的基本类型之中，我们要用到这个结构和和nativeOC的内部交互或者使用

#####   1.我们在VLOC脚本中第一个一样的结构体

```
struct UIOffset {
    CGFloat horizontal;
    CGFloat vertical;  
}

```

##### 2.如果系统有一个方法需要UIOffset为参数

```
- (void)needUIOffset:(UIOffset )offset
{
    NSLog(@"the offset is:%@ --- %@",@(offset.horizontal), @(offset.vertical) );
}

```

##### 3.QBDF脚本写法

```
id theOffset = UIOffset(12,34.3);
[theobja needUIOffset:theOffset];
```
##### 4.输出结果如下
```
the offset is:12 --- 34.3
```


# VLOC language 语法3-C函数支持
##支持的C函数
###1.OC常用c函数
 * NSLog 
```
id a = 10;
NSLog(@"a is:%@",a);
```
 * CGRectMake 同OC
 * CGSizeMake 同OC
 * CGPointMake 同OC
 * NSRangeMake 同OC
 * UIEdgeInsetsMake 同OC
 * dispatch_sync_main 等同OC如下
    
``` 
dispatch_sync(dispatch_get_main_queue(), ^{

 });
       
```

 * dispatch_async_main 等同OC如下
 
``` 
dispatch_async(dispatch_get_main_queue(), ^{

 });
  
```

 *  dispatch_async_global_queue 等同OC如下
 
```
dispatch_async(dispatch_get_global_queue(0, 0), ^{
 
});

```
###2.VLOC自定义c函数


//前后各两个下划线

*   "__QBDF_SETENV__" 设置环境变量 本次程序运行中可以在任意脚本中通过 "__VLOC_GETENV__" 读取
*  "__QBDF_GETENV__" 读取环境变量 (>=1.2)
* "__QBDF_SETUSERDEFAULT__" 设置userDefault 持久化，（当然也可以，自己用NSUserDefault 的代码写）(>=V1.2)
* "__QBDF_GETUSERDEFAULT__" 设置userDefault 持久化，（当然也可以，自己用NSUserDefault 的代码写）(>=v1.2)
* "__QBDF_FREE__" 强制释放变量

 >注意正常来说，变量会随着作用域的消失而释放，但是有时候作用域特别大的时候，而且前面生成的对象特别大，可以在作用域中间调用这个代码，删除特别大的变量，但是这种情况要成需要自己保证在此代码后不再应用改变量。
 
```
int a = 1000;
int b = 2000;

__QBDF_FREE__(a);
int c = a *b; //ERROR! 变量已经被释放

int m = 10;
if(2 >1)
{
    int m = 34;
    __VLOC_FREE__(m); //释放值为34 这个m
    __VLOC_FREE__(m); //释放值为10 这个m
}

```

###2.数学函数支持 
* ftoa（可接受两个参数，2参数代表小数位）
* ftof（可接受两个参数，2参数代表小数位）
* ceil
* floor
* abs
* sqrt
* log
* log10
* pow

```
double a = 12.3455;
NSLog(@"a is :%@",a);
NSLog(@"ftof(a,2) is:%@",ftof(a,2));
NSLog(@"ftoa(a,3) is:%@",ftoa(a,3));
NSLog(@"ftof(a) is:%@",ftof(a));
NSLog(@"ftoa(a) is:%@",ftoa(a));
NSLog(@"ceil(a) is:%@",ceil(a));
NSLog(@"floor(a) is:%@",floor(a));
NSLog(@"abs(a) is:%@",abs(a));
NSLog(@"sqrt(a) is:%@",sqrt(a));
NSLog(@"log(a) is:%@",log(a));
NSLog(@"log10(a) is:%@",log10(a));
NSLog(@"pow(a,2) is:%@",pow(a,2));
NSLog(@"pow(10,3) is:%@",pow(10,3));

输出如下：
a is :12.3455
ftof(a,2) is:12.35
ftoa(a,3) is:12.346
ftof(a) is:12.3455
ftoa(a) is:12.3455
ceil(a) is:13
floor(a) is:12
abs(a) is:12.3455
sqrt(a) is:3.513616370635816
log(a) is:2.513291624204572
log10(a) is:1.091508683805707
pow(a,2) is:152.41137025
pow(10,3) is:1000
```

###其他C函数
CGRectContainsRect()
CGRectContainsPoin()
等


# QBDF 语法4-OC类属性block等支持
##对OC支持
###OC 调用
>本于对OC调用支持，限制如果有结构体参数：必须是我们支持的5种结构体。

```
id dict = [NSMutableDictionary new];                
//oc 调用
dict[@"good"] = @"I'm in the dict";                 
//字典下标语法糖

id array = [NSMutableArray new];
[array addObject:@"1"];
[array addObject:@"2"];
[array addObject:@"3"];
[array addObject:@"4"];
int count = 1;
array[count +2] = 45;                                
//数组下标语法糖
id theobj =[ViewControllerShareView shareInstance];  
//基本的objc 调用
theobj->f1 = 15.1;                                   
//->成员变量处理
theobj->bad = @"I'm
bad
bad";                                                 
//->objc 成员变量处理和多行字符串
id frame =     CGRectMake(200, 300, 600, 200);       //基本c方法使用,目前支持这几个常用的
id point =     CGPointMake(10, 20);
id range =     NSMakeRange( 0, 5);
id rect =      CGRectMake(90, 23, 1, 60);

//测试objc语法调用
id view = [[UIButton alloc] initWithFrame:frame];
[theobj addSubview:view];
[view setBackgroundColor:[UIColor redColor]];
[view setTitle:@"good " forState:0];
[view setTitle:@"press " forState:1];
//[view.titleLabel setFont:[UIFont systemFontOfSize:rect.origin.x]];
view.titleLabel.font = [UIFont systemFontOfSize:rect.origin.x];                  
//属性作为左值调用
[view.layer setCornerRadius:point.y];
[view.layer setBorderWidth:range.length];
[view.layer setBorderColor:[UIColor blueColor].CGColor];
id key = @"good";
NSLog(@"value %@ %@ %@ %@ %@",theobj->good , theobj->f1,theobj->c , theobj->bad,dict[key]);  
//变量读取 //变量的下标读取
NSLog(@"array is %@ the index[%@] is:%@",array,count+2,array[2]); 
//变量读取 //变量的下标读取 //参数是表达式的用法
```
### OC类的属性
>全类型支持
>

```

@interface TestViewB:UIView

@property(nonatomic ,strong)id      thetext;
//这里只支持ID类型属性
//另外可以用可以用setVLOCPro系列方法，见下一小节
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

```

### OC类的生成与覆盖
>本语言支持OC类的定义和覆盖，有限制如下：@interface ...@end可以定义类，基类：但是不能定义成员变量，属性和成员方法。
属性可以通本语言支持的函数变相支持，成员方法都在@implemation@end 定义，
>  

```


@interface VLOCcell : UICollectionViewCell
@property(nonatomic ,strong)UILabel *  namelabel;
@property(nonatomic ,strong)UILabel *  contentlabel;
@property(nonatomic ,strong)UIImageView *  imageView;
@end


//这里设置一个环境变量，代表只定义一次

@implementation VLOCcell

- (VLOCcell *)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self setBackgroundColor:[UIColor purpleColor]];
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bounds.size.height -54, self.bounds.size.width, 40)];
        label.font = [UIFont systemFontOfSize:15];
        label.textColor =[UIColor orangeColor];
        label.text = @"短视频A短视频A短视频A短视频A短视频A短视频A短视频A短视频A短视频A短视频A短视频A短视频A短视频A短视频A短视频A短视频A短视频A短视频A";
        label.numberOfLines = 0;
        label.lineBreakMode = 0;
        [self addSubview:label];
        
        UILabel * labelB = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bounds.size.height -12, self.bounds.size.width, 12)];
        labelB.font = [UIFont systemFontOfSize:15];
        labelB.textColor =[UIColor blackColor];
        labelB.text = @"详细信息，详细信息";
        [self addSubview:labelB];
        
        
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - 65)];
        imageView.backgroundColor = [UIColor whiteColor];
        [self addSubview:imageView];
        self.imageView = imageView;
        
    }
    
    void (^blockA)()
    {
        id data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://desk.fd.zol-img.com.cn/t_s1920x1080c5/g5/M00/0F/04/ChMkJlbegiyIaSExAAh2hrdk6UsAAM7xQOueUQACHae442.jpg"]];
        if(data)
        {
            UIImage * image = [UIImage imageWithData:data];
            void (^blockB)()
            {
                self.imageView.image = image;
            }
            dispatch_async_main(blockB);
            
        }
    }
    
    dispatch_async_global_queue(blockA);
    
    return self;
    
}

- (void)dealloc
{
//    NSLog(@"cell dealloc");
//    id newself =  self;
//    NSLog(@"self is:%@",newself);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
@end



@interface myView:UIView <UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>

@end

@implementation myView

- (myView *)initWithFrame:(CGRect)frame
{
    self =  [super initWithFrame:frame];
    
    
    UICollectionViewFlowLayout * lay = [[UICollectionViewFlowLayout alloc] init];
    
    UICollectionView * collctionView =  [[UICollectionView alloc] initWithFrame:CGRectMake(0, 100, self.bounds.size.width, self.bounds.size.height -100) collectionViewLayout:lay];
    
    [self setVLOCProp:lay forKey:@"layout"];
    [self setVLOCProp:collctionView forKey:@"collctionView"];
    
    
    [collctionView setBackgroundColor:[UIColor orangeColor]];
    collctionView.autoresizingMask = 18;
    [collctionView registerClass:[VLOCcell class] forCellWithReuseIdentifier:@"cell"]; //注册cell信息
    
    collctionView.delegate = self;
    collctionView.dataSource = self;
    collctionView.alwaysBounceVertical = 1;
    [self addSubview:collctionView];
    [collctionView reloadData];
    
    
    return self;
}



- (int)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{

    return 3;
}

- (int)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(int)section
{
    
    return 30;
}

- (id )collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    id color = [UIColor redColor];
    [cell setBackgroundColor:color];
    return cell;
}

- (CGSize) collectionView:(id )collectionView layout:(UICollectionView * )collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
   // NSLog(@"hahha");
    return  CGSizeMake(118 , 108);
}

@end

id theobj =baseView;
id contentView = [[myView alloc] initWithFrame:theobj.bounds];
[contentView setBackgroundColor:[UIColor blackColor]];
contentView.layer.borderWidth = 4.0;
contentView.layer.borderColor = [UIColor orangeColor].CGColor;
contentView.tag = 0;
contentView.autoresizingMask = 18;
return contentView;
```



###block 
####定义和使用
>注意，当前版本的block定义语法和OC语法有一些出入，比较类型于c的函数定义，且不支持匿名block，具体代码如下：

```
void (^blockA)()
{
            
    id data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://pic1.nipic.com/2009-02-09/200929180899_2.jpg"]];
    id image = [UIImage imageWithData:data];
    void (^blockB)()
    {
     imageView.image = image;
    }
     dispatch_async_main(blockB);
     //必须是非匿名block
}
dispatch_async_global_queue(blockA);

注意暂不支持这种写法：
 dispatch_async_main(^{
 
  ...
 });

```
####block的外部变量捕获
本语言不支持__block关键字，但是外部变量可以随意捕获，可以在block中引用任意外部变量并赋值

```
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
```

####block的完备调用
>所谓的完备调用是指的任何本语言的定义个block可以传给系统需要block的函数作为参数，系统返回的block可以在本语言中使用，本语言支持和oc系统的block完备调用，有限制如下：
如果block中有结构变量，则该变量必须是本语言支持的CGRect，CGPoint，CGSize，NSRange，UIEdgeInsts 类型，否则无法传给OC底层，OC底层也无法传递给本需要

```
//OC ViewControllerShareView.m
- (void)needBlockParamsF:(NSString *)name block:(UIEdgeInsets (^)(UIEdgeInsets a))block
{
    NSLog(@"有返回值UIEdigeInsert 类型参数block start");
    UIEdgeInsets size = block(UIEdgeInsetsMake(222, 333, 444, 555));
    NSLog(@"res is:%@",[NSValue valueWithUIEdgeInsets:size]);
    
    NSLog(@"有返回值UIEdigeInsert 类型参数block end");
}

//本语言脚本 
UIEdgeInsets (^blockF)(UIEdgeInsets a)
{
    NSLog(@"in block a is%@ b is:%@ ",a ,@"b");
    id frame =     UIEdgeInsetsMake(10  , 5, 50.2, 5.0);       //基本c方法使用,目前支持这几个常用的
    return frame;
}
id theobja =[ViewControllerShareView shareInstance];  //基本的objc 调用

[theobja needBlockParamsF:@"fatboyli" block:blockF];
//传入oc后也能从oc中拿到返回值
```
>block 这块内容很多，暂时掠过，有问题可直接rtx:fatboyli


##虚拟机的使用与注册变量
>本语言以framework发布的，只有两个头文件：
>
```
#import <QBDFLanguage/QBDFVM.h>
#import <QBDFLanguage/QBDFScriptInterpreter.h>
```

使用示例代码如下：

```
NSString *theStr = [[NSBundle mainBundle] pathForResource:@"res/source_class" ofType:@"m"];
QBDFScriptInterpreter *interpreter = [[QBDFScriptInterpreter alloc] init];
NSArray *codes =  [interpreter QBDF_TranslateWithFile:theStr];
NSLog(@"<===================EVAL RES===========================>");
NSLog(@"%@",UICollectionElementKindSectionHeader);
[[QBDFVM shareInstance] evalCode:codes withInitEnvVar:@{@"theobj":self.view}];

```

//这里注册了一个theobj的变量，在本语言脚本里可以直接使用

```
...

id baseview = [[myView alloc] initWithFrame:theobj.bounds];
[baseview setBackgroundColor:[UIColor blackColor]];
baseview.layer.borderWidth = 4.0;
baseview.layer.borderColor = [UIColor orangeColor].CGColor;
baseview.tag = 0;
baseview.autoresizingMask = 18;
[theobj addSubview:baseview];
//直接使用变量theobj
__QBDF_FREE__(baseview);

if(__QBDFVM_VERSION__ > 0.1)
{
    NSLog(@"当前版本大于0.1 %@",__QBDFVM_VERSION__);
}
NSLog(@"QBHD版本:%@",__QBHD_VERSION__);

int i = 10;
if (2 >1)
{
    int i = 23;
    NSLog(@"i is %@",i); //i is 23
    
    __QBDF_FREE__(i);
    NSLog(@"i is %@",i); //i is 10
}

NSLog(@"i is %@",i);    //i is 10

```
如下：
![](media/14969930360215/14969975834265.jpg)




# VLOC language 语法5-全类型声明和指针支持
###1.全类型支持&全类型指针（所有基本类型）
```

char ch = '2';
unsigned char chB = '3';
short sh = 4;
unsigned short shB = 5;
long lon = 6;
unsigned long lonB = 7;
long long ll = 8;
unsigned long long llb = 9;

float flo = 10.1;
double dou = 11.1;
NSInteger inte = 13;
NSUInteger inteB = 14;

CGFloat cgflo = 12.1;
CGSize theSize = CGSizeMake(13,14);
CGPoint thePoint = CGPointMake(14,15);
CGRect theRect = CGRectMake(15,16,17,18);
NSRange theRange = NSMakeRange(16,18);
UIEdgeInsets   inserts = UIEdgeInsetsMake(17, 19, 20, 21);

id theView = [[UIView alloc] initWithFrame:CGRectZero];


NSLog(@"char is:%@",ch);
NSLog(@"unsigned char is:%@",chB);
NSLog(@"short is:%@",sh);
NSLog(@"unsigned short is:%@",shB);
NSLog(@"long is:%@",lon);
NSLog(@"unsigned long is:%@",lonB);
NSLog(@"long long is:%@",ll);
NSLog(@"unsigned long long is:%@",llb);
NSLog(@"float is:%@",flo);
NSLog(@"double is:%@",dou);
NSLog(@"NSInteger is:%@",inte);
NSLog(@"NSUInteger is:%@",inteB);

NSLog(@"CGFloat is:%@",cgflo);
NSLog(@"CGSize is:%@",theSize);
NSLog(@"CGPoint is:%@",thePoint);
NSLog(@"CGRect is:%@",theRect);
NSLog(@"NSRange is:%@",theRange);
NSLog(@"UIEdgeInsets is:%@",inserts);
NSLog(@"theView is:%@",theView);


NSLog(@"---------------------------");
[TestObjct getCharPTR:&ch];
[TestObjct getUNCharPTR:&chB];
[TestObjct getShortPTR:&sh];
[TestObjct getUNShortPTR:&shB];
[TestObjct getLongPTR:&lon];
[TestObjct getUNLongPTR:&lonB];

[TestObjct getLongLongPTR:&ll];
[TestObjct getUNLongLongPTR:&llb];
[TestObjct getfloatPTR:&flo];
[TestObjct getDoublePTR:&dou];
[TestObjct getCGFloatPTR:&cgflo];

[TestObjct getNSIntergerPTR:&inte];
[TestObjct getNSUIntergerPTR:&inteB];
[TestObjct getCGSizePTR:&theSize];
[TestObjct getCGPointPTR:&thePoint];
[TestObjct getCGRectPTR:&theRect];
[TestObjct getNSRangePTR:&theRange];
[TestObjct getUIEdgeInsetsPTR:&inserts];
[TestObjct getVOIDPTR:&inserts];
[TestObjct getUIViewPTR:&theView];



NSLog(@"char is:%@",ch);
NSLog(@"unsigned char is:%@",chB);
NSLog(@"short is:%@",sh);
NSLog(@"unsigned short is:%@",shB);
NSLog(@"long is:%@",lon);
NSLog(@"unsigned long is:%@",lonB);
NSLog(@"long long is:%@",ll);
NSLog(@"unsigned long long is:%@",llb);
NSLog(@"float is:%@",flo);
NSLog(@"double is:%@",dou);
NSLog(@"NSInteger is:%@",inte);
NSLog(@"NSUInteger is:%@",inteB);
NSLog(@"CGFloat is:%@",cgflo);
NSLog(@"CGSize is:%@",theSize);
NSLog(@"CGPoint is:%@",thePoint);
NSLog(@"CGRect is:%@",theRect);
NSLog(@"NSRange is:%@",theRange);
NSLog(@"UIEdgeInsets is:%@",inserts);
NSLog(@"theView is:%@",theView);

long thenewl =345;
[TestObjct newLongPtr:&thenewl];

@implementation TestObjct
+ (void)newLongPtr:(long *)theptr
{
    NSLog(@"this is the new Longptr");
    *theptr = 4567;
}
@end

[TestObjct newLongPtr:&thenewl];
NSLog(@"thenewl is:%@",thenewl);

```


###2.无障碍，id类型变量声明
###虽然依然可以用id，声明任何变量，但是现在可以用UIView *，NSObjct *，
```
struct myStruct
{
    int c;
    CGSize size;
    double b;
    CGRect rect;
    int d;
    
}

UIView *theView;
UIButton *btn;
NSObject *theobjct;
theView = [[UIView alloc] initWithFrame:CGRectMake(0,0,0,0)];
NSLog(@"theView is%@",theView);
struct myStruct theStruct;
theStruct.c = 100;
theStruct.b = 10.0;

struct myStruct *pstruct;
pstruct = &theStruct;
NSLog(@"thestruct is:%@",theStruct);
NSLog(@"thestruct is:%@",*pstruct);
int a = 10;
int d = 20;
if(a*d > 0)
{
    NSLog(@"a *b > 0");
}

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
    //属性覆盖，注意这里的写法，要用ORIG来调用原来的方法
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
```

###3.struct定义与指针
>非编译器级别支持的struct暂时不能用于block,但是可以和native互相传递

```

struct myStruct
{
    int c;
    CGSize size;
    double b;
    CGRect rect;
    int d;

}

struct myStruct a;
a.c = 100;
NSLog(@"a.c  is%@",a.c);


struct myStruct *b;
b = &a;
(*b).b = 110;

NSLog(@"b  is%@",*b);
NSLog(@"a  is%@",a);


```


