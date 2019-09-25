



@interface qbdfcell : UICollectionViewCell
@property(nonatomic ,strong)UILabel *  namelabel;
@property(nonatomic ,strong)UILabel *  contentlabel;
@property(nonatomic ,strong)UIImageView *  imageView;
@end


//这里设置一个环境变量，代表只定义一次

@implementation qbdfcell

- (qbdfcell *)initWithFrame:(CGRect)frame
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
    
    [self setQBDFProp:lay forKey:@"layout"];
    [self setQBDFProp:collctionView forKey:@"collctionView"];
    
    
    [collctionView setBackgroundColor:[UIColor orangeColor]];
    collctionView.autoresizingMask = 18;
    [collctionView registerClass:[qbdfcell class] forCellWithReuseIdentifier:@"cell"]; //注册cell信息
    
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
  //  id listData = [self getQBDFProp:@"listData"];
    
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
    return  CGSizeMake(218 , 188);
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
