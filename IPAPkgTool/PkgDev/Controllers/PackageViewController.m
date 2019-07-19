//
//  PackageViewController.m
//
//  Created by dyf on 16/6/7.
//  Copyright © 2016 dyf. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "PackageViewController.h"
#import "PkgAppConstants.h"
#import "PkgAppUtils.h"
#import "PkgInfoModel.h"
#import "PkgInfoTableCell.h"
#import "PkgAppMacros.h"

typedef void (^ProgressAnimationFinishBlock)(BOOL finished);

static CGFloat kTableRowHeight = 120;

@interface PackageViewController () <NSTableViewDataSource, NSTableViewDelegate>
@property (weak) IBOutlet NSTableView *channelTableView;
@property (weak) IBOutlet NSButton    *selectAllButton;
@property (weak) IBOutlet NSButton    *backButton;
@property (weak) IBOutlet NSButton    *pkgButton;

@property (assign) NSInteger          count;
@property (strong) NSMutableArray     *dataArray;

@end

@implementation PackageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setCount:0];
    [self setTableProperties];
    [self getTableDataSource];
    [self setSelectAllButtonTextColor];
}

- (void)mouseDown:(NSEvent *)theEvent {
    [self forceResignFirstResponder];
}

- (void)pkgStart {
    self.backButton.enabled      = NO;
    self.pkgButton.enabled       = NO;
    self.selectAllButton.enabled = NO;
}

- (void)pkgEnd {
    self.backButton.enabled      = YES;
    self.pkgButton.enabled       = YES;
    self.selectAllButton.enabled = YES;
}

- (void)setSelectAllButtonTextColor {
    [PkgAppUtils setTextColorForButton:_selectAllButton color:[NSColor whiteColor]];
}

- (void)setTableProperties {
    _channelTableView.backgroundColor = [NSColor clearColor];
    _channelTableView.delegate        = self;
    _channelTableView.dataSource      = self;
    _channelTableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;
}

- (NSArray *)channelConfigLists {
    NSString *path     = [PkgAppUtils localRead:cfgFilePathKey];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    return dict[@"XC_CHANNELS"];
}

- (void)getTableDataSource {
    _dataArray        = [NSMutableArray arrayWithCapacity:0];
    NSArray *channels = [self channelConfigLists];
    
    for (NSDictionary *dic in channels) {
        PkgInfoModel *model       = [[PkgInfoModel alloc] init];
        model.checkBoxState       = 0;
        model.channelIdentifier   = dic[@"XC_CHANNEL_NAME"];
        model.bundleIdentifier    = dic[@"XC_INFOPLIST_ARGS"][@"BundleId"];
        model.mobileprovisionPath = [PkgAppUtils localRead:mobileprovisionPathKey];
        model.certName            = [PkgAppUtils localRead:certNameKey];
        [_dataArray addObject:model];
    }
    
    [_channelTableView reloadData];
}

- (void)updateDataSource {
    [_dataArray removeAllObjects];
    
    NSArray *channels = [self channelConfigLists];
    for (NSInteger index = 0; index < channels.count; index++) {
        NSDictionary *dic          = channels[index];
        
        PkgInfoModel *model        = [[PkgInfoModel alloc] init];
        model.checkBoxState        = 0;
        
        PkgInfoTableCell *cellView = [self cellViewAtRow:index];
        if (cellView) {
            model.checkBoxState    = cellView.checkBoxButton.state;
        }
        
        model.channelIdentifier    = dic[@"XC_CHANNEL_NAME"];
        model.bundleIdentifier     = dic[@"XC_INFOPLIST_ARGS"][@"BundleId"];
        model.mobileprovisionPath  = [PkgAppUtils localRead:mobileprovisionPathKey];
        model.certName             = [PkgAppUtils localRead:certNameKey];
        
        [_dataArray addObject:model];
    }
    
    [_channelTableView reloadData];
}

- (PkgInfoTableCell *)cellViewAtRow:(NSInteger)row {
    return [_channelTableView viewAtColumn:0 row:row makeIfNecessary:NO];
}

- (NSInteger)rowForCellView:(PkgInfoTableCell *)cellView {
    return [_channelTableView rowForView:cellView];
}

