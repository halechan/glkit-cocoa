//
//  
//

#import "GLKCocoaWindow.h"

@implementation GLKCocoaWindow
- (BOOL)canBecomeKeyWindow {
    // Required for NSBorderlessWindowMask windows
    return YES;
}

@end
