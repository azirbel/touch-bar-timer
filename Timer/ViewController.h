#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property (weak) IBOutlet NSButton *githubButton;
@property (weak) IBOutlet NSButton *websiteButton;
@property (weak) IBOutlet NSButton *openAtLoginCheckbox;
@property (weak) IBOutlet NSButton *writeToLogFileCheckbox;
@property (weak) IBOutlet NSTextField *writeToLogFileDescription;

- (IBAction)onOpenAtLoginChanged:(id)sender;
- (IBAction)onWriteToLogFileChanged:(id)sender;

@end

