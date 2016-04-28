//
//  RunTime.m
//  XLFBaseModelKit
//
//  Created by Marike Jave on 14-4-3.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//

#import <objc/runtime.h>

#import "XLFRunTime.h"
#import "XLFBaseModel.h"

@implementation XLFRunTime

+ (NSArray<NSDictionary<NSString *, NSString *> *> *)ivarList:(Class)cls{
    
    NSMutableArray *reVal = [[NSMutableArray alloc] init];
    unsigned int numIvars = 0;
    Ivar * ivars = class_copyIvarList(cls, &numIvars);
    if (numIvars>0) {
        
        for(int i = 0; i < numIvars; i++) {
            
            Ivar thisIvar = ivars[i];
            const char *ivarName=ivar_getName(thisIvar);
            const char *ivarType=ivar_getTypeEncoding(thisIvar);
            [reVal addObject: @{@"name":[NSString stringWithUTF8String:ivarName],@"attribute":[NSString stringWithUTF8String:ivarType]}];
        }
        free(ivars);
    }
    return reVal;
}

+ (NSArray<NSString *> *)ivarNameList:(Class)cls{
    
    NSMutableArray<NSString *> *reVal = [[NSMutableArray<NSString *> alloc] init];
    
    unsigned int numIvars = 0;
    Ivar *ivars = class_copyIvarList(cls,&numIvars);
    if (numIvars>0) {
        
        for(int i = 0; i < numIvars; i++) {
            
            Ivar thisIvar = ivars[i];
            const char *ivarName=ivar_getName(thisIvar);
            [reVal addObject:[[NSString stringWithUTF8String:ivarName] stringByReplacingOccurrencesOfString:@"_" withString:@""]];
        }
        free(ivars);
    }
    
    return reVal;
}

+ (NSArray<NSString *> *)allIvarNameList:(Class<XLFBaseModelInterface>)cls{
    
    NSMutableArray *reVal=[[NSMutableArray alloc] init];
    Class etClass = cls;
    Class etEndCls = cls;
    
    if ([etClass respondsToSelector:@selector(superEndClass)]) {
        etEndCls = [cls superEndClass];
    }
    
    while (YES) {
        
        unsigned int numIvars = 0;
        Ivar *ivars = class_copyIvarList(etClass, &numIvars);
        if (numIvars > 0) {
            
            for(int i = 0; i < numIvars; i++) {
                
                Ivar thisIvar = ivars[i];
                const char *ivarName=ivar_getName(thisIvar);
                [reVal addObject:[[NSString stringWithUTF8String:ivarName] stringByReplacingOccurrencesOfString:@"_" withString:@""]];
            }
            free(ivars);
        }
        if (etClass == etEndCls) {
            break;
        }
        etClass = class_getSuperclass(etClass);
    }
    return reVal;
}

+ (NSArray<NSDictionary<NSString *, NSString *> *> *)allIvarList:(Class<XLFBaseModelInterface>)cls{
    
    NSMutableArray<NSDictionary<NSString *, NSString *> *> *reVal = [[NSMutableArray<NSDictionary<NSString *, NSString *> *> alloc] init];
    Class etClass = cls;
    Class etEndCls  = cls;
    
    if ([etClass respondsToSelector:@selector(superEndClass)]) {
        etEndCls = [cls superEndClass];
    }
    
    while (YES) {
        
        NSArray<NSDictionary<NSString *, NSString *> *> *value=[self ivarList:etClass];
        if (value) {
            
            [reVal addObjectsFromArray:value];
        }
        if (etClass==etEndCls) {
            break;
        }
        etClass=class_getSuperclass(etClass);
    }
    return reVal;
}

+ (id)ivarValue:(NSObject<XLFBaseModelInterface> *)instance ivarName:(NSString *)ivarName{
    
    id reVal = nil;
    // 获取Ivar
    Ivar ivar = class_getInstanceVariable([instance class], [ivarName cStringUsingEncoding:NSUTF8StringEncoding]);
    // 取得变量的类型
    const char *type = ivar_getTypeEncoding(ivar);
    
    if (type != NULL && type[0]=='@') {
        
        reVal = object_getIvar(instance, ivar);
    }
    else{
        
        // 基本数据类型或者结构体
        // 取得变量的偏移量
        ptrdiff_t offset=ivar_getOffset(ivar);
        NSUInteger ivarSize = 0;
        NSUInteger ivarAlignment = 0;
        // 取得变量的Type
        NSGetSizeAndAlignment(type, &ivarSize, &ivarAlignment);
        // 变量指针
        Byte *ivarPointer=(Byte *)(__bridge const void *)instance+offset;
        reVal=[NSData dataWithBytes:ivarPointer length:ivarSize];
    }
    
    return reVal;
}

