//
//  QBDFBLkTool.m
//  TestQBDFScript
//
//  Created by fatboyli on 2017/6/4.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "QBDFBLkTool.h"
#import "QBDFScriptMainDefine.h"
#import "QBDFMthdSign.h"
#import "QBDFVMContext.h"
#import <UIKit/UIKit.h>
#import "QBDFOCCALLCenter.h"
#import "QBDFNil.h"
#import "ffi.h"
#import "QBDFVarTypeHelper.h"

enum {
    BLOCK_DEALLOCATING =      (0x0001),
    BLOCK_REFCOUNT_MASK =     (0xfffe),
    BLOCK_NEEDS_FREE =        (1 << 24),
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25),
    BLOCK_HAS_CTOR =          (1 << 26),
    BLOCK_IS_GC =             (1 << 27),
    BLOCK_IS_GLOBAL =         (1 << 28),
    BLOCK_USE_STRET =         (1 << 29),
    BLOCK_HAS_SIGNATURE  =    (1 << 30)
};

struct QBDFSimulateBlock {
    void *isa;
    int flags;
    int reserved;
    void *invoke;
    struct QBDFSimulateBlockDescriptor *descriptor;
};

struct QBDFSimulateBlockDescriptor {
    //Block_descriptor_1
    struct {
        unsigned long int reserved;
        unsigned long int size;
    };
    
    /*
     //Block_descriptor_2
     //no need
     struct {
     // requires BLOCK_HAS_COPY_DISPOSE
     void (*copy)(void *dst, const void *src);
     void (*dispose)(const void *);
     };
     */
    
    //Block_descriptor_3
    struct {
        // requires BLOCK_HAS_SIGNATURE
        const char *signature;
        const char *layout;
    };
};


@interface QBDFBLkTool()
{
    
    ffi_cif *_cifPtr;
    ffi_type **_args;
    ffi_closure *_closure;
    BOOL _generatedPtr;
    void *_blockPtr;
    struct QBDFSimulateBlockDescriptor *_descriptor;
    }
@end


