//
//  QBDFOCCALLCenter.m
//  QBDFScript
//
//  Created by fatboyli on 17/5/22.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "QBDFOCCALLCenter.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "QBDFScriptMainDefine.h"
#import "QBDFBLkTool.h"
#import "QBDFSYSCenter.h"
#import "QBDFVMContext.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "QBDFBLKDescription.h"
#import "QBDFStruct.h"
#import "QBDFSYSCenter+SuperCall.h"
#import "QBDFSYSCenter+QBDFStruct.h"

static id (*new_msgSend1)(id, SEL, id,...) = (id (*)(id, SEL, id,...)) objc_msgSend;
static id (*new_msgSend2)(id, SEL, id, id,...) = (id (*)(id, SEL, id, id,...)) objc_msgSend;
static id (*new_msgSend3)(id, SEL, id, id, id,...) = (id (*)(id, SEL, id, id, id,...)) objc_msgSend;
static id (*new_msgSend4)(id, SEL, id, id, id, id,...) = (id (*)(id, SEL, id, id, id, id,...)) objc_msgSend;
static id (*new_msgSend5)(id, SEL, id, id, id, id, id,...) = (id (*)(id, SEL, id, id, id, id, id,...)) objc_msgSend;
static id (*new_msgSend6)(id, SEL, id, id, id, id, id, id,...) = (id (*)(id, SEL, id, id, id, id, id, id,...)) objc_msgSend;
static id (*new_msgSend7)(id, SEL, id, id, id, id, id, id, id,...) = (id (*)(id, SEL, id, id, id, id, id, id,id,...)) objc_msgSend;
static id (*new_msgSend8)(id, SEL, id, id, id, id, id, id, id, id,...) = (id (*)(id, SEL, id, id, id, id, id, id, id, id,...)) objc_msgSend;
static id (*new_msgSend9)(id, SEL, id, id, id, id, id, id, id, id, id,...) = (id (*)(id, SEL, id, id, id, id, id, id, id, id, id, ...)) objc_msgSend;
static id (*new_msgSend10)(id, SEL, id, id, id, id, id, id, id, id, id, id,...) = (id (*)(id, SEL, id, id, id, id, id, id, id, id, id, id,...)) objc_msgSend;

static id getArgument(id valObj){
    if ([valObj isKindOfClass:[QBDFNil class]])
    {
        return nil;
    }
    return valObj;
}




@interface QBDFOCCALLCenter()
{
//    id testpoint;
}
@end
@implementation QBDFOCCALLCenter


+(instancetype)shareInstance
{
    static QBDFOCCALLCenter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[QBDFOCCALLCenter alloc] init];
    });
    return instance;
}



- (id)runInstanceMethodOfTargetName:(id)argtarget sel:(NSString *)selname args:(NSArray *)args
{
    if(!argtarget)
    {
        return nil;
    }
    id target = argtarget;
    SEL sel = NSSelectorFromString(selname);
    if([argtarget isKindOfClass:[QBDFNil class]])
    {
        return nil;
    }
    
    BOOL issuper = NO;
    NSString *superClsName = @"";
    if([target isKindOfClass:[QBDFSuprWrapepr class]]) //super 解包
    {
        issuper = YES;
        if(((QBDFSuprWrapepr *)argtarget).isassign)
        {
            target = ((QBDFSuprWrapepr *)argtarget).assignTarget;
        }else
        {
            
            target = ((QBDFSuprWrapepr *)argtarget).target;
        }
        NSString *decKey = getSuperCallKeyNameBySelName(selname);
        NSString *theCurSupValue = [[QBDFSYSCenter shareInstance] readCallSuperClassWithKey:decKey];
        NSString *value = nil;
        Class realClass = [target class];
        if(theCurSupValue)
        {
            value = theCurSupValue;
            realClass = NSClassFromString(value);
        }
        Class  superCls = [realClass superclass];
        Method superMethod = class_getInstanceMethod(superCls, sel);
        IMP superIMP = method_getImplementation(superMethod);
        superClsName = NSStringFromClass(superCls);
        NSString *superSelectorName = [NSString stringWithFormat:@"__QBDFSUPER_%@_QBFBLDF_%@",superClsName,selname];
        SEL superSelector = NSSelectorFromString(superSelectorName);
        if(![realClass instancesRespondToSelector:superSelector])
        {
            class_addMethod([realClass class], superSelector, superIMP, method_getTypeEncoding(superMethod));
        }
        sel = superSelector;//置换super
    }
    if([target isKindOfClass:[QBDFAssignWrapper class]])
    {
        target = ((QBDFAssignWrapper *)argtarget).assignTarget;
    }
    if(!target)
    {
        return nil;
    }
    NSMethodSignature *sig = [target methodSignatureForSelector:sel];
    if(sig)
    {
        if([sig numberOfArguments] -2 != [args count])
        {
            return [self _valArgsWithTarget:target sel:sel args:args sig:sig];
        }
        
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:target];
        [inv setSelector:sel];
        [self _setInvArguments:inv sig:sig selName:selname args:args isblk:NO];
        NSString *decKey = getSuperCallKeyNameBySelName(NSStringFromSelector(sel));
        if(superClsName.length >0)
        {
            
            [[QBDFSYSCenter shareInstance] updateCallSuperClassWithKey:decKey value:superClsName];
        }
        [inv invoke];
        if(superClsName.length > 0)
        {
            [[QBDFSYSCenter shareInstance] deleteCallSuperClassWithKey:decKey];
        }
        return [self _getReturnValueOfInvocation:inv sig:sig selName:selname];
    }else
    {
        NSDictionary *node =QBDFGetNodeOfClassNameHierachy(NSStringFromClass([target class]), selname)  ;// [QBDFSYSCenter
        if(node)
        {
          return  [QBDFVMContext QBDF_RUNOCMTHDWithNode:node args:args sel:sel target:target];
        }else
        {
            __QBDF_ERROR__([NSString stringWithFormat:@"%@ 不支持方法 %@",target,selname]);
            
        }
       
    }
    return nil;
}
//读取属性
- (id)readPropertyValueWithTarget:(id)target propertName:(NSString *)name
{
    if([target isKindOfClass:[QBDFStruct class]])
    {
        QBDFStruct *structTarget =( QBDFStruct *)target;
        return [structTarget readProperty:name];
    }
    else if([target isKindOfClass:[NSValue class]])
    {
        return [self _readStructValueByDotWithTarget:target properName:name];
    }else
    {
        //直接运行这个方法
        return [self runInstanceMethodOfTargetName:target sel:name args:nil];
    }
}