+ (id)ivarValueWithObject:(NSObject<XLFBaseModelInterface> *)instance ivarName:(NSString *)ivarName{
    
    id reVal = [self ivarValue:instance ivarName:ivarName];
    // 获取Ivar
    Ivar ivar = class_getInstanceVariable([instance class], [ivarName cStringUsingEncoding:NSUTF8StringEncoding]);
    // 取得变量的类型
    const char *type = ivar_getTypeEncoding(ivar);
    switch (type[0]) {
            
        case '@':
        {
            // 对象
            NSString *type = [self ivarType:instance ivarName:ivarName];
            
            if (reVal) {
                
                if ([reVal isKindOfClass:[XLFBaseModel class]]) {
                    
                    reVal = [self attributeWithInstance:reVal];
                }
                else if ([reVal isKindOfClass:[NSArray class]] && [type rangeOfString:@"@\"NSArray" options:NSLiteralSearch].location==0) {
                    
                    // Model Array
                    NSMutableArray *arrayObject=[[NSMutableArray alloc] init];
                    
                    for (id reValItem in reVal) {
                        
                        id item = reValItem;
                        
                        if ([item isKindOfClass:[XLFBaseModel class]]) {
                            
                            item = [self attributeWithInstance:reValItem];
                        }
                        
                        [arrayObject addObject:item];
                    }
                    reVal=arrayObject;
                }
                else if ([reVal isKindOfClass:[NSNull class]] || [type rangeOfString:@"@\"NSNull" options:NSLiteralSearch].location==0){
                    
                    reVal = nil;
                }
            }
            break;
        }
        case 'B':
        case 'c':
        {
            // char && BOOL
            char number;
            [reVal getBytes:&number length:((NSData *)reVal).length];
            reVal=[NSNumber numberWithChar:number];
            break;
        }
        case 'b':
        case 'C':
        {
            
            // unsigned_char
            unsigned char number;
            [reVal getBytes:&number length:((NSData *)reVal).length];
            reVal=[NSNumber numberWithUnsignedChar:number];
            break;
        }
        case 's':
        {
            // short
            short number;
            [reVal getBytes:&number length:((NSData *)reVal).length];
            reVal=[NSNumber numberWithShort:number];
            break;
        }
        case 'S':
        {
            
            // unsigned_short
            unsigned short number;
            [reVal getBytes:&number length:((NSData *)reVal).length];
            reVal=[NSNumber numberWithUnsignedChar:number];
            break;
        }
        case 'i':
        {
            
            // int
            int number;
            [reVal getBytes:&number length:((NSData *)reVal).length];
            reVal=[NSNumber numberWithInt:number];
            break;
        }
        case 'I':
        {
            
            // unsigned_int
            unsigned int number;
            [reVal getBytes:&number length:((NSData *)reVal).length];
            reVal=[NSNumber numberWithUnsignedInt:number];
            break;
        }
        case 'l':
        {
            
            // long
            long number;
            [reVal getBytes:&number length:((NSData *)reVal).length];
            reVal=[NSNumber numberWithLong:number];
            break;
        }
        case 'L':
        {
            
            // unsigned_long
            unsigned long number;
            [reVal getBytes:&number length:((NSData *)reVal).length];
            reVal=[NSNumber numberWithUnsignedLong:number];
            break;
        }
        case 'q':
        {
            
            // long_long
            long long number;
            [reVal getBytes:&number length:((NSData *)reVal).length];
            reVal=[NSNumber numberWithLongLong:number];
            break;
        }
        case 'Q':
        {
            
            // unsigned_long_long
            unsigned long long number;
            [reVal getBytes:&number length:((NSData *)reVal).length];
            reVal=[NSNumber numberWithUnsignedLongLong:number];
            break;
        }
        case 'f':
        {
            
            // float
            float number;
            [reVal getBytes:&number length:((NSData *)reVal).length];
            reVal=[NSNumber numberWithFloat:number];
            break;
        }
        case 'd':
        {
            
            // double
            double number;
            [reVal getBytes:&number length:((NSData *)reVal).length];
            reVal=[NSNumber numberWithDouble:number];
            break;
        }
        case '{':
        {
            // struct
            break;
        }
        default:
            break;
    }
    return reVal;
}

