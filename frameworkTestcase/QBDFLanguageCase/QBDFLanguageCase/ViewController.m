//
//  ViewController.m
//  QBDFLanguageCase
//
//  Created by fatboyli on 2017/6/9.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "ViewController.h"
#import <QBDFLanguage/QBDFLanguage.h>
#import <QBDFLanguage/QBDFScriptInterpreter.h>
#import <QBDFLanguage/QBDFVM.h>




@implementation TestShareInstance


+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static TestShareInstance *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [TestShareInstance new];
    });
    return instance;
}

- (int)needSpecialNSInt:(NSInteger *)a
{
    if(a)
    {
        
        *a = 1100;
    }
    return 0;
}
- (void)needSpecialBOOLPoint:(BOOL *)pint
{
    *pint = YES;
}

- (void)needSpecialCGRect:(CGRect *)prect
{
    *prect = CGRectMake(100, 1001, 1002, 1004);
    
}

@end

@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *theStr = [[NSBundle mainBundle] pathForResource:@"res/source_mulicall" ofType:@"m"];
    QBDFScriptInterpreter *interpreter = [[QBDFScriptInterpreter alloc] init];
    NSArray *codes =  [interpreter QBDF_TranslateWithFile:theStr];
    
    NSData *data=[NSJSONSerialization dataWithJSONObject:codes options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString *jsonStr=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"jsonStr==%@",jsonStr);
    
    NSLog(@"<===================EVAL RES===========================>");
    NSLog(@"%@",UICollectionElementKindSectionHeader);
    [[QBDFVM shareInstance] evalCode:codes withInitEnvVar:@{@"theobj":self.view}];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
