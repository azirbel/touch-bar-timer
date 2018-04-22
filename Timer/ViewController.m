#import "ViewController.h"
#import "AppDelegate.h"

static NSString *githubURL = @"https://github.com/azirbel/touch-bar-timer";
static NSString *projectURL = @"https://touch-bar-timer.alexzirbel.com/";
static NSString *bylineURL = @"https://alexzirbel.com/";

@implementation ViewController

NSString* logFilePath;
BOOL writeToLogFile;

- (void)viewDidLoad {
  [super viewDidLoad];
  
  if ([[NSUserDefaults standardUserDefaults] objectForKey:@"auto_login"] == nil) {
    // the opposite is used later
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"auto_login"];
    [[NSUserDefaults standardUserDefaults] synchronize];
  }

  logFilePath = [[NSUserDefaults standardUserDefaults] objectForKey:@"log_file_path"];
  writeToLogFile = [[NSUserDefaults standardUserDefaults] boolForKey:@"write_to_log_file"];
  [self.writeToLogFileCheckbox setState: writeToLogFile];

  BOOL state = [[NSUserDefaults standardUserDefaults] boolForKey:@"auto_login"];
  [self.openAtLoginCheckbox setState: !state];
  
  if (logFilePath != nil) {
    _logFileUrlField.stringValue = [self readableFilePath:logFilePath];
  }

  // enable to nil out preferences
  //[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"auto_login"];
  //[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"log_file_path"];
  //[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"write_to_log_file"];
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
      _logFileUrlField.stringValue = logFilePath;
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
  NSInteger state = [self.openAtLoginCheckbox state];
  BOOL enableState = NO;
  if (state == NSOnState) {
    enableState = YES;
  }

  [[NSUserDefaults standardUserDefaults] setBool:!enableState forKey:@"auto_login"];
}

- (IBAction)onWriteToLogFileChanged:(id)sender {
  writeToLogFile = [self.writeToLogFileCheckbox state];
  
  [[NSUserDefaults standardUserDefaults] setBool:writeToLogFile forKey:@"write_to_log_file"];
}

- (IBAction)onBylinePressed:(id)sender {
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:bylineURL]];
}

@end
