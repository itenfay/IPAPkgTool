//
//  ViewController.m
//
//  Created by dyf on 16/5/31.
//  Copyright © 2016 dyf. All rights reserved.
//

#import "ViewController.h"
#import "PermissionViewController.h"
#import "PkgAppNetworking.h"

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[self loadingPermissionView];
}

- (void)loadingPermissionView {
	PermissionViewController *pvc = [[PermissionViewController alloc] init];
	[self addChildViewController:pvc];
	[self.view addSubview:pvc.view];
}

- (void)setRepresentedObject:(id)representedObject {
	[super setRepresentedObject:representedObject];
	// Update the view, if already loaded.
}

@end
