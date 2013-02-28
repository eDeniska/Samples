//
//  SDKeychain.h
//  SecureData
//
//  Created by Danis Tazetdinov on 28.02.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDKeychain : NSObject


+(id)defaultKeychain;
+(id)keychainWithService:(NSString*)service;
+(id)keychainWithService:(NSString*)service accessGroup:(NSString*)accessGroup;


-(id)initWithService:(NSString*)service;
-(id)initWithService:(NSString*)service accessGroup:(NSString*)accessGroup;


-(id)objectForKey:(id)key;
- (void)setObject:(id)obj forKey:(id <NSCopying>)key;

- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;


@end
