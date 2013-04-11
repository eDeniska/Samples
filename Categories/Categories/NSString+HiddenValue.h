//
//  NSString+HiddenValue.h
//  Categories
//
//  Created by Danis Tazetdinov on 11.04.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HiddenValue)

-(void)showInAlert;

@property (nonatomic, copy) NSString *hiddenValue;

@end
