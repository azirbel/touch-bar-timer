#import "ViewController.h"
#import <ServiceManagement/ServiceManagement.h>
#import "AppDelegate.h"

static NSString *githubURL = @"https://github.com/azirbel/touch-bar-timer";
static NSString *projectURL = @"https://touch-bar-timer.alexzirbel.com/";
static NSString *bylineURL = @"https://alexzirbel.com/";

@implementation ViewController

NSString* logFilePath;
BOOL writeToLogFile;

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // SET UP DEFAULTS
  
  if ([[NSUserDefaults standardUserDefaults] objectForKey:@"auto_login"] == nil) {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"auto_login"];
  }
  
  if ([[NSUserDefaults standardUserDefaults] objectForKey:@"log_file_path"] == nil) {
    NSArray * paths = NSSearchPathForDirectoriesInDomains (NSDownloadsDirectory, NSUserDomainMask, YES);
    NSString * desktopPath = [paths objectAtIndex:0];
    NSArray* components = [NSArray arrayWithObjects:desktopPath, @"log.csv", nil];
    NSString* defaultPath = [self readableFilePath:[NSString pathWithComponents:components]];
    
    [[NSUserDefaults standardUserDefaults] setObject:defaultPath forKey:@"log_file_path"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"write_to_log_file"];
  }
  
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  // SET UP UI FROM DEFAULTS

  BOOL autoLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"auto_login"];
  logFilePath = [[NSUserDefaults standardUserDefaults] objectForKey:@"log_file_path"];
  writeToLogFile = [[NSUserDefaults standardUserDefaults] boolForKey:@"write_to_log_file"];
  
  [self.writeToLogFileCheckbox setState: writeToLogFile];
  [self.openAtLoginCheckbox setState: autoLogin];
  _writeToLogFileDescription.stringValue = [NSString stringWithFormat:@"Save log to %@", logFilePath];

  // enable to nil out preferences
  /*
   NSLog(@"WARNING: Nil out preferences");
   [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"auto_login"];
   [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"log_file_path"];
   [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"write_to_log_file"];
   [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"show_menu"];
   */
}

-(void)viewDidAppear {
  [super viewDidAppear];
  [[self.view window] setTitle:@"Touch Bar Timer"];
  [[self.view window] center];
}

- (void)setRepresentedObject:(id)representedObject {
  [super setRepresentedObject:representedObject];

  [[[[NSApplication sharedApplication] windows] lastObject] setTitle:@"Touch Bar Timer"];
}

- (NSString*)readableFilePath:(NSString*)path {
  NSString* newPath = [path stringByReplacingOccurrencesOfString:@"file://"
                                         withString:@""];
  return [newPath stringByReplacingOccurrencesOfString:@"file:"
                                        withString:@""];
}

- (IBAction)onChangeLogFilePressed:(id)sender {
  NSOpenPanel *panel = [NSOpenPanel openPanel];
  [panel setCanChooseFiles:YES];
  [panel setCanChooseDirectories:YES];
  [panel setAllowsMultipleSelection:NO];
  
  NSInteger clicked = [panel runModal];
  
  if (clicked == NSFileHandlingPanelOKButton) {
    for (NSURL *url in [panel URLs]) {
      if ([self isDirectory:url]) {
        NSArray* components = [NSArray arrayWithObjects:url.absoluteString, @"log.csv", nil];
        logFilePath = [self readableFilePath:[NSString pathWithComponents:components]];
      } else {
        logFilePath = [self readableFilePath:url.absoluteString];
      }
      
      [[NSUserDefaults standardUserDefaults] setObject:logFilePath forKey:@"log_file_path"];
      [[NSUserDefaults standardUserDefaults] synchronize];
      _writeToLogFileDescription.stringValue = [NSString stringWithFormat:@"Save log to %@", logFilePath];
    }
  }
}

// https://stackoverflow.com/questions/22277117/how-to-find-out-if-the-nsurl-is-a-directory-or-not
- (BOOL)isDirectory:(NSURL*)url {
  NSNumber *isDirectory;
  BOOL success = [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
  if (success && [isDirectory boolValue]) {
    return YES;
  } else {
    return NO;
  }
}

- (IBAction)quitPressed:(id)sender {
  [NSApp terminate:nil];
}

- (IBAction)onGithubPressed:(id)sender {
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:githubURL]];
}

- (IBAction)onWebsitePressed:(id)sender {
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:projectURL]];
}

- (IBAction)onOpenAtLoginChanged:(id)sender {
  BOOL autoLogin = ([self.openAtLoginCheckbox state] == NSOnState);
  
  [[NSUserDefaults standardUserDefaults] setBool:autoLogin forKey:@"auto_login"];
  if (!SMLoginItemSetEnabled((__bridge CFStringRef)@"azirbel.touch-bar-timer-launcher", autoLogin)) {
    NSLog(@"ERROR: Setting 'start at login' was not successful!");
  } else {
    NSLog(@"Setting 'start at login' was successful!");
  }
}

- (IBAction)onWriteToLogFileChanged:(id)sender {
  writeToLogFile = [self.writeToLogFileCheckbox state];
  
  [[NSUserDefaults standardUserDefaults] setBool:writeToLogFile forKey:@"write_to_log_file"];
}

- (IBAction)onBylinePressed:(id)sender {
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:bylineURL]];
}

@end