+ (NSString *)ivarType:(NSObject<XLFBaseModelInterface> *)instance ivarName:(NSString *)ivarName{
    
    NSString *reVal;
    // 获取Ivar
    Ivar ivar=class_getInstanceVariable([instance class],[ivarName cStringUsingEncoding:NSUTF8StringEncoding]);
    // 取得变量的大小
    const char *type = ivar_getTypeEncoding(ivar);
    if (type!=NULL) {
        
        reVal=[NSString stringWithUTF8String:type];
    }else{
        
        // NIF_WARN(@"找不到变量%@",ivarName);
        reVal=@"";
    }
    return reVal;
}

+ (void)setIvarValue:(NSObject<XLFBaseModelInterface> *)instance ivarName:(NSString *)ivarName value:(id)value{
    
    // 获取Ivar
    Ivar ivar = class_getInstanceVariable([instance class],[ivarName cStringUsingEncoding:NSUTF8StringEncoding]);
    // 取得变量的Type
    NSString *type=[self ivarType:instance ivarName:ivarName];
    
    if ([type length]>0) {
        
        if ([@"@" isEqualToString:[type substringToIndex:1]]) {
            
            // NSObject
            if([value isKindOfClass:[NSNumber class]]){
                
                value = [NSString stringWithFormat:@"%@",value];
            }
            
            [instance willChangeValueForKey:[ivarName substringFromIndex:1]];
            object_setIvar(instance, ivar, value);
            [instance didChangeValueForKey:[ivarName substringFromIndex:1]];
            
            return;
            //            [self object_setInstanceVariable:instance name:[ivarName cStringUsingEncoding:NSUTF8StringEncoding] value:(void *)value];
        }
        else if([value isKindOfClass:[NSString class]] ){
            
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            
            id number = [formatter numberFromString:value];
            
            if(number){
                
                value = number;
            }
        }
        if (!value) {
            
            value = @0;
        }
        if ([value isKindOfClass:[NSNumber class]]) {
            
            const char *charAttributes=[type cStringUsingEncoding:NSUTF8StringEncoding];
            switch (charAttributes[0]) {
                    
                case 'B':
                case 'c':
                {
                    // char or BOOL
                    char number=[((NSNumber *)value) charValue];
                    value=[NSData dataWithBytes:&number length:sizeof(number)];
                    break;
                }
                case 'b':
                case 'C':
                {
                    // unsigned_char or Boolean
                    unsigned char number=[((NSNumber *)value) unsignedCharValue];
                    value=[NSData dataWithBytes:&number length:sizeof(number)];
                    break;
                }
                case 's':
                {
                    // short
                    short number=[((NSNumber *)value) shortValue];
                    value=[NSData dataWithBytes:&number length:sizeof(number)];
                    break;
                }
                case 'S':
                {
                    // unsigned_short
                    unsigned short number=[((NSNumber *)value) unsignedShortValue];
                    value=[NSData dataWithBytes:&number length:sizeof(number)];
                    break;
                }
                case 'i':
                {
                    // int
                    int number=[((NSNumber *)value) intValue];
                    value=[NSData dataWithBytes:&number length:sizeof(number)];
                    break;
                }
                case 'I':
                {
                    // unsigned_int
                    unsigned int number=[((NSNumber *)value) unsignedIntValue];
                    value=[NSData dataWithBytes:&number length:sizeof(number)];
                    break;
                }
                case 'l':
                {
                    // long
                    long number=[((NSNumber *)value) longValue];
                    value=[NSData dataWithBytes:&number length:sizeof(number)];
                    break;
                }
                case 'L':
                {
                    // unsigned_long
                    unsigned long number=[((NSNumber *)value) unsignedLongValue];
                    value=[NSData dataWithBytes:&number length:sizeof(number)];
                    break;
                }
                case 'q':
                {
                    // long_long
                    long long number=[((NSNumber *)value) longLongValue];
                    value=[NSData dataWithBytes:&number length:sizeof(number)];
                    break;
                }
                case 'Q':
                {
                    // unsigned_long_long
                    unsigned long long number=[((NSNumber *)value) unsignedLongLongValue];
                    value=[NSData dataWithBytes:&number length:sizeof(number)];
                    break;
                }
                case 'f':
                {
                    // float
                    float number=[((NSNumber *)value) floatValue];
                    value=[NSData dataWithBytes:&number length:sizeof(number)];
                    break;
                }
                case 'd':
                {
                    // double
                    double number=[((NSNumber *)value) doubleValue];
                    value=[NSData dataWithBytes:&number length:sizeof(number)];
                    break;
                }
                case '{':
                {
                    // struct
                    break;
                }
                default:
                    break;
            }
            // 基本数据类型或者结构体
            // 取得变量的偏移量
            ptrdiff_t offset=ivar_getOffset(ivar);
            NSUInteger ivarSize = 0;
            NSUInteger ivarAlignment = 0;
            // 取得变量的大小
            NSGetSizeAndAlignment([type cStringUsingEncoding:NSUTF8StringEncoding], &ivarSize, &ivarAlignment);
            // 变量指针
            Byte *ivarPointer=(Byte *)((__bridge const void *)instance + offset);
            
            [instance willChangeValueForKey:[ivarName substringFromIndex:1]];
            [value getBytes:ivarPointer length:((NSData *)value).length];
            [instance didChangeValueForKey:[ivarName substringFromIndex:1]];
        }
    }
}

