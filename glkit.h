//
//
//

typedef void* GLKWindow;

int init();

void terminate();

NSOpenGLContext* createGLContext();

GLKWindow createWindow(int width, int height);