- (PkgInfoModel *)modelForRow:(NSInteger)row {
    return (PkgInfoModel *)[_dataArray objectAtIndex:row];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _dataArray.count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return kTableRowHeight;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    PkgInfoModel *model        = [self modelForRow:row];
    
    PkgInfoTableCell *cellView = [tableView makeViewWithIdentifier:@"PkgInfoTableCell" owner:self];
    
    cellView.checkBoxButton.state  = model.checkBoxState;
    cellView.checkBoxButton.target = self;
    cellView.checkBoxButton.action = @selector(checkBoxAtCellViewAction:);
    
    cellView.channelNameTextField.stringValue     = model.channelIdentifier;
    cellView.bundleIdTextField.stringValue        = model.bundleIdentifier;
    cellView.mobileprovisionTextField.stringValue = model.mobileprovisionPath;
    
    cellView.selectFilePathButton.tag    = row;
    cellView.selectFilePathButton.target = self;
    cellView.selectFilePathButton.action = @selector(selectMobileprovisionAction:);
    [PkgAppUtils setTextColorForButton:cellView.selectFilePathButton color:[NSColor whiteColor]];
    
    NSArray *certNames         = [PkgAppUtils localRead:certNamesKey];
    NSMutableArray *itemTitles = [NSMutableArray arrayWithArray:certNames];
    for (NSString *certName in certNames) {
        if ([certName isEqualToString:model.certName]) {
            [itemTitles removeObject:certName];
            [itemTitles insertObject:certName atIndex:0];
        }
    }
    [cellView.certPopUpButton addItemsWithTitles:itemTitles];
    
    cellView.progressIndicator.maxValue      = 1.0;
    cellView.progressIndicator.doubleValue   = 0;
    cellView.progressIndicator.emptyColor    = [NSColor grayColor];
    cellView.progressIndicator.progressColor = [NSColor greenColor];
    
    return cellView;
}

- (void)checkBoxAtCellViewAction:(NSButton *)button {
    self.selectAllButton.state = [self isSelectAllForCellView];
}

- (void)selectMobileprovisionAction:(NSButton *)button {
    PkgAppUtils *utils = [[PkgAppUtils alloc] init];
    [utils openFinder:YES chooseDirectories:NO allowedFileTypes:@[@"mobileprovision", @"MOBILEPROVISION"] completionHandler:^(NSString *path) {
        if (path) {
            NSInteger row              = button.tag;
            PkgInfoTableCell *cellView = [self cellViewAtRow:row];
            
            if (cellView) {
                cellView.mobileprovisionTextField.stringValue = path;
            }
        }
    }];
}

- (NSInteger)isSelectAllForCellView {
    NSInteger rows = _dataArray.count;
    for (NSInteger row = 0; row < rows; row++) {
        PkgInfoTableCell *cellView = [self cellViewAtRow:row];
        if (!cellView.checkBoxButton.state) {
            return 0;
        }
    }
    return 1;
}

- (BOOL)isLessThanRows:(NSInteger)row {
    return row < _dataArray.count;
}

- (BOOL)isLastSelectedRow:(NSInteger)row {
    NSInteger rows = _dataArray.count;
    if (row < rows) {
        for (NSInteger i = row + 1; i < rows; i++) {
            PkgInfoTableCell *cellView = [self cellViewAtRow:i];
            if (cellView && cellView.checkBoxButton.state) {
                return NO;
            }
        }
    }
    return YES;
}

- (NSInteger)indexOfArray:(NSArray *)array forChannleName:(NSString *)channelName {
    for (NSInteger idx = 0; idx < array.count; idx++) {
        NSDictionary *dict = [array objectAtIndex:idx];
        NSString *name = [dict objectForKey:@"XC_CHANNEL_NAME"];
        if ([name isEqualToString:channelName]) {
            return idx;
        }
    }
    return 0;
}

- (NSString *)getVectorDirectoryPath {
    return [[NSBundle mainBundle] pathForResource:VectorDirname ofType:nil];
}

- (NSString *)getBinDirectoryPath {
    return [[self getVectorDirectoryPath] stringByAppendingString:PkgCmdLocDirpath];
}

