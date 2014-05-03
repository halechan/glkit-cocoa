#import <Cocoa/Cocoa.h>
#import <OpenGL/gl.h>
#import "GLKApplication.h"
#import "GLKCocoaWindow.h"
#import "GLKWindowDelegate.h"
#import "GLKApplicationDelegate.h"
#import "GLKMenu.h"
#import "GLKView.h"
#import "glkit.h"


// Needed for _NSGetProgname
#include <crt_externs.h>

// Global state shared between compilation units of GLFW
// These are documented in internal.h
//
GLboolean _glkInitialized = FALSE;
GLKGlobal _glk;

int init(void) {
    if (_glkInitialized) {
        return TRUE;
    }
    
    memset(&_glk, 0, sizeof(_glk));
    
	_glk.autoreleasePool = [[NSAutoreleasePool alloc] init];
    _glk.eventSource = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
    
    if (!_glk.eventSource) {
        return FALSE;
    }
    
    CGEventSourceSetLocalEventsSuppressionInterval(_glk.eventSource, 0.0);
    
    if (!initContextAPI()) {
        return FALSE;
    }
    
    initTimer();
    //initJoysticks();
    
    //_glfw.monitors = _glfwPlatformGetMonitors(&_glfw.monitorCount);
    //if (_glfw.monitors == NULL) {
    //    _glfwInputError(GLFW_PLATFORM_ERROR, "No monitors found");
    //    _glfwPlatformTerminate();
    //    return GL_FALSE;
    //}
    
    _glkInitialized = TRUE;
    
    // Not all window hints have zero as their default value
    //glfwDefaultWindowHints();

    
    return TRUE;
    
}


NSOpenGLContext* createContext() {
    unsigned int attributeCount = 0;
    
#define ADD_ATTR(x) { attributes[attributeCount++] = x; }
#define ADD_ATTR2(x, y) { ADD_ATTR(x); ADD_ATTR(y); }
    
    // Arbitrary array size here
    NSOpenGLPixelFormatAttribute attributes[40];
    
    ADD_ATTR(NSOpenGLPFADoubleBuffer);
    ADD_ATTR(NSOpenGLPFAClosestPolicy);
    ADD_ATTR2(NSOpenGLPFAColorSize, 24);
    ADD_ATTR2(NSOpenGLPFAAlphaSize, 8);
    ADD_ATTR2(NSOpenGLPFADepthSize, 24);
    ADD_ATTR2(NSOpenGLPFAStencilSize, 8);
    // NOTE: All NSOpenGLPixelFormats on the relevant cards support sRGB
    //       frambuffer, so there's no need (and no way) to request it
    
    ADD_ATTR(0);
    
#undef ADD_ATTR
#undef ADD_ATTR2
    
    NSOpenGLPixelFormat* pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
    assert(pixelFormat);
    
    NSOpenGLContext* glContext = [[NSOpenGLContext alloc]
                                  initWithFormat:pixelFormat
                                  shareContext:NULL];
    assert(glContext);
    
    return glContext;
}

// Destroy the OpenGL context
//
void destroyContext(GLKWindow* window) {
    //[window->pixelFormat release];
    //window->pixelFormat = nil;
    
    [window->context release];
    window->context = nil;
}

void destroyWindow(GLKWindow* handle) {
    GLKWindow* window = (GLKWindow*) handle;
    
    GLK_REQUIRE_INIT();
    
    // Allow closing of NULL (to match the behavior of free)
    if (window == NULL) {
        return;
    }
    
    // Clear all callbacks to avoid exposing a half torn-down window object
    //memset(&window->callbacks, 0, sizeof(window->callbacks));
    
    // The window's context must not be current on another thread when the
    // window is destroyed
    if (window == getCurrentContext()) {
        makeContextCurrent(NULL);
    }
    
    // Clear the focused window pointer if this is the focused window
    if (window == _glk.focusedWindow) {
        _glk.focusedWindow = NULL;
    }
    
    [window->object orderOut:nil];
    
    //if (window->monitor) {
    //    leaveFullscreenMode(window);
    //}
    
    destroyContext(window);
    
    [window->object setDelegate:nil];
    [window->delegate release];
    window->delegate = nil;
    
    [window->view release];
    window->view = nil;
    
    [window->object close];
    window->object = nil;
    
    // Unlink window from global linked list
    {
        GLKWindow** prev = &_glk.windowListHead;
        
        while (*prev != window) {
            prev = &((*prev)->next);
        }
        
        *prev = window->next;
    }
    
    free(window);
}

