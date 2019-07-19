//
//  PermissionViewController.m
//
//  Created by dyf on 16/6/3.
//  Copyright © 2016 dyf. All rights reserved.
//

#import "PermissionViewController.h"
#import "PrepackageViewController.h"
#import "PkgAppUtils.h"
#import "PkgAppConstants.h"

@interface PermissionViewController ()
@property (weak) IBOutlet NSTextField       *umTextField;
@property (weak) IBOutlet NSSecureTextField *pwdTextField;
@property (weak) IBOutlet NSButton          *remPwdButton;
@property (weak) IBOutlet NSButton          *reqAccButton;
@property (weak) IBOutlet NSTextField       *versionCodeLabel;

@property (strong) NSProgressIndicator      *indicator;

@end

@implementation PermissionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setValueForTextField];
    [self setValueForVersionCodeLabel];
    [self setTextColorForButton];
    [self readRemPwdButtonState];
}

- (void)setValueForVersionCodeLabel {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *v            = infoDict[@"CFBundleShortVersionString"];
    NSString *buildV       = infoDict[@"CFBundleVersion"];
    NSString *vCode        = [NSString stringWithFormat:@"%@ (%@)", v, buildV];
    [self.versionCodeLabel setStringValue:vCode];
}

- (void)setValueForTextField {
    NSData *accData = [PkgAppUtils localRead:pkgAccKey];
    if (accData) {
        NSString *acc = [[NSString alloc] initWithData:accData encoding:NSUTF8StringEncoding];
        self.umTextField.stringValue = acc;
    } else {
        self.umTextField.stringValue = @"Admin";
    }
    
    NSData *pwdData = [PkgAppUtils localRead:pkgPwdKey];
    if (pwdData) {
        NSString *pwd = [[NSString alloc] initWithData:pwdData encoding:NSUTF8StringEncoding];
        self.pwdTextField.stringValue = pwd;
    } else {
        self.pwdTextField.stringValue = @"Admin";
    }
}

- (void)setTextColorForButton {
    [PkgAppUtils setTextColorForButton:_remPwdButton color:[NSColor whiteColor]];
    [PkgAppUtils setTextColorForButton:_reqAccButton color:[NSColor whiteColor]];
}

- (void)readRemPwdButtonState {
    self.remPwdButton.state = [[PkgAppUtils localRead:remPwdStateKey] integerValue];
}

- (void)showIndicator {
    if (!_indicator) {
        CGFloat width    = 100;
        CGFloat height   = 100;
        CGFloat x        = (self.view.frame.size.width  - width )/2;
        CGFloat y        = (self.view.frame.size.height - height)/2;
        
        _indicator       = [[NSProgressIndicator alloc] init];
        _indicator.frame = CGRectMake(x, y, width, height);
        _indicator.style = NSProgressIndicatorSpinningStyle;
        
        [_indicator startAnimation:nil];
        [self.view addSubview:_indicator];
        
        [self performSeletorAfterDelay:1.2];
    }
}

- (void)performSeletorAfterDelay:(double)timeInterval {
    [self performSelector:@selector(loginCallback)
               withObject:nil
               afterDelay:timeInterval];
}

- (void)loginCallback {
    PrepackageViewController *prepkgVc = [[PrepackageViewController alloc] init];
    
    [self.parentViewController addChildViewController:prepkgVc];
    [self.view.superview addSubview:prepkgVc.view];
    
    [self remove];
}

- (void)remove {
    if (_indicator) {
        [_indicator stopAnimation:nil];
        [_indicator removeFromSuperview];
        _indicator = nil;
    }
    
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}

- (IBAction)minimizeAction:(id)sender {
    [self hideApp:sender];
}

- (IBAction)closeAction:(id)sender {
    [self terminateApp:sender];
}

- (IBAction)loginAction:(id)sender {
    [self showIndicator];
}

- (IBAction)remPwdAction:(id)sender {
    NSInteger state = self.remPwdButton.state;
    
    [PkgAppUtils localStore:[NSNumber numberWithInteger:state] forKey:remPwdStateKey];
    
    if (state) {
        
        if (self.umTextField.stringValue.length > 0) {
            NSData *accData = [self.umTextField.stringValue dataUsingEncoding:NSUTF8StringEncoding];
            [PkgAppUtils localStore:accData forKey:pkgAccKey];
        }
        
        if (self.pwdTextField.stringValue.length > 0) {
            NSData *pwdData = [self.pwdTextField.stringValue dataUsingEncoding:NSUTF8StringEncoding];
            [PkgAppUtils localStore:pwdData forKey:pkgPwdKey];
        }
        
    }
}

- (IBAction)reqAccAction:(id)sender {
    NSString *url = [NSString stringWithFormat:@"https://www.baidu.com"];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

@end
