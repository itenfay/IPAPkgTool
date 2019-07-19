//
//  PkgInfoTableCell.m
//
//  Created by dyf on 16/6/7.
//  Copyright © 2016 dyf. All rights reserved.
//

#import "PkgInfoTableCell.h"

@interface PkgInfoTableCell ()
@property (strong) IBOutlet NSView *view;
@end

@implementation PkgInfoTableCell

- (instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		NSString *nibName = NSStringFromClass([self class]);
		if ([self loadNibNamed:nibName]) {
			[self setFrame:self.view.bounds];
			[self addSubview:self.view];
		}
	}
	return self;
}

- (BOOL)loadNibNamed:(NSString *)nibName {
	return [[NSBundle mainBundle] loadNibNamed:nibName owner:self topLevelObjects:nil];
}

- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	// Drawing code here.
}

@end
