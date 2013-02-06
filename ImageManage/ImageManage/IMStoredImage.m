//
//  IMStoredImage.m
//  ImageManage
//
//  Created by Danis Tazetdinov on 06.02.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import "IMStoredImage.h"

@interface IMStoredImage()

@property (nonatomic, readwrite, assign) NSUInteger height;
@property (nonatomic, readwrite, assign) NSUInteger width;
@property (nonatomic, readwrite, assign) NSUInteger components;
@property (nonatomic, readwrite, assign) NSUInteger bitsPerComponent;
@property (nonatomic, readwrite, assign) CGBitmapInfo bitmapInfo;

@property (nonatomic, readwrite, strong) NSData *imageData;

@end

@implementation IMStoredImage

-(id)initWithImage:(UIImage*)image
{
    self = [super init];
    if (self)
    {
        if (image)
        {
            self.width = CGImageGetWidth(image.CGImage);
            self.height = CGImageGetHeight(image.CGImage);
            
            self.bitsPerComponent = CGImageGetBitsPerComponent(image.CGImage);
            self.components = CGImageGetBitsPerPixel(image.CGImage) / CGImageGetBitsPerComponent(image.CGImage);
            
            self.bitmapInfo = CGImageGetBitmapInfo(image.CGImage);
            
            CGDataProviderRef imageDataProviderRef = CGImageGetDataProvider(image.CGImage);
            self.imageData = (__bridge_transfer NSData*) CGDataProviderCopyData(imageDataProviderRef);
        }
    }
    return self;
}

-(UIImage *)image
{
    if (self.imageData)
    {
        CGDataProviderRef imageDataProviderRef = CGDataProviderCreateWithData(NULL,
                                                                              self.imageData.bytes,
                                                                              self.imageData.length,
                                                                              NULL);
        
        CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
        
        CGImageRef imageRef = CGImageCreate(self.width,
                                            self.height,
                                            self.bitsPerComponent,
                                            self.bitsPerComponent * self.components,
                                            self.width * self.components * self.bitsPerComponent / 8,
                                            colorSpaceRef,
                                            self.bitmapInfo,
                                            imageDataProviderRef,
                                            NULL,
                                            NO,
                                            kCGRenderingIntentDefault);
        
        UIImage *image = [UIImage imageWithCGImage:imageRef];
       
        CGImageRelease(imageRef);
        CGColorSpaceRelease(colorSpaceRef);
        CGDataProviderRelease(imageDataProviderRef);
        
        return image;
    }
    else
    {
        return nil;
    }
}

-(NSString *)description
{
    if (self.imageData)
    {
        NSMutableString *desc = [NSMutableString string];
        [desc appendString:@"<IMStoredImage: ...>\n"];
        unsigned char *rawImageData = (unsigned char *)self.imageData.bytes;
        size_t bytesPerPixel = self.components * self.bitsPerComponent / 8;
        size_t bytesPerRow = self.width * bytesPerPixel;
        for (size_t i = 0; i < self.height; i++)
        {
            for (size_t j = 0; j < self.width; j++)
            {
                [desc appendString:@"("];
                for (size_t k = 0; k < bytesPerPixel; k++)
                {
                    if (k)
                    {
                        [desc appendString:@","];
                    }
                    [desc appendFormat:@"%.2X", rawImageData[i * bytesPerRow + j * bytesPerPixel + k]];
                }
                [desc appendString:@") "];
                
            }
            [desc appendString:@"\n"];
        }
        
        return desc;
        
    }
    else
    {
        return [NSString stringWithFormat:@"<IMStoredImage: empty>"];
    }
}

@end
