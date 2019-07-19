//
//  PkgInfoTableCell.h
//
//  Created by dyf on 16/6/7.
//  Copyright © 2016 dyf. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AYProgressIndicator.h"

@interface PkgInfoTableCell : NSTableCellView
@property (weak) IBOutlet NSButton            *checkBoxButton;
@property (weak) IBOutlet NSTextField         *channelNameTextField;
@property (weak) IBOutlet NSTextField         *bundleIdTextField;
@property (weak) IBOutlet NSTextField         *displayNameTextField;
@property (weak) IBOutlet NSTextField         *mobileprovisionTextField;
@property (weak) IBOutlet NSButton            *selectFilePathButton;
@property (weak) IBOutlet NSPopUpButton       *certPopUpButton;
@property (weak) IBOutlet AYProgressIndicator *progressIndicator;
@end