+ (NSData *)archivedDataWithRootObject:(id)object{
    
    NSData *reVal=[NSKeyedArchiver archivedDataWithRootObject:object];
    return reVal;
}

+ (NSInteger)sizeOfObject:(id)object{
    
    NSInteger reVal=class_getInstanceSize([object class]);
    return reVal;
}


+ (id)initWithCoder:(NSCoder *)aDecoder withInstance:(NSObject<XLFBaseModelInterface> *)instance{
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
    NSArray *list=[XLFRunTime allIvarList:[instance class]];
    for (id item in list) {
        
        NSString *name=[item objectForKey:@"name"];
        id data = [aDecoder decodeObjectForKey:name];
        if (data) {
            
            if ([@"_" isEqualToString:[name substringToIndex:1]]) {
                
                name = [name substringFromIndex:1];
            }
            [dict setObject:data forKey:name];
        }
    }
    [self setAttributes:dict withInstance:instance];
    
    return instance;
}

+ (void)encodeWithCoder:(NSCoder *)aCoder withInstance:(NSObject<XLFBaseModelInterface> *)instance{
    
    NSArray *list=[XLFRunTime allIvarList:[instance class]];
    
    for (id item in list) {
        
        NSString *name = [item objectForKey:@"name"];
        
        id data = [XLFRunTime ivarValueWithObject:instance ivarName:name];
        
        [aCoder encodeObject:data forKey:name];
    }
}

+ (NSDictionary<NSString *, id> *)attributeWithInstance:(NSObject<XLFBaseModelInterface> *)instance{
    
    NSMutableDictionary<NSString *, id> *reVal=[[NSMutableDictionary alloc] init];
    NSArray<NSDictionary<NSString *, NSString *> *> *list=[XLFRunTime allIvarList:[instance class]];
    
    for (id item in list) {
        
        NSString *name = [item objectForKey:@"name"];
        id data = [self ivarValueWithObject:instance ivarName:name];
        if (data) {
            
            if ([[data class] respondsToSelector:@selector(superEndClass)]) {
                data = [self attributeWithInstance:data];
            }
            if ([data isKindOfClass:[NSSet class]]) {
                data = [data allObjects];
            }
            if ([data isKindOfClass:[NSArray class]]) {
                NSArray *objects = data;
                NSMutableArray *results = [NSMutableArray array];
                for (id object in objects) {
                    if ([[object class] respondsToSelector:@selector(superEndClass)]) {
                        [results addObject:[self attributeWithInstance:object]];
                    }
                    else{
                        [results addObject:object];
                    }
                }
                data = results;
            }
            if (![data isKindOfClass:[NSNull class]]) {
                
                if ([@"_" isEqualToString:[name substringToIndex:1]]) {
                    name = [name substringFromIndex:1];
                }
                [reVal setObject:data forKey:name];
            }
        }
    }
    return reVal;
}

