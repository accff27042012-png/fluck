#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <mach/mach.h>
#import <dlfcn.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import <mach-o/dyld.h>  // THÊM HEADER NÀY

static void* _baseAddress = NULL;
static BOOL _isInjected = NO;

void* GetBaseAddress() {
    if (_baseAddress) return _baseAddress;
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        if (strstr(name, "FreeFire") || strstr(name, "Garena") || strstr(name, "UnityFramework")) {
            _baseAddress = (void *)_dyld_get_image_header(i);
            return _baseAddress;
        }
    }
    return NULL;
}

// === ESP Manager ===
@interface FluckESP : NSObject
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) NSInteger style;
@property (nonatomic, assign) BOOL showHealth;
@property (nonatomic, assign) BOOL showDistance;
+ (instancetype)shared;
- (void)update;
@end

@implementation FluckESP {
    UIView *_overlay;
}
+ (instancetype)shared {
    static FluckESP *instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{ instance = [[self alloc] init]; });
    return instance;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        _enabled = NO;
        _style = 0;
        _showHealth = YES;
        _showDistance = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            // SỬA: Sử dụng connectedScenes thay vì keyWindow deprecated
            UIWindow *keyWindow = nil;
            if (@available(iOS 13.0, *)) {
                NSSet *scenes = [UIApplication sharedApplication].connectedScenes;
                for (UIScene *scene in scenes) {
                    if ([scene isKindOfClass:[UIWindowScene class]]) {
                        UIWindowScene *windowScene = (UIWindowScene *)scene;
                        if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                            keyWindow = windowScene.windows.firstObject;
                            break;
                        }
                    }
                }
            } else {
                keyWindow = [UIApplication sharedApplication].keyWindow;
            }
            if (keyWindow) {
                self->_overlay = [[UIView alloc] initWithFrame:keyWindow.bounds];
                self->_overlay.backgroundColor = [UIColor clearColor];
                self->_overlay.userInteractionEnabled = NO;
                [keyWindow addSubview:self->_overlay];
            }
        });
    }
    return self;
}
- (void)update {
    if (!_enabled || !_overlay) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIView *view in self->_overlay.subviews) {
            [view removeFromSuperview];
        }
    });
}
@end

// === Aimbot Manager ===
@interface FluckAimbot : NSObject
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL silentAim;
@property (nonatomic, assign) BOOL autoFire;
+ (instancetype)shared;
- (void)update;
@end

@implementation FluckAimbot
+ (instancetype)shared {
    static FluckAimbot *instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{ instance = [[self alloc] init]; });
    return instance;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        _enabled = NO;
        _silentAim = NO;
        _autoFire = NO;
    }
    return self;
}
- (void)update {
    if (!_enabled) return;
}
@end

// === Floating Menu ===
@interface FluckMenu : UIView
+ (instancetype)shared;
- (void)show;
- (void)hide;
- (void)toggle;
- (void)setupUI;
- (void)saveSettings;
- (void)loadSettings;
@end

@implementation FluckMenu {
    UIView *_backgroundView;
    UIView *_menuView;
    NSMutableDictionary *_settings;
    BOOL _isMenuOpen;
}

+ (instancetype)shared {
    static FluckMenu *instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _settings = [NSMutableDictionary dictionary];
        _isMenuOpen = NO;
        [self loadSettings];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupUI];
        });
    }
    return self;
}

- (UIWindow *)getKeyWindow {
    // SỬA: Hàm helper để lấy key window không bị deprecated
    if (@available(iOS 13.0, *)) {
        NSSet *scenes = [UIApplication sharedApplication].connectedScenes;
        for (UIScene *scene in scenes) {
            if ([scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                    return windowScene.windows.firstObject;
                }
            }
        }
        return nil;
    } else {
        return [UIApplication sharedApplication].keyWindow;
    }
}

