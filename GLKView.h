//
//  GLKView.h
//  glkit-cocoa
//
//  Created by Aguilar, Juan Carlos on 4/22/14.
//  Copyright (c) 2014 Aguilar, Juan Carlos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "glkit.h"

@interface GLKView : NSView
{
    GLKWindow* window;
    NSTrackingArea* trackingArea;
}

- (id)initWithGLKWindow:(GLKWindow*)initWindow;

@end
