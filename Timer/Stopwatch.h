#import <Cocoa/Cocoa.h>

// TOOD: do I need this?
#ifndef Stopwatch_h
#define Stopwatch_h

@interface Stopwatch : NSObject

@property (nonatomic, weak) id delegate;

+ (instancetype) stopwatchWithDelegate:(id)delegate;
- (void) start;
- (void) stop;
- (void) reset;
- (void) logToFile:(NSString*)filePath;

@end

#endif /* Stopwatch_h */
