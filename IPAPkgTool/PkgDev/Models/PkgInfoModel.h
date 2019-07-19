//
//  PkgInfoModel.h
//
//  Created by dyf on 16/6/15.
//  Copyright © 2016 dyf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PkgInfoModel : NSObject
@property (nonatomic, assign) NSInteger checkBoxState;
@property (nonatomic, copy  ) NSString  *channelIdentifier;
@property (nonatomic, copy  ) NSString  *bundleIdentifier;
@property (nonatomic, copy  ) NSString  *mobileprovisionPath;
@property (nonatomic, copy  ) NSString  *certName;
@end
