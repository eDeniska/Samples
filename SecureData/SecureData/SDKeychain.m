//
//  SDKeychain.m
//  SecureData
//
//  Created by Danis Tazetdinov on 28.02.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import "SDKeychain.h"

@interface SDKeychain()

@property (nonatomic, copy) NSString* accessGroup;
@property (nonatomic, copy) NSString* service;

@end

@implementation SDKeychain

-(id)init
{
    return [self initWithService:[[NSBundle mainBundle] bundleIdentifier]
                     accessGroup:[[NSBundle mainBundle] bundleIdentifier]];
}

-(id)initWithService:(NSString*)service
{
    return [self initWithService:service
                     accessGroup:[[NSBundle mainBundle] bundleIdentifier]];
}

-(id)initWithService:(NSString*)service accessGroup:(NSString*)accessGroup
{
    self = [super init];
    if (self)
    {
        self.accessGroup = accessGroup;
        self.service = service;
    }
    return self;
}

+(id)defaultKeychain
{
    static dispatch_once_t onceToken;
    static SDKeychain *keychain;
    dispatch_once(&onceToken, ^{
        keychain = [[self alloc] init];
    });
    return keychain;
}

+(id)keychainWithService:(NSString*)service accessGroup:(NSString*)accessGroup
{
    return [[self alloc] initWithService:service accessGroup:accessGroup];
}

+(id)keychainWithService:(NSString*)service
{
    return [[self alloc] initWithService:service];
}

-(id)objectForKey:(id)key
{
    return [self objectForKeyedSubscript:key];
}

- (void)setObject:(id)obj forKey:(id <NSCopying>)key
{
    [self setObject:obj forKeyedSubscript:key];
}

- (id)objectForKeyedSubscript:(id)key
{
    NSDictionary *keychainItem = [self loadKeychainDictionaryWithIdentifier:key];
    return keychainItem[(__bridge id)kSecValueData];
}

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key
{
    if (obj)
    {
        NSMutableDictionary *storedValue = [[self loadKeychainDictionaryWithIdentifier:key] mutableCopy];
        
        
        if (storedValue)
        {
            // updating value
            storedValue[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
            [storedValue removeObjectForKey:(__bridge id)kSecValueData];
            
            NSMutableDictionary *newValue = [storedValue mutableCopy];
            
            newValue[(__bridge id)kSecValueData] = [obj dataUsingEncoding:NSUTF8StringEncoding];
#if TARGET_IPHONE_SIMULATOR
            [newValue removeObjectForKey:(__bridge id)kSecAttrAccessGroup];
#endif
            [newValue removeObjectForKey:(__bridge id)kSecClass];
            
            OSStatus result = SecItemUpdate((__bridge CFDictionaryRef)storedValue, (__bridge CFDictionaryRef)newValue);
            NSLog(@"update result = %ld", result);
        }
        else
        {
            // adding new value
            NSDictionary *newValue =  @{
#if !TARGET_IPHONE_SIMULATOR
                                        (__bridge id)kSecAttrAccessGroup : self.accessGroup,
#endif
                                        (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
                                        (__bridge id)kSecAttrAccount : key,
                                        (__bridge id)kSecAttrService : self.service,
                                        (__bridge id)kSecValueData : [obj dataUsingEncoding:NSUTF8StringEncoding],
                                        
                                        };

            OSStatus result = SecItemAdd((__bridge CFDictionaryRef)newValue, NULL);
            NSLog(@"add result = %ld", result);
        }
    }
    else
    {
        // deleting object from keychain
        
        NSDictionary *query = @{
#if !TARGET_IPHONE_SIMULATOR
                                (__bridge id)kSecAttrAccessGroup : self.accessGroup,
#endif
                                (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
                                (__bridge id)kSecAttrAccount : key,
                                (__bridge id)kSecAttrService : self.service
                                };
        
        OSStatus result = SecItemDelete((__bridge CFDictionaryRef)query);
        NSLog(@"delete result = %ld", result);
    }
}

#pragma mark - Utility methods

-(NSDictionary*)loadKeychainDictionaryWithIdentifier:(id)identifier
{
    NSDictionary *query = @{
#if !TARGET_IPHONE_SIMULATOR
                            (__bridge id)kSecAttrAccessGroup : self.accessGroup,
#endif
                            (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecReturnAttributes : (__bridge id)kCFBooleanTrue,
                            (__bridge id)kSecReturnData : (__bridge id)kCFBooleanTrue,
                            (__bridge id)kSecAttrAccount : identifier,
                            (__bridge id)kSecAttrService : self.service
                            };
    
    CFDictionaryRef resultCF;
    NSMutableDictionary *results;
    OSStatus loadResult = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef*)&resultCF);
    NSLog(@"load result = %ld", loadResult);
    if (loadResult == noErr)
    {
        results = [(__bridge_transfer NSDictionary*)resultCF mutableCopy];
        results[(__bridge id)kSecValueData] = [[NSString alloc] initWithData:results[(__bridge id)kSecValueData] encoding:NSUTF8StringEncoding];
    }
    
    return results;
}

@end
