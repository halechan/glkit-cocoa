//
//
//

#include <mach/mach_time.h>

#import "glkit.h"

// Return raw time
//
static uint64_t getRawTime(void) {
    return mach_absolute_time();
}

// Initialise timer
//
void initTimer(void) {
    mach_timebase_info_data_t info;
    mach_timebase_info(&info);
    
    _glk.timeResolution = (double) info.numer / (info.denom * 1.0e9);
    _glk.timeBase = getRawTime();
}


double getTime(void) {
    return (double) (getRawTime() - _glk.timeBase) * _glk.timeResolution;
}

void setTime(double time) {
    _glk.timeBase = getRawTime() - (uint64_t) (time / _glk.timeResolution);
}
