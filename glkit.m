#import <Cocoa/Cocoa.h>
#import "GLKMenu.h"
#import "glkit.h"

GLKMenu* menu;
NSWindow* window;

int init() {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    
    ProcessSerialNumber psn;
    psn.highLongOfPSN = 0;
    psn.lowLongOfPSN = kCurrentProcess;
    TransformProcessType(&psn, kProcessTransformToForegroundApplication);
    
    NSApplicationLoad();
    [NSApplication sharedApplication];
    
    
    [NSApp activateIgnoringOtherApps:YES];
    
    menu = [[GLKMenu alloc] retain];
    
	[pool release];
    
	return 0;
    
}

void terminate() {
    [NSApp terminate:nil];
	[menu release];
    [window release];
}

NSOpenGLContext* createGLContext() {
    NSOpenGLPixelFormatAttribute pixelAttrs[] = {
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
        NSOpenGLPFAColorSize, 24,
        NSOpenGLPFAAlphaSize, 8,
        NSOpenGLPFADepthSize, 24,
        NSOpenGLPFAStencilSize, 8,
        NSOpenGLPFASampleBuffers, 0,
        0,
    };
    
    NSOpenGLPixelFormat* pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:pixelAttrs];
    assert(pixelFormat);
    
    NSOpenGLContext* glContext = [[NSOpenGLContext alloc]
                                  initWithFormat:pixelFormat
                                  shareContext:NULL];
    assert(glContext);
    
    return glContext;
}

GLKWindow createWindow(int width, int height) {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    window = [[[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, width, height)
                                          styleMask:( NSResizableWindowMask | NSClosableWindowMask | NSTitledWindowMask)
                                            backing:NSBackingStoreBuffered
                                              defer:NO]
              retain];
    
    NSOpenGLContext *glContext = createGLContext();
    [glContext setView:[window contentView]];
    
    NSScreen *screen = [window screen];
    NSRect screenSize = [screen visibleFrame];
    
    // Calculate the actual center
    CGFloat x = (screenSize.size.width - width) / 2;
    CGFloat y = (screenSize.size.height - height) / 2;
    
    NSRect newFrame = NSMakeRect(x, y, width, height);
    
    [window setFrame:newFrame display:YES animate:NO];
    [window makeKeyAndOrderFront:NSApp];
    
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp run];
    
    [pool release];
    
    return (GLKWindow)window;
    
}
