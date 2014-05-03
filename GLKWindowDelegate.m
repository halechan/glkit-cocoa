//
//  GLKWindowDelegate.m
//  glkit-cocoa
//
//  Created by Aguilar, Juan Carlos on 5/2/14.
//  Copyright (c) 2014 Aguilar, Juan Carlos. All rights reserved.
//

#import "GLKWindowDelegate.h"
#import "glkit.h"

@implementation GLKWindowDelegate

- (id)initWithGLKWindow:(GLKWindow *)initWindow {
    self = [super init];
    if (self != nil)
        window = initWindow;
    
    return self;
}

- (BOOL)windowShouldClose:(id)sender {
    inputWindowCloseRequest(window);
    return NO;
}

- (void)windowDidResize:(NSNotification *)notification {
    [window->context update];
    
    //const NSRect contentRect = [window->view frame];
    //const NSRect fbRect = convertRectToBacking(window, contentRect);
    
    //inputFramebufferSize(window, fbRect.size.width, fbRect.size.height);
    //inputWindowSize(window, contentRect.size.width, contentRect.size.height);
    //inputWindowDamage(window);
    
    //if (window->cursorMode == GLFW_CURSOR_DISABLED) {
    //    centerCursor(window);
    //}
}

- (void)windowDidMove:(NSNotification *)notification {
    [window->context update];
    
    //int x, y;
    //getWindowPos(window, &x, &y);
    //inputWindowPos(window, x, y);
    
    //if (window->cursorMode == GLFW_CURSOR_DISABLED) {
    //    centerCursor(window);
    //}
}

- (void)windowDidMiniaturize:(NSNotification *)notification {
    //inputWindowIconify(window, TRUE);
}

- (void)windowDidDeminiaturize:(NSNotification *)notification {
    //if (window->monitor) {
    //    enterFullscreenMode(window);
    //}
    
    //inputWindowIconify(window, FALSE);
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
    //inputWindowFocus(window, TRUE);
    //applyCursorMode(window);
}

- (void)windowDidResignKey:(NSNotification *)notification {
    //inputWindowFocus(window, FALSE);
    //window->cursorMode = GLFW_CURSOR_NORMAL;
    //applyCursorMode(window);
}


@end
