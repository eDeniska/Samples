//
//  IMStoredImage.h
//  ImageManage
//
//  Created by Danis Tazetdinov on 06.02.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMStoredImage : NSObject

@property (nonatomic, readonly, assign) NSUInteger height;
@property (nonatomic, readonly, assign) NSUInteger width;
@property (nonatomic, readonly, assign) NSUInteger components;
@property (nonatomic, readonly, assign) NSUInteger bitsPerComponent;
@property (nonatomic, readonly, assign) CGBitmapInfo bitmapInfo;

@property (nonatomic, readonly, strong) NSData *imageData;

@property (nonatomic, readonly, copy) UIImage *image;

-(id)initWithImage:(UIImage*)image;


@end
