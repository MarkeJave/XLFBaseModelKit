//
//  XLFBaseModel.m
//  XLFBaseModelKit
//
//  Created by Marike Jave on 14-4-3.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//

#import <objc/runtime.h>

#import "XLFBaseModel.h"
#import "XLFRunTime.h"

@interface FORCELOAD_XLFBaseModel : NSObject
@end
@implementation FORCELOAD_XLFBaseModel
@end

@implementation NSObject(XLFBaseModel)

- (id)modelWithClass:(Class)_class;{
    
    return nil;
}

- (id)modelWithClass:(Class)_class attribute:(NSDictionary*)attribute;{
    
    return nil;
}

- (NSArray*)modelsWithClass:(Class)_class;{
    
    return nil;
}

- (NSArray*)modelsWithClass:(Class)_class attributes:(NSArray*)attributes;{
    
    return nil;
}

@end

@implementation NSObject (RunTime)

//+ (Class)superEndClass;{
//    
//    return [self class];
//}

+ (id)model;{
    
    return [[[self class] alloc] init];
}

+ (id)modelWithAttributes:(NSDictionary* )attributes;{
    
    return [[[self class] alloc] initWithAttributes:attributes];
}

- (id)initWithAttributes:(NSDictionary* )attributes;{
    
    self = [self init];
    
    if (self ) {
        
        [self setAttributes:attributes];
    }
    return self;
}

- (void)setAttributes:(NSDictionary *)attributes{
    
    [XLFRunTime setAttributes:attributes withInstance:self];
}

- (NSDictionary *)dictionary{
    
    return [XLFRunTime attributeWithInstance:self];
}

- (Class)arrayModelClassWithPropertyName:(NSString*)propertyName;{
    
    return nil;
}

@end

//
//@implementation NSNull(XLFBaseModel)
//
//- (id)modelWithClass:(Class)_class;{
//    
//    return [super modelWithClass:_class];
//}
//
//- (id)modelWithClass:(Class)_class attribute:(NSDictionary*)attribute;{
//    
//    return [super modelWithClass:_class attribute:attribute];
//}
//
//- (NSArray*)modelsWithClass:(Class)_class;{
//    
//    return nil;
//}
//
//- (NSArray*)modelsWithClass:(Class)_class attributes:(NSArray*)attributes;{
//    
//    return nil;
//}
//
//
//@end

@implementation NSDictionary (XLFBaseModel)

- (id)modelWithClass:(Class)_class;{
    
    return [[_class alloc] initWithAttributes:self];
}

+ (id)modelWithClass:(Class)_class attribute:(NSDictionary*)attribute;{
    
    return [attribute modelWithClass:_class];
    
}
@end

@implementation NSDictionary (UnknownClass)

- (id)modelWithUnKnownClass:(Class)unknownClass;{
    
    return [[unknownClass alloc] initWithAttributes:self];
}

+ (id)modelWithUnKnownClass:(Class)unknownClass attribute:(NSDictionary*)attribute;{
    
    return [attribute modelWithUnKnownClass:unknownClass];
}

@end

@implementation NSArray (XLFBaseModel)

- (NSArray*)modelsWithClass:(Class)_class;{
    
    NSMutableArray *models = [NSMutableArray array];
    
    for (NSDictionary* item in self) {
        
        if ([item respondsToSelector:@selector(modelWithClass:)]) {
            
            [models addObject:[item modelWithClass:_class]];
        }
        else if([item isKindOfClass:_class]){
            
            [models addObject:item];
        }
    }
    
    return [NSArray arrayWithArray:models];
}

+ (NSArray*)modelsWithClass:(Class)_class attributes:(NSArray*)attributes;{
    
    return [attributes modelsWithClass:_class];
}

@end

@implementation NSMutableArray (XLFBaseModel)

- (NSMutableArray*)modelsWithClass:(Class)_class;{
    
    NSMutableArray *models = [NSMutableArray array];
    
    for (NSDictionary* item in self) {
        
        if ([item respondsToSelector:@selector(modelWithClass:)]) {
            
            [models addObject:[item modelWithClass:_class]];
        }
        else if([item isKindOfClass:_class]){
            
            [models addObject:item];
        }
    }
    
    return models;
}

+ (NSMutableArray*)modelsWithClass:(Class)_class attributes:(NSArray*)attributes;{
    
    return [self modelsWithClass:_class attributes:attributes];
}

@end

@implementation NSSet (XLFBaseModel)

+ (NSSet*)modelsWithClass:(Class)_class attributes:(NSArray*)attributes;{
    
    NSMutableSet *models = [NSMutableSet set];
    
    for (NSDictionary* attribute in attributes) {
        
        if ([attribute respondsToSelector:@selector(modelWithClass:)]) {
            
            [models addObject:[attribute modelWithClass:_class]];
        }
        else if([attribute isKindOfClass:_class]){
            
            [models addObject:attribute];
        }
    }
    
    return [NSSet setWithSet:models];
}

@end

@implementation NSMutableSet (XLFBaseModel)

+ (NSMutableSet*)modelsWithClass:(Class)_class attributes:(NSArray*)attributes;{
    
    NSMutableSet *models = [NSMutableSet set];
    
    for (NSDictionary* attribute in attributes) {
        
        if ([attribute respondsToSelector:@selector(modelWithClass:)]) {
            
            [models addObject:[attribute modelWithClass:_class]];
        }
        else if([attribute isKindOfClass:_class]){
            
            [models addObject:attribute];
        }
    }
    
    return models;
}

@end

@implementation XLFBaseModel

- (void)dealloc{
    
}

+ (Class)superEndClass;{
    
    return [XLFBaseModel class];
}

