//
// 
//

#import <Cocoa/Cocoa.h>
#import "GLKMenu.h"

@implementation GLKMenu
@synthesize menu;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)setAppName:(NSString*)name
{
    NSString* oldTitle = @"Quit go";
    NSString* newTitle = [NSString stringWithFormat:@"Quit %@", name];
    [[[[menu itemAtIndex:0] submenu] itemWithTitle:oldTitle] setTitle:newTitle];
}

- (void)load
{
    if (NSApp == NULL) {
        NSLog(@"NSApp is null");
    }
    
    menu = [NSApp mainMenu];
    if (menu == NULL) {
        NSLog(@"menu is null");
    }
    
    //TODO: how does glfw handle this?
    
    NSMenuItem* appItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Go" action:NULL keyEquivalent:@""];
    
    NSMenu* appMenu = [[NSMenu alloc] initWithTitle:@"Go"];
    [appMenu insertItemWithTitle:@"About go" action:NULL keyEquivalent:@"" atIndex:0];
    [appMenu insertItemWithTitle:@"Quit go" action:NULL keyEquivalent:@"" atIndex:1];
    
    [appItem setSubmenu:appMenu];
    
    [menu addItem:appItem];
    
    NSMenuItem* fileItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"File" action:NULL keyEquivalent:@""];
    [menu addItem:fileItem];
}

@end
