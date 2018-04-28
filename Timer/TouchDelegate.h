#import <Foundation/Foundation.h>

@protocol TouchDelegate <NSObject>

- (void)onTap:(NSButton *)sender;
- (void)onDoubleTap:(NSButton *)sender;
- (void)onHoldPressed:(NSButton *)sender;

@end
