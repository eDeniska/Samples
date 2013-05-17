//
//  NSMutableString+Transform.h
//  Actions
//
//  Created by Danis Tazetdinov on 16.05.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableString (Transform)

-(BOOL)transform:(CFStringRef)transform;
-(BOOL)transform:(CFStringRef)transform range:(NSRange)range reverse:(BOOL)reverse;

@end
