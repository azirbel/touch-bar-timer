#import <Foundation/Foundation.h>
#import "Stopwatch.h"
#import "AppDelegate.h"

@interface Stopwatch ()

@end

@implementation Stopwatch

NSDate *startTime;
NSTimer *timer;
NSTimeInterval totalDuration;

+ (instancetype) stopwatchWithDelegate:(id)delegate {
  return [[Stopwatch alloc] initWithDelegate:delegate];
}

- (id) initWithDelegate:(id)delegate {
  self = [super init];
  
  if (self) {
    totalDuration = 0;
    self.delegate = delegate;
  }
  
  return self;
}

- (void) onTick {
  NSTimeInterval currentDuration = -[startTime timeIntervalSinceNow] + totalDuration;

  SEL selector = NSSelectorFromString(@"onTick");
  if ([self.delegate respondsToSelector:selector]) {
    [self.delegate onTick:currentDuration];
  }
}

- (void) start {
  startTime = [NSDate date];
  // TODO(azirbel): A little annoying that it doesn't tick on the original schedule. Maybe I can start/resume the timer instead of making a new one?
  timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                           target:self
                                         selector:@selector(onTick)
                                         userInfo:nil
                                          repeats:YES];
  [self onTick];
}

- (void) stop {
  if (timer) {
    [timer invalidate];
    timer = nil;
    
    NSString* logFilePath = [[NSUserDefaults standardUserDefaults] objectForKey:@"log_file_path"];
    BOOL writeToLogFile = [[NSUserDefaults standardUserDefaults] boolForKey:@"write_to_log_file"];

    if (writeToLogFile && logFilePath) {
      [self logToFile:logFilePath];
    }
    
    startTime = nil;
  }
  
  [self onTick];
}

- (void) reset {
  [self stop];
  totalDuration = 0;
  [self onTick];
}

- (void) logToFile:(NSString*)filePath {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if (![fileManager isWritableFileAtPath:filePath]) {
    NSString *initialContents = [NSString stringWithFormat: @"start,end,duration,total_duration"];
    [initialContents writeToFile:filePath
                      atomically:true
                        encoding:NSUTF8StringEncoding
                           error:nil];
  }
  
  NSError* error = nil;
  NSString *contents = [NSString stringWithContentsOfFile:filePath
                                                 encoding:NSUTF8StringEncoding
                                                    error:&error];
  
  if (![contents hasPrefix:@"start,end,duration,total_duration"]) {
    NSLog(@"ERROR: Log file doesn't start with appropriate CSV headers. Not writing to file.");
    return;
  }
  
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
    [newContents writeToFile:filePath
                  atomically:true
                    encoding:NSUTF8StringEncoding
                       error:nil];
  }
}

@end
