//
//  PrepackageViewController.m
//
//  Created by dyf on 16/6/6.
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

#import "PrepackageViewController.h"
#import "PkgAppConstants.h"
#import "PkgAppUtils.h"
#import "PackageViewController.h"

@interface PrepackageViewController () <NSComboBoxDataSource, NSTextFieldDelegate>
@property (weak) IBOutlet NSTextField   *projPath_textField;
@property (weak) IBOutlet NSTextField   *outPath_textField;
@property (weak) IBOutlet NSTextField   *cfgFilePath_textField;
@property (weak) IBOutlet NSTextField   *sdksPath_textField;
@property (weak) IBOutlet NSTextField   *iconPath_textField;
@property (weak) IBOutlet NSTextField   *mobileprovison_textField;
@property (weak) IBOutlet NSPopUpButton *popUp_button;
@property (weak) IBOutlet NSComboBox    *certComboBox;

@property (strong) NSMutableArray       *certComboBoxItems;

@end

@implementation PrepackageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setDelegateForTextField];
    [self setDataSourceForCertComboBox];
    [self getCertItemsForComboBox];
    [self loadHistoricRecords];
}

- (void)loadHistoricRecords {
    NSString *projPath = [PkgAppUtils localRead:xcprojPathKey];
    if (projPath) {
        [self searchTargets:projPath];
        self.projPath_textField.stringValue = projPath;
    }
    
    NSString *optPath = [PkgAppUtils localRead:outputPathKey];
    if (optPath) {
        self.outPath_textField.stringValue = optPath;
    }
    
    NSString *cfgFilePath = [PkgAppUtils localRead:cfgFilePathKey];
    if (cfgFilePath) {
        self.cfgFilePath_textField.stringValue = cfgFilePath;
    }
    
    NSString *sdksDirPath = [PkgAppUtils localRead:sdksDirPathKey];
    if (sdksDirPath) {
        self.sdksPath_textField.stringValue = sdksDirPath;
    }
    
    NSString *iconDirPath = [PkgAppUtils localRead:iconDirPathKey];
    if (iconDirPath) {
        self.iconPath_textField.stringValue = iconDirPath;
    }
    
    NSString *mpPath = [PkgAppUtils localRead:mobileprovisionPathKey];
    if (mpPath) {
        self.mobileprovison_textField.stringValue = mpPath;
    }
    
    NSString *certPath = [PkgAppUtils localRead:certNameKey];
    if (certPath) {
        self.certComboBox.stringValue = certPath;
    }
}

- (void)setDelegateForTextField {
    self.projPath_textField.delegate = self;
}

- (void)setDataSourceForCertComboBox {
    self.certComboBox.usesDataSource = YES;
    self.certComboBox.dataSource     = self;
}

