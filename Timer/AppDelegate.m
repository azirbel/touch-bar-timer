#import "AppDelegate.h"
#import "TouchBar.h"
#import <ServiceManagement/ServiceManagement.h>
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

  [self enableLoginAutostart];
  
  [[[[NSApplication sharedApplication] windows] lastObject] makeKeyAndOrderFront:nil];
  [[NSApplication sharedApplication] activateIgnoringOtherApps:true];
  
  stopwatch = [Stopwatch stopwatchWithDelegate:self];
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
  [[[[NSApplication sharedApplication] windows] lastObject] makeKeyAndOrderFront:nil];
  [[NSApplication sharedApplication] activateIgnoringOtherApps:true];
}

- (IBAction) quitMenuItemAction:(id)sender {
  [NSApp terminate:nil];
}

- (IBAction) prefsMenuItemAction:(id)sender {
    [self onHoldPressed:sender];
}

@end