//更新属性
- (void)updatePropertyValueWithTarget:(id)target propertName:(NSString *)name value:(id)value
{
    if(!name || ![name isKindOfClass:[NSString class]] || name.length==0)
    {
        return;
    }
    if([target isKindOfClass:[NSValue class]])
    {
        __QBDF_ERROR__(@"不能直接更新基本结构变量，请用CGXXXXMake系列函数");
        
    }else if([target isKindOfClass:[QBDFStruct class]])
    {
        QBDFStruct *stuctValue = (QBDFStruct *)target;
        [stuctValue setProperty:name value:value];

    }else
    {
        //直接运行这个方法
        NSString *first=[[name substringToIndex:1] uppercaseString];
        NSString *next =[name substringFromIndex:1];
        NSString *setsel = nil;
        setsel = [NSString stringWithFormat:@"set%@%@:",first ,next?:@""];
        [self runInstanceMethodOfTargetName:target sel:setsel args:@[value]];
        return;
    }
}
//读取变量
- (id)readIvarValueWithTarget:(id)target propertName:(NSString *)name
{
    Ivar ponyIvar = class_getInstanceVariable ([target class], [name cStringUsingEncoding:NSUTF8StringEncoding]);
    NSString *strtype = [NSString stringWithCString:ivar_getTypeEncoding(ponyIvar) encoding:NSUTF8StringEncoding ];
    if([strtype hasPrefix:@"@"])//这是一个objc的对象
    {
        id val = object_getIvar (target, ponyIvar);
        if(val)
        {
            return val;
        }
    }else
    {
        Ivar gilliganIvar = class_getInstanceVariable ([target class],[name cStringUsingEncoding:NSUTF8StringEncoding]);
        ptrdiff_t offset = ivar_getOffset(gilliganIvar);
        unsigned char *stuffBytes = (unsigned char *)(__bridge void *)target;
        
        id theres;
        
        #define QBDF_VAR_CASE(encode, type ) \
        case encode: {                              \
        type resvalue = * ((type *)(stuffBytes + offset));\
        theres = @(resvalue); \
        break; \
        }
        const char *argumentType = ivar_getTypeEncoding(gilliganIvar);
        switch (argumentType[0] == 'r' ? stuffBytes[1] : argumentType[0])
        {
                QBDF_VAR_CASE('c', char)
                QBDF_VAR_CASE('C', unsigned char)
                QBDF_VAR_CASE('s', short)
                QBDF_VAR_CASE('S', unsigned short)
                QBDF_VAR_CASE('i', int)
                QBDF_VAR_CASE('I', unsigned int)
                QBDF_VAR_CASE('l', long)
                QBDF_VAR_CASE('L', unsigned long)
                QBDF_VAR_CASE('q', long long)
                QBDF_VAR_CASE('Q', unsigned long long)
                QBDF_VAR_CASE('f', float)
                QBDF_VAR_CASE('d', double)
                QBDF_VAR_CASE('B', BOOL)
        }

        return theres;
    }
    return nil;
}