- (void)getCertItemsForComboBox {
    PkgAppUtils *utils = [[PkgAppUtils alloc] init];
    [utils getCertsWithCompletionHandler:^(NSMutableArray *certs) {
        self.certComboBoxItems = certs;
        [self.certComboBox reloadData];
        
        if (self.certComboBoxItems.count > 0) {
            [self.certComboBox setStringValue:[self.certComboBoxItems firstObject]];
            [PkgAppUtils localStore:self.certComboBox.stringValue forKey:certNameKey];
            [PkgAppUtils localStore:self.certComboBoxItems forKey:certNamesKey];
        }
    }];
}

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox {
    if ([self.certComboBox isEqual:aComboBox]) {
        return [self.certComboBoxItems count];
    }
    return 0;
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index {
    if ([self.certComboBox isEqual:aComboBox]) {
        return [self.certComboBoxItems objectAtIndex:index];
    }
    return nil;
}

- (void)mouseDown:(NSEvent *)theEvent {
    [self forceResignFirstResponder];
}

- (void)alertUser:(NSString *)title message:(NSString *)message {
    [PkgAppUtils showAlert:nil style:NSCriticalAlertStyle title:title message:message buttonTitles:@[@"好的"] completionHandler:nil];
}

- (BOOL)validateStringValueForTextField {
    BOOL result = self.projPath_textField.stringValue.length > 0 ? YES : NO;
    if (!result) {
        [self alertUser:@"提示" message:@"请选择本地项目xxx.xcodeproj文件"];
        return NO;
    }
    
    result = self.outPath_textField.stringValue.length > 0 ? YES : NO;
    if (!result) {
        [self alertUser:@"提示" message:@"请选择输出目录"];
        return NO;
    }
    
    result = self.cfgFilePath_textField.stringValue.length > 0 ? YES : NO;
    if (!result) {
        [self alertUser:@"提示" message:@"请选择本地配置文件"];
        return NO;
    }
    
    result = self.sdksPath_textField.stringValue.length > 0 ? YES : NO;
    if (!result) {
        [self alertUser:@"提示" message:@"请选择本地SDK资源目录"];
        return NO;
    }
    
    result = self.iconPath_textField.stringValue.length > 0 ? YES : NO;
    if (!result) {
        [self alertUser:@"提示" message:@"请选择本地ICON目录"];
        return NO;
    }
    
    result = self.mobileprovison_textField.stringValue.length > 0 ? YES : NO;
    if (!result) {
        [self alertUser:@"提示" message:@"请选择签名xxx.mobileprovison文件"];
        return NO;
    }
    
    return YES;
}

- (BOOL)fileExists {
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    NSString *projPath = self.projPath_textField.stringValue;
    if (![fileMgr fileExistsAtPath:projPath]) {
        [self alertUser:@"提示" message:@"本地项目xxx.xcodeproj不存在"];
        return NO;
    }
    
    NSString *outPath = self.outPath_textField.stringValue;
    if (![fileMgr fileExistsAtPath:outPath]) {
        [self alertUser:@"提示" message:@"输出目录不存在"];
        return NO;
    }
    
    NSString *cfgFilePath = self.cfgFilePath_textField.stringValue;
    if (![fileMgr fileExistsAtPath:cfgFilePath]) {
        [self alertUser:@"提示" message:@"本地配置文件不存在"];
        return NO;
    }
    
    NSString *sdksPath = self.sdksPath_textField.stringValue;
    if (![fileMgr fileExistsAtPath:sdksPath]) {
        [self alertUser:@"提示" message:@"本地SDK资源目录不存在"];
        return NO;
    }
    
    NSString *iconPath = self.iconPath_textField.stringValue;
    if (![fileMgr fileExistsAtPath:iconPath]) {
        [self alertUser:@"提示" message:@"本地ICON目录不存在"];
        return NO;
    }
    
    NSString *mobileprovisionPath = self.mobileprovison_textField.stringValue;
    if (![fileMgr fileExistsAtPath:mobileprovisionPath]) {
        [self alertUser:@"提示" message:@"本地xxx.mobileprovison文件不存在"];
        return NO;
    }
    
    return YES;
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
    if (control == self.projPath_textField) {
        if ([self.projPath_textField.stringValue isEqualToString:ConsStringEmpty]) {
            [self.popUp_button removeAllItems];
        }
    }
    return YES;
}

- (NSString *)titleOfPopUpBtnSelectedItem {
    return [self.popUp_button titleOfSelectedItem];
}

- (void)searchTargets:(NSString *)path {
    NSError *error = nil;
    
    NSArray *paths = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path error:&error];
    
    if (!error) {
        NSMutableArray *tmmpArray = [NSMutableArray arrayWithCapacity:0];
        
        for (NSString *item in paths) {
            
            if ([item hasSuffix:@"xcscheme"]) {
                NSString *subItem = [[item componentsSeparatedByString:@"/"] lastObject];
                NSString *target  = [[subItem componentsSeparatedByString:@"."] firstObject];
                if (![tmmpArray containsObject:target]) {
                    [tmmpArray addObject:target];
                }
            }
        }
        
        if (tmmpArray.count > 0) {
            [self.popUp_button removeAllItems];
            [self.popUp_button addItemsWithTitles:tmmpArray];
            [PkgAppUtils localStore:[self titleOfPopUpBtnSelectedItem] forKey:xcprojTargetKey];
        }
    }
}

