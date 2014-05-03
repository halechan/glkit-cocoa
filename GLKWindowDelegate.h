//
//  GLKWindowDelegate.h
//  glkit-cocoa
//
//  Created by Aguilar, Juan Carlos on 5/2/14.
//  Copyright (c) 2014 Aguilar, Juan Carlos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "glkit.h"

@interface GLKWindowDelegate : NSObject {
    GLKWindow* window;
}

- (id)initWithGLKWindow:(GLKWindow *)initWndow;

@end
