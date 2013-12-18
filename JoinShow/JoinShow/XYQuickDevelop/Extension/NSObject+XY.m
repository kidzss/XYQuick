//
//  NSObject+XY.m
//  JoinShow
//
//  Created by Heaven on 13-7-31.
//  Copyright (c) 2013年 Heaven. All rights reserved.
//

#import "NSObject+XY.h"
#import "XYPrecompile.h"
//#import "XYExtension.h"

#undef	NSObject_key_performSelector
#define NSObject_key_performSelector	"NSObject.performSelector"
#undef	NSObject_key_performTarget
#define NSObject_key_performTarget	"NSObject.performTarget"
#undef	NSObject_key_performBlock
#define NSObject_key_performBlock	"NSObject.performBlock"
#undef	NSObject_key_loop
#define NSObject_key_loop	"NSObject.loop"
#undef	NSObject_key_afterDelay
#define NSObject_key_afterDelay	"NSObject.afterDelay"
#undef	NSObject_key_object
#define NSObject_key_object	"NSObject.object"

#undef	NSObject_isHookDealloc
#define NSObject_isHookDealloc	"NSObject.isHookDealloc"

DUMMY_CLASS(NSObject_XY);

@implementation NSObject (XY)

@dynamic attributeList;

/*
@dynamic isHookDealloc;
-(BOOL) isHookDealloc{
    NSNumber *obj = objc_getAssociatedObject(self, NSObject_isHookDealloc);
	BOOL b = [obj boolValue];
    
	return b;
}
- (void)setIsHookDealloc:(BOOL)b
{
	objc_setAssociatedObject(self, NSObject_isHookDealloc, [NSNumber numberWithBool:b], OBJC_ASSOCIATION_ASSIGN);
}

-(void) NSObject_dealloc{
    NSLogDD
    objc_removeAssociatedObjects(self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    XY_swizzleInstanceMethod([self class], @selector(NSObject_dealloc), @selector(dealloc));
    self.isHookDealloc = NO;
	[self dealloc];
}
-(void) hookDealloc{
    if (!self.isHookDealloc) {
        XY_swizzleInstanceMethod([self class], @selector(dealloc), @selector(NSObject_dealloc));
        self.isHookDealloc = YES;
    }
}
*/
////////////////////////  perform  ////////////////////////
-(void) performSelector:(SEL)aSelector  target:(id)target  mark:(id)mark afterDelay:(NSTimeInterval(^)(void))aBlockTime loop:(BOOL)loop isRunNow:(BOOL)now{
    if (!aBlockTime) return;
    
    NSTimeInterval t;
    if (now) {
        t = 0;
    }else{
        t = aBlockTime();
    }
    
    objc_setAssociatedObject(self, NSObject_key_performBlock, nil, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(self, NSObject_key_performTarget, target, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(self, NSObject_key_performSelector, (id)aSelector, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(self, NSObject_key_afterDelay, aBlockTime, OBJC_ASSOCIATION_COPY);
    objc_setAssociatedObject(self, NSObject_key_loop, (id)loop, OBJC_ASSOCIATION_ASSIGN);
    
    [self performSelector:@selector(randomRerform:) withObject:mark afterDelay:t];
}
-(void) performBlock:(void(^)(void))aBlock mark:(id)mark afterDelay:(NSTimeInterval(^)(void))aBlockTime loop:(BOOL)loop isRunNow:(BOOL)now{
    if (!aBlockTime) return;
    
    NSTimeInterval t;
    if (aBlockTime) {
        t = aBlockTime();
    }
    if (now) {
        t = 0;
    }

    objc_setAssociatedObject(self, NSObject_key_performBlock, aBlock, OBJC_ASSOCIATION_COPY);
    objc_setAssociatedObject(self, NSObject_key_performSelector, nil, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(self, NSObject_key_performTarget, nil, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(self, NSObject_key_afterDelay, aBlockTime, OBJC_ASSOCIATION_COPY);
    objc_setAssociatedObject(self, NSObject_key_loop, (id)loop, OBJC_ASSOCIATION_ASSIGN);
    
    [self performSelector:@selector(randomRerform:) withObject:mark afterDelay:t];
}
-(void) randomRerform:(id)anArgument{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(randomRerform:) object:nil];
    
    void (^aBlock)(void) = objc_getAssociatedObject(self, NSObject_key_performBlock);
    if (aBlock) {
        aBlock();
    }
    
    SEL sel =   (SEL)objc_getAssociatedObject(self, NSObject_key_performSelector);
    if (sel) {
        id target = objc_getAssociatedObject(self, NSObject_key_performTarget);
        [target performSelector:sel withObject:anArgument];
    }
    
    
     NSTimeInterval (^aBlockTime)(void) = objc_getAssociatedObject(self, NSObject_key_afterDelay);
    NSTimeInterval t = 0;
    if (aBlockTime) {
        t = aBlockTime();
    }
    
    BOOL b = (BOOL)objc_getAssociatedObject(self, NSObject_key_loop);
    if (b) {
        [self performSelector:@selector(randomRerform:) withObject:anArgument afterDelay:t];
    }
}
-(void) removePerformRandomDelay{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(randomRerform:) object:nil];
    
    objc_setAssociatedObject(self, NSObject_key_performBlock, nil, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(self, NSObject_key_performSelector, nil, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(self, NSObject_key_performTarget, nil, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(self, NSObject_key_afterDelay, nil, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(self, NSObject_key_object, nil, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(self, NSObject_key_loop, nil, OBJC_ASSOCIATION_ASSIGN);
}
////////////////////////  NSNotificationCenter  ////////////////////////
-(void) registerMessage:(NSString*)aMsg selector:(SEL)aSel source:(id)source{
    if (aMsg == nil || aSel == nil) return;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:aSel name:aMsg object:source];
  //  [self hookDealloc];
}
-(void) unregisterMessage:(NSString*)aMsg{
    if (aMsg == nil) return;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:aMsg object:nil];
}
-(void) unregisterAllMessage{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void) sendMessage:(NSString *)aMsg withObject:(NSObject *)object{
    if (aMsg == nil) return;
    [[NSNotificationCenter defaultCenter] postNotificationName:aMsg object:object userInfo:nil];
}

////////////////////////  property  ////////////////////////
-(NSArray *) attributeList{
    NSUInteger			propertyCount = 0;
    objc_property_t     *properties = class_copyPropertyList( [self class], &propertyCount );
    NSMutableArray *    array = [[[NSMutableArray alloc] init] autorelease];
    for ( NSUInteger i = 0; i < propertyCount; i++ )
    {
        const char *name = property_getName(properties[i]);
        NSString *propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        
        //   const char *attr = property_getAttributes(properties[i]);
        // NSLogD(@"%@, %s", propertyName, attr);
        [array addObject:propertyName];
    }
    free( properties );
    return array;
}

////////////////////////  Conversion  ////////////////////////
- (NSInteger)asInteger
{
	return [[self asNSNumber] integerValue];
}

- (float)asFloat
{
	return [[self asNSNumber] floatValue];
}

- (BOOL)asBool
{
	return [[self asNSNumber] boolValue];
}

- (NSNumber *)asNSNumber
{
	if ( [self isKindOfClass:[NSNumber class]] )
	{
		return (NSNumber *)self;
	}
	else if ( [self isKindOfClass:[NSString class]] )
	{
		return [NSNumber numberWithInteger:[(NSString *)self integerValue]];
	}
	else if ( [self isKindOfClass:[NSDate class]] )
	{
		return [NSNumber numberWithDouble:[(NSDate *)self timeIntervalSince1970]];
	}
	else if ( [self isKindOfClass:[NSNull class]] )
	{
		return [NSNumber numberWithInteger:0];
	}
    
	return nil;
}

- (NSString *)asNSString
{
	if ( [self isKindOfClass:[NSNull class]] )
		return nil;
    
	if ( [self isKindOfClass:[NSString class]] )
	{
		return (NSString *)self;
	}
	else if ( [self isKindOfClass:[NSData class]] )
	{
		NSData * data = (NSData *)self;
		return [[[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding] autorelease];
	}
	else
	{
		return [NSString stringWithFormat:@"%@", self];
	}
}

- (NSDate *)asNSDate
{
	if ( [self isKindOfClass:[NSDate class]] )
	{
		return (NSDate *)self;
	}
	else if ( [self isKindOfClass:[NSString class]] )
	{
		NSDate * date = nil;
        
		if ( nil == date )
		{
			NSString * format = @"yyyy-MM-dd HH:mm:ss z";
			NSDateFormatter * formatter = [[[NSDateFormatter alloc] init] autorelease];
			[formatter setDateFormat:format];
			[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            
			date = [formatter dateFromString:(NSString *)self];
		}
        
		if ( nil == date )
		{
			NSString * format = @"yyyy/MM/dd HH:mm:ss z";
			NSDateFormatter * formatter = [[[NSDateFormatter alloc] init] autorelease];
			[formatter setDateFormat:format];
			[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
			
			date = [formatter dateFromString:(NSString *)self];
		}
        
		if ( nil == date )
		{
			NSString * format = @"yyyy-MM-dd HH:mm:ss";
			NSDateFormatter * formatter = [[[NSDateFormatter alloc] init] autorelease];
			[formatter setDateFormat:format];
			[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
			
			date = [formatter dateFromString:(NSString *)self];
		}
        
		if ( nil == date )
		{
			NSString * format = @"yyyy/MM/dd HH:mm:ss";
			NSDateFormatter * formatter = [[[NSDateFormatter alloc] init] autorelease];
			[formatter setDateFormat:format];
			[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
			
			date = [formatter dateFromString:(NSString *)self];
		}
        
		return date;
        
        //		NSTimeZone * local = [NSTimeZone localTimeZone];
        //		return [NSDate dateWithTimeInterval:(3600 + [local secondsFromGMT])
        //								  sinceDate:[dateFormatter dateFromString:text]];
	}
	else
	{
		return [NSDate dateWithTimeIntervalSince1970:[self asNSNumber].doubleValue];
	}
	
	return nil;
}

- (NSData *)asNSData
{
	if ( [self isKindOfClass:[NSString class]] )
	{
		return [(NSString *)self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	}
	else if ( [self isKindOfClass:[NSData class]] )
	{
		return (NSData *)self;
	}
    
	return nil;
}

- (NSArray *)asNSArray
{
	if ( [self isKindOfClass:[NSArray class]] )
	{
		return (NSArray *)self;
	}
	else
	{
		return [NSArray arrayWithObject:self];
	}
}
/*
- (NSArray *)asNSArrayWithClass:(Class)clazz
{
	if ( [self isKindOfClass:[NSArray class]] )
	{
		NSMutableArray * results = [NSMutableArray array];
        
		for ( NSObject * elem in (NSArray *)self )
		{
			if ( [elem isKindOfClass:[NSDictionary class]] )
			{
				NSObject * obj = [[self class] objectFromDictionary:elem];
				[results addObject:obj];
			}
		}
		
		return results;
	}
    
	return nil;
}
*/
- (NSMutableArray *)asNSMutableArray
{
	if ( [self isKindOfClass:[NSMutableArray class]] )
	{
		return (NSMutableArray *)self;
	}
	
	return nil;
}

- (NSMutableArray *)asNSMutableArrayWithClass:(Class)clazz
{
	NSArray * array = [self asNSArrayWithClass:clazz];
	if ( nil == array )
		return nil;
    
	return [NSMutableArray arrayWithArray:array];
}

- (NSDictionary *)asNSDictionary
{
	if ( [self isKindOfClass:[NSDictionary class]] )
	{
		return (NSDictionary *)self;
	}
    
	return nil;
}

- (NSMutableDictionary *)asNSMutableDictionary
{
	if ( [self isKindOfClass:[NSMutableDictionary class]] )
	{
		return (NSMutableDictionary *)self;
	}
	
	NSDictionary * dict = [self asNSDictionary];
	if ( nil == dict )
		return nil;
    
	return [NSMutableDictionary dictionaryWithDictionary:dict];
}

@end