- (void)setupUI {
    UIWindow *keyWindow = [self getKeyWindow];
    if (!keyWindow) return;
    
    self.frame = keyWindow.bounds;
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = YES;
    [keyWindow addSubview:self];
    
    _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    _backgroundView.hidden = YES;
    [self addSubview:_backgroundView];
    
    CGFloat menuWidth = 320;
    CGFloat menuHeight = 380;
    _menuView = [[UIView alloc] initWithFrame:CGRectMake((self.bounds.size.width - menuWidth) / 2,
                                                          (self.bounds.size.height - menuHeight) / 2,
                                                          menuWidth, menuHeight)];
    _menuView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.95];
    _menuView.layer.cornerRadius = 16;
    _menuView.layer.masksToBounds = YES;
    _menuView.hidden = YES;
    [self addSubview:_menuView];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, menuWidth, 28)];
    title.text = @"FLUCK MOD";
    title.textColor = [UIColor colorWithRed:0.2 green:0.6 blue:1 alpha:1];
    title.font = [UIFont boldSystemFontOfSize:18];
    title.textAlignment = NSTextAlignmentCenter;
    [_menuView addSubview:title];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(menuWidth - 44, 10, 30, 30);
    [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [_menuView addSubview:closeBtn];
    
    [self addSwitch:@"ESP" y:50 key:@"esp_enabled"];
    [self addSegmented:@[@"Box", @"Lines", @"Skeleton"] y:86 key:@"esp_style"];
    [self addSwitch:@"Health" y:124 key:@"esp_health"];
    [self addSwitch:@"Distance" y:162 key:@"esp_distance"];
    [self addSwitch:@"Aimbot" y:210 key:@"aim_enabled"];
    [self addSwitch:@"Silent Aim" y:248 key:@"aim_silent"];
    [self addSwitch:@"Auto Fire" y:286 key:@"aim_autofire"];
}

- (void)addSwitch:(NSString *)title y:(CGFloat)y key:(NSString *)key {
    UISwitch *sw = [[UISwitch alloc] init];
    sw.on = [[_settings objectForKey:key] boolValue];
    sw.tag = [self tagForKey:key];
    [sw addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    
    UIView *row = [[UIView alloc] initWithFrame:CGRectMake(12, y, _menuView.bounds.size.width - 24, 34)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 140, 24)];
    label.text = title;
    label.textColor = [UIColor colorWithWhite:0.9 alpha:1];
    label.font = [UIFont systemFontOfSize:14];
    [row addSubview:label];
    sw.frame = CGRectMake(180, 0, 80, 34);
    [row addSubview:sw];
    [_menuView addSubview:row];
}

- (void)addSegmented:(NSArray *)items y:(CGFloat)y key:(NSString *)key {
    UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:items];
    seg.selectedSegmentIndex = [[_settings objectForKey:key] integerValue];
    seg.tag = [self tagForKey:key];
    [seg addTarget:self action:@selector(segChanged:) forControlEvents:UIControlEventValueChanged];
    
    UIView *row = [[UIView alloc] initWithFrame:CGRectMake(12, y, _menuView.bounds.size.width - 24, 34)];
    seg.frame = CGRectMake((row.bounds.size.width - seg.bounds.size.width) / 2, 2, seg.bounds.size.width, 30);
    [row addSubview:seg];
    [_menuView addSubview:row];
}

- (NSInteger)tagForKey:(NSString *)key {
    if ([key isEqualToString:@"esp_enabled"]) return 1000;
    if ([key isEqualToString:@"esp_style"]) return 1001;
    if ([key isEqualToString:@"esp_health"]) return 1002;
    if ([key isEqualToString:@"esp_distance"]) return 1003;
    if ([key isEqualToString:@"aim_enabled"]) return 2000;
    if ([key isEqualToString:@"aim_silent"]) return 2001;
    if ([key isEqualToString:@"aim_autofire"]) return 2002;
    return 0;
}

- (void)switchChanged:(UISwitch *)sender {
    NSInteger tag = sender.tag;
    BOOL on = sender.on;
    NSString *key = @"";
    switch (tag) {
        case 1000: key = @"esp_enabled"; [FluckESP shared].enabled = on; break;
        case 1002: key = @"esp_health"; [FluckESP shared].showHealth = on; break;
        case 1003: key = @"esp_distance"; [FluckESP shared].showDistance = on; break;
        case 2000: key = @"aim_enabled"; [FluckAimbot shared].enabled = on; break;
        case 2001: key = @"aim_silent"; [FluckAimbot shared].silentAim = on; break;
        case 2002: key = @"aim_autofire"; [FluckAimbot shared].autoFire = on; break;
    }
    [_settings setObject:@(on) forKey:key];
    [self saveSettings];
}

