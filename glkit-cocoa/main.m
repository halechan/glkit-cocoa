#import "glkit.h"
#include <OpenGL/gl.h>
#include <OpenGL/OpenGL.h>

int main(int argc, const char * argv[]) {
    int width = 640;
    int height = 480;
    
    GLKWindow* window;
    
    if (!init()) {
        exit(EXIT_FAILURE);
    }
    
    window = createWindow(width, height, "Simple example", NULL, NULL);
    if (!window) {
        terminate();
        exit(EXIT_FAILURE);
    }
    
    makeContextCurrent(window);

    while (!windowShouldClose(window)) {
        
        float ratio = width / (float) height;
        glViewport(0, 0, width, height);
        glClear(GL_COLOR_BUFFER_BIT);
        
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        glOrtho(-ratio, ratio, -1.f, 1.f, 1.f, -1.f);
        glMatrixMode(GL_MODELVIEW);
        
        glLoadIdentity();
        glRotatef((float) getTime() * 50.f, 0.f, 0.f, 1.f);
        
        glBegin(GL_TRIANGLES);
        glColor3f(1.f, 0.f, 0.f);
        glVertex3f(-0.6f, -0.4f, 0.f);
        glColor3f(0.f, 1.f, 0.f);
        glVertex3f(0.6f, -0.4f, 0.f);
        glColor3f(0.f, 0.f, 1.f);
        glVertex3f(0.f, 0.6f, 0.f);
        glEnd();
        
        swapBuffers(window);
        
        pollEvents();
    }
    
    destroyWindow(window);
    
    terminate();
    
    exit(EXIT_SUCCESS);
    
}

