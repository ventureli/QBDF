//
//  QBDFSYSCenter.m
//  TestQBDFScript
//
//  Created by fatboyli on 2017/6/6.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "QBDFSYSCenter.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <UIKit/UIKit.h>
#import "QBDFScriptMainDefine.h"
#import "QBDFOCCALLCenter.h"
#import "QBDFVMContext.h"
#import "QBDFMthdSign.h"
#import "QBDFSYSCenter+SuperCall.h"
#import "QBDFVM.h"
#import "QBDFSYSCenter+QBDFStruct.h"
#import "QBDFStruct.h"
#import "QBDFVarTypeHelper.h"

static NSArray* _qbdfGetArgumentList(__unsafe_unretained id self , SEL cmd , NSInvocation *theInvoCation);

static NSMutableDictionary *_qbdfpropKeys;
static const void *qbdfPropKey(NSString *propName) {
    if (!_qbdfpropKeys) _qbdfpropKeys = [[NSMutableDictionary alloc] init];
    id key = _qbdfpropKeys[propName];
    if (!key) {
        key = [propName copy];
        [_qbdfpropKeys setObject:key forKey:propName];
    }
    return (__bridge const void *)(key);
}

static id getQBDFPropIMP(id slf, SEL selector, NSString *propName) {
    return objc_getAssociatedObject(slf, qbdfPropKey(propName));
}
static void setQBDFPropIMP(id slf, SEL selector, id val, NSString *propName) {
    objc_setAssociatedObject(slf, qbdfPropKey(propName), val, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


static void setQBDFPropIMPCopy(id slf, SEL selector, id val, NSString *propName) {
    objc_setAssociatedObject(slf, qbdfPropKey(propName), val, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

static void setQBDFPropIMPWeak(id slf, SEL selector, id val, NSString *propName) {
    objc_setAssociatedObject(slf, qbdfPropKey(propName), val, OBJC_ASSOCIATION_ASSIGN);
}

static char *methodTypesInProtocol(NSString *protocolName, NSString *selectorName, BOOL isInstanceMethod, BOOL isRequired)
{
    Protocol *protocol = objc_getProtocol([[protocolName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] cStringUsingEncoding:NSUTF8StringEncoding]);
    unsigned int selCount = 0;
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(protocol, isRequired, isInstanceMethod, &selCount);
    for (int i = 0; i < selCount; i ++) {
        if ([selectorName isEqualToString:NSStringFromSelector(methods[i].name)]) {
            char *types = malloc(strlen(methods[i].types) + 1);
            strcpy(types, methods[i].types);
            free(methods);
            return types;
        }
    }
    free(methods);
    return NULL;
}

NSString *getSuperCallKeyNameBySelName(NSString *selName)
{
    NSString *tmpKey = selName;
    if([tmpKey hasPrefix:@"__QBDFSUPER_"])
    {
        NSUInteger location =[tmpKey rangeOfString:@"_QBFBLDF_"].location;
       if( location != NSNotFound)
       {
           
           tmpKey  = [tmpKey stringByReplacingCharactersInRange:NSMakeRange(0, location +9) withString:@""];
           
       }
    }
    NSString *dec =  [[NSThread currentThread] description];
    NSString *decKey = [NSString stringWithFormat:@"%@__<>__%@",dec?:@"",tmpKey ?:@""];
    return decKey;
    
    
}

NSDictionary *QBDFGetNodeOfClassNameHierachy(NSString *clsName , NSString *tagselName)
{
    NSDictionary *node = nil;
    NSString *className = clsName;
    NSString *selName = tagselName;
    NSString *decKey = getSuperCallKeyNameBySelName(tagselName);
    BOOL issuper = NO;
    id theSuperValue = [[QBDFSYSCenter shareInstance] readCallSuperClassWithKey:decKey];
    if (theSuperValue) {
        issuper = YES;
        className = theSuperValue;
        NSUInteger location =[selName rangeOfString:@"_QBFBLDF_"].location;
        if( location != NSNotFound)
        {
            selName  = [selName stringByReplacingCharactersInRange:NSMakeRange(0, location +9) withString:@""];
            
        }
    }
    NSString *realClasName = className;
    while(!node)
    {
        node = [QBDFSYSCenter nodeOfClsName:className sel:selName];
        if(node)
        {
            NSString *key = [NSString stringWithFormat:@"%@_(%@)", realClasName ,selName];
            NSString *value = className?:@"NSObject";
            
            break;
        }
        Class superClass = class_getSuperclass(NSClassFromString(className));
        if(!superClass)
        {
            break;
        }
        className = NSStringFromClass(superClass);
    }
    
    return node;
}

static void QBDFExecuteORIGForwardInvocation(id slf, SEL selector, NSInvocation *invocation)
{
    SEL origForwardSelector = @selector(ORIGforwardInvocation:);
    
    if ([slf respondsToSelector:origForwardSelector]) {
        NSMethodSignature *methodSignature = [slf methodSignatureForSelector:origForwardSelector];
        if (!methodSignature) {
            __QBDF_ERROR__([NSString stringWithFormat:@"unrecognized selector -ORIGforwardInvocation: for instance %@", slf]);
            return;
        }
        NSInvocation *forwardInv= [NSInvocation invocationWithMethodSignature:methodSignature];
        [forwardInv setTarget:slf];
        [forwardInv setSelector:origForwardSelector];
        [forwardInv setArgument:&invocation atIndex:2];
        [forwardInv invoke];
    } else {
        Class superCls = [[slf class] superclass];
        Method superForwardMethod = class_getInstanceMethod(superCls, @selector(forwardInvocation:));
        void (*superForwardIMP)(id, SEL, NSInvocation *);
        superForwardIMP = (void (*)(id, SEL, NSInvocation *))method_getImplementation(superForwardMethod);
        superForwardIMP(slf, @selector(forwardInvocation:), invocation);
    }
}

static void QBDFforwardInvocation(__unsafe_unretained id self , SEL cmd , NSInvocation *theInvoCation)
{
    // NSLog(@"fatboyli forword self %@",NSStringFromSelector(cmd));
    //寻找参数
    NSArray *argsRes = _qbdfGetArgumentList(self, cmd, theInvoCation);
    //NSLog(@"%@",argsRes);
    BOOL deallocFlag = NO;
    id slf = self;
    
    NSString *clsName = NSStringFromClass([theInvoCation.target class]);
    NSString *selName = NSStringFromSelector(theInvoCation.selector);
    
    
  
    if([selName isEqualToString:@"dealloc"])
    {
        deallocFlag = YES;
        
    }
    NSDictionary *node = nil;
    NSString *tmpdecKey = getSuperCallKeyNameBySelName(selName);
    
    if(![QBDFSYSCenter haveOverrideMethod:clsName selname:selName] && ![[QBDFSYSCenter shareInstance] readCallSuperClassWithKey:tmpdecKey])
    //没有覆盖过这个方法，还进入了forward ，只能是调用super呢
     {
        NSString *superSelectorName = [NSString stringWithFormat:@"QBDFSUPER_%@", selName];
         [[QBDFSYSCenter shareInstance] updateCallSuperClassWithKey:tmpdecKey value:NSStringFromClass([self superclass])];
         node = QBDFGetNodeOfClassNameHierachy(clsName, superSelectorName);
    }else
    {
        //这里的逻辑太过复杂，要处理完整继承和非完整集链接的super关键字贯穿问题，小胖整整搞了一星期才搞定，轻易不要动，除非发现确定bug
        node = QBDFGetNodeOfClassNameHierachy(clsName, selName);
        NSString *nodeDecInWhichClassName = node[@"forclass"];
        if( nodeDecInWhichClassName && nodeDecInWhichClassName.length >0)
        {
            if(![nodeDecInWhichClassName isEqualToString:clsName])
            {
                [[QBDFSYSCenter shareInstance] updateCallSuperClassWithKey:tmpdecKey value:nodeDecInWhichClassName];
                
            }
        }else{
            NSLog(@"error");
        }
    }
    if(!node)
    {
        QBDFExecuteORIGForwardInvocation(slf, cmd, theInvoCation);
        return;
    }
    NSMethodSignature *methodSignature = [theInvoCation methodSignature];
    if(node)
    {
        id target = theInvoCation.target;
        SEL sel = theInvoCation.selector;
        __autoreleasing id res = [QBDFVMContext QBDF_RUNOCMTHDWithNode:node args:argsRes sel:sel target:target];
        if([res isKindOfClass:[QBDFNil class]])
        {
            res = nil;
        }
        char returnType[255];
        strcpy(returnType, [methodSignature methodReturnType]);
        
        switch (returnType[0] == 'r' ? returnType[1] : returnType[0])
        {
                
                #define QBDF_FWD_RET_CASE(_typeChar, _type, _typeSelector)   \
                case _typeChar : { \
                _type tmpRes =[res _typeSelector ] ; \
                [theInvoCation setReturnValue:&tmpRes];\
                break;  \
                }
                QBDF_FWD_RET_CASE('c', char, charValue)
                QBDF_FWD_RET_CASE('C', unsigned char, unsignedCharValue)
                QBDF_FWD_RET_CASE('s', short, shortValue)
                QBDF_FWD_RET_CASE('S', unsigned short, unsignedShortValue)
                QBDF_FWD_RET_CASE('i', int, intValue)
                QBDF_FWD_RET_CASE('I', unsigned int, unsignedIntValue)
                QBDF_FWD_RET_CASE('l', long, longValue)
                QBDF_FWD_RET_CASE('L', unsigned long, unsignedLongValue)
                QBDF_FWD_RET_CASE('q', long long, longLongValue)
                QBDF_FWD_RET_CASE('Q', unsigned long long, unsignedLongLongValue)
                QBDF_FWD_RET_CASE('f', float, floatValue)
                QBDF_FWD_RET_CASE('d', double, doubleValue)
                QBDF_FWD_RET_CASE('B', BOOL, boolValue)
            case '@':
            {
                if ([res isKindOfClass:[QBDFNil class]]) {
                    res = nil;
                }
                [theInvoCation setReturnValue:&res];\
                break;
            }
            case '^':
            case '*':
            {
                if([res isKindOfClass:[QBDFNil class]] || [res isKindOfClass:[NSNull class]])
                {
                    id valObj = nil;
                    [theInvoCation setReturnValue:&valObj];
                    
                }else
                {
                    void *tempResultSet = (__bridge void *)res;
                    [theInvoCation setReturnValue:&tempResultSet];
                    
                }
                break;
            }
                
            case 'v': {
                
                ;
                break;
            }
                
            case '{': {
                
                NSString *structName = [QBDFSYSCenter extractStructName:([NSString stringWithUTF8String:returnType])];
                #define QBDF_FWD_STRUCT(_type, _methodName) \
                else if ([structName rangeOfString:@#_type].location != NSNotFound) {    \
                    _type value;   \
                    if( [ res respondsToSelector:@selector(_methodName)])\
                    {\
                        value =[res _methodName];  \
                    }\
                    [theInvoCation setReturnValue:&value]; \
                    break; \
                }
                
                if(0){}
                QBDF_FWD_STRUCT(CGRect, CGRectValue)
                QBDF_FWD_STRUCT(CGPoint, CGPointValue)
                QBDF_FWD_STRUCT(CGSize, CGSizeValue)
                QBDF_FWD_STRUCT(NSRange, rangeValue)
                QBDF_FWD_STRUCT(UIEdgeInsets, UIEdgeInsetsValue)
                else
                {
                  
                    if([res isKindOfClass:[QBDFStruct class]])
                    {
                        QBDFStruct *qbst = (QBDFStruct *)res;
                        int size =  [qbst memSize];
                        void *ret = malloc(size);
                        [qbst getMemStructData:ret];
                        [theInvoCation setReturnValue:ret];
                        free(ret);
                    }
                    
                }
                
                break;
            }
            default: {
                break;
            }
        }
        
        
    }else{
        
    }
    
    
    if (deallocFlag)
    {
        slf = nil;
        Class instClass = object_getClass(self);
        Method deallocMethod = class_getInstanceMethod(instClass, NSSelectorFromString(@"ORIGdealloc"));
        void (*originalDealloc)(__unsafe_unretained id, SEL) = (__typeof__(originalDealloc))method_getImplementation(deallocMethod);
        originalDealloc(self, NSSelectorFromString(@"dealloc"));
        
    }
    
    
    
}

static void overrideMethod(Class cls, NSString *selectorName, const char *typeDescription)
{
    SEL selector = NSSelectorFromString(selectorName);
    
    if (!typeDescription) {
        Method method = class_getInstanceMethod(cls, selector);
        typeDescription = (char *)method_getTypeEncoding(method);
    }
    
    IMP originalImp = class_respondsToSelector(cls, selector) ? class_getMethodImplementation(cls, selector) : NULL;
    
    IMP msgForwardIMP = _objc_msgForward;
#if !defined(__arm64__)
    if (typeDescription[0] == '{') {
        NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:typeDescription];
        if ([methodSignature.debugDescription rangeOfString:@"is special struct return? YES"].location != NSNotFound) {
            msgForwardIMP = (IMP)_objc_msgForward_stret;
        }
    }
#endif
    
    if (class_getMethodImplementation(cls, @selector(forwardInvocation:)) != (IMP)QBDFforwardInvocation)
    {
        IMP originalForwardImp = class_replaceMethod(cls, @selector(forwardInvocation:), (IMP)QBDFforwardInvocation, "v@:@");
        if (originalForwardImp) {
            class_addMethod(cls, @selector(ORIGforwardInvocation:), originalForwardImp, "v@:@");
        }
    }
    
    if (class_respondsToSelector(cls, selector)) {
        NSString *originalSelectorName = [NSString stringWithFormat:@"ORIG%@", selectorName];
        SEL originalSelector = NSSelectorFromString(originalSelectorName);
        if(!class_respondsToSelector(cls, originalSelector)) {
            class_addMethod(cls, originalSelector, originalImp, typeDescription);
        }
    }
    // Replace the original selector at last, preventing threading issus when
    // the selector get called during the execution of `overrideMethod`
    class_replaceMethod(cls, selector, msgForwardIMP, typeDescription);
}





static NSArray* _qbdfGetArgumentList(__unsafe_unretained id self , SEL cmd , NSInvocation *theInvoCation)
{
    NSMethodSignature * signure = [theInvoCation methodSignature];
    NSInteger argCount = [signure numberOfArguments];
    
    NSMutableArray *resArray = [NSMutableArray new];
    for (NSInteger i = 2 ; i < argCount; i ++) {
        
        const char * type = [signure getArgumentTypeAtIndex:i];
        char currentChar = '\0';
        if(strlen(type) > 0)
        {
            currentChar = type[0];
        }else{
            
        }
        //NSLog(@"type is is:%s",type);
        
        
        #define GET_ARGUMNET_SWITCH_NSVALU_CASE(thechar , thetype)  \
        case thechar: \
        { \
        thetype value; \
        [theInvoCation getArgument:&value atIndex:i]; \
        [resArray addObject:@(value)]; \
        break; \
        }
                
        
        switch (currentChar) {
                GET_ARGUMNET_SWITCH_NSVALU_CASE('c' , char)
                GET_ARGUMNET_SWITCH_NSVALU_CASE('i' , int)
                GET_ARGUMNET_SWITCH_NSVALU_CASE('C', unsigned char)
                GET_ARGUMNET_SWITCH_NSVALU_CASE('s', short)
                GET_ARGUMNET_SWITCH_NSVALU_CASE('S', unsigned short)
                GET_ARGUMNET_SWITCH_NSVALU_CASE('I', unsigned int)
                GET_ARGUMNET_SWITCH_NSVALU_CASE('l', long)
                GET_ARGUMNET_SWITCH_NSVALU_CASE('L', unsigned long)
                GET_ARGUMNET_SWITCH_NSVALU_CASE('q', long long)
                GET_ARGUMNET_SWITCH_NSVALU_CASE('Q', unsigned long long)
                GET_ARGUMNET_SWITCH_NSVALU_CASE('f', float)
                GET_ARGUMNET_SWITCH_NSVALU_CASE('d', double)
                GET_ARGUMNET_SWITCH_NSVALU_CASE('B', BOOL)
            case '@':
            {
                __autoreleasing id value;
                [theInvoCation getArgument:&value atIndex:i];
                if(!value)
                {
                    value = [QBDFNil new];
                }
                if(strlen(type) > 1)
                {
                    if(strcmp("@?", type)) // is a Block @encode(typeof(^{}));
                    {
                        [resArray addObject:[value copy]];
                    }else
                    {
                        [resArray addObject:value];
                    }
                }else
                {
                    [resArray addObject:value?:[QBDFNil new]];
                }
                break;
            }
            case '[': //array
            {
                id array;
                [theInvoCation getArgument:&array atIndex:i];
                [resArray addObject:array];
                break;
                
            }
                
            case '{':  //struct
            {
                id value = [QBDFSYSCenter getStructArgumentWithType:type inv:theInvoCation index:i];
                if(value)
                {
                    [resArray addObject:value];
                }
                break;
            }
                
            case ':': {
                SEL selector;
                [theInvoCation getArgument:&selector atIndex:i];
                NSString *selectorName = NSStringFromSelector(selector);
                [resArray addObject:(selectorName ? selectorName:@"")];
                break;
            }
            case '^':
            case '*': {
                void *arg;  //A character string (char *)
                [theInvoCation getArgument:&arg atIndex:i];
                if(arg)
                {
                    id value = [NSValue valueWithPointer:arg];
                    if(value)
                    {
                        [resArray addObject: value]; //转成ID
                    }else{
                        [resArray addObject: [QBDFNil new]]; //转成ID
                        
                    }
                }else
                {
                }
                break;
            }
            case '#': {
                Class arg;  //A character string (char *)
                [theInvoCation getArgument:&arg atIndex:i];
                if(arg)
                {

                    [resArray addObject: arg]; //转成ID
                }else
                {
                    [resArray addObject: [QBDFNil new]]; //转成ID
                
                }
                break;
            }

                
                
                
            default:
                break;
        }
        
    }
    return resArray;
}


IMP QBDFGetEmptyForwardIMP(char *typeDescription, NSMethodSignature *methodSignature)
{
    IMP msgForwardIMP = _objc_msgForward;
    #if !defined(__arm64__)
    if (typeDescription[0] == '{') {
        NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:typeDescription];
        if ([methodSignature.debugDescription rangeOfString:@"is special struct return? YES"].location != NSNotFound) {
            msgForwardIMP = (IMP)_objc_msgForward_stret;
        }
    }
    #endif
    
    return msgForwardIMP;
}

//class_addMethod(cls, @selector(setQBDFProp:forKey:), (IMP)setQBDFPropIMP, "v@:@@");
//class_addMethod(cls, @selector(setQBDFCopyProp:forKey:), (IMP)setQBDFPropIMPCopy, "v@:@@");
//class_addMethod(cls, @selector(setQBDFWeakProp:forKey:), (IMP)setQBDFPropIMPWeak, "v@:@@");


void strongSetter(id self,SEL _CMD , id value)
{
    NSString *selName =  NSStringFromSelector(_CMD);
    if ([selName hasPrefix:@"ORIG"]) {
        selName = [selName substringFromIndex:4];
    }
    if ([selName hasPrefix:@"set"]) {
        selName = [selName substringFromIndex:3];
    }

    NSString *proName = [selName lowercaseString];
   
    proName = [[proName stringByReplacingOccurrencesOfString:@":" withString:@""] lowercaseString];
    proName =[NSString stringWithFormat:@"_%@",[proName lowercaseString]];
    if([self respondsToSelector:@selector(setQBDFProp:forKey:)])
    {
        [self performSelector:@selector(setQBDFProp:forKey:) withObject:value withObject:proName];
    }
}

void copySetter(id self,SEL _CMD , id value)
{
    NSString *selName =  [NSStringFromSelector(_CMD) lowercaseString];
    NSString *proName = [[selName stringByReplacingOccurrencesOfString:@"set" withString:@""] lowercaseString];
    proName = [[proName stringByReplacingOccurrencesOfString:@":" withString:@""] lowercaseString];
    proName =[NSString stringWithFormat:@"_%@",[proName lowercaseString]];
    if([self respondsToSelector:@selector(setQBDFCopyProp:forKey:)])
    {
        [self performSelector:@selector(setQBDFCopyProp:forKey:) withObject:value withObject:proName];
        //        [self setQBDFProp:value forKey:proName];
    }
}


void weakSetter(id self,SEL _CMD , id value)
{
    NSString *selName =  [NSStringFromSelector(_CMD) lowercaseString];
    NSString *proName = [[selName stringByReplacingOccurrencesOfString:@"set" withString:@""] lowercaseString];
    proName = [[proName stringByReplacingOccurrencesOfString:@":" withString:@""] lowercaseString];
    proName =[NSString stringWithFormat:@"_%@",[proName lowercaseString]];
    if([self respondsToSelector:@selector(setQBDFWeakProp:forKey:)])
    {
        [self performSelector:@selector(setQBDFWeakProp:forKey:) withObject:value withObject:proName];
        //        [self setQBDFProp:value forKey:proName];
    }
}

void atostrongSetter(id self,SEL _CMD , id value)
{
    NSString *selName =  [NSStringFromSelector(_CMD) lowercaseString];
    NSString *proName = [[selName stringByReplacingOccurrencesOfString:@"set" withString:@""] lowercaseString];
    proName = [[proName stringByReplacingOccurrencesOfString:@":" withString:@""] lowercaseString];
    proName =[NSString stringWithFormat:@"_%@",[proName lowercaseString]];
    if([self respondsToSelector:@selector(setQBDFProp:forKey:)])
    {
        @synchronized (self) {
            
        [self performSelector:@selector(setQBDFProp:forKey:) withObject:value withObject:proName];
    
        }
    }
}

void atocopySetter(id self,SEL _CMD , id value)
{
    NSString *selName =  [NSStringFromSelector(_CMD) lowercaseString];
    NSString *proName = [[selName stringByReplacingOccurrencesOfString:@"set" withString:@""] lowercaseString];
    proName = [[proName stringByReplacingOccurrencesOfString:@":" withString:@""] lowercaseString];
    proName =[NSString stringWithFormat:@"_%@",[proName lowercaseString]];
    if([self respondsToSelector:@selector(setQBDFCopyProp:forKey:)])
    {
        @synchronized (self) {
            
        [self performSelector:@selector(setQBDFCopyProp:forKey:) withObject:value withObject:proName];
        //        [self setQBDFProp:value forKey:proName];
        }
    }
}


void atoweakSetter(id self,SEL _CMD , id value)
{
    NSString *selName =  [NSStringFromSelector(_CMD) lowercaseString];
    NSString *proName = [[selName stringByReplacingOccurrencesOfString:@"set" withString:@""] lowercaseString];
    proName = [[proName stringByReplacingOccurrencesOfString:@":" withString:@""] lowercaseString];
    proName =[NSString stringWithFormat:@"_%@",[proName lowercaseString]];
    if([self respondsToSelector:@selector(setQBDFWeakProp:forKey:)])
    {
        @synchronized (self) {
            
            [self performSelector:@selector(setQBDFWeakProp:forKey:) withObject:value withObject:proName];
            //        [self setQBDFProp:value forKey:proName];
            
        }
    }
}




id getter(id self ,SEL _CMD)
{
     NSString *selName =  NSStringFromSelector(_CMD);
     selName =  [NSString stringWithFormat:@"_%@",[selName lowercaseString]];
    if([self respondsToSelector:@selector(getQBDFProp:)])
    {
        return [self performSelector:@selector(getQBDFProp:) withObject:selName];
    }
    return nil;
}





static NSMutableDictionary * QBDFSysReplaceDict = nil;
static NSMutableDictionary * QBDFSysClsProperyDict = nil;

@interface QBDFSYSCenter()
@end
@implementation QBDFSYSCenter
+(instancetype)shareInstance
{
    static QBDFSYSCenter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        QBDFSysReplaceDict = [NSMutableDictionary new];
        QBDFSysClsProperyDict = [NSMutableDictionary new];
        instance = [[QBDFSYSCenter alloc] init];
        instance.registerStructDict = [NSMutableDictionary new];
        instance.callSuperClassMethod = [NSMutableDictionary new];
     
    });
    return instance;
}




- (int)decCLSWithName:(NSString *)name
              supName:(NSString *)supName
              procals:(NSArray *)potocs
              proptys:(NSArray *)proptys
{
    Class supecls = NSClassFromString(supName);
    if(!supecls)
    {
        __QBDF_ERROR__([NSString stringWithFormat:@"father class 不存在"]);
    }
    Class cls = NSClassFromString(name);
    NSString *key = [NSString stringWithFormat:@"DECLS_%@",name];
    if(!cls)
    {
        cls = objc_allocateClassPair(supecls, name.UTF8String, 0);
        [self addPropForCls:cls props:proptys];
        
        objc_registerClassPair(cls);
        
    }else
    {
        NSString *keyvalue =[[QBDFVM shareInstance] getQBDFValue:key];
        int onlyonce = [[[QBDFVM shareInstance] getQBDFENV:__QBDF_IMPCLS_ONCE__] intValue];
        if([keyvalue isKindOfClass:[NSString class]] && [keyvalue isEqualToString:@"1"] && onlyonce == 1) //只定义一次
        {
            return 0;
        }
    }
    if (potocs.count > 0) {
        for (NSString* protocolName in potocs) {
            Protocol *protocol = objc_getProtocol([[protocolName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] cStringUsingEncoding:NSUTF8StringEncoding]);
            class_addProtocol (cls, protocol);
        }
    }
    //这里注册属性，暂时先不写
    //添加两个属性方法
    class_addMethod(cls, @selector(getQBDFProp:), (IMP)getQBDFPropIMP, "@@:@");
    class_addMethod(cls, @selector(setQBDFProp:forKey:), (IMP)setQBDFPropIMP, "v@:@@");
    class_addMethod(cls, @selector(setQBDFCopyProp:forKey:), (IMP)setQBDFPropIMPCopy, "v@:@@");
    class_addMethod(cls, @selector(setQBDFWeakProp:forKey:), (IMP)setQBDFPropIMPWeak, "v@:@@");
    [[QBDFVM shareInstance] setQBDFValue:@"1" forKey:key];
    return 0;
}

- (void)addPropForCls:(Class)cls props:(NSArray *)proptys
{
    for(int i = 0; i < [proptys count] ; i ++)
    {
        NSDictionary *prop = proptys[i];
        NSString *name = READNODEVALUE(prop, CMD_CLSD_PROPTY_NAME);
        id type = READNODEVALUE(prop, CMD_CLSD_PROPTY_BASETYPE);
        NSMutableArray *decs = [READNODEVALUE(prop, CMD_CLSD_PROPTY_OWNERDEC) mutableCopy];
        
        
        objc_property_attribute_t ownershipc = { "C", "" };          //COPY
        objc_property_attribute_t ownershipn = { "N", "" };          //nonatic
        objc_property_attribute_t ownerships = { "&", "" };          //nonatic
        objc_property_attribute_t ownershipw = { "W", "" };          //nonatic
        
        //直接运行这个方法
        NSString *first=[[name substringToIndex:1] uppercaseString];
        NSString *next =[name substringFromIndex:1];
        NSString *setsel = nil;
        setsel = [NSString stringWithFormat:@"set%@%@:",first ,next?:@""];
        
        BOOL good;
        if([type isEqualToString:QBDF_VAR_DECTYPE_ID])//全部转成ID进行存储po
        {
        }else
        {
            [decs removeObject:@"weak"];
            [decs removeObject:@"copy"];
            [decs removeObject:@"assign"];
            [decs removeObject:@"strong"];
            [decs addObject:@"strong"];
            
        }
        NSString *varname = [NSString stringWithFormat:@"_%@",[name lowercaseString]];
        BOOL addgood = class_addIvar(cls, [varname UTF8String] , sizeof(id), log(sizeof(id)), @encode(id));
        if(addgood)
        {
            objc_property_attribute_t type = {"T", "@\"id\""};     //type
            objc_property_attribute_t backingivar = { "V", [varname UTF8String]};
        
        if([decs containsObject:@"atomic"])
        {
            if([decs containsObject:@"strong"])
            {
                
                objc_property_attribute_t attrs[] = {type,ownerships, backingivar};
                good =  class_addProperty(cls, [varname UTF8String], attrs,3);
                class_addMethod(cls, NSSelectorFromString(setsel), (IMP)atostrongSetter, "v@:@");
                
              }else if([decs containsObject:@"weak"])
            {
                objc_property_attribute_t attrs[] = {type, ownershipw, backingivar};
                good =  class_addProperty(cls, [varname UTF8String], attrs,3);
                class_addMethod(cls, NSSelectorFromString(setsel), (IMP)atoweakSetter, "v@:@");
                
            }else if([decs containsObject:@"copy"]){
                objc_property_attribute_t attrs[] = {type, ownershipc, backingivar};
                good =  class_addProperty(cls, [varname UTF8String], attrs,3);
                
                class_addMethod(cls, NSSelectorFromString(setsel), (IMP)atocopySetter, "v@:@");
                
            }else{
                objc_property_attribute_t attrs[] = {type,ownerships, backingivar};
                good =  class_addProperty(cls, [varname UTF8String], attrs,3);
                class_addMethod(cls, NSSelectorFromString(setsel), (IMP)strongSetter, "v@:@");
                
            }
            
            class_addMethod(cls, NSSelectorFromString(name), (IMP)getter, "@@:");
            

        }else{
            
            if([decs containsObject:@"strong"])
            {
                
                objc_property_attribute_t attrs[] = {type, ownershipn,ownerships, backingivar};
                good =  class_addProperty(cls, [varname UTF8String], attrs,4);
                
                class_addMethod(cls, NSSelectorFromString(setsel), (IMP)strongSetter, "v@:@");
                
            }else if([decs containsObject:@"weak"])
            {
                
                objc_property_attribute_t attrs[] = {type, ownershipn,ownershipw, backingivar};
                good =  class_addProperty(cls, [varname UTF8String], attrs,4);
                
                class_addMethod(cls, NSSelectorFromString(setsel), (IMP)weakSetter, "v@:@");
                
            }else if([decs containsObject:@"copy"]){
                objc_property_attribute_t attrs[] = {type, ownershipn,ownershipc, backingivar};
                good =  class_addProperty(cls, [varname UTF8String], attrs,4);
                
                class_addMethod(cls, NSSelectorFromString(setsel), (IMP)copySetter, "v@:@");
                
            }else{
                objc_property_attribute_t attrs[] = {type, ownershipn,ownerships, backingivar};
                good =  class_addProperty(cls, [varname UTF8String], attrs,4);
                class_addMethod(cls, NSSelectorFromString(setsel), (IMP)strongSetter, "v@:@");
            }
        }
        class_addMethod(cls, NSSelectorFromString(name), (IMP)getter, "@@:");
        }
        
        
    }
}



+ (NSString *)typeNameOfType:(id)type
{
    return [QBDFVarTypeHelper typeElemenNameOfType:type];
}

- (NSString *)_getMethodSignTypesWithMTHDNode:(NSDictionary *)node
{
    NSMutableString *str = [NSMutableString stringWithString:@""];
    NSArray *xingCan = READNODEVALUE(node, CMD_CLSIMP_MTHODXINGCAN);
    NSDictionary *dictRet = READNODEVALUE(node, CMD_CLSIMP_MTHODRET);
    id retType = READNODEVALUE(dictRet, CMD_FUN_RET_BASETYPE);
    [str appendString:[[self class] typeNameOfType:retType]];
    [str appendString:[NSString stringWithFormat:@"%@%ld",[NSString stringWithUTF8String:@encode(id)],sizeof(id)]];
    
    [str appendString:[NSString stringWithFormat:@"%@%ld",[NSString stringWithUTF8String:@encode(SEL)],sizeof(SEL)]];
    
    for(NSInteger i = 0;i < [xingCan count];i++)
    {
        NSDictionary *argDecNode = xingCan[i];
        id baseType = READNODEVALUE(argDecNode, CMD_FUN_ARG_BASETYPE);
        [str appendString:[[self class] typeNameOfType:baseType]];
    }
   
    return str;

}

- (int)impCLSWithName:(NSString *)name
              methods:(NSArray *)mthds
{
    Class cls = NSClassFromString(name);
    
   // [[self class] showClassMethodListWithClass:cls];
  
    
    NSString *key = [NSString stringWithFormat:@"IMPCLS_%@",name];
    if (!cls)
    {
        __QBDF_ERROR__([NSString stringWithFormat:@"类%@不存在",name]);
        return 0;
    }else{
        NSString *keyvalue =[[QBDFVM shareInstance] getQBDFValue:key];
        int onlyonce = [[[QBDFVM shareInstance] getQBDFENV:__QBDF_IMPCLS_ONCE__] intValue];
        if([keyvalue isKindOfClass:[NSString class]] && [keyvalue isEqualToString:@"1"] && onlyonce == 1) //只定义一次
        {
            return 0;
        }
    }
    
    
    unsigned int count;
    __unsafe_unretained Protocol **protocolList = class_copyProtocolList(cls, &count);
//    for (unsigned int i = 0; i<count; i++) {
//        Protocol *myprotocal = protocolList[i];
//        const char *protocolname = protocol_getName(myprotocal);
//    }
    
    
    for(int i = 0 ;i < [mthds count];i++)
    {
        NSDictionary *mthd = mthds[i];
        NSString *sel = READNODEVALUE(mthd, CMD_CLSIMP_MTHODSEL);
        [[self class] setNodeOfClassName:name sel:sel node:mthd];
        BOOL isclass = [READNODEVALUE(mthd, CMD_CLSIMP_MTHODISCLS) boolValue];
        Class currCls = isclass ? objc_getMetaClass(name.UTF8String):cls;
        
        SEL select = NSSelectorFromString(sel);
        
            if (class_respondsToSelector(currCls, select))
            {
                overrideMethod(currCls, sel ,NULL);
            
            } else
            {
            
                BOOL overrided = NO;
                
                for (unsigned int i = 0; i<count; i++)
                {
                    
                    Protocol *myprotocal = protocolList[i];
                    const char *protocolname = protocol_getName(myprotocal);
                    char *types = methodTypesInProtocol([NSString stringWithUTF8String:protocolname], sel, !isclass, YES);
                    if (!types) types = methodTypesInProtocol([NSString stringWithUTF8String:protocolname], sel, !isclass, NO);
                    if (types) {
                        overrideMethod(currCls, sel,types);
                        free(types);
                        overrided = YES;
                        break;
                    }
                }
                if(!overrided)
                {
                    NSString *typestr = [self _getMethodSignTypesWithMTHDNode:mthd]; //这个type 首先应该从protocol中取，然后才是从自己生成
                    overrideMethod(currCls  , sel, [typestr cStringUsingEncoding:NSUTF8StringEncoding]);
                }
            }

    }
    [[QBDFVM shareInstance] setQBDFValue:@"1" forKey:key];
    
    free(protocolList);
   // [[self class] showClassMethodListWithClass:cls];
    
    
    return 0;
}



+ (void)reSaveORIGMethod:(SEL )select class:(Class)cls
{
    Method method =  class_getInstanceMethod(cls, select);
    NSMethodSignature *methodSignature = [cls instanceMethodSignatureForSelector:select];
    if(!method)
    {
        return;
    }
    if(methodSignature)
    {
        
        IMP ROIGIMp = method_getImplementation(method);
        
        
        NSString *originalSelectorName = [NSString stringWithFormat:@"ORIG%@", NSStringFromSelector(select)];
        
        SEL originalSelector = NSSelectorFromString(originalSelectorName);
        if(!class_respondsToSelector(cls, originalSelector))
        {
            class_addMethod(cls, originalSelector, ROIGIMp, method_getDescription(method)->types);
        }
    }
}

+ (void)setMethodToNull:(SEL )select class:(Class)cls types:(NSString *)typestr
{
    Method method =  class_getInstanceMethod(cls, select);
    NSMethodSignature *methodSignature = [cls instanceMethodSignatureForSelector:select];
    
    if(methodSignature && method)
    {
        
        IMP nullIMP = QBDFGetEmptyForwardIMP(method_getDescription(method)->types,methodSignature);
        class_replaceMethod(cls, select,nullIMP  , method_getDescription(method)->types);
        
    }else{
        
     
    }
}

+ (void)replaceForwardInvocation:(Class)cls
{
    SEL forwardSel = NSSelectorFromString(@"forwardInvocation:");
    Method method =  class_getInstanceMethod(cls, forwardSel);
    IMP newIMP = (IMP)QBDFforwardInvocation;
    class_replaceMethod(cls, forwardSel, newIMP, method_getDescription(method)->types);
    
}

+ (void)showClassMethodListWithClass:(Class)cls
{
    unsigned int count;
    Method *list= class_copyMethodList(cls, &count);
    NSLog(@"----------------- class %@ %@",NSStringFromClass(cls),@" method list---------------");
    for(int i = 0 ; i < count;i++)
    {
        Method themethod = list[i];
        NSLog(@"- %@",NSStringFromSelector(method_getName(themethod)));
    }
    
    list= class_copyMethodList(objc_getMetaClass(NSStringFromClass(cls).UTF8String), &count);
    for(int i = 0 ; i < count;i++)
    {
        Method themethod = list[i];
        NSLog(@"+ %@",NSStringFromSelector(method_getName(themethod)));
    }
    NSLog(@"-------------------------------------------------");
}

+ (NSDictionary *)nodeOfClsName:(NSString *)name sel:(NSString *)sel
{
    if(
       !([name isKindOfClass:[NSString class]] && [sel isKindOfClass:[NSString class]] && name.length >0 && sel.length >0)
       )
    {
        return nil;
    }
    NSString *key = [NSString stringWithFormat:@"%@<QBDF_QQHD>%@",name,sel];
    return QBDFSysReplaceDict[key];
}

+ (BOOL)haveOverrideMethod:(NSString *)className selname:(NSString *)selcName
{
  if(  [[self class] nodeOfClsName:className sel:selcName] == nil)
  {
      return NO;
  }else{
      return YES;
  }
}

+ (void)setNodeOfClassName:(NSString *)name sel:(NSString *)sel node:(NSDictionary *)node
{
    if(
       !([name isKindOfClass:[NSString class]] && [sel isKindOfClass:[NSString class]] && name.length >0 && sel.length >0)
       )
    {
        return ;
    }
    if(!node)
    {
        return;
    }
    NSString *key = [NSString stringWithFormat:@"%@<QBDF_QQHD>%@",name,sel];
    node = [node mutableCopy];
    ((NSMutableDictionary *)node)[@"forclass"] =  name?:@"";
    QBDFSysReplaceDict[key] = node;
    
}

 

@end