void QBDFBlockInterpreter(ffi_cif *cif, void *ret, void **args, void *userdata)
{
    
    QBDFBLkTool *blockObj = (__bridge  QBDFBLkTool*)userdata;
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    for (int i = 1; i < blockObj.sign.argumentTypes.count; i ++)
    {
        id param;
        void *argumentPtr = args[i];
        NSString *typeEncoding = [blockObj.sign argumentTypes][i];
        
        
        
        if([typeEncoding isEqualToString: [NSString stringWithUTF8String:@encode(CGSize)]])
        {
            CGSize returnValue = *(CGSize *)argumentPtr;
            param = [NSValue valueWithCGSize:returnValue];
        }else if([typeEncoding isEqualToString: [NSString stringWithUTF8String:@encode(CGPoint)]])
        {
            CGPoint returnValue = *(CGPoint *)argumentPtr;
            param = [NSValue valueWithCGPoint:returnValue];
        }else if([typeEncoding isEqualToString: [NSString stringWithUTF8String:@encode(CGRect)]])
        {
            CGRect returnValue = *(CGRect *)argumentPtr;
            param = [NSValue valueWithCGRect:returnValue];
        }else if([typeEncoding isEqualToString: [NSString stringWithUTF8String:@encode(NSRange)]])
        {
            NSRange returnValue = *(NSRange *)argumentPtr;
            param = [NSValue valueWithRange:returnValue];
        }else if([typeEncoding isEqualToString: [NSString stringWithUTF8String:@encode(UIEdgeInsets)]])
        {
            UIEdgeInsets returnValue = *(UIEdgeInsets *)argumentPtr;
            param = [NSValue valueWithUIEdgeInsets: returnValue];
        }
        
        unichar thechar;
        if(typeEncoding.length == 0)
        {
            thechar = 'v';
        }else{
            thechar =[typeEncoding characterAtIndex:0];
        }
        switch (thechar)
        {
                
            #define QBDF_BLOCK_NUMBER_CASE(_typeString, _type, _selector) \
            case _typeString: {                              \
            _type returnValue = *(_type *)argumentPtr;                     \
            param = [NSNumber _selector:returnValue];\
            break; \
            }
          

            QBDF_BLOCK_NUMBER_CASE('c', char, numberWithChar)
            QBDF_BLOCK_NUMBER_CASE('C', unsigned char, numberWithUnsignedChar)
            QBDF_BLOCK_NUMBER_CASE('s', short, numberWithShort)
            QBDF_BLOCK_NUMBER_CASE('S', unsigned short, numberWithUnsignedShort)
            QBDF_BLOCK_NUMBER_CASE('i', int, numberWithInt)
            QBDF_BLOCK_NUMBER_CASE('I', unsigned int, numberWithUnsignedInt)
            QBDF_BLOCK_NUMBER_CASE('l', long, numberWithLong)
            QBDF_BLOCK_NUMBER_CASE('L', unsigned long, numberWithUnsignedLong)
            QBDF_BLOCK_NUMBER_CASE('q', long long, numberWithLongLong)
            QBDF_BLOCK_NUMBER_CASE('Q', unsigned long long, numberWithUnsignedLongLong)
            QBDF_BLOCK_NUMBER_CASE('f', float, numberWithFloat)
            QBDF_BLOCK_NUMBER_CASE('d', double, numberWithDouble)
            QBDF_BLOCK_NUMBER_CASE('B', BOOL, numberWithBool)
            case '@':
            {
                param = (__bridge id)(*(void**)argumentPtr);
                break;
            }
            case '*':
            case '^':
            {
                param = [NSValue valueWithPointer:argumentPtr];
                break;
            }
            case ':':
            {
                SEL *argPtr = (SEL *)argumentPtr;
                SEL theSEL = *argPtr;
                params = NSStringFromSelector(theSEL);
                break;
            }
        }
       [params addObject:param];
    
    }
        
    __autoreleasing id res = [QBDFVMContext QBDF_RunBlkWithNode:blockObj.node args:params frameInfo:blockObj.frameStack];
    
    void **retPtrPtr = ret;
    *retPtrPtr = (__bridge  void *)res;
    
    NSString *retTypes = blockObj.sign.returnType;

    if([retTypes isEqualToString: [NSString stringWithUTF8String:@encode(CGSize)]])
    {
        CGSize *retPtr = ret;
        *retPtr = [res CGSizeValue];
    }else if([retTypes isEqualToString: [NSString stringWithUTF8String:@encode(CGPoint)]])
    {
        
        CGPoint *retPtr = ret;
        *retPtr = [res CGPointValue];
    }else if([retTypes isEqualToString: [NSString stringWithUTF8String:@encode(CGRect)]])
    {
        
        CGRect *retPtr = ret;
        *retPtr = [res CGRectValue];
    }else if([retTypes isEqualToString: [NSString stringWithUTF8String:@encode(NSRange)]])
    {
        
        NSRange *retPtr = ret;
        *retPtr = [res rangeValue];
        
    }else if([retTypes isEqualToString: [NSString stringWithUTF8String:@encode(UIEdgeInsets)]])
    {
        
        UIEdgeInsets *retPtr = ret;
        *retPtr = [res UIEdgeInsetsValue];
    }
    unichar retchar;
    if(retTypes.length == 0)
    {
        retchar = 'v';
    }else{
        retchar =[retTypes characterAtIndex:0];
    }
    
    switch (retchar)
    {
            #define QBDF_ARG_CASE(_typeString, _type, _selector) \
            case _typeString: {                              \
            _type *retPtr = ret; \
            *retPtr = [res _selector];   \
            break; \
            }
            QBDF_ARG_CASE('c', char, charValue)
            QBDF_ARG_CASE('C', unsigned char, unsignedCharValue)
            QBDF_ARG_CASE('s', short, shortValue)
            QBDF_ARG_CASE('S', unsigned short, unsignedShortValue)
            QBDF_ARG_CASE('i', int, intValue)
            QBDF_ARG_CASE('I', unsigned int, unsignedIntValue)
            QBDF_ARG_CASE('l', long, longValue)
            QBDF_ARG_CASE('L', unsigned long, unsignedLongValue)
            QBDF_ARG_CASE('q', long long, longLongValue)
            QBDF_ARG_CASE('Q', unsigned long long, unsignedLongLongValue)
            QBDF_ARG_CASE('f', float, floatValue)
            QBDF_ARG_CASE('d', double, doubleValue)
            QBDF_ARG_CASE('B', BOOL, boolValue)
        case '@':
        case '#': {
            id retObj = res;
           
            void **retPtrPtr = ret;
            *retPtrPtr = (__bridge void *)retObj;
            break;
        }
        case '*':
        case '^':
        {
            if([res isKindOfClass:[QBDFNil class]])
            {
                *retPtrPtr = NULL;
                
            }else
            {
                void *pointer = [((NSValue *)res) pointerValue];
                void **retPtrPtr = ret;
                *retPtrPtr = pointer;
                
            }
            break;
        }
        case ':':
        {
            if([res isKindOfClass:[QBDFNil class]] || [res isKindOfClass:[NSNull class]] || !res)
            {
                *retPtrPtr = nil;
                
            }else
            {
                NSString *str = [res description];
                SEL **retPtrPtr = ret;
                *retPtrPtr = NSSelectorFromString(str);
            }
        }
    }
     
}

