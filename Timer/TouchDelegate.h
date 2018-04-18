#import <Foundation/Foundation.h>

@protocol TouchDelegate <NSObject>

- (void)onPressed:(NSButton *)sender;
- (void)onLongPressed:(NSButton *)sender;
- (void)onHoldPressed:(NSButton *)sender;

@end
