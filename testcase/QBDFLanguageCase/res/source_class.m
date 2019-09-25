




@interface qbdfcell : UICollectionViewCell

@end


//这里设置一个环境变量，代表只定义一次

@implementation qbdfcell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self setBackgroundColor:[UIColor purpleColor]];
        id label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bounds.size.height -35, self.bounds.size.width, 20)];
        label.font = [UIFont systemFontOfSize:20];
        label.textColor =[UIColor blackColor];
        label.text = @"短视频A";
        [self setQBDFProp:label forKey:@"namelabel"];
        [self addSubview:label];
    
        
        id labelB = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bounds.size.height -15, self.bounds.size.width, 15)];
        labelB.font = [UIFont systemFontOfSize:15];
        labelB.textColor =[UIColor blackColor];
        labelB.text = @"详细信息，详细信息";
        [self setQBDFProp:labelB forKey:@"contentlabel"];
        [self addSubview:labelB];
        
        
        id imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - 35)];
        imageView.backgroundColor = [UIColor whiteColor];
        [self addSubview:imageView];
        [self setQBDFProp:imageView forKey:@"imageView"];
        
       
        void (^blockA)()
        {
            
            id data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://pic1.nipic.com/2009-02-09/200929180899_2.jpg"]];
            if(data)
            {
                
                id image = [UIImage imageWithData:data];
                void (^blockB)()
                {
                    imageView.image = image;
                }
                dispatch_async_main(blockB);
            }
        }
        dispatch_async_global_queue(blockA);
    }
    return self;
}

@end


@interface qbdfmySumply : UICollectionReusableView

@end

@implementation qbdfmySumply

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self setBackgroundColor:[UIColor purpleColor]];
        id label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.bounds.size.width-20, self.bounds.size.height)];
        label.font = [UIFont systemFontOfSize:40];
        label.textColor =[UIColor blackColor];
        label.textAlignment = 1;
        label.text = @"分类";
        [self setQBDFProp:label forKey:@"namelabel"];
        
        [self addSubview:label];
    }
    return self;
}

- (void)setTitle:(id)str
{
    id label = [self getQBDFProp:@"namelabel"];
    label.text = str;
    
}

@end


@interface myView:UIView <UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>

@property int a;
@property int b;
@end

@implementation myView

- (id)initWithFrame:(CGRect)frame
{
    self =  [super initWithFrame:frame];
    
    
    id lay = [[UICollectionViewFlowLayout alloc] init];
    
    id collctionView =  [[UICollectionView alloc] initWithFrame:CGRectMake(0, 100, self.bounds.size.width, self.bounds.size.height -100) collectionViewLayout:lay];
    
    [self setQBDFProp:lay forKey:@"layout"];
    [self setQBDFProp:collctionView forKey:@"collctionView"];
    
    
    [collctionView setBackgroundColor:[UIColor orangeColor]];
    collctionView.autoresizingMask = 18;
    [collctionView registerClass:[qbdfcell class] forCellWithReuseIdentifier:@"cell"]; //注册cell信息
    [collctionView registerClass:[qbdfmySumply class] forSupplementaryViewOfKind:@"UICollectionElementKindSectionHeader" withReuseIdentifier:@"header"];
    
    collctionView.delegate = self;
    collctionView.dataSource = self;
    collctionView.alwaysBounceVertical = 1;
    [self addSubview:collctionView];
    [collctionView reloadData];
    
    
    return self;
}


- (int)numberOfSectionsInCollectionView:(id)collectionView
{
    return 3;
}

- (int)collectionView:(id)collectionView numberOfItemsInSection:(int)section
{
    return 30;
}

- (id )collectionView:(id)collectionView cellForItemAtIndexPath:(id)indexPath
{
    
    id cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    id color = [UIColor redColor];
    [cell setBackgroundColor:color];
    return cell;
}
- (double)collectionView:(id )collectionView layout:(id )collectionViewLayout minimumLineSpacingForSectionAtIndex:(int)section
{
    return 20;
}
- (double)collectionView:(id )collectionView layout:(id )collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(int)section
{
    return 10;
}

- (CGSize) collectionView:(id )collectionView layout:(id )collectionViewLayout sizeForItemAtIndexPath:(id)indexPath
{
   // NSLog(@"hahha");
    return  CGSizeMake(100 , 170);
}
- (UIEdgeInsets)collectionView:(id)collectionView layout:(id)collectionViewLayout insetForSectionAtIndex:(int)section
{
    return UIEdgeInsetsMake(50  , 10, 50, 10);
    
}

- (CGSize)collectionView:(id )collectionView layout:(id)collectionViewLayout referenceSizeForHeaderInSection:(int)section
{
    return CGSizeMake(self.bounds.size.width, 100);
}

- (id )collectionView:(id)collectionView viewForSupplementaryElementOfKind:(id)kind atIndexPath:(id)indexPath
{
    if([kind isEqualToString:@"UICollectionElementKindSectionHeader"])
    {
        id headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
        [headerView setTitle:[NSString stringWithFormat:@"第%@分类",(indexPath.row +1)]];
        return headerView;
    }else
    {
        return nil;
    }
}
- (void)collectionView:(id)collectionView didSelectItemAtIndexPath:(id)indexPath
{
    id message = [NSString stringWithFormat:@"点击了:%@ - %@",indexPath.section,indexPath.row];
    id alertView = [[UIAlertView alloc] initWithTitle:@"点击" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:@"cancel", nil];
    [alertView show];
}

@end

id baseview = [[myView alloc] initWithFrame:theobj.bounds];
[baseview setBackgroundColor:[UIColor blackColor]];
baseview.layer.borderWidth = 4.0;
baseview.layer.borderColor = [UIColor orangeColor].CGColor;
baseview.tag = 0;
baseview.autoresizingMask = 18;
[theobj addSubview:baseview];

//__QBDF_FREE__(baseview);

if(__QBDFVM_VERSION__ > 0.1)
{
    NSLog(@"当前版本大于0.1 %@",__QBDFVM_VERSION__);
}
NSLog(@"QBHD版本:%@",__QBHD_VERSION__);

int i = 10;
//int i = 50;
if (2 >1)
{
    int i = 23;
    NSLog(@"i is %@",i); //i is 23
    
    __QBDF_FREE__(i);
    NSLog(@"i is %@",i); //i is 10
}

NSLog(@"i is %@",i);    //i is 10

