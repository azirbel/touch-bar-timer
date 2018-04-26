#import "AppDelegate.h"
#import "TouchBar.h"
#import "TouchButton.h"
#import "TouchDelegate.h"
#import "Stopwatch.h"
#import <Cocoa/Cocoa.h>

static const NSTouchBarItemIdentifier muteIdentifier = @"azirbel.touch-bar-timer";
static NSString *const MASCustomShortcutKey = @"customShortcut";

@interface AppDelegate () <TouchDelegate>

@end

@implementation AppDelegate

bool timerActive;
NSButton *touchBarButton;
NSButton *pressedButton;
TouchButton *button;
Stopwatch* stopwatch;
NSWindow* mainWindow;

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

  [NSTouchBarItem addSystemTrayItem:mute];
  DFRElementSetControlStripPresenceForIdentifier(muteIdentifier, YES);
  
  stopwatch = [Stopwatch stopwatchWithDelegate:self];
  
  mainWindow = [[[NSApplication sharedApplication] windows] lastObject];

  // MAYBE AUTO LAUNCH THE PREFERENCES UI - ONLY ON VERY FIRST LAUNCH
  if ([[NSUserDefaults standardUserDefaults] objectForKey:@"show_menu"] == nil) {
    [mainWindow makeKeyAndOrderFront:nil];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:true];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"show_menu"];
    [[NSUserDefaults standardUserDefaults] synchronize];
  }
}

- (void) applicationWillTerminate:(NSNotification *)aNotification {
  [stopwatch stop];
}

- (NSColor *) colorState:(bool)timerActive {
  NSColor* greenColor = [NSColor colorWithCalibratedRed:42.0/255 green:160.0/255 blue:28.0/255 alpha:1.0f];
  return timerActive ? greenColor : NSColor.clearColor;
}

- (void) onTick:(NSTimeInterval)duration {
  NSInteger durationInt = (NSInteger) (duration);
  NSInteger hours = durationInt / 3600;
  NSInteger minutes = (durationInt / 60) % 60;
  NSInteger seconds = durationInt % 60;
  
  if (hours) {
    button.title = [NSString stringWithFormat:@"%ldh:%02ld", hours, minutes];
  } else {
    button.title = [NSString stringWithFormat:@"%ld:%02ld", minutes, seconds];
  }
}

- (void) onPressed:(TouchButton*)sender {
  timerActive = !timerActive;
  
  pressedButton = (NSButton *)sender;
  [pressedButton setBezelColor: [self colorState: timerActive]];
  
  if (timerActive) {
    [stopwatch start];
  } else {
    [stopwatch stop];
  }
}

- (void) onLongPressed:(TouchButton*)sender {
  timerActive = false;
  
  pressedButton = (NSButton *)sender;
  [pressedButton setBezelColor: [self colorState: timerActive]];
  
  [stopwatch reset];
}

- (void) onHoldPressed:(NSButton *)sender {
  [mainWindow makeKeyAndOrderFront:nil];
  [[NSApplication sharedApplication] activateIgnoringOtherApps:true];
}

- (IBAction) quitMenuItemAction:(id)sender {
  [NSApp terminate:nil];
}

- (IBAction) prefsMenuItemAction:(id)sender {
    [self onHoldPressed:sender];
}

@end
