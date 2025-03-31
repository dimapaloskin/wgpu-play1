#include <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>
#include <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <QuartzCore/CAMetalLayer.h>
#import "App.h"

#import "webgpu/webgpu.h"


@interface WindowDelegate : NSObject <NSWindowDelegate>
- (void)setResizeCallback:(void (*)(void))callback;
@end

@implementation WindowDelegate {
  void (*resizeCallback)(void);
}


- (void)windowWillClose:(NSNotification*)notification {
  [NSApp terminate:self];
}
- (void)windowDidResize:(NSNotification*)notification {
  NSRect frame = [[notification object] frame];

  NSScreen* screen = [[notification object] screen];
  CGFloat scaleFactor = [screen backingScaleFactor];

  NSLog(@"Window resized to: %f x %f", frame.size.width * scaleFactor,
        frame.size.height * scaleFactor);

  NSView* contentView = [[notification object] contentView];
  CAMetalLayer* metalLayer = (CAMetalLayer*)[contentView layer];
  metalLayer.drawableSize = CGSizeMake(frame.size.width * scaleFactor,
                                       frame.size.height * scaleFactor);

  if (resizeCallback) {
    resizeCallback();
  }
}

- (void)setResizeCallback:(void (*)(void))callback {
  self.resizeCallback = callback;
}

@end

WGPUSurface create_window(WGPUInstance instance) {
  @autoreleasepool {
    App* app = [App sharedApplication];
    [app setShouldPrintDebugMessages:false];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    [NSApp finishLaunching];

    WindowDelegate* delegate = [[WindowDelegate alloc] init];
    NSUInteger style = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |
                       NSWindowStyleMaskResizable;

    NSRect rect = NSMakeRect(0, 0, 800, 600);
    NSWindow* window =
        [[NSWindow alloc] initWithContentRect:rect
                                    styleMask:style
                                      backing:NSBackingStoreBuffered
                                        defer:NO];
    [window setDelegate:delegate];
    [window setTitle:@"Hello there"];
    [window center];
    [window makeKeyAndOrderFront:nil];

    NSScreen* screen = [window screen];
    CGFloat scaleFactor = [screen backingScaleFactor];
    NSLog(@"Screen scale factor: %f", scaleFactor);
    NSLog(@"---------------------------");

    NSView* contentView = [window contentView];
    CAMetalLayer* metalLayer = [CAMetalLayer layer];
    [metalLayer setDevice:MTLCreateSystemDefaultDevice()];
    [metalLayer setPixelFormat:MTLPixelFormatBGRA8Unorm];
    [metalLayer setFramebufferOnly:YES];
    [metalLayer setContentsScale:scaleFactor];
    [contentView setWantsLayer:YES];
    [contentView setLayer:metalLayer];

    CGSize viewSize = contentView.frame.size;
    NSLog(@"View size: %f x %f", viewSize.width, viewSize.height);

    metalLayer.drawableSize =
        CGSizeMake(viewSize.width * scaleFactor, viewSize.height * scaleFactor);

    WGPUSurfaceDescriptorFromMetalLayer fromMetalLayer;
    fromMetalLayer.chain.sType = WGPUSType_SurfaceDescriptorFromMetalLayer;
    fromMetalLayer.chain.next = NULL;
    fromMetalLayer.layer = metalLayer;

    WGPUSurfaceDescriptor surfaceDescriptor;
    surfaceDescriptor.nextInChain = (WGPUChainedStruct*)&fromMetalLayer;
    surfaceDescriptor.label = NULL;

    return wgpuInstanceCreateSurface(instance, &surfaceDescriptor);
  }
}

void poll_events(void) {
  @autoreleasepool {
    NSEvent* event;
    while ((event = [NSApp nextEventMatchingMask:NSEventMaskAny
                                       untilDate:[NSDate distantPast]
                                          inMode:NSDefaultRunLoopMode
                                         dequeue:YES])) {
      [NSApp sendEvent:event];
      [NSApp updateWindows];
    }
  }
}

void setResizeCallback(void (*callback)(void)) {
  @autoreleasepool {
    NSApplication* app = NSApp;
    NSWindow* window = [app mainWindow];

    NSLog(@"%p", window);

    // [delegate setResizeCallback:callback];
  }
}
