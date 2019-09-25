//
//  QBDFSYSCenter+QBDFStruct.h
//  TestQBDFScript
//
//  Created by fatboyli on 2017/8/4.
//  Copyright © 2017年 fatboyli. All rights reserved.
//

#import "QBDFSYSCenter.h"
#import "QBDFScriptMainDefine.h"


#define STRUCT_KEY_SIZE     @"size"
#define STRUCT_KEY_NAME     @"name"

#define STRUCT_KEY_ELEMENT_BASE_TYPE     @"elementBASEType"
#define STRUCT_KEY_ELEMENT_SUB_TYPE     @"elementSUBType"
#define STRUCT_KEY_ELEMENTOFFSET   @"elementOffset"
#define STRUCT_KEY_ELEMENTSIZE     @"elementSize"
#define STRUCT_KEY_ELEMENTNAME     @"elementName"



@interface QBDFStructDefine : NSObject
@property(nonatomic, strong)NSString           *structName;
@property(nonatomic, strong)NSArray<NSMutableDictionary *>            *elements;
@property(nonatomic, assign)int                totalSize;

//+ (int)sizeOfType:(NSString *)type;

@end

@interface QBDFSYSCenter (QBDFStruct)

- (void)registerStructByCmd:(NSDictionary *)cmd;

- (QBDFStructDefine *)readStructDefine:(NSString *)structName;
+ (NSString *)extractStructName:(NSString *)typeEncodeString;
+ (id) getStructArgumentWithType:(const char *)theTypeStr inv:(NSInvocation *)theInvoCation index:(NSInteger) index;
@end
