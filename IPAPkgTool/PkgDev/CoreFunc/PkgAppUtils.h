//
//  PkgAppUtils.h
//
//  Created by dyf on 16/6/7.
//  Copyright © 2016 dyf. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// PkgApp Choose Response Block
typedef void (^PkgAppChooseResponseBlock)(NSString *path);

// PkgApp Get Certs Response Block
typedef void (^PkgAppGetCertsResponseBlock)(NSMutableArray *certs);

@interface PkgAppUtils : NSObject

/**
 *  打开Finder，选择文件或目录
 *
 *  @param canChooseFiles       是否能选择文件
 *  @param canChooseDirectories 是否能选择目录
 *  @param fileTypes            文件类型
 *  @param handler              完成回调
 */
- (void)openFinder:(BOOL)canChooseFiles chooseDirectories:(BOOL)canChooseDirectories allowedFileTypes:(NSArray<NSString *> *)fileTypes completionHandler:(PkgAppChooseResponseBlock)handler;

/**
 *  打开Finder，选择文件或目录
 *
 *  @param canChooseFiles       是否能选择文件
 *  @param canChooseDirectories 是否能选择目录
 *  @param canCreateDirectories 是否能创建目录
 *  @param fileTypes            文件类型
 *  @param handler              完成回调
 */
- (void)openFinder:(BOOL)canChooseFiles chooseDirectories:(BOOL)canChooseDirectories canCreateDirectories:(BOOL)canCreateDirectories allowedFileTypes:(NSArray<NSString *> *)fileTypes completionHandler:(PkgAppChooseResponseBlock)handler;

/**
 *  展示对话框
 *
 *  @param window
 *  @param style        样式
 *  @param title        标题
 *  @param message      信息
 *  @param buttonTitles 按钮标题
 *  @param handler
 *
 *  @return
 */
+ (NSAlert *)showAlert:(NSWindow *)window style:(NSAlertStyle)style title:(NSString *)title message:(NSString *)message buttonTitles:(NSArray *)buttonTitles completionHandler:(void (^)(NSInteger returnCode))handler;

/**
 *  获取证书
 *
 *  @param handler 完成回调
 */
- (void)getCertsWithCompletionHandler:(PkgAppGetCertsResponseBlock)handler;

/**
 *  本地存储
 *
 *  @param value
 *  @param key
 */
+ (void)localStore:(id)value forKey:(NSString *)key;

/**
 *  本地读取
 *
 *  @param key
 *
 *  @return
 */
+ (id)localRead:(NSString *)key;

/**
 *  设置按钮字体颜色
 *
 *  @param button 按钮
 *  @param color  RGB颜色
 */
+ (void)setTextColorForButton:(NSButton *)button color:(NSColor *)color;

@end
