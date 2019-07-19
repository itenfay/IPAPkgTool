//
//  PkgAppStatusBarEvents.m
//
//  Created by dyf on 16/6/30.
//  Copyright © 2016 dyf. All rights reserved.
//

#import "PkgAppStatusBarEvents.h"
#import "PkgAppUtils.h"

@implementation PkgAppStatusBarEvents

+ (void)help {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    
    NSString *title = [NSString stringWithFormat:@"Technical Support"];
    NSString *message = [NSString stringWithFormat:@"@Author: %@", infoDict[@"Author"]];
    message = [message stringByAppendingString:@"\n"];
    message = [message stringByAppendingFormat:@"@Email: %@", infoDict[@"Email"]];
    
    [PkgAppUtils showAlert:nil style:NSWarningAlertStyle title:title message:message buttonTitles:@[@"OK"] completionHandler:nil];
}

@end