+ (void)setAttributes:(NSDictionary*)attributes withInstance:(NSObject<XLFBaseModelInterface> *)instance{
    
    if ([attributes isKindOfClass:[NSDictionary class]]) {
        
        NSArray *allKeys = [attributes allKeys];
        for (id key in allKeys ) {
            
            NSString *name=[NSString stringWithFormat:@"_%@",key];
            NSString *type=[self ivarType:instance ivarName:name];
            
            // 能够找到变量
            if ([type length]>0) {
                
                id value = [attributes objectForKey:key];
                
                if ([value isKindOfClass:[NSArray class]]) {
                    
                    if([@"@\"NSArray\"" isEqualToString:type]) {
                        
                        if ([instance respondsToSelector:@selector(arrayModelClassWithPropertyName:)]) {
                            
                            Class class = [instance arrayModelClassWithPropertyName:key];
                            
                            if (class && [class respondsToSelector:@selector(superEndClass)] &&
                                [value respondsToSelector:@selector(modelsWithClass:)]) {
                                
                                // Model Array
                                value = [value modelsWithClass:class];
                            }
                        }
                    }
                    else if([@"@\"NSMutableArray\"" isEqualToString:type]) {
                        
                        if ([instance respondsToSelector:@selector(arrayModelClassWithPropertyName:)]) {
                            
                            Class class = [instance arrayModelClassWithPropertyName:key];
                            
                            if (class && [class respondsToSelector:@selector(superEndClass)]) {
                                
                                // Model Array
                                value = [NSMutableArray modelsWithClass:class attributes:value];
                            }
                        }
                    }
                    else if([@"@\"NSSet\"" isEqualToString:type]) {
                        
                        if ([instance respondsToSelector:@selector(arrayModelClassWithPropertyName:)]) {
                            
                            Class class = [instance arrayModelClassWithPropertyName:key];
                            
                            if (class && [class respondsToSelector:@selector(superEndClass)]) {
                                
                                // Model Array
                                value = [NSSet modelsWithClass:class attributes:value];
                            }
                        }
                    }
                    else if([@"@\"NSMutableSet\"" isEqualToString:type]) {
                        
                        if ([instance respondsToSelector:@selector(arrayModelClassWithPropertyName:)]) {
                            
                            Class class = [instance arrayModelClassWithPropertyName:key];
                            
                            if (class && [class respondsToSelector:@selector(superEndClass)]) {
                                
                                // Model Array
                                value = [NSMutableSet modelsWithClass:class attributes:value];
                            }
                        }
                    }
                    [self setIvarValue:instance ivarName:name value:value];
                }
                else if ([value isKindOfClass:[NSDictionary class]]) {
                    
                    if (![@"@\"NSDictionary\"" isEqualToString:type]) {
                        
                        // Model Type
                        type = [type substringWithRange:NSMakeRange(2, type.length-3)];
                        
                        // Model Class
                        Class class = NSClassFromString(type);
                        
                        // Model Object
                        if ([class respondsToSelector:@selector(superEndClass)] &&
                            [value respondsToSelector:@selector(modelWithClass:)]) {
                            
                            value = [value modelWithClass:class];
                        }
                    }
                    [self setIvarValue:instance ivarName:name value:value];
                }
                else if([value isKindOfClass:[NSNull class]]){
                    
                    [self setIvarValue:instance ivarName:name value:nil];
                }
                else {
                    [self setIvarValue:instance ivarName:name value:value];
                }
            }
            else{
                NSLog(@"WARNING:%@ 找不到变量%@", [instance class], name);
            }
        }
    }
    else{
        NSLog(@"ERROR:找不到对象%@ 数据结构不匹配%@", [instance class], [attributes class]);
    }
}

+ (NSString *)getModelName:(NSString *)type{
    
    NSString *reVal;
    NSInteger length=type.length-@"@\"NSArray\"".length-8-2;
    reVal=[type substringWithRange:NSMakeRange(10, length)];
    
    return reVal;
}

+ (void)save{
    
    [NSKeyedArchiver archiveRootObject:self toFile:[[self class] archiverPath]];
}

+ (NSString*)archiverPath;{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    documentsPath=[NSString stringWithFormat:@"%@/AppDevData.dat",documentsPath];
    return documentsPath;
}

+ (BOOL)isSuperClass:(Class)superClass class:(Class)class{
    
    BOOL reVal=NO;
    Class temp=[class superclass];
    while (YES) {
        
        if (superClass==temp) {
            
            reVal=YES;
            break;
        }
        if (temp==[NSObject class]) {
            
            break;
        }
        temp=[temp superclass];
    }
    return reVal;
}

+ (void)removeObjectForKey:(NSString*)aKey withInstance:(NSObject<XLFBaseModelInterface> *)instance;{
    
    [self setIvarValue:instance ivarName:[NSString stringWithFormat:@"_%@",aKey] value:nil];
}

+ (void)setObject:(id)anObject forKey:(NSString*)aKey withInstance:(NSObject<XLFBaseModelInterface> *)instance;{
    
    [self setIvarValue:instance ivarName:[NSString stringWithFormat:@"_%@",aKey] value:anObject];
}

+ (id)objectForKey:(NSString*)aKey withInstance:(NSObject<XLFBaseModelInterface> *)instance;{
    
    return [self ivarValue:instance ivarName:[NSString stringWithFormat:@"_%@",aKey]];
}

+ (void)clearWithInstance:(NSObject<XLFBaseModelInterface> *)instance;{
    
    NSArray *allIvarNames = [self allIvarNameList:[instance class]];
    
    for (NSString *ivarName in allIvarNames) {
        
        [self setIvarValue:instance ivarName:[NSString stringWithFormat:@"_%@",ivarName] value:nil];
    }
}

@end
