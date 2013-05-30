//
//  INViewController.h
//  Introspector
//
//  Created by Danis Tazetdinov on 30.05.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INViewController : UIViewController

@property (nonatomic, strong) NSString *value;
@property (atomic, copy) NSNumber *key;

@property (nonatomic, unsafe_unretained) NSString *unretained;
@property (nonatomic, weak) NSString *weak;

@property (atomic, assign) int keyInt;

@end
