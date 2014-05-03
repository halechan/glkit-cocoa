//
//  GLKApplication.m
//  glkit-cocoa
//
//  Created by Aguilar, Juan Carlos on 5/2/14.
//  Copyright (c) 2014 Aguilar, Juan Carlos. All rights reserved.
//

#import "GLKApplication.h"

@implementation GLKApplication
// From http://cocoadev.com/index.pl?GameKeyboardHandlingAlmost
// This works around an AppKit bug, where key up events while holding
// down the command key don't get sent to the key window.
- (void)sendEvent:(NSEvent *)event {
    if ([event type] == NSKeyUp && ([event modifierFlags] & NSCommandKeyMask))
        [[self keyWindow] sendEvent:event];
    else
        [super sendEvent:event];
}

@end