- (NSString *)getTaskLaunchPath {
    NSString *vectorDirPath = [self getVectorDirectoryPath];
    NSString *binDirPath    = [vectorDirPath stringByAppendingString:PkgCmdLocDirpath];
    return [binDirPath stringByAppendingPathComponent:PkgCmdName];
}

- (NSString *)getInitSdkArgs:(NSArray *)array {
    NSString *args = ConsStringEmpty;
    
    for (NSInteger i = 0; i < array.count; i++) {
        NSString *item = [array objectAtIndex:i];
        if (i == 0) {
            args = item;
        } else {
            args = [args stringByAppendingFormat:@"|%@", item];
        }
    }
    
    return args;
}

- (NSString *)getSysDylibs:(NSArray *)array {
    NSString *args = ConsStringEmpty;
    
    for (NSInteger i = 0; i < array.count; i++) {
        NSString *item = [array objectAtIndex:i];
        if (i == 0) {
            args = item;
        } else {
            args = [args stringByAppendingFormat:@" %@", item];
        }
    }
    
    return args;
}

- (NSString *)getSysFrameworks:(NSArray *)array {
    NSString *args = ConsStringEmpty;
    
    for (NSInteger i = 0; i < array.count; i++) {
        NSString *item = [array objectAtIndex:i];
        if (i == 0) {
            args = item;
        } else {
            args = [args stringByAppendingFormat:@" %@", item];
        }
    }
    
    return args;
}

- (NSString *)getInfoPlistArgs:(NSDictionary *)dict bundleId:(NSString *)bundleId displayName:(NSString *)displayName {
    NSString *args = ConsStringEmpty;
    args = [args stringByAppendingFormat:@"BundleDisplayName=%@", displayName];
    
    for (NSInteger i = 0; i < dict.count; i++) {
        NSString *key   = dict.allKeys[i];
        NSString *value = [dict valueForKey:key];
        if ([key isEqualToString:@"BundleId"]) {
            args = [args stringByAppendingFormat:@"|%@=%@", key, bundleId];
        } else {
            args = [args stringByAppendingFormat:@"|%@=%@", key, value];
        }
    }
    
    return args;
}

- (void)invalidateTimer:(NSTimer *)timer {
    [timer invalidate];
    timer = nil;
}

- (BOOL)lessThanSetValue:(AYProgressIndicator *)indicator {
    return indicator.doubleValue < 0.8;
}

- (void)progressIncreaseAnimation:(AYProgressIndicator *)indicator completion:(ProgressAnimationFinishBlock)completion {
    if (indicator) {
        CGFloat progress = [self lessThanSetValue:indicator] ? 0.1 : 0.02;
        NSDictionary *userInfo = @{@"Indicator": indicator,
                                   @"Value"    : @(progress),
                                   @"Block"    : [completion copy]};
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(progressTransitionAnimation:) userInfo:userInfo repeats:YES];
    }
}

- (void)progressReduceAnimation:(AYProgressIndicator *)indicator completion:(ProgressAnimationFinishBlock)completion {
    if (indicator) {
        NSDictionary *userInfo = @{@"Indicator": indicator,
                                   @"Value"    : @(0.2),
                                   @"Block"    : [completion copy]};
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(progressTransitionAnimation:) userInfo:userInfo repeats:YES];
    }
}

- (void)progressTransitionAnimation:(NSTimer *)timer {
    NSDictionary *userInfo         = (NSDictionary *)timer.userInfo;
    AYProgressIndicator *indicator = [userInfo objectForKey:@"Indicator"];
    CGFloat value                  = [[userInfo objectForKey:@"Value"] doubleValue];
    
    indicator.doubleValue         += value;
    if (indicator.doubleValue == 1.0 || indicator.doubleValue == 0.0) {
        ProgressAnimationFinishBlock block = [userInfo objectForKey:@"Block"];
        block(YES);
        [self invalidateTimer:timer];
    }
}

- (void)updateProgress:(AYProgressIndicator *)indicator {
    if (indicator && indicator.doubleValue <= 0.92) {
        indicator.doubleValue += 0.002;
    }
}