- (NSViewController *)getPackageViewController {
    NSArray *viewControllers = [self parentViewController].childViewControllers;
    
    for (NSViewController *viewController in viewControllers) {
        if ([viewController isMemberOfClass:[PackageViewController class]]) {
            return viewController;
        }
    }
    
    return nil;
}

- (IBAction)minimizeAction:(id)sender {
    [self hideApp:sender];
}

- (IBAction)closeAction:(id)sender {
    [self terminateApp:sender];
}

- (IBAction)xcodeprojBrowse:(id)sender {
    PkgAppUtils *utils = [[PkgAppUtils alloc] init];
    [utils openFinder:YES chooseDirectories:NO allowedFileTypes:@[@"xcodeproj"] completionHandler:^(NSString *path) {
        if (path) {
            [self searchTargets:path];
            [self.projPath_textField setStringValue:path];
            [PkgAppUtils localStore:path forKey:xcprojPathKey];
        }
    }];
}

- (IBAction)outputBrowse:(id)sender {
    PkgAppUtils *utils = [[PkgAppUtils alloc] init];
    [utils openFinder:NO chooseDirectories:YES canCreateDirectories:YES allowedFileTypes:nil completionHandler:^(NSString *path) {
        if (path) {
            [self.outPath_textField setStringValue:path];
            [PkgAppUtils localStore:path forKey:outputPathKey];
        }
    }];
}

- (IBAction)pkgCfgBrowse:(id)sender {
    PkgAppUtils *utils = [[PkgAppUtils alloc] init];
    [utils openFinder:YES chooseDirectories:NO allowedFileTypes:@[@"plist", @"PLIST"] completionHandler:^(NSString *path) {
        if (path) {
            [self.cfgFilePath_textField setStringValue:path];
            [PkgAppUtils localStore:path forKey:cfgFilePathKey];
        }
    }];
}

- (IBAction)selectSdksBrowse:(id)sender {
    PkgAppUtils *utils = [[PkgAppUtils alloc] init];
    [utils openFinder:NO chooseDirectories:YES allowedFileTypes:nil completionHandler:^(NSString *path) {
        if (path) {
            [self.sdksPath_textField setStringValue:path];
            [PkgAppUtils localStore:path forKey:sdksDirPathKey];
        }
    }];
}

- (IBAction)popUpAction:(id)sender {
    NSString *target = [self titleOfPopUpBtnSelectedItem];
    if (target) {
        [PkgAppUtils localStore:target forKey:xcprojTargetKey];
    }
}

- (IBAction)selectIconBrowse:(id)sender {
    PkgAppUtils *utils = [[PkgAppUtils alloc] init];
    [utils openFinder:NO chooseDirectories:YES allowedFileTypes:nil completionHandler:^(NSString *path) {
        if (path) {
            [self.iconPath_textField setStringValue:path];
            [PkgAppUtils localStore:path forKey:iconDirPathKey];
        }
    }];
}

- (IBAction)provisioningBrowse:(id)sender {
    PkgAppUtils *utils = [[PkgAppUtils alloc] init];
    [utils openFinder:YES chooseDirectories:NO allowedFileTypes:@[@"mobileprovision", @"MOBILEPROVISION"] completionHandler:^(NSString *path) {
        if (path) {
            [self.mobileprovison_textField setStringValue:path];
            [PkgAppUtils localStore:path forKey:mobileprovisionPathKey];
        }
    }];
}

- (IBAction)certComboBoxAction:(id)sender {
    NSString *path = self.certComboBox.stringValue;
    if (path) {
        [PkgAppUtils localStore:path forKey:certNameKey];
    }
}

- (IBAction)nextStepAction:(id)sender {
    [self forceResignFirstResponder];
    
    if ([self validateStringValueForTextField] && [self fileExists]) {
        NSViewController *pkgViewController = [self getPackageViewController];
        
        if (pkgViewController) {
            [pkgViewController.view setHidden:NO];
            [(PackageViewController *)pkgViewController updateDataSource];
            
        } else {
            PackageViewController *pkgVC = [[PackageViewController alloc] init];
            [self.parentViewController addChildViewController:pkgVC];
            [self.view.superview addSubview:pkgVC.view];
        }
    }
}

@end