//更新变量
- (void)updateIvarValueWithTarget:(id)target propertName:(NSString *)name value:(id)value
{
    Ivar ponyIvar = class_getInstanceVariable ([target class], [name cStringUsingEncoding:NSUTF8StringEncoding]);
    NSString *strtype = [NSString stringWithCString:ivar_getTypeEncoding(ponyIvar) encoding:NSUTF8StringEncoding ];
    if([strtype hasPrefix:@"@"])//这是一个objc的对象
    {
        object_setIvar(target, ponyIvar, value);
    }else
    {
        Ivar gilliganIvar = class_getInstanceVariable ([target class],[name cStringUsingEncoding:NSUTF8StringEncoding]);
        ptrdiff_t offset = ivar_getOffset(gilliganIvar);
        unsigned char *stuffBytes = (unsigned char *)(__bridge void *)target;
        
        #define QBDF_UPVAR_CASE(_typeString, _type, _selector) \
        case _typeString: {                              \
          *((_type *)(stuffBytes + offset)) = [value _selector];\
        break; \
        }
        const char *argumentType = ivar_getTypeEncoding(gilliganIvar);
        switch (argumentType[0] == 'r' ? stuffBytes[1] : argumentType[0])
        {
            QBDF_UPVAR_CASE('c', char, charValue)
            QBDF_UPVAR_CASE('C', unsigned char, unsignedCharValue)
            QBDF_UPVAR_CASE('s', short, shortValue)
            QBDF_UPVAR_CASE('S', unsigned short, unsignedShortValue)
            QBDF_UPVAR_CASE('i', int, intValue)
            QBDF_UPVAR_CASE('I', unsigned int, unsignedIntValue)
            QBDF_UPVAR_CASE('l', long, longValue)
            QBDF_UPVAR_CASE('L', unsigned long, unsignedLongValue)
            QBDF_UPVAR_CASE('q', long long, longLongValue)
            QBDF_UPVAR_CASE('Q', unsigned long long, unsignedLongLongValue)
            QBDF_UPVAR_CASE('f', float, floatValue)
            QBDF_UPVAR_CASE('d', double, doubleValue)
            QBDF_UPVAR_CASE('B', BOOL, boolValue)
        }
    }
    return;

}

