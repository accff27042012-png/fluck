#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

// ============================================================
// FLUCK BUTTON
// ============================================================

@interface FluckButton : UIButton
@property (nonatomic, assign) BOOL isActive;
@end

@implementation FluckButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.isActive = NO;
        [self addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
        self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        self.layer.cornerRadius = 8;
        self.clipsToBounds = YES;
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return self;
}

- (void)toggle {
    self.isActive = !self.isActive;
    if (self.isActive) {
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.6 blue:0.0 alpha:1.0];
    } else {
        self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    }
    NSLog(@"Fluck toggled: %@", self.titleLabel.text);
}

@end

// ============================================================
// FLUCK MENU VIEW CONTROLLER
// ============================================================

@interface FluckMenuViewController : UIViewController
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, assign) BOOL isVisible;
@end

@implementation FluckMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.isVisible = NO;
    [self setupMenu];
}

- (void)setupMenu {
    // Menu Background
    self.menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 260, 380)];
    self.menuView.backgroundColor = [UIColor colorWithWhite:0.05 alpha:0.92];
    self.menuView.layer.cornerRadius = 14;
    self.menuView.layer.borderColor = [UIColor colorWithRed:0.0 green:0.8 blue:1.0 alpha:0.5].CGColor;
    self.menuView.layer.borderWidth = 2;
    self.menuView.center = self.view.center;
    [self.view addSubview:self.menuView];
    
    // Title
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, 260, 30)];
    title.text = @"⚡ Fluck Pro v1.0";
    title.textColor = [UIColor colorWithRed:0.0 green:0.8 blue:1.0 alpha:1.0];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont boldSystemFontOfSize:18];
    [self.menuView addSubview:title];
    
    // Separator
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, 48, 230, 1)];
    line.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1.0];
    [self.menuView addSubview:line];
    
    // Features
    NSArray *features = @[
        @"🎯 Aimbot",
        @"👁️ ESP",
        @"🪄 Fly Hack",
        @"💉 God Mode",
        @"⚡ Speed Hack",
        @"🛡️ Wall Hack",
        @"📡 Radar",
        @"🎨 Chams"
    ];
    
    CGFloat y = 60;
    for (int i = 0; i < features.count; i++) {
        FluckButton *btn = [[FluckButton alloc] initWithFrame:CGRectMake(15, y + i * 36, 230, 30)];
        [btn setTitle:features[i] forState:UIControlStateNormal];
        [self.menuView addSubview:btn];
    }
    
    // Close button
    UIButton *close = [UIButton buttonWithType:UIButtonTypeSystem];
    CGFloat closeY = 60 + features.count * 36 + 10;
    close.frame = CGRectMake(30, closeY, 200, 36);
    [close setTitle:@"✕ Close Menu" forState:UIControlStateNormal];
    [close setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    close.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    close.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
    close.layer.cornerRadius = 8;
    [close addTarget:self action:@selector(closeMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:close];
}

- (void)closeMenu {
    [self hideWithAnimation];
}

- (void)showWithAnimation {
    self.isVisible = YES;
    self.view.hidden = NO;
    self.menuView.transform = CGAffineTransformMakeScale(0.5, 0.5);
    self.menuView.alpha = 0;
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:0 animations:^{
        self.menuView.transform = CGAffineTransformIdentity;
        self.menuView.alpha = 1;
    } completion:nil];
}

- (void)hideWithAnimation {
    [UIView animateWithDuration:0.2 animations:^{
        self.menuView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        self.menuView.alpha = 0;
    } completion:^(BOOL finished) {
        self.isVisible = NO;
        self.view.hidden = YES;
    }];
}

- (void)toggle {
    if (self.isVisible) {
        [self hideWithAnimation];
    } else {
        [self showWithAnimation];
    }
}

@end

// ============================================================
// FLUCK MANAGER
// ============================================================

