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
NSDate *startTime;
NSTimer *timer;
NSButton *pressedButton;
NSTimeInterval totalDuration;
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

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification {
  [[[[NSApplication sharedApplication] windows] lastObject] close];

  DFRSystemModalShowsCloseBoxWhenFrontMost(YES);
  
  NSCustomTouchBarItem *mute =
  [[NSCustomTouchBarItem alloc] initWithIdentifier:muteIdentifier];

  button = [TouchButton buttonWithTitle: @"0:00" target:nil action:nil];
  // Size, weight 0 get us the default system sizes
  button.font = [NSFont monospacedDigitSystemFontOfSize:0 weight:0];
  [button setDelegate: self];
  mute.view = button;

  touchBarButton = button;
  
  totalDuration = 0;

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

- (void) applicationWillTerminate:(NSNotification *)aNotification {
  [self stopTimer];
}

- (NSColor *) colorState:(bool)timerActive {
  NSColor* greenColor = [NSColor colorWithCalibratedRed:42.0/255 green:160.0/255 blue:28.0/255 alpha:1.0f];
  return timerActive ? greenColor : NSColor.clearColor;
}

- (void) onTick {
  NSTimeInterval currentDuration = -[startTime timeIntervalSinceNow];
  NSInteger durationInt = (NSInteger) (totalDuration + currentDuration);
  NSInteger minutes = (durationInt / 60) % 60;
  NSInteger seconds = durationInt % 60;
  
  button.title = [NSString stringWithFormat:@"%ld:%02ld", minutes, seconds];
}

- (void) startTimer {
  startTime = [NSDate date];
  // TODO(azirbel): A little annoying that it doesn't tick on the original schedule. Maybe I can start/resume the timer instead of making a new one?
  timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                           target:self
                                         selector:@selector(onTick)
                                         userInfo:nil
                                          repeats:YES];
  [self onTick];
}

- (void) stopTimer {
  if (timer) {
    [timer invalidate];
    timer = nil;
    
    NSString* logFile = @"/Users/alex/Desktop/log.csv";
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager isWritableFileAtPath:logFile]) {
      NSString *initialContents = [NSString stringWithFormat: @"start,end,duration,total_duration"];
      [initialContents writeToFile:logFile
                        atomically:true
                          encoding:NSUTF8StringEncoding
                            error:nil];
    }
    
    NSError* error = nil;
    NSString *contents = [NSString stringWithContentsOfFile:logFile
                                                   encoding:NSUTF8StringEncoding
                                                      error:&error];
    
    // TODO(azirbel): Prevent writing if file doesn't start with the specified CSV headers
    
    NSTimeInterval duration = -[startTime timeIntervalSinceNow];
    totalDuration += duration;
    
    NSLog(@"%f", totalDuration);
    
    NSDate* endTime = [NSDate date];
    
    if (error) {
      NSLog(@"ERROR while loading from file: %@", error);
    } else {
      NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
      [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
      NSString *newContents = [NSString stringWithFormat: @"%@\n%@,%@,%02f,%02f",
                               contents,
                               [dateFormatter stringFromDate:startTime],
                               [dateFormatter stringFromDate:endTime],
                               duration,
                               totalDuration
                              ];
      [newContents writeToFile:logFile
                    atomically:true
                      encoding:NSUTF8StringEncoding
                         error:nil];
    }
    
    startTime = nil;
  }
  
  [self onTick];
}

- (void) onPressed:(TouchButton*)sender {
  timerActive = !timerActive;
  
  pressedButton = (NSButton *)sender;
  [pressedButton setBezelColor: [self colorState: timerActive]];
  
  if (timerActive) {
    [self startTimer];
  } else {
    [self stopTimer];
  }
}

- (void) onLongPressed:(TouchButton*)sender {
  timerActive = !timerActive;
  
  pressedButton = (NSButton *)sender;
  [pressedButton setBezelColor: [self colorState: timerActive]];
  
  [self stopTimer];
  totalDuration = 0;
  [self onTick];
}

- (void) onHoldPressed:(NSButton *)sender {
  [[[[NSApplication sharedApplication] windows] lastObject] makeKeyAndOrderFront:nil];
  [[NSApplication sharedApplication] activateIgnoringOtherApps:true];
}

- (IBAction) prefsMenuItemAction:(id)sender {

    [self onLongPressed:sender];
}

- (IBAction) quitMenuItemAction:(id)sender {
    [NSApp terminate:nil];
}

- (IBAction) menuMenuItemAction:(id)sender {

}

- (void) handleStatusButtonAction {
    NSEvent *event = [[NSApplication sharedApplication] currentEvent];
    
    if ((event.modifierFlags & NSEventModifierFlagControl) || (event.modifierFlags & NSEventModifierFlagOption) || (event.type == NSEventTypeRightMouseUp)) {
        
        [self showMenu];
        
        return;
    }
}


@end
