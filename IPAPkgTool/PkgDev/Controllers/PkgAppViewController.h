//
//  PkgAppViewController.h
//
//  Created by dyf on 16/6/6.
//  Copyright © 2016 dyf. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PkgAppViewController : NSViewController

/**
 *  隐藏App
 *
 *  @param sender 消息触发者
 */
- (void)hideApp:(nullable id)sender;

/**
 *  退出App
 *
 *  @param sender 消息触发者
 */
- (void)terminateApp:(nullable id)sender;

/**
 *  强制注销第一响应
 *
 *  @return bool
 */
- (BOOL)forceResignFirstResponder;

/**
 *  返回视图的窗体
 *
 *  @return
 */
- (nullable NSWindow *)window;

@end
