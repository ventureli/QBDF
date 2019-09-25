int *a = malloc(sizeof(int) *1);
NSLog(@"a is:%@",a);
*a = 20;
NSLog(@"*a is:%@",*a);
free(a);


int *b = malloc(sizeof(int) *3);
//申请并操作内存
b[0] = 1;
b[1] = 22;
b[2] = 33;
NSLog(@"b[0] is:%@",b[0]);
NSLog(@"b[1] is:%@",b[1]);
NSLog(@"b[2] is:%@",b[2]);
free(b);

CGSize *theSize = malloc(sizeof(CGSize)*1);
*theSize = CGSizeMake(23,44);
theSize[0] = CGSizeMake(43,44);
NSLog(@"the sizeif:%@",*theSize);
free(theSize);

double *ptrd =malloc(sizeof(double)*1);
[TestObjct getDoublePTR:ptrd]; //指针传入系统
NSLog(@"the double is:%@",*ptrd);
free(ptrd);

