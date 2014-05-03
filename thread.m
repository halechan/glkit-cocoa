#include <stdio.h>
#include <pthread.h>

#import "glkit.h"

int initTLS(void) {
    if (pthread_key_create(&_glk.context, NULL) != 0) {
        //TODO: Handle this better in Go
        NSLog(@"POSIX: Failed to create context TLS");
        return FALSE;
    }
    
    return TRUE;
}

void terminateTLS(void) {
    pthread_key_delete(_glk.context);
}

void setCurrentContext(GLKWindow* context) {
    pthread_setspecific(_glk.context, context);
}

GLKWindow* getCurrentContext(void) {
    return pthread_getspecific(_glk.context);
}
