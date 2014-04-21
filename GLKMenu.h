//
//
//

#import <Foundation/Foundation.h>

@interface GLKMenu : NSObject {
@private
    NSMenu* menu;
    NSString* appName;
}

@property (assign) IBOutlet NSMenu* menu;

- (void)setAppName:(NSString*)name;
- (void)load;

@end