+ (id)model;{
    
    return [[[self class] alloc] init];
}

+ (id)modelWithAttributes:(NSDictionary* )attributes;{
    
    return [[[self class] alloc] initWithAttributes:attributes];
}

- (Class)arrayModelClassWithPropertyName:(NSString*)propertyName;{
    
    return nil;
}

- (id)init{
    self = [super init];
    if (self) {
        
        
    }
    return self;
}

- (id)initWithAttributes:(NSDictionary* )attributes;{
    self = [self init];
    if (![attributes isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    if (self ) {
        
        [self setAttributes:attributes];
    }
    return self;
}

- (void)setAttributes:(NSDictionary *)attributes{
    
    [XLFRunTime setAttributes:attributes withInstance:self];
}

- (NSDictionary *)dictionary{
    
    return [XLFRunTime attributeWithInstance:self];
}

- (NSString *)description{
    
    return [[self dictionary] description];
}

- (void)clear;{
    
    [XLFRunTime clearWithInstance:self];
}

@end

@implementation XLFBaseModel (KVO)

- (void)addObserverForNewValue:(NSObject *)observer;{
    
    [self addObserverForNewValue:observer keyPaths:nil];
}

- (void)addObserverForOldValueChanged:(NSObject *)observer;{
    
    [self addObserverForOldValueChanged:observer keyPaths:nil];
}

- (void)removeObserver:(NSObject *)observer;{
    
    [self removeObserver:observer keyPaths:nil];
}

- (void)addObserverForNewValue:(NSObject *)observer keyPaths:(NSArray *)keyPaths;{
    
    keyPaths = (keyPaths && [keyPaths count]) ? keyPaths : [self observableKeypaths];
    
    for (NSString *keyPath in keyPaths) {
        
        [self addObserver:observer forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)addObserverForOldValueChanged:(NSObject *)observer keyPaths:(NSArray *)keyPaths;{
    
    keyPaths = (keyPaths && [keyPaths count]) ? keyPaths : [self observableKeypaths];
    
    for (NSString *keyPath in keyPaths) {
        
        [self addObserver:observer forKeyPath:keyPath options:NSKeyValueObservingOptionOld context:NULL];
    }
}

- (void)removeObserver:(NSObject *)observer keyPaths:(NSArray *)keyPaths;{
    
    if (!keyPaths || [keyPaths count]) {
        
        id observationInfo = [self observationInfo];
        
        if (observationInfo) {
            
            NSMutableArray *mutableKeyPaths = [NSMutableArray array];
            
            NSArray *observances = [XLFRunTime ivarValue:observationInfo ivarName:@"_observances"];
            
            for (id observance in observances) {
                
                id containtedObserver = [XLFRunTime ivarValue:observance ivarName:@"_observer"];
                id property = [XLFRunTime ivarValue:observance ivarName:@"_property"];
                
                if (observer && [containtedObserver isEqual:observer] && property) {
                    
                    NSString *keyPath = [XLFRunTime ivarValue:property ivarName:@"_keyPath"];
                    
                    if (keyPath) {
                        
                        [mutableKeyPaths addObject:[keyPath mutableCopy]];
                    }
                }
            }
            keyPaths = mutableKeyPaths;
        }
    }
    
    //    keyPaths = (!keyPaths || [keyPaths count]) ? keyPaths : [self observableKeypaths];
    
    for (NSString *keyPath in keyPaths) {
        
        [self removeObserver:observer forKeyPath:keyPath];
    }
}

- (void)removeAllObserver{
    
    id observationInfo = [self observationInfo];
    
    if (observationInfo) {
        
        NSArray *observances = [XLFRunTime ivarValue:observationInfo ivarName:@"_observances"];
        
        for (id observance in observances) {
            
            id observer = [XLFRunTime ivarValue:observance ivarName:@"_observer"];
            id property = [XLFRunTime ivarValue:observance ivarName:@"_property"];
            
            if (observer && property) {
                
                NSString *keyPath = [XLFRunTime ivarValue:property ivarName:@"_keyPath"];
                
                if (keyPath) {
                    
                    [self removeObserver:observer forKeyPath:keyPath];
                }
            }
        }
    }
}

- (NSArray *)observableKeypaths {
    
    return [XLFRunTime ivarNameList:[self class]];
}

@end

@implementation XLFBaseModel (KV)

- (void)removeObjectForKey:(NSString*)aKey;{
    
    [XLFRunTime removeObjectForKey:aKey withInstance:self];
}

- (void)setObject:(id)anObject forKey:(NSString*)aKey;{
    
    [XLFRunTime setObject:anObject forKey:aKey withInstance:self];
}

- (id)objectForKey:(NSString*)aKey;{
    
    return [XLFRunTime objectForKey:aKey withInstance:self];
}

@end

@implementation XLFBaseModel (Copying)

- (id)copyWithZone:(NSZone*)zone;{
    
    return [[[self class] allocWithZone:zone] initWithAttributes:[self dictionary]];
}

- (void)copyModel:(XLFBaseModel *)model;{
    
    [self setAttributes:[model dictionary]];
}


@end

@implementation XLFBaseModel (MutableCopying)

- (id)mutableCopyWithZone:(NSZone*)zone{
    
    NSData *encoderData = [XLFRunTime archivedDataWithRootObject:self];
    typeof(self)copyObjec = [NSKeyedUnarchiver unarchiveObjectWithData:encoderData];
    
    return copyObjec;
}

@end

@implementation XLFBaseModel (Coding)

- (id)initWithCoder:(NSCoder *)aDecoder{
    
    self=[XLFRunTime initWithCoder:aDecoder withInstance:self];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [XLFRunTime encodeWithCoder:aCoder withInstance:self];
}

@end