void terminate() {
    if (!_glkInitialized) {
        return;
    }
    // Close all remaining windows
    while (_glk.windowListHead) {
        destroyWindow((GLKWindow*) _glk.windowListHead);
    }
    
    if (_glk.eventSource) {
        CFRelease(_glk.eventSource);
        _glk.eventSource = NULL;
    }
    
    [NSApp setDelegate:nil];
    [_glk.delegate release];
    _glk.delegate = nil;
    
    [_glk.autoreleasePool release];
    _glk.autoreleasePool = nil;
    
    [_glk.cursor release];
    _glk.cursor = nil;
    
    free(_glk.clipboardString);
    
    //terminateJoysticks();
    terminateTLS();
    
    _glkInitialized = GL_FALSE;
    
    [NSApp terminate:nil];
}


// Try to figure out what the calling application is called
//
static NSString* findAppName(void) {
    size_t i;
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    // Keys to search for as potential application names
    NSString* GLFWNameKeys[] = {
        @"CFBundleDisplayName",
        @"CFBundleName",
        @"CFBundleExecutable",
    };
    
    for (i = 0;  i < sizeof(GLFWNameKeys) / sizeof(GLFWNameKeys[0]);  i++) {
        id name = [infoDictionary objectForKey:GLFWNameKeys[i]];
        if (name &&
            [name isKindOfClass:[NSString class]] &&
            ![name isEqualToString:@""]) {
            return name;
        }
    }
    
    char** progname = _NSGetProgname();
    if (progname && *progname) {
        return [NSString stringWithUTF8String:*progname];
    }
    
    // Really shouldn't get here
    return @"GLFW Application";
}


// Set up the menu bar (manually)
// This is nasty, nasty stuff -- calls to undocumented semi-private APIs that
// could go away at any moment, lots of stuff that really should be
// localize(d|able), etc.  Loading a nib would save us this horror, but that
// doesn't seem like a good thing to require of GLFW's clients.
//
static void createMenuBar(void) {
    NSString* appName = findAppName();
    
    NSMenu* bar = [[NSMenu alloc] init];
    [NSApp setMainMenu:bar];
    
    NSMenuItem* appMenuItem =
    [bar addItemWithTitle:@"" action:NULL keyEquivalent:@""];
    NSMenu* appMenu = [[NSMenu alloc] init];
    [appMenuItem setSubmenu:appMenu];
    
    [appMenu addItemWithTitle:[NSString stringWithFormat:@"About %@", appName]
                       action:@selector(orderFrontStandardAboutPanel:)
                keyEquivalent:@""];
    [appMenu addItem:[NSMenuItem separatorItem]];
    NSMenu* servicesMenu = [[NSMenu alloc] init];
    [NSApp setServicesMenu:servicesMenu];
    [[appMenu addItemWithTitle:@"Services"
                        action:NULL
                 keyEquivalent:@""] setSubmenu:servicesMenu];
    [appMenu addItem:[NSMenuItem separatorItem]];
    [appMenu addItemWithTitle:[NSString stringWithFormat:@"Hide %@", appName]
                       action:@selector(hide:)
                keyEquivalent:@"h"];
    [[appMenu addItemWithTitle:@"Hide Others"
                        action:@selector(hideOtherApplications:)
                 keyEquivalent:@"h"]
     setKeyEquivalentModifierMask:NSAlternateKeyMask | NSCommandKeyMask];
    [appMenu addItemWithTitle:@"Show All"
                       action:@selector(unhideAllApplications:)
                keyEquivalent:@""];
    [appMenu addItem:[NSMenuItem separatorItem]];
    [appMenu addItemWithTitle:[NSString stringWithFormat:@"Quit %@", appName]
                       action:@selector(terminate:)
                keyEquivalent:@"q"];
    
    NSMenuItem* windowMenuItem =
    [bar addItemWithTitle:@"" action:NULL keyEquivalent:@""];
    NSMenu* windowMenu = [[NSMenu alloc] initWithTitle:@"Window"];
    [NSApp setWindowsMenu:windowMenu];
    [windowMenuItem setSubmenu:windowMenu];
    
    [windowMenu addItemWithTitle:@"Minimize"
                          action:@selector(performMiniaturize:)
                   keyEquivalent:@"m"];
    [windowMenu addItemWithTitle:@"Zoom"
                          action:@selector(performZoom:)
                   keyEquivalent:@""];
    [windowMenu addItem:[NSMenuItem separatorItem]];
    [windowMenu addItemWithTitle:@"Bring All to Front"
                          action:@selector(arrangeInFront:)
                   keyEquivalent:@""];
    
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 1070
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
        // TODO: Make this appear at the bottom of the menu (for consistency)
        
        [windowMenu addItem:[NSMenuItem separatorItem]];
        [[windowMenu addItemWithTitle:@"Enter Full Screen"
                               action:@selector(toggleFullScreen:)
                        keyEquivalent:@"f"]
         setKeyEquivalentModifierMask:NSControlKeyMask | NSCommandKeyMask];
    }
