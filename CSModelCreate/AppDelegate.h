//
//  AppDelegate.h
//  CSModelCreate
//
//  Created by hanxing on 2017/3/21.
//  Copyright © 2017年 hanxing. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>


@property (assign) IBOutlet NSWindow *window;
- (IBAction)generate:(id)sender;
@property (weak) IBOutlet NSTextField *modelNameField;
@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSTextField *prefixField;

@end