- (void)segChanged:(UISegmentedControl *)sender {
    NSInteger idx = sender.selectedSegmentIndex;
    if (sender.tag == 1001) {
        [_settings setObject:@(idx) forKey:@"esp_style"];
        [FluckESP shared].style = idx;
    }
    [self saveSettings];
}

- (void)show {
    if (_isMenuOpen) return;
    _isMenuOpen = YES;
    _backgroundView.hidden = NO;
    _menuView.hidden = NO;
    _menuView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    _menuView.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self->_menuView.transform = CGAffineTransformIdentity;
        self->_menuView.alpha = 1;
        self->_backgroundView.alpha = 1;
    }];
}

- (void)hide {
    if (!_isMenuOpen) return;
    _isMenuOpen = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self->_menuView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        self->_menuView.alpha = 0;
        self->_backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        self->_backgroundView.hidden = YES;
        self->_menuView.hidden = YES;
    }];
    [self saveSettings];
}

- (void)toggle {
    if (_isMenuOpen) [self hide];
    else [self show];
}

- (void)saveSettings {
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/fluck_settings.plist"];
    [_settings writeToFile:path atomically:YES];
}

- (void)loadSettings {
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/fluck_settings.plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    if (dict) {
        _settings = [dict mutableCopy];
    }
    
    [FluckESP shared].enabled = [[_settings objectForKey:@"esp_enabled"] boolValue];
    [FluckESP shared].style = [[_settings objectForKey:@"esp_style"] integerValue];
    [FluckESP shared].showHealth = [[_settings objectForKey:@"esp_health"] boolValue];
    [FluckESP shared].showDistance = [[_settings objectForKey:@"esp_distance"] boolValue];
    
    [FluckAimbot shared].enabled = [[_settings objectForKey:@"aim_enabled"] boolValue];
    [FluckAimbot shared].silentAim = [[_settings objectForKey:@"aim_silent"] boolValue];
    [FluckAimbot shared].autoFire = [[_settings objectForKey:@"aim_autofire"] boolValue];
}
@end

// === Hooking ===
static void (*orig_Update)(id self, SEL _cmd);
static void new_Update(id self, SEL _cmd) {
    orig_Update(self, _cmd);
    if (!_isInjected) {
        _isInjected = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[FluckMenu shared] show];
        });
    }
    [[FluckESP shared] update];
    [[FluckAimbot shared] update];
}

static void (*orig_SendEvent)(id self, SEL _cmd, UIEvent *event);
static void new_SendEvent(id self, SEL _cmd, UIEvent *event) {
    orig_SendEvent(self, _cmd, event);
    NSSet *touches = [event allTouches];
    for (UITouch *touch in touches) {
        if (touch.phase == UITouchPhaseBegan && touch.tapCount == 3) {
            [[FluckMenu shared] toggle];
        }
    }
}

__attribute__((constructor))
static void initialize(void) {
    NSLog(@"Fluck Mod loaded!");
    Class unityClass = NSClassFromString(@"UnityPlayer");
    if (unityClass) {
        Method updateMethod = class_getInstanceMethod(unityClass, NSSelectorFromString(@"Update"));
        if (updateMethod) {
            orig_Update = (void (*)(id, SEL))method_getImplementation(updateMethod);
            method_setImplementation(updateMethod, (IMP)new_Update);
        }
    }
    Class appClass = [UIApplication class];
    Method sendEventMethod = class_getInstanceMethod(appClass, @selector(sendEvent:));
    if (sendEventMethod) {
        orig_SendEvent = (void (*)(id, SEL, UIEvent *))method_getImplementation(sendEventMethod);
        method_setImplementation(sendEventMethod, (IMP)new_SendEvent);
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[FluckMenu shared] show];
    });
}
