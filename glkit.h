//
//
//
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

#define TRUE                           1
#define FALSE                          0

// Checks for whether the library has been intitalized
#define GLK_REQUIRE_INIT()                         \
if (!_glkInitialized)                           \
{                                                \
NSLog(@"GLK is not initialized"); \
return;                                      \
}
#define GLK_REQUIRE_INIT_OR_RETURN(x)              \
if (!_glkInitialized)                           \
{                                                \
NSLog(@"GLK is not initialized"); \
return x;                                    \
}

typedef struct GLKMonitor {
    
} GLKMonitor;

typedef struct GLKWindow {
    struct          GLKWindow* next;
    
    // Window settings and state
    GLboolean           iconified;
    GLboolean           resizable;
    GLboolean           decorated;
    GLboolean           visible;
    GLboolean           closed;
    
    id              object;
    id              context;
    id	            delegate;
    id              view;
    unsigned int    modifierFlags;
    int             cursorInside;
} GLKWindow;

typedef struct GLKGlobal {
    double              timeBase;
    double              timeResolution;
    
    CGEventSourceRef    eventSource;
    id                  delegate;
    id                  autoreleasePool;
    id                  cursor;
    
    char*               clipboardString;
    
    // dlopen handle for dynamically loading OpenGL extension entry points
    void*               framework;
    pthread_key_t       context;
    
    
    GLKWindow*    windowListHead;
    GLKWindow*    focusedWindow;
    
    GLKMonitor**  monitors;
    int             monitorCount;
} GLKGlobal;


/*! @brief Flag indicating whether GLKit has been successfully initialized.
 */
extern GLboolean _glkInitialized;

/*! @brief All global data protected by @ref _glkInitialized.
 *  This should only be touched after a call to @ref init that has not been
 *  followed by a call to @ref terminate.
 */
extern GLKGlobal _glk;


int init(void);

int initContextAPI(void);

void initTimer(void);

int initTLS(void);

void terminate(void);

void terminateTLS(void);

NSOpenGLContext* createContext(void);

void setCurrentContext(GLKWindow* context);

void makeContextCurrent(GLKWindow* handle);

GLKWindow* getCurrentContext(void);

GLKWindow* createWindow(int width, int height,
                             const char* title,
                             GLKMonitor* monitor,
                             GLKWindow* share);

void destroyWindow(GLKWindow* window);

int windowShouldClose(GLKWindow* window);

void inputWindowCloseRequest(GLKWindow* window);

void pollEvents(void);

void swapBuffers(GLKWindow* window);

double getTime(void);