#endif /*MAC_OS_X_VERSION_MAX_ALLOWED*/
    
    // Prior to Snow Leopard, we need to use this oddly-named semi-private API
    // to get the application menu working properly.
    SEL setAppleMenuSelector = NSSelectorFromString(@"setAppleMenu:");
    [NSApp performSelector:setAppleMenuSelector withObject:appMenu];
}



// Initialize the Cocoa Application Kit
//
static GLboolean initializeAppKit(void)
{
    if (NSApp) {
        return TRUE;
    }
    
    // Implicitly create shared NSApplication instance
    [GLKApplication sharedApplication];
    
    // In case we are unbundled, make us a proper UI application
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    
    // Menu bar setup must go between sharedApplication above and
    // finishLaunching below, in order to properly emulate the behavior
    // of NSApplicationMain
    createMenuBar();
    
    [NSApp finishLaunching];
    
    return TRUE;
}

void makeContextCurrent(GLKWindow* handle) {
    GLKWindow* window = (GLKWindow*) handle;
    
    if (!_glkInitialized) {                                                \
        NSLog(@"GLK is not initialized");
    }
    
    if (getCurrentContext() == window) {
        return;
    }
    
    if (window) {
        [window->context makeCurrentContext];
    } else {
        [NSOpenGLContext clearCurrentContext];
    }
    
    setCurrentContext(window);
}