- (void)_updateStructValueByDotWithTarget:(id)target properName:(NSString *)name value:(id)value
{
    if(![target isKindOfClass:[NSValue class]])
    {
        __QBDF_ERROR__([NSString stringWithFormat:@"error 不能用.%@符号取值%@",name,target]);
        
    }else{
        NSString *types =  [NSString stringWithCString:[target objCType] encoding:NSUTF8StringEncoding];//[value objCType];
        if([types hasPrefix:@"{CGPoint"])
        {
            
            CGPoint oldPoint = [target CGPointValue];
            if([name isEqualToString:@"x"])
            {
                target = [NSValue valueWithCGPoint:CGPointMake([value doubleValue], oldPoint.y)];
            }else if([name isEqualToString:@"y"])
            {
                target = [NSValue valueWithCGPoint:CGPointMake(oldPoint.x, [value doubleValue])];
            }else{
                __QBDF_ERROR__([NSString stringWithFormat:@"CGPoint 没有%@属性",name]);
                
            
            }
        }else if([types hasPrefix:@"{CGSize"])
        {
            CGSize oldsize = [target CGSizeValue];
            
            if([name isEqualToString:@"width"])
            {
                target = [NSValue valueWithCGSize:CGSizeMake([value doubleValue], oldsize.height)];
                
            }else if([name isEqualToString:@"height"])
            {
                
                target = [NSValue valueWithCGSize:CGSizeMake(oldsize.width,[value doubleValue])];
            }else{
                __QBDF_ERROR__([NSString stringWithFormat:@"CGSize 没有%@属性",name]);
                
              
            }
        }else if([types hasPrefix:@"{CGRect"])
        {
            CGRect  oldRect = [target CGRectValue];
            
            if([name isEqualToString:@"origin"])
            {
                CGRect rect;
                rect.size = oldRect.size;
                rect.origin = [value CGPointValue];
                target = [NSValue valueWithCGRect:rect];
                
                
            }else if([name isEqualToString:@"size"])
            {
                CGRect rect;
                rect.origin = oldRect.origin;
                rect.size = [value CGSizeValue];
                target = [NSValue valueWithCGRect:rect];

            }else{
//                NSAssert1(0, @"CGRect 没有%@属性", name);
                __QBDF_ERROR__([NSString stringWithFormat:@"CGRect 没有%@属性",name]);
                
         
            }
            
        }else if([types hasPrefix:@"{_NSRange"])
        {
            NSRange oldRan = [target rangeValue];
            if([name isEqualToString:@"length"])
            {
                target = [NSValue valueWithRange:NSMakeRange(oldRan.location, [value doubleValue])];

            }else if([name isEqualToString:@"location"])
            {
                target = [NSValue valueWithRange:NSMakeRange([value doubleValue],oldRan.location)];
            }else{
//                NSAssert1(0, @"CGRect 没有%@属性", name);
                __QBDF_ERROR__([NSString stringWithFormat:@"_NSRange 没有%@属性",name]);
                
            }
        }else if([types hasPrefix:@"{UIEdgeInsets"]){
            UIEdgeInsets oldinsert = [target UIEdgeInsetsValue];
            UIEdgeInsets newinsert ;
            if([name isEqualToString:@"top"])
            {
                newinsert = UIEdgeInsetsMake([value floatValue], oldinsert.left, oldinsert.bottom, oldinsert.right);
            }
            if([name isEqualToString:@"left"])
            {
                newinsert =UIEdgeInsetsMake(oldinsert.top,[value floatValue] , oldinsert.bottom, oldinsert.right);
            }
            if([name isEqualToString:@"bottom"])
            {
                newinsert = UIEdgeInsetsMake(oldinsert.top,oldinsert.left,[value floatValue] , oldinsert.right);
            }
            if([name isEqualToString:@"right"])
            {
                newinsert = UIEdgeInsetsMake(oldinsert.top,oldinsert.left,oldinsert.bottom,[value floatValue]);
            }
            target = [NSValue valueWithUIEdgeInsets:newinsert];
        }else{
            __QBDF_ERROR__([NSString stringWithFormat:@"_cannot process the struct %@",target]);
            
        }
    }
    return ;
}
- (id)_readStructValueByDotWithTarget:(id)target properName:(NSString *)name
{
    NSValue *value = (NSValue *)target;
    if(![target isKindOfClass:[NSValue class]])
    {
        __QBDF_ERROR__([NSString stringWithFormat:@"error 不能用.%@符号取值%@",name,target]);
        return nil;
    }else{
        NSString *types =  [NSString stringWithCString:[value objCType] encoding:NSUTF8StringEncoding];
        if([types hasPrefix:@"{CGPoint"])
        {
            if([name isEqualToString:@"x"])
            {
                return @([value CGPointValue].x);
            }else if([name isEqualToString:@"y"])
            {
                
                return @([value CGPointValue].y);
            }else{
                __QBDF_ERROR__([NSString stringWithFormat:@"CGPoint 没有%@属性",name]);
                return @(0);
            }
        }else if([types hasPrefix:@"{CGSize"])
        {
            if([name isEqualToString:@"width"])
            {
                return @([value CGSizeValue].width);
            }else if([name isEqualToString:@"height"])
            {
                return @([value CGSizeValue].height);
            }else{
                __QBDF_ERROR__([NSString stringWithFormat:@"CGSize 没有%@属性",name]);
                
                return @(0);
            }
        }else if([types hasPrefix:@"{CGRect"])
        {
            if([name isEqualToString:@"origin"])
            {
                return  [NSValue valueWithCGPoint:[value CGRectValue].origin];
            }else if([name isEqualToString:@"size"])
            {
                return [NSValue valueWithCGSize:[value CGRectValue].size];
            }else{
                __QBDF_ERROR__([NSString stringWithFormat:@"CGRect 没有%@属性",name]);
                
                return @(0);
            }
            
        }else if([types hasPrefix:@"{_NSRange"])
        {
            if([name isEqualToString:@"length"])
            {
                return @([value rangeValue].length);
            }else if([name isEqualToString:@"location"])
            {
                return @([value rangeValue].location);
            }else{
                __QBDF_ERROR__([NSString stringWithFormat:@"_NSRange 没有%@属性",name]);
                
                return @(0);
            }
        }else if([types hasPrefix:@"{UIEdgeInsets"])
        {
            if([name isEqualToString:@"top"])
            {
                return @([value UIEdgeInsetsValue].top);
            }
            if([name isEqualToString:@"left"])
            {
                return @([value UIEdgeInsetsValue].left);
                
            }
            if([name isEqualToString:@"bottom"])
            {
                return @([value UIEdgeInsetsValue].bottom);
                
            }
            if([name isEqualToString:@"right"])
            {
                return @([value UIEdgeInsetsValue].right);
                
            }
        }else{
            __QBDF_ERROR__([NSString stringWithFormat:@"cannot process the struct %@",target]);
            
        }
    }
    return nil;
}
//读取下标和[@"good"]字典变量
- (id)readArrayOrDictValue:(id)target key:(id)name
{
    if([target isKindOfClass:[NSDictionary class]])
    {
//        NSLog(@"dict");
        if(name)
        {
            return target[name];
        }
        
    }else if([target isKindOfClass:[NSArray class]])
    {
        if(name)
        {
            if([((NSArray *)target) count] > [name integerValue])
            {
                return target[[name integerValue]];
            }
        }
        
    }else
    {
        
//        NSAssert(0, @"中括号表达式用于左值的时候，只能是可变数组和可变字典");
        __QBDF_ERROR__(@"中括号表达式用于左值的时候，只能是可变数组和可变字典");
        
        
    }
    return nil;
}
//更新下标和[@"good"]字典变量
- (void)updateArrayOrDictValue:(id)target key:(id )name value:(id)value
{
    if([target isKindOfClass:[NSMutableDictionary class]])
    {
        if(name)
        {
            target[name] = value;
        }
        
    }else if([target isKindOfClass:[NSMutableArray class]])
    {
        if(name)
        {
            target[[name integerValue]] = value;
        }
        
    }else
    {
        __QBDF_ERROR__(@"中括号表达式用于左值的时候，只能是可变数组和可变字典");
    }
}

