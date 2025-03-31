#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>

#import "App.h"

@implementation App

bool shouldPrintDebugMessages = true;

- (void)setShouldPrintDebugMessages:(bool)value {
  shouldPrintDebugMessages = value;
}

- (void)printEventMessage:(NSEvent*)event {
  switch ([event type]) {
    case NSEventTypeKeyDown: {
      NSString* characters = [event characters];
      if ([characters length] > 0) {
        unichar character = [characters characterAtIndex:0];
        NSLog(@"Key pressed: %C", character);
      }
      break;
    }
    case NSEventTypeMouseMoved: {
      NSWindow* window = [event window];
      if (window) {
        NSPoint locationInWindow = [event locationInWindow];
        NSView* contentView = [window contentView];
        NSPoint locationInView = [contentView convertPoint:locationInWindow
                                                  fromView:nil];

        NSLog(@"Mouse in view coords: (%f, %f)", locationInView.x,
              locationInView.y);
      }

      break;
    }
    case NSEventTypeLeftMouseDown: {
      NSLog(@"Left mouse button pressed");
      break;
    }
    case NSEventTypeRightMouseDown: {
      NSLog(@"Right mouse button pressed");
      break;
    }
    default:
      break;
  }
}

- (void)sendEvent:(NSEvent*)event {
  if ([event type] == NSEventTypeKeyDown) {
    unsigned short keyCode = [event keyCode];
    if (keyCode == 53) {  // ESC key
      [NSApp terminate:nil];
    }
  }
  if (shouldPrintDebugMessages) {
    [self printEventMessage:event];
  }
  [super sendEvent:event];
}
@end
