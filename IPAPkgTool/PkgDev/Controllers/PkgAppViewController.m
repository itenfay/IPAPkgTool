//
//  PkgAppViewController.m
//
//  Created by dyf on 16/6/6.
//  Copyright © 2016 dyf. All rights reserved.
//

#import "PkgAppViewController.h"

@interface PkgAppViewController ()

@end

@implementation PkgAppViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)hideApp:(id)sender {
    [[NSApplication sharedApplication] hide:sender];
}

- (void)terminateApp:(id)sender {
    [[NSApplication sharedApplication] terminate:sender];
}

- (BOOL)forceResignFirstResponder {
    return [[NSApplication sharedApplication].keyWindow makeFirstResponder:nil];
}

- (NSWindow *)window {
    return self.view.window;
}

@end