- (void)_setInvArguments:(NSInvocation *)inv sig:(NSMethodSignature *)sig  selName:(NSString *)selname args:(NSArray *)args isblk:(BOOL)isbok
{
    if([args count]==0)
    {
        
        return;
    }
    NSInteger numberofArgs = [sig numberOfArguments];
    int cha = isbok?1:2;
    if(([args count] +cha )!= numberofArgs)
    { //可变参数
        
        __QBDF_ERROR__([NSString stringWithFormat:@"参数个数不对%@",selname]);
        return;
    }
    for (NSUInteger i = cha; i < numberofArgs; i++)
    {
        const char *argumentType = [sig getArgumentTypeAtIndex:i];
        id valObj = args[i-cha];
        switch (argumentType[0] == 'r' ? argumentType[1] : argumentType[0])
        {
            #define QBDF_ARG_CASE(_typeString, _type, _selector) \
            case _typeString: {                              \
            _type value = [valObj _selector];                     \
            [inv setArgument:&value atIndex:i];\
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
                
            case ':': {
                SEL value = nil;
                if (valObj) {
                    value = NSSelectorFromString([valObj description]);
                }
                [inv setArgument:&value atIndex:i];
                
                break;
            }
            case '{': {
                NSString *typeString = [QBDFSYSCenter extractStructName:([NSString stringWithUTF8String:argumentType])];
                id val = args[i- cha];
                #define QBDF_ARG_STRUCT(_type, _methodName,defaultValue) \
                else if ([typeString rangeOfString:@#_type].location != NSNotFound) {    \
                    if([val respondsToSelector:@selector(_methodName)])\
                    {   \
                        _type value = [val _methodName];  \
                        [inv setArgument:&value atIndex:i];  \
                    }else{\
                        _type value = defaultValue;   \
                        [inv setArgument:&value atIndex:i];  \
                    }\
                break; \
                }
        
                if(0){}
                QBDF_ARG_STRUCT(CGRect, CGRectValue,CGRectZero)
                QBDF_ARG_STRUCT(CGPoint, CGPointValue,CGPointZero)
                QBDF_ARG_STRUCT(CGSize, CGSizeValue,CGSizeZero)
                QBDF_ARG_STRUCT(NSRange, rangeValue, NSMakeRange(0, 0))
                QBDF_ARG_STRUCT(UIEdgeInsets, UIEdgeInsetsValue,UIEdgeInsetsZero)
                else
                {
                    if([val isKindOfClass:[QBDFStruct class]])
                    {
                        QBDFStruct *qbst = (QBDFStruct *)val;
                        int size =  [qbst memSize];
                        void *ret = malloc(size);
                        [qbst getMemStructData:ret];
                        [inv setArgument:ret atIndex:i];
                        free(ret);
                    }
                }
                
                break;
            }
            case '*':
            case '^': {
                if([args[i-cha] isKindOfClass:[QBDFNil class]])
                {
                    valObj = nil;
                    [inv setArgument:&valObj atIndex:i];
                }else if([args[i-cha] isKindOfClass:[NSNull class]])
                {
                    valObj = NULL;
                    [inv setArgument:&valObj atIndex:i];
                }else
                {
                    NSValue *val = args[i-cha];
                    if([val respondsToSelector:@selector(pointerValue)])
                    {
                        void *value = [val pointerValue];
                        [inv setArgument:&value atIndex:i];
                    }else{
                        valObj = nil;
                        [inv setArgument:&valObj atIndex:i];

                    }
                    
                }
                break;
            }
            case '#': {
                    Class value = valObj;
                    [inv setArgument:&value atIndex:i];
                    break;
              
            }
                
            default: {
                
                if([valObj isKindOfClass:[QBDFAssignWrapper class]])
                {
                    valObj = ((QBDFAssignWrapper *)valObj).assignTarget;
                }
                if ([valObj isKindOfClass:[NSNull class]]){
                    valObj = NULL;
                    [inv setArgument:&valObj atIndex:i];
                    break;
                }
                if ([valObj isKindOfClass:[QBDFNil class]]) {
                    valObj = nil;
                    [inv setArgument:&valObj atIndex:i];
                    break;
                }else
                {
                    //如果是block
                    if([valObj isKindOfClass:[QBDFBLkTool class]]) //TODO:Fix heree
                    {
                       __autoreleasing QBDFBLkTool *tool = valObj;
                        void *blockPtr = [tool blockPtr];
                        __autoreleasing id  blk = [(__bridge   id)blockPtr copy];
                        objc_setAssociatedObject(blk ,[@"thetook" UTF8String],tool,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                        [inv setArgument:&blk atIndex:i];
                    }else
                    {
                        [inv setArgument:&valObj atIndex:i];
                        
                    }
                    
                }
            }
        }
    }
    
}




- (id)_getReturnValueOfInvocation:(NSInvocation *)inv sig:(NSMethodSignature *)sig selName:(NSString *)selname
{
    if(!sig)
    {
        return nil;
    }
    if(!inv)
    {
        return nil;
    }
    if(!selname)
    {
        return nil;
    }
    char returnType[255];
    strcpy(returnType, [sig methodReturnType]);
    
    id returnValue;
    if (strncmp(returnType, "v", 1) != 0)
    {
        if (strncmp(returnType, "@", 1) == 0)
        {
            void *result;
            [inv getReturnValue:&result];
            
            if ([selname isEqualToString:@"alloc"] || [selname isEqualToString:@"new"] ||
                [selname isEqualToString:@"copy"] || [selname isEqualToString:@"mutableCopy"]) {
                returnValue = (__bridge_transfer id)result;
            } else {
                returnValue = (__bridge id)result;
            }
            
            if([returnValue isKindOfClass:[QBDFNil class]])
            {
                returnValue = nil;
            }
            if([returnValue isKindOfClass:[QBDFAssignWrapper class]])
            {
                returnValue = ((QBDFAssignWrapper *)returnValue).assignTarget;
            }
            
        } else {
            switch (returnType[0] == 'r' ? returnType[1] : returnType[0])
            {
                    //基本参考JP的使用，返回值处理
                    #define QBDF_RET_CASE(_typechar, _type) \
                    case _typechar: {                              \
                    _type tempResultSet; \
                    [inv getReturnValue:&tempResultSet];\
                    returnValue = @(tempResultSet); \
                    break; \
                    }
                    QBDF_RET_CASE('c', char)
                    QBDF_RET_CASE('C', unsigned char)
                    QBDF_RET_CASE('s', short)
                    QBDF_RET_CASE('S', unsigned short)
                    QBDF_RET_CASE('i', int)
                    QBDF_RET_CASE('I', unsigned int)
                    QBDF_RET_CASE('l', long)
                    QBDF_RET_CASE('L', unsigned long)
                    QBDF_RET_CASE('q', long long)
                    QBDF_RET_CASE('Q', unsigned long long)
                    QBDF_RET_CASE('f', float)
                    QBDF_RET_CASE('d', double)
                    QBDF_RET_CASE('B', BOOL)
                    
                case '{':
                {
                    NSString *typeString = [QBDFSYSCenter extractStructName:[NSString stringWithUTF8String:returnType]];
                    #define QBDF_RET_STRUCT(_type, _methodName) \
                    else if ([typeString rangeOfString:@#_type].location != NSNotFound) {    \
                    _type tempResultSet;   \
                    [inv getReturnValue:&tempResultSet]; \
                    returnValue = [NSValue _methodName:tempResultSet];\
                    }
                    if(0){}
                    QBDF_RET_STRUCT(CGRect, valueWithCGRect)
                    QBDF_RET_STRUCT(CGPoint, valueWithCGPoint)
                    QBDF_RET_STRUCT(CGSize, valueWithCGSize)
                    QBDF_RET_STRUCT(NSRange, valueWithRange)
                    QBDF_RET_STRUCT(UIEdgeInsets, valueWithUIEdgeInsets)
                    else
                    {
                        QBDFStructDefine *define  =  [[QBDFSYSCenter shareInstance] readStructDefine:typeString];
                        if(define)
                        {
                            int size = define.totalSize;
                            if(size > 0)
                            {
                                void *ret = malloc(size);
                                [inv getReturnValue:ret];
                                QBDFStruct *theStruct = [QBDFStruct getInstanceWithData:ret theDefine:define];
                                returnValue = theStruct;
                                free(ret);
                                break;
                            }
                        }
                    }
                }
                break;
                    
                case '*':
                case '^': //CGColor 这种
                {
                    //指针和block 暂不支持偶
                    void *tempResultSet;
                    [inv getReturnValue:&tempResultSet];
                    returnValue = [NSValue valueWithPointer:tempResultSet];
                }
                    break;
                case '#':
                {
                    Class result;
                    [inv getReturnValue:&result];
                    returnValue =  result;
                    break;
                }
            }
        }
    }else
    {
        
    }
    return returnValue;
    
}


- (id)callBLKWithblk:(id)blk args:(NSArray *)args
{
    QBDFBLKDescription *dec = [[QBDFBLKDescription alloc] initWithBlock:blk];
    NSMethodSignature *sig =  dec.blockSignature;
    if(sig)
    {
       NSInvocation *inv =   [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:[blk copy]];
        [self _setInvArguments:inv sig:sig selName:@"" args:args isblk:YES ];
        [inv invoke];
        return [self _getReturnValueOfInvocation:inv sig:sig selName:@""];
        
    }
    return [QBDFNil new];
}


- (id)_valArgsWithTarget:(id)sender sel:(SEL)selector args:(NSArray *)argumentsList sig:(NSMethodSignature *)sig
{
    id results;
    int numberOfArguments = (int)[sig numberOfArguments] -2;
    
    if([argumentsList count] == 1) {
        results = new_msgSend1(sender, selector, getArgument([argumentsList objectAtIndex:0]));
    } else if([argumentsList count] == 2) {
        if(numberOfArguments == 1) {
            results = new_msgSend1(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]));
        } else if(numberOfArguments == 2){
            results = new_msgSend2(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]));
        }
    } else if([argumentsList count] == 3) {
        if(numberOfArguments == 1) {
            results = new_msgSend1(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]));
        } else if(numberOfArguments == 2){
            results = new_msgSend2(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]));
        } else if(numberOfArguments == 3){
            results = new_msgSend3(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]));
        }
    } else if([argumentsList count] == 4) {
        if(numberOfArguments == 1) {
            results = new_msgSend1(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]));
        } else if(numberOfArguments == 2){
            results = new_msgSend2(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]));
        } else if(numberOfArguments == 3){
            results = new_msgSend3(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]));
        } else if(numberOfArguments == 4){
            results = new_msgSend4(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]));
        }
    } else if([argumentsList count] == 5) {
        if(numberOfArguments == 1) {
            results = new_msgSend1(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]));
        } else if(numberOfArguments == 2){
            results = new_msgSend2(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]));
        } else if(numberOfArguments == 3){
            results = new_msgSend3(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]));
        } else if(numberOfArguments == 4){
            results = new_msgSend4(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]));
        } else if(numberOfArguments == 5){
            results = new_msgSend5(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]));
        }
    } else if([argumentsList count] == 6) {
        if(numberOfArguments == 1) {
            results = new_msgSend1(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]));
        } else if(numberOfArguments == 2){
            results = new_msgSend2(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]));
        } else if(numberOfArguments == 3){
            results = new_msgSend3(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]));
        } else if(numberOfArguments == 4){
            results = new_msgSend4(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]));
        } else if(numberOfArguments == 5){
            results = new_msgSend5(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]));
        } else if(numberOfArguments == 6){
            results = new_msgSend6(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]));
        }
    } else if([argumentsList count] == 7) {
        if(numberOfArguments == 1) {
            results = new_msgSend1(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]));
        } else if(numberOfArguments == 2){
            results = new_msgSend2(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]));
        } else if(numberOfArguments == 3){
            results = new_msgSend3(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]));
        } else if(numberOfArguments == 4){
            results = new_msgSend4(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]));
        } else if(numberOfArguments == 5){
            results = new_msgSend5(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]));
        } else if(numberOfArguments == 6){
            results = new_msgSend6(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]));
        } else if(numberOfArguments == 7){
            results = new_msgSend7(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]));
        }
    } else if([argumentsList count] == 8) {
        if(numberOfArguments == 1) {
            results = new_msgSend1(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]), getArgument([argumentsList objectAtIndex:7]));
        } else if(numberOfArguments == 2){
            results = new_msgSend2(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]), getArgument([argumentsList objectAtIndex:7]));
        } else if(numberOfArguments == 3){
            results = new_msgSend3(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]), getArgument([argumentsList objectAtIndex:7]));
        } else if(numberOfArguments == 4){
            results = new_msgSend4(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]), getArgument([argumentsList objectAtIndex:7]));
        } else if(numberOfArguments == 5){
            results = new_msgSend5(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]), getArgument([argumentsList objectAtIndex:7]));
        } else if(numberOfArguments == 6){
            results = new_msgSend6(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]), getArgument([argumentsList objectAtIndex:7]));
        } else if(numberOfArguments == 7){
            results = new_msgSend7(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]), getArgument([argumentsList objectAtIndex:7]));
        } else if(numberOfArguments == 8){
            results = new_msgSend8(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]), getArgument([argumentsList objectAtIndex:7]));
        }
    } else if([argumentsList count] == 9) {
        if(numberOfArguments == 1) {
            results = new_msgSend1(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]), getArgument([argumentsList objectAtIndex:7]), getArgument([argumentsList objectAtIndex:8]));
        } else if(numberOfArguments == 2){
            results = new_msgSend2(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]), getArgument([argumentsList objectAtIndex:7]), getArgument([argumentsList objectAtIndex:8]));
        } else if(numberOfArguments == 3){
            results = new_msgSend3(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]), getArgument([argumentsList objectAtIndex:7]), getArgument([argumentsList objectAtIndex:8]));
        } else if(numberOfArguments == 4){
            results = new_msgSend4(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]), getArgument([argumentsList objectAtIndex:7]), getArgument([argumentsList objectAtIndex:8]));
        } else if(numberOfArguments == 5){
            results = new_msgSend5(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]), getArgument([argumentsList objectAtIndex:7]), getArgument([argumentsList objectAtIndex:8]));
        } else if(numberOfArguments == 6){
            results = new_msgSend6(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]), getArgument([argumentsList objectAtIndex:7]), getArgument([argumentsList objectAtIndex:8]));
        } else if(numberOfArguments == 7){
            results = new_msgSend7(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]), getArgument([argumentsList objectAtIndex:7]), getArgument([argumentsList objectAtIndex:8]));
        } else if(numberOfArguments == 8){
            results = new_msgSend8(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]), getArgument([argumentsList objectAtIndex:7]), getArgument([argumentsList objectAtIndex:8]));
        } else if(numberOfArguments == 9){
            results = new_msgSend9(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]), getArgument([argumentsList objectAtIndex:7]), getArgument([argumentsList objectAtIndex:8]));
        }
    } else if([argumentsList count] == 10) {
        if(numberOfArguments == 1) {
            results = new_msgSend1(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]), getArgument([argumentsList objectAtIndex:7]), getArgument([argumentsList objectAtIndex:8]), getArgument([argumentsList objectAtIndex:9]));
        } else if(numberOfArguments == 2){
            results = new_msgSend2(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]), getArgument([argumentsList objectAtIndex:7]), getArgument([argumentsList objectAtIndex:8]), getArgument([argumentsList objectAtIndex:9]));
        } else if(numberOfArguments == 3){
            results = new_msgSend3(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]), getArgument([argumentsList objectAtIndex:7]), getArgument([argumentsList objectAtIndex:8]), getArgument([argumentsList objectAtIndex:9]));
        } else if(numberOfArguments == 4){
            results = new_msgSend4(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]), getArgument([argumentsList objectAtIndex:7]), getArgument([argumentsList objectAtIndex:8]), getArgument([argumentsList objectAtIndex:9]));
        } else if(numberOfArguments == 5){
            results = new_msgSend5(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]), getArgument([argumentsList objectAtIndex:7]), getArgument([argumentsList objectAtIndex:8]), getArgument([argumentsList objectAtIndex:9]));
        } else if(numberOfArguments == 6){
            results = new_msgSend6(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]), getArgument([argumentsList objectAtIndex:7]), getArgument([argumentsList objectAtIndex:8]), getArgument([argumentsList objectAtIndex:9]));
        } else if(numberOfArguments == 7){
            results = new_msgSend7(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]), getArgument([argumentsList objectAtIndex:7]), getArgument([argumentsList objectAtIndex:8]), getArgument([argumentsList objectAtIndex:9]));
        } else if(numberOfArguments == 8){
            results = new_msgSend8(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]), getArgument([argumentsList objectAtIndex:7]), getArgument([argumentsList objectAtIndex:8]), getArgument([argumentsList objectAtIndex:9]));
        } else if(numberOfArguments == 9){
            results = new_msgSend9(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]), getArgument([argumentsList objectAtIndex:7]), getArgument([argumentsList objectAtIndex:8]), getArgument([argumentsList objectAtIndex:9]));
        } else if(numberOfArguments == 10){
            results = new_msgSend10(sender, selector, getArgument([argumentsList objectAtIndex:0]), getArgument([argumentsList objectAtIndex:1]), getArgument([argumentsList objectAtIndex:2]), getArgument([argumentsList objectAtIndex:3]), getArgument([argumentsList objectAtIndex:4]), getArgument([argumentsList objectAtIndex:5]), getArgument([argumentsList objectAtIndex:6]), getArgument([argumentsList objectAtIndex:7]), getArgument([argumentsList objectAtIndex:8]), getArgument([argumentsList objectAtIndex:9]));
        }
    }
    
    return results;
}


@end
