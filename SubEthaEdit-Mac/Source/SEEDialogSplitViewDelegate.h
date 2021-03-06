//  SEEDialogSplitViewDelegate.h
//  SubEthaEdit
//
//  Created by Michael Ehrmann on 18.03.14.

#import <Cocoa/Cocoa.h>

#define SPLITMINHEIGHTDIALOG 130.0

@class PlainTextWindowControllerTabContext;

@interface SEEDialogSplitViewDelegate : NSObject <NSSplitViewDelegate>
- (instancetype)initWithTabContext:(PlainTextWindowControllerTabContext *)tabContext;
@end
