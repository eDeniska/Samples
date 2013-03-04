//
//  Macros.h
//  GDC Book
//
//  Created by Danis Tazetdinov on 10.01.12.
//  Copyright (c) 2012 Fujitsu Russia GDC. All rights reserved.
//

#ifndef GDC_Book_Macros_h
#define GDC_Book_Macros_h

#if DEBUG

#define DLog(fmt, ...) NSLog((@"(%@) %s [%d] " fmt), NSStringFromClass([self class]), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#else

#define DLog(...)

#endif

#define DAbort(fmt, ...) { NSLog((@"Failure at (%@) %s [%d] " fmt), NSStringFromClass([self class]), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); abort(); }

#endif