@interface FluckManager : NSObject
+ (instancetype)shared;
- (void)start;
- (void)stop;
- (void)toggleMenu;
@property (nonatomic, strong) UIWindow *overlayWindow;
@property (nonatomic, strong) FluckMenuViewController *menuVC;
@property (nonatomic, assign) BOOL running;
@end

@implementation FluckManager

+ (instancetype)shared {
    static FluckManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FluckManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.running = NO;
    }
    return self;
}

- (UIWindowScene *)getActiveScene {
    UIWindowScene *scene = nil;
    NSArray *scenes = [UIApplication sharedApplication].connectedScenes.allObjects;
    for (UIScene *s in scenes) {
        if ([s isKindOfClass:[UIWindowScene class]]) {
            UIWindowScene *ws = (UIWindowScene *)s;
            if (ws.activationState == UISceneActivationStateForegroundActive) {
                scene = ws;
                break;
            }
        }
    }
    if (!scene && scenes.count > 0) {
        for (UIScene *s in scenes) {
            if ([s isKindOfClass:[UIWindowScene class]]) {
                scene = (UIWindowScene *)s;
                break;
            }
        }
    }
    return scene;
}

- (void)start {
    if (self.running) return;
    self.running = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindowScene *scene = [self getActiveScene];
        
        // Tạo window
        if (@available(iOS 26.0, *)) {
            if (scene) {
                self.overlayWindow = [[UIWindow alloc] initWithWindowScene:scene];
            } else {
                self.overlayWindow = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
            }
        } else {
            self.overlayWindow = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        }
        
        self.overlayWindow.windowLevel = UIWindowLevelAlert + 1;
        self.overlayWindow.backgroundColor = [UIColor clearColor];
        self.overlayWindow.userInteractionEnabled = YES;
        self.overlayWindow.hidden = NO;
        
        self.menuVC = [[FluckMenuViewController alloc] init];
        self.menuVC.view.frame = self.overlayWindow.bounds;
        self.overlayWindow.rootViewController = self.menuVC;
        self.menuVC.view.hidden = YES;
        
        // Show menu sau 0.5s
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.menuVC showWithAnimation];
        });
        
        NSLog(@"✅ Fluck started successfully!");
    });
}

- (void)stop {
    if (!self.running) return;
    self.running = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.menuVC) {
            [self.menuVC hideWithAnimation];
        }
        if (self.overlayWindow) {
            self.overlayWindow.hidden = YES;
            self.overlayWindow = nil;
        }
        NSLog(@"⛔ Fluck stopped");
    });
}

- (void)toggleMenu {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.menuVC) {
            [self.menuVC toggle];
        }
    });
}

- (BOOL)isMenuVisible {
    return self.menuVC.isVisible;
}

@end

// ============================================================
// CONSTRUCTOR - TỰ ĐỘNG CHẠY KHI INJECT
// ============================================================

__attribute__((constructor))
static void fluck_constructor(void) {
    NSLog(@"═══════════════════════════════════════════════");
    NSLog(@"║   🔥 Fluck Pro v1.0 Loaded               ║");
    NSLog(@"║   📅 Build: %s %s", __DATE__, __TIME__);
    NSLog(@"═══════════════════════════════════════════════");
    [[FluckManager shared] start];
}

__attribute__((destructor))
static void fluck_destructor(void) {
    NSLog(@"Fluck Pro Unloaded");
    [[FluckManager shared] stop];
}

// ============================================================
// EXPORT FUNCTIONS (GỌI TỪ BÊN NGOÀI)
// ============================================================

extern "C" {
    void start_fluck(void) {
        [[FluckManager shared] start];
    }
    
    void stop_fluck(void) {
        [[FluckManager shared] stop];
    }
    
    void toggle_fluck_menu(void) {
        [[FluckManager shared] toggleMenu];
    }
    
    bool is_fluck_visible(void) {
        return [[FluckManager shared] isMenuVisible];
    }
}

// ============================================================
// MAIN (CHO TEST)
// ============================================================

int main(int argc, char *argv[]) {
    @autoreleasepool {
        start_fluck();
        sleep(60);
        stop_fluck();
    }
    return 0;
}
