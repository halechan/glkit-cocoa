//
//
//

#import "GLKApplicationDelegate.h"
#import "glkit.h"

@implementation GLKApplicationDelegate

/*
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    GLKWindow* window;
    
    for (window = _glk.windowListHead;  window;  window = window->next) {
        inputWindowCloseRequest(window);
    }
    
    return NSTerminateCancel;
}

- (void)applicationDidHide:(NSNotification *)notification {
    GLKWindow* window;
    
    for (window = _glk.windowListHead;  window;  window = window->next) {
        inputWindowVisibility(window, FALSE);
    }
}

- (void)applicationDidUnhide:(NSNotification *)notification {
    GLKWindow* window;
    
    for (window = _glk.windowListHead;  window;  window = window->next) {
        if ([window->object isVisible]) {
            inputWindowVisibility(window, TRUE);
        }
    }
}

- (void)applicationDidChangeScreenParameters:(NSNotification *) notification {
    inputMonitorChange();
}
*/
@end
