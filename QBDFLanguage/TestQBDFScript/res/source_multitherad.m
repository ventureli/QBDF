@interface testMultiThread : NSObject

@end

@implementation testMultiThread

- (void)doMultiThread
{
    id queue = [[NSOperationQueue alloc] init];
    id op1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(run:) object:@"fatboyli"];
    
    void (^block)()
    {
        for (int i = 0; i < 20; i++)
        {
            NSLog(@"2-----%@", [NSThread currentThread],i);
        }
    }
    id op2 = [NSBlockOperation blockOperationWithBlock:block];
    [queue addOperation:op2];
    [queue addOperation:op1];
    
}
- (void)run:(id )name
{
    for(int i = 0;i < 30 ;i++)
    {
        
        NSLog(@"1------%@ name is :%@ i is:%@", [NSThread currentThread],name ,i);
    }
}

@end

id a = [testMultiThread new];
//PC = 4;
//
[a doMultiThread];

int c = 12 +8;
int d = 90;

