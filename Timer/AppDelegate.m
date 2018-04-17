#import "AppDelegate.h"
#import "TouchBar.h"
#import <ServiceManagement/ServiceManagement.h>
#import "TouchButton.h"
#import "TouchDelegate.h"
#import <Cocoa/Cocoa.h>
#import <MASShortcut/Shortcut.h>

static const NSTouchBarItemIdentifier muteIdentifier = @"azirbel.touch-bar-timer";
static NSString *const MASCustomShortcutKey = @"customShortcut";

@interface AppDelegate () <TouchDelegate>

@end

@implementation AppDelegate

NSButton *touchBarButton;
bool timerActive;

TouchButton *button;

- (void) awakeFromNib {
    bool hideStatusBar = false;
    bool statusBarButtonToggle = false;
    bool useAlternateStatusBarIcons = false;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"hide_status_bar"] != nil) {
        hideStatusBar = [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_status_bar"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"status_bar_button_toggle"] != nil) {
        statusBarButtonToggle = [[NSUserDefaults standardUserDefaults] boolForKey:@"status_bar_button_toggle"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"status_bar_alternate_icons"] != nil) {
        useAlternateStatusBarIcons = [[NSUserDefaults standardUserDefaults] boolForKey:@"status_bar_alternate_icons"];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:hideStatusBar forKey:@"hide_status_bar"];
    [[NSUserDefaults standardUserDefaults] setBool:statusBarButtonToggle forKey:@"status_bar_button_toggle"];
    [[NSUserDefaults standardUserDefaults] setBool:useAlternateStatusBarIcons forKey:@"status_bar_alternate_icons"];
    
    [self setShortcutKey];
}

- (void) setShortcutKey {
    
    // default shortcut is "Shift Command 0"
    MASShortcut *firstLaunchShortcut = [MASShortcut shortcutWithKeyCode:kVK_ANSI_0 modifierFlags:NSEventModifierFlagCommand | NSEventModifierFlagShift];
    NSData *firstLaunchShortcutData = [NSKeyedArchiver archivedDataWithRootObject:firstLaunchShortcut];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:@{
                                 MASCustomShortcutKey : firstLaunchShortcutData
                                 }];
    
    [defaults synchronize];
    
    
    [[MASShortcutMonitor sharedMonitor] registerShortcut:firstLaunchShortcut withAction:^{
        [self shortCutKeyPressed];
    }];
    
}

- (void) shortCutKeyPressed {

}

- (void) showMenu {
    [self.statusBar popUpStatusItemMenu:self.statusMenu];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[[[NSApplication sharedApplication] windows] lastObject] close];

    DFRSystemModalShowsCloseBoxWhenFrontMost(YES);

    NSCustomTouchBarItem *mute =
    [[NSCustomTouchBarItem alloc] initWithIdentifier:muteIdentifier];

    button = [TouchButton buttonWithTitle: @"1:32" target:nil action:nil];
    [button setDelegate: self];
    mute.view = button;

    touchBarButton = button;

    [NSTouchBarItem addSystemTrayItem:mute];
    DFRElementSetControlStripPresenceForIdentifier(muteIdentifier, YES);

    [self enableLoginAutostart];
}

-(void) enableLoginAutostart {
    // on the first run this should be nil. So don't setup auto run
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"auto_login"] == nil) {
        return;
    }

    bool state = [[NSUserDefaults standardUserDefaults] boolForKey:@"auto_login"];
    if(!SMLoginItemSetEnabled((__bridge CFStringRef)@"Pixel-Point.Mute-Me-Now-Launcher", !state)) {
        NSLog(@"The login was not succesfull");
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
}

-(NSColor *)colorState:(bool)timerActive {
    return timerActive ? NSColor.greenColor : NSColor.clearColor;
}

- (void)onPressed:(TouchButton*)sender
{
    timerActive = !timerActive;
    
    NSLog (@"active: %s", timerActive ? "true" : "false");
    
    NSButton *button = (NSButton *)sender;
    [button setBezelColor: [self colorState: timerActive]];
}

- (void)onLongPressed:(TouchButton*)sender
{
    [[[[NSApplication sharedApplication] windows] lastObject] makeKeyAndOrderFront:nil];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:true];
}

- (IBAction)prefsMenuItemAction:(id)sender {

    [self onLongPressed:sender];
}

- (IBAction)quitMenuItemAction:(id)sender {
    [NSApp terminate:nil];
}

- (IBAction)menuMenuItemAction:(id)sender {

}

- (void) handleStatusButtonAction {
    NSEvent *event = [[NSApplication sharedApplication] currentEvent];
    
    if ((event.modifierFlags & NSEventModifierFlagControl) || (event.modifierFlags & NSEventModifierFlagOption) || (event.type == NSEventTypeRightMouseUp)) {
        
        [self showMenu];
        
        return;
    }
}


@end