- (void)checkTask:(NSTimer *)timer {
    NSDictionary *dict         = (NSDictionary *)timer.userInfo;
    NSTask *task               = [dict objectForKey:@"Task"];
    NSInteger row              = [[dict objectForKey:@"Row"] integerValue];
    
    PkgInfoTableCell *cellView = [self cellViewAtRow:row];
    [self updateProgress:cellView.progressIndicator];
    
    if (![task isRunning]) {
        [self invalidateTimer:timer];
        
        [self progressIncreaseAnimation:cellView.progressIndicator completion:^(BOOL finished) {
            
            if (finished) {
                [self pkgControl:_count++];
            }
            
        }];
    }
}

- (NSMutableDictionary *)dictionaryWithDict:(NSDictionary *)dict {
    return [NSMutableDictionary dictionaryWithDictionary:dict];
}

- (void)updateEnvironmentForTask:(NSTask *)task {
    NSMutableDictionary *env = [self dictionaryWithDict:task.environment];
    [env removeObjectForKey:MallocNanoZoneKey];
    [task setEnvironment:env];
}

- (void)scheduledTimerForChecking:(NSTask *)task row:(NSInteger)row {
    NSDictionary *dict = @{@"Task": task, @"Row": @(row)};
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkTask:) userInfo:dict repeats:YES];
}

- (void)writeToFile:(NSString *)filename errorLog:(NSData *)errorLog {
    NSString *dirpath  = [PkgAppUtils localRead:outputPathKey];
    NSString *filepath = [dirpath stringByAppendingPathComponent:filename];
    PKGLog(@"filepath: %@", filepath);
    [errorLog writeToFile:filepath atomically:YES];
}

- (BOOL)checkError:(NSString *)string {
    NSRange range = [string rangeOfString:@"** BUILD FAILED **"];
    return range.location != NSNotFound;
}

- (NSString *)findOutChannelName:(NSString *)string {
    NSRange r1              = [string rangeOfString:@"xcproj_cflags"];
    NSRange r2              = [string rangeOfString:@"xcproj_dstpath"];
    NSRange newR            = NSMakeRange(r1.location + r1.length + 1,
                                          r2.location - (r1.location + r1.length + 1));
    NSString *substr        = [string substringWithRange:newR];
    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@": \n"];
    return [substr stringByTrimmingCharactersInSet:charSet];
}

- (void)fileHandleReadCompleted:(NSNotification *)noti {
    NSData *data       = [[noti userInfo] objectForKey:NSFileHandleNotificationDataItem];
    NSString *contents = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if ([self checkError:contents]) {
        PKGLog(@"ErrorLog: %@", contents);
        NSString *channelName = [self findOutChannelName:contents];
        NSString *filename    = [channelName stringByAppendingString:@"_errorlog.txt"];
        [self writeToFile:filename errorLog:data];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadToEndOfFileCompletionNotification object:[noti object]];
}

- (void)fileHandleReadObserver:(NSPipe *)pipe {
    NSFileHandle *fileHandle = [pipe fileHandleForReading];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileHandleReadCompleted:) name:NSFileHandleReadToEndOfFileCompletionNotification object:fileHandle];
    [fileHandle readToEndOfFileInBackgroundAndNotify];
}

- (void)launch:(NSString *)launchPath arguments:(NSArray *)args row:(NSInteger)row {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:launchPath];
    [task setArguments:args];
    
    [self updateEnvironmentForTask:task];
    [self scheduledTimerForChecking:task row:row];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    [task setStandardError:pipe];
    [self fileHandleReadObserver:pipe];
    
    [task launch];
}