GLKWindow* createWindow(int width, int height,
                       const char* title,
                       GLKMonitor* monitor,
                       GLKWindow* share) {
    
    
    GLKWindow* window;
    GLKWindow* previous;
    
    GLK_REQUIRE_INIT_OR_RETURN(NULL);
    
    if (width <= 0 || height <= 0) {
        NSLog(@"Invalid window size");
        return NULL;
    }
    
    window = calloc(1, sizeof(GLKWindow));
    window->next = _glk.windowListHead;
    _glk.windowListHead = window;
    
    // Save the currently current context so it can be restored later
    previous = (GLKWindow*) getCurrentContext();
    
    if (!initializeAppKit()) {
        return FALSE;
    }
    
    // There can only be one application delegate, but we allocate it the
    // first time a window is created to keep all window code in this file
    if (_glk.delegate == nil) {
        _glk.delegate = [[GLKApplicationDelegate alloc] init];
        if (_glk.delegate == nil) {
            NSLog(@"Cocoa: Failed to create application delegate");
            return FALSE;
        }
        
        [NSApp setDelegate:_glk.delegate];
    }
    
    window->delegate = [[GLKWindowDelegate alloc] initWithGLKWindow:window];
    if (window->delegate == nil) {
        NSLog(@"Cocoa: Failed to create window delegate");
        return FALSE;
    }
    
    unsigned int styleMask = 0;
    
    //TODO: Make this configurable
    styleMask = NSTitledWindowMask | NSClosableWindowMask |
    NSMiniaturizableWindowMask | NSResizableWindowMask;
    
    window->object = [[GLKCocoaWindow alloc]
                         initWithContentRect:NSMakeRect(0, 0, width, height)
                         styleMask:styleMask
                         backing:NSBackingStoreBuffered
                         defer:NO];
    
    if (window->object == nil) {
        NSLog(@"Cocoa: Failed to create window");
        return FALSE;
    }
    
    window->view = [[GLKView alloc] initWithGLKWindow:window];
    
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 1070
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
#if defined(_GLFW_USE_RETINA)
        [window->view setWantsBestResolutionOpenGLSurface:YES];
#endif
        
        //if (wndconfig->resizable) {
            [window->object setCollectionBehavior:NSWindowCollectionBehaviorFullScreenPrimary];
        //}
    }
#endif /*MAC_OS_X_VERSION_MAX_ALLOWED*/
    
    [window->object setTitle:[NSString stringWithUTF8String:title]];
    [window->object setContentView:window->view];
    [window->object setDelegate:window->delegate];
    [window->object setAcceptsMouseMovedEvents:YES];
    [window->object center];
    
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 1070
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
        [window->object setRestorable:NO];
    }
#endif /*MAC_OS_X_VERSION_MAX_ALLOWED*/
    
    
    window->context = createContext();
    
    [window->context setView:window->view];
    
    makeContextCurrent(window);
    
    // Clearing the front buffer to black to avoid garbage pixels left over
    // from previous uses of our bit of VRAM
    glClear(GL_COLOR_BUFFER_BIT);
    swapBuffers(window);
    
    // Restore the previously current context (or NULL)
    makeContextCurrent(previous);
    
    // Make us the active application
    // HACK: This has been moved here from initializeAppKit to prevent
    //       applications using only hidden windows from being activated, but
    //       should probably not be done every time any window is shown
    [NSApp activateIgnoringOtherApps:YES];
    
    [window->object makeKeyAndOrderFront:nil];
    
    
    return window;
    
}

int windowShouldClose(GLKWindow* handle) {
    GLKWindow* window = (GLKWindow*) handle;
    GLK_REQUIRE_INIT_OR_RETURN(0);
    return window->closed;
}

void inputWindowCloseRequest(GLKWindow* window) {
    window->closed = TRUE;
}

void pollEvents(void) {
    GLK_REQUIRE_INIT();
    for (;;)
    {
        NSEvent* event = [NSApp nextEventMatchingMask:NSAnyEventMask
                                            untilDate:[NSDate distantPast]
                                               inMode:NSDefaultRunLoopMode
                                              dequeue:YES];
        if (event == nil)
            break;
        
        [NSApp sendEvent:event];
    }
    
    [_glk.autoreleasePool drain];
    _glk.autoreleasePool = [[NSAutoreleasePool alloc] init];
}


void swapBuffers(GLKWindow* window) {
    GLK_REQUIRE_INIT();
    // ARP appears to be unnecessary, but this is future-proof
    [window->context flushBuffer];
}

// Initialize OpenGL support
//
int initContextAPI(void)
{
    if (!initTLS()) {
        return FALSE;
    }
    
    _glk.framework = CFBundleGetBundleWithIdentifier(CFSTR("com.apple.opengl"));
    if (_glk.framework == NULL) {
        //TODO: Handle this better in Go
        NSLog(@"NSGL: Failed to locate OpenGL framework");
        return FALSE;
    }
    
    return TRUE;
}
