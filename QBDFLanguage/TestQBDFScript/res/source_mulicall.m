
//
//
//
//__QBDF_SETENV__(@"__QBDF_DECCLS_ONCE__",0);
//__QBDF_SETENV__(@"__QBDF_IMPCLS_ONCE__",0);

@interface qbdfsubCell : UIView

@property(nonatomic ,strong)id  label;
@property(nonatomic ,strong)id  labelB;
@property(nonatomic ,strong)id  imageView;
@end

@implementation qbdfsubCell

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
        
        self.label = label;
//        [self setQBDFProp:label forKey:@"namelabel"];
        [self addSubview:label];
    
        
        id labelB = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bounds.size.height -15, self.bounds.size.width, 15)];
        labelB.font = [UIFont systemFontOfSize:15];
        labelB.textColor =[UIColor blackColor];
        labelB.text = @"详细信息，详细信息";
//        [self setQBDFProp:labelB forKey:@"contentlabel"];
        self.labelB = labelB;
        [self addSubview:labelB];
        
        
        id imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - 35)];
        imageView.backgroundColor = [UIColor whiteColor];
        [self addSubview:imageView];
//        [self setQBDFProp:imageView forKey:@"imageView"];
        self.imageView = imageView;
       
        void (^blockA)()
        {
            
            id data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://desk.fd.zol-img.com.cn/t_s1920x1080c5/g5/M00/0F/04/ChMkJlbegiyIaSExAAh2hrdk6UsAAM7xQOueUQACHae442.jpg"]];
            id image = [UIImage imageWithData:data];
            void (^blockB)()
            {
                imageView.image = image;
            }
            dispatch_async_main(blockB);
        }
        
        dispatch_async_global_queue(blockA);
    }
    return self;
}
@end

id subcell = [[qbdfsubCell alloc] initWithFrame:baseView.bounds];
[baseView addSubview:subcell];



