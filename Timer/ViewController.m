#import "ViewController.h"
#import "AppDelegate.h"

static NSString *githubURL = @"https://github.com/pixel-point/mute-me";
static NSString *projectURL = @"https://touch-bar-timer.alexzirbel.com/";
static NSString *bylineURL = @"https://alexzirbel.com/";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"auto_login"] == nil) {
    
        // the opposite is used later
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"auto_login"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    BOOL state = [[NSUserDefaults standardUserDefaults] boolForKey:@"auto_login"];
    [self.autoLoginState setState: !state];

    // enable to nil out preferences
    //[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"auto_login"];
}

-(void)viewDidAppear {
    [super viewDidAppear];
    [[self.view window] setTitle:@"Touch Bar Timer"];
    [[self.view window] center];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    [[[[NSApplication sharedApplication] windows] lastObject] setTitle:@"Mute Me"];
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

- (IBAction)onLoginStartChanged:(id)sender {
    NSInteger state = [self.autoLoginState state];
    BOOL enableState = NO;
    if(state == NSOnState) {
        enableState = YES;
    }

    [[NSUserDefaults standardUserDefaults] setBool:!enableState forKey:@"auto_login"];
}

- (IBAction)onBylinePressed:(id)sender {
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:bylineURL]];
}

@end