- (void)prelaunch:(PkgInfoTableCell *)cellView {
    NSString *xcprojPath          = [PkgAppUtils localRead:xcprojPathKey];
    NSString *target	          = [PkgAppUtils localRead:xcprojTargetKey];
    NSString *outputPath          = [PkgAppUtils localRead:outputPathKey];
    NSString *cfgFilePath         = [PkgAppUtils localRead:cfgFilePathKey];
    NSString *sdksDirPath         = [PkgAppUtils localRead:sdksDirPathKey];
    NSString *iconDirPath         = [PkgAppUtils localRead:iconDirPathKey];
    
    NSString *channelName         = cellView.channelNameTextField.stringValue;
    NSString *bundleId            = cellView.bundleIdTextField.stringValue;
    NSString *certName            = cellView.certPopUpButton.titleOfSelectedItem;
    NSString *mobileProvisionPath = cellView.mobileprovisionTextField.stringValue;
    NSString *displayName         = cellView.displayNameTextField.stringValue;
    
    NSArray *lists                = [self channelConfigLists];
    NSInteger index               = [self indexOfArray:lists forChannleName:channelName];
    NSString *archs               = lists[index][@"XC_ARCHS"];
    NSString *minDeployment       = lists[index][@"XC_MIN_DEPLOYMENT"];
    
    NSString *initSdkArgs         = [self getInitSdkArgs:lists[index][@"XC_INITSDK_ARGS"]];
    NSString *sysDylibArgs        = [self getSysDylibs:lists[index][@"XC_SYS_DYLIBS"]];
    NSString *sysFrameworkArgs    = [self getSysFrameworks:lists[index][@"XC_SYS_FRAMEWORK"]];
    NSString *infoPlistArgs       = [self getInfoPlistArgs:lists[index][@"XC_INFOPLIST_ARGS"] bundleId:bundleId displayName:displayName];
    
    NSMutableArray *argContainer = [NSMutableArray arrayWithCapacity:0];
    [argContainer addObject:xcprojPath];
    [argContainer addObject:target];
    [argContainer addObject:outputPath];
    [argContainer addObject:cfgFilePath];
    [argContainer addObject:sdksDirPath];
    [argContainer addObject:iconDirPath];
    [argContainer addObject:channelName];
    [argContainer addObject:archs];
    [argContainer addObject:minDeployment];
    [argContainer addObject:certName];
    [argContainer addObject:mobileProvisionPath];
    [argContainer addObject:initSdkArgs];
    [argContainer addObject:sysDylibArgs];
    [argContainer addObject:sysFrameworkArgs];
    [argContainer addObject:infoPlistArgs];
    
    [argContainer addObject:[self getBinDirectoryPath]];
    
    NSInteger row = [self rowForCellView:cellView];
    if ([self isLastSelectedRow:row]) {
        [argContainer addObject:@"y"];
    } else {
        [argContainer addObject:@"n"];
    }
    
    //PKGLog(@"Arg Container: %@", argContainer);
    
    [self launch:[self getTaskLaunchPath] arguments:[argContainer copy] row:row];
}

- (void)pkgControl:(NSInteger)row {
    if ([self isLessThanRows:row]) {
        
        PkgInfoTableCell *cellView = [self cellViewAtRow:row];
        
        if (cellView && cellView.checkBoxButton.state) {
            [self prelaunch:cellView];
        } else {
            [self pkgControl:_count++];
        }
        
    } else {
        
        [self pkgEnd];
        [self setCount:0];
        [self popUpAlert];
    }
}

- (void)popUpAlert {
    [PkgAppUtils showAlert:nil style:NSInformationalAlertStyle title:@"提示" message:@"全部完成" buttonTitles:@[@"前往查看", @"知道了"] completionHandler:^(NSInteger returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            [[NSWorkspace sharedWorkspace] openFile:[PkgAppUtils localRead:outputPathKey]];
        }
        [self restoreRawValueForCellView];
    }];
}

- (void)restoreRawValueForCellView {
    NSInteger count = _dataArray.count;
    for (NSInteger idx = 0; idx < count; idx++) {
        PkgInfoTableCell *cellView = [self cellViewAtRow:idx];
        if (cellView) {
            cellView.checkBoxButton.state = 0;
            cellView.progressIndicator.doubleValue = 0;
        }
    }
}

- (IBAction)minimizeAction:(id)sender {
    [self hideApp:sender];
}

- (IBAction)closeAction:(id)sender {
    [self hideApp:sender];
}

- (IBAction)backAction:(id)sender {
    [self forceResignFirstResponder];
    [self.view setHidden:YES];
}

- (IBAction)selectAllAction:(id)sender {
    NSInteger state = self.selectAllButton.state;
    NSInteger rows  = _dataArray.count;
    for (NSInteger row = 0; row < rows; row++) {
        PkgInfoTableCell *cellView = [self cellViewAtRow:row];
        if (cellView) {
            cellView.checkBoxButton.state = state;
        }
    }
}

- (IBAction)runPkg:(id)sender {
    [self forceResignFirstResponder];
    [self pkgStart];
    [self pkgControl:_count++];
}

@end