@implementation QBDFBLkTool
+ (NSString *)nameofbaseType:(id)type
{
    return [type description];
}
+ (id)createBLKWithNode:(NSDictionary *)blknode
{
    return [[self alloc] initWithNodeDict:blknode];
    
}


- (id)initWithNodeDict:(NSDictionary *)dict
{
    self = [super init];
    if(self)
    {
        self.node = dict;
        NSDictionary *retDict = READNODEVALUE(dict, CMD_FUN_RET);
        NSString *retBaseType = [READNODEVALUE(retDict, CMD_FUN_RET_BASETYPE) description];
        NSString *retSubType = [READNODEVALUE(retDict, CMD_FUN_RET_SUBTYPE) description];
        NSArray *decArray = READNODEVALUE(dict, CMD_FUN_ARG);
        
        self.sign = [[QBDFMthdSign alloc] initWithRetBaseType:retBaseType retSubType:retSubType argtyps:decArray];
    }
    return self;
}

- (void *)blockPtr
{
    if (_generatedPtr) {
        return _blockPtr;
    }
    _generatedPtr = YES;
    ffi_type *returnType = [QBDFVarTypeHelper ffiTypeWithEncodingChar:self.sign.returnType];
    NSUInteger argumentCount = self.sign.argumentTypes.count;
    _cifPtr = malloc(sizeof(ffi_cif));
    void *blockImp = NULL;
    _args = malloc(sizeof(ffi_type *) *argumentCount) ;
    for (int i = 0; i < argumentCount; i++)
    {
        ffi_type* current_ffi_type = [QBDFVarTypeHelper ffiTypeWithEncodingChar:([self.sign argumentTypes ][i])];
        _args[i] = current_ffi_type;
    }
    _closure = ffi_closure_alloc(sizeof(ffi_closure), (void **)&blockImp);
    
    if(ffi_prep_cif(_cifPtr, FFI_DEFAULT_ABI, (unsigned int)argumentCount, returnType, _args) == FFI_OK) {
        if (ffi_prep_closure_loc(_closure, _cifPtr, QBDFBlockInterpreter, (__bridge   void *)self, blockImp) != FFI_OK) {
            NSAssert(NO, @"generate block error");
        }
    }
    
    NSString *oldType = self.sign.types;
    struct QBDFSimulateBlockDescriptor descriptor = {
        0,
        sizeof(struct QBDFSimulateBlock),
        [oldType cStringUsingEncoding:NSUTF8StringEncoding],
        NULL
    };
    
    _descriptor = malloc(sizeof(struct QBDFSimulateBlockDescriptor));
    memcpy(_descriptor, &descriptor, sizeof(struct QBDFSimulateBlockDescriptor));
    
    struct QBDFSimulateBlock simulateBlock = {
        &_NSConcreteStackBlock,
        (BLOCK_HAS_SIGNATURE), 0,
        blockImp,
        _descriptor
    };
    
    _blockPtr = malloc(sizeof(struct QBDFSimulateBlock));
    memcpy(_blockPtr, &simulateBlock, sizeof(struct QBDFSimulateBlock));
    
    return _blockPtr;
    
}

- (void)dealloc
{
    if(_closure != NULL)
    {
        
        ffi_closure_free(_closure);
        free(_args);
        free(_cifPtr);
        free(_blockPtr);
        free(_descriptor);
    }
    return;
}


@end
