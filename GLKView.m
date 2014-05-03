//
//
//
//

#import <Foundation/Foundation.h>
#import "GLKView.h"
#import "glkit.h"

@implementation GLKView

+ (void)initialize {
    if (self == [GLKView class]) {
        //if (_glfw.ns.cursor == nil)
        //{
        //    NSImage* data = [[NSImage alloc] initWithSize:NSMakeSize(16, 16)];
        //    _glfw.ns.cursor = [[NSCursor alloc] initWithImage:data
        //                                              hotSpot:NSZeroPoint];
        //    [data release];
        //}
    }
}

- (id)initWithGLKWindow:(GLKWindow*)initWindow {
    self = [super init];
    if (self != nil) {
        window = initWindow;
        trackingArea = nil;
        
        [self updateTrackingAreas];
        [self registerForDraggedTypes:[NSArray arrayWithObjects:
                                       NSFilenamesPboardType, nil]];
    }
    
    return self;
}

-(void)dealloc {
    [trackingArea release];
    [super dealloc];
}

- (BOOL)isOpaque {
    return YES;
}

- (BOOL)canBecomeKeyView {
    return YES;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

@end
