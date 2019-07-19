//
//  PkgAppUtils.m
//
//  Created by dyf on 16/6/7.
//  Copyright © 2016 dyf. All rights reserved.
//

#import "PkgAppUtils.h"

@interface PkgAppUtils ()
@property (nonatomic, copy) PkgAppGetCertsResponseBlock getCertsHandler;
@end

@implementation PkgAppUtils

- (void)openFinder:(BOOL)canChooseFiles chooseDirectories:(BOOL)canChooseDirectories allowedFileTypes:(NSArray<NSString *> *)fileTypes completionHandler:(PkgAppChooseResponseBlock)handler {
    [self openFinder:canChooseFiles chooseDirectories:canChooseDirectories canCreateDirectories:NO allowedFileTypes:fileTypes completionHandler:handler];
}

- (void)openFinder:(BOOL)canChooseFiles chooseDirectories:(BOOL)canChooseDirectories canCreateDirectories:(BOOL)canCreateDirectories allowedFileTypes:(NSArray<NSString *> *)fileTypes completionHandler:(PkgAppChooseResponseBlock)handler {
    NSOpenPanel *openDlg = [[NSOpenPanel alloc] init];
    [openDlg setCanChooseFiles:canChooseFiles];
    [openDlg setCanChooseDirectories:canChooseDirectories];
    [openDlg setCanCreateDirectories:canCreateDirectories];
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg setAllowsOtherFileTypes:NO];
    [openDlg setAllowedFileTypes:fileTypes];
    
    if ([openDlg runModal] == NSModalResponseOK) {
        !handler ?: handler([[[openDlg URLs] objectAtIndex:0] path]);
    }
}

+ (NSAlert *)showAlert:(NSWindow *)window style:(NSAlertStyle)style title:(NSString *)title message:(NSString *)message buttonTitles:(NSArray *)buttonTitles completionHandler:(void (^)(NSInteger))handler {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setAlertStyle:style];
    [alert setMessageText:title];
    [alert setInformativeText:message];
    
    for (NSString *buttonTitle in buttonTitles) {
        [alert addButtonWithTitle:buttonTitle];
    }
    
    if (window) {
        [alert beginSheetModalForWindow:window completionHandler:^(NSModalResponse returnCode) {
            if (handler) {
                handler(returnCode);
            }
        }];
    } else {
        NSInteger returnCode = [alert runModal];
        if (handler) {
            handler(returnCode);
        }
    }
    
    return alert;
}

- (void)getCertsWithCompletionHandler:(PkgAppGetCertsResponseBlock)handler {
    self.getCertsHandler = handler;
    
    NSTask *certTask = [[NSTask alloc] init];
    [certTask setLaunchPath:@"/usr/bin/security"];
    [certTask setArguments:@[@"find-identity", @"-v", @"-p", @"codesigning"]];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkCerts:) userInfo:certTask repeats:YES];
    
    NSPipe *pipe = [NSPipe pipe];
    [certTask setStandardOutput:pipe];
    [certTask setStandardError:pipe];
    NSFileHandle *fileHandle = [pipe fileHandleForReading];
    
    [certTask launch];
    
    [NSThread detachNewThreadSelector:@selector(watchGetCerts:) toTarget:self withObject:fileHandle];
}

- (void)checkCerts:(NSTimer *)timer {
    NSTask *certTask = (NSTask *)timer.userInfo;
    if ([certTask isRunning] == 0) {
        [timer invalidate];
        timer = nil;
    }
}

- (void)watchGetCerts:(NSFileHandle *)streamHandle {
    @autoreleasepool {
        NSData *data = [streamHandle readDataToEndOfFile];
        NSString *secResult = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        if (!secResult || secResult.length < 1) {
            return;
        }
        
        NSArray *rawResult = [secResult componentsSeparatedByString:@"\""];
        NSMutableArray *tmpCertsResult = [NSMutableArray arrayWithCapacity:0];
        for (int i = 0; i <= [rawResult count] - 2; i += 2) {
            if (rawResult.count - 1 < i + 1) {
                // Invalid array, don't add an object to that position
            } else {
                [tmpCertsResult addObject:[rawResult objectAtIndex:i+1]];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            !self.getCertsHandler ?: self.getCertsHandler(tmpCertsResult);
        });
    }
}

+ (void)localStore:(id)value forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)localRead:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (void)setTextColorForButton:(NSButton *)button color:(NSColor *)color {
    @autoreleasepool {
        NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[button attributedTitle]];
        NSUInteger len = [attrTitle length];
        NSRange range = NSMakeRange(0, len);
        [attrTitle addAttribute:NSForegroundColorAttributeName value:color range:range];
        [attrTitle fixAttributesInRange:range];
        [button setAttributedTitle:attrTitle];
        [button setNeedsDisplay:YES];
    }
}

@end
