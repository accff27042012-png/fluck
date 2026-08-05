#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <mach/mach.h>
#import <mach/vm_map.h>
#import <sys/sysctl.h>

// ============ FIX MISSING FUNCTIONS ============
static inline kern_return_t mach_vm_write(vm_map_t task, mach_vm_address_t address, vm_offset_t data, mach_msg_type_number_t size) {
    return vm_write(task, address, data, size);
}

static inline kern_return_t mach_vm_read_overwrite(vm_map_t task, mach_vm_address_t address, mach_vm_size_t size, mach_vm_address_t data, mach_vm_size_t *outsize) {
    vm_size_t temp_outsize = (vm_size_t)*outsize;
    kern_return_t kr = vm_read_overwrite(task, address, (vm_size_t)size, data, &temp_outsize);
    *outsize = (mach_vm_size_t)temp_outsize;
    return kr;
}

static inline void sys_icache_invalidate(void *addr, size_t len) {
    // iOS cache flush
    __asm__ volatile("icache ivau, %0" : : "r"(addr));
}

// ============ ENTITY INFO CLASS ============
@interface EntityInfo : NSObject
@property (nonatomic, assign) float distance;
@property (nonatomic, assign) void *entity;
@end

@implementation EntityInfo
@end

// ============ FEATURE STATE ============
static inline bool get_feature_state(const char *feature) {
    // TODO: Implement actual feature toggle with user defaults or file
    return true;
}

// ============ FFHACK MENU ============
@interface FFHackMenu : NSObject
+ (void)show;
+ (void)hide;
+ (void)toggle;
+ (void)updateFrame;
@end

@implementation FFHackMenu

static UIWindow *menuWindow = nil;
static CGFloat screen_width = 0;
static CGFloat screen_height = 0;

+ (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (menuWindow) return;
        
        // Fix deprecated UIScreen
        if (@available(iOS 26.0, *)) {
            // Use new API for iOS 26+
            UIWindowScene *scene = (UIWindowScene *)[UIApplication sharedApplication].connectedScenes.allObjects.firstObject;
            if ([scene isKindOfClass:[UIWindowScene class]]) {
                screen_width = scene.screen.bounds.size.width;
                screen_height = scene.screen.bounds.size.height;
            }
        } else {
            // Fallback for older iOS
            screen_width = [UIScreen mainScreen].bounds.size.width;
            screen_height = [UIScreen mainScreen].bounds.size.height;
        }
        
        menuWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 200, 300)];
        menuWindow.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
        menuWindow.windowLevel = UIWindowLevelAlert + 1;
        menuWindow.hidden = NO;
        
        // Add menu items
        UIViewController *vc = [[UIViewController alloc] init];
        vc.view.backgroundColor = [UIColor clearColor];
        menuWindow.rootViewController = vc;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 180, 30)];
        label.text = @"FFHack Menu";
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        [vc.view addSubview:label];
        
        // Close button
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        closeBtn.frame = CGRectMake(10, 250, 180, 40);
        [closeBtn setTitle:@"Close" forState:UIControlStateNormal];
        [closeBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [vc.view addSubview:closeBtn];
        
        NSLog(@"FFHackMenu shown");
    });
}

+ (void)hide {
    dispatch_async(dispatch_get_main_queue(), ^{
        menuWindow.hidden = YES;
        menuWindow = nil;
        NSLog(@"FFHackMenu hidden");
    });
}

+ (void)toggle {
    if (menuWindow) {
        [self hide];
    } else {
        [self show];
    }
}

+ (void)updateFrame {
    // Update menu position if needed
}

@end

// ============ MAIN EXPORT ============
extern "C" {
    void start_ffhack() {
        NSLog(@"FFHack started!");
        [FFHackMenu show];
    }
    
    void stop_ffhack() {
        NSLog(@"FFHack stopped!");
        [FFHackMenu hide];
    }
}
