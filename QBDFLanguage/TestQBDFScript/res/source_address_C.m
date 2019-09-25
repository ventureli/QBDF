UIView *view = [[UIView alloc] initWithFrame:CGRectZero];

UIView **ptrview = &view;
NSLog(@"theview is:%@",view);
NSLog(@"ptrview is:%@",ptrview);
NSLog(@"*ptrview is:%@",*ptrview);

//ERROR msg
id *erroptr = [[UIView alloc] initWithFrame:CGRectZero]; //这是一个错误的赋值

NSLog(@"erroptr is:%@",erroptr);
NSLog(@"*erroptr is:%@",*erroptr);
