//
//  PkgAppMacros.h
//
//  Created by dyf on 16/6/28.
//  Copyright © 2016 dyf. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#ifndef PkgAppMacros_h
#define PkgAppMacros_h

#ifdef DEBUG
	#define PKGLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
	#define PKGLog(...) {}
#endif

#endif /* PkgAppMacros_h */
