#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

// ============================================================
// FLUCK BUTTON
// ============================================================

@interface FluckButton : UIButton
@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, strong) UILabel *statusLabel;
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
        self.userInteractionEnabled = YES;
        
        // Status indicator
        self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 30, 0, 25, frame.size.height)];
        self.statusLabel.text = @"○";
        self.statusLabel.textColor = [UIColor grayColor];
        self.statusLabel.font = [UIFont systemFontOfSize:16];
        self.statusLabel.textAlignment = NSTextAlignmentCenter;
        self.statusLabel.userInteractionEnabled = NO;
        [self addSubview:self.statusLabel];
    }
    return self;
}

- (void)toggle {
    self.isActive = !self.isActive;
    if (self.isActive) {
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.6 blue:0.0 alpha:1.0];
        self.statusLabel.text = @"●";
        self.statusLabel.textColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
    } else {
        self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        self.statusLabel.text = @"○";
        self.statusLabel.textColor = [UIColor grayColor];
    }
    NSLog(@"✅ Toggled: %@ - %@", self.titleLabel.text, self.isActive ? @"ON" : @"OFF");
}

@end

// ============================================================
// FLUCK MENU VIEW CONTROLLER
// ============================================================

@interface FluckMenuViewController : UIViewController <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, assign) BOOL isVisible;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) UILabel *fpsLabel;
@property (nonatomic, strong) NSTimer *fpsTimer;
@end

@implementation FluckMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.userInteractionEnabled = YES;
    self.isVisible = NO;
    self.buttons = [NSMutableArray array];
    [self setupMenu];
    [self setupFPSMonitor];
}

- (void)setupFPSMonitor {
    self.fpsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 20)];
    self.fpsLabel.textColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
    self.fpsLabel.font = [UIFont systemFontOfSize:12];
    self.fpsLabel.text = @"FPS: 0";
    [self.menuView addSubview:self.fpsLabel];
    
    self.fpsTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer *timer) {
        // Mock FPS
        int fps = 30 + arc4random_uniform(31);
        self.fpsLabel.text = [NSString stringWithFormat:@"FPS: %d", fps];
    }];
}

- (void)setupMenu {
    // Menu Background
    CGFloat menuWidth = 280;
    CGFloat menuHeight = 450;
    self.menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, menuWidth, menuHeight)];
    self.menuView.backgroundColor = [UIColor colorWithWhite:0.05 alpha:0.95];
    self.menuView.layer.cornerRadius = 16;
    self.menuView.layer.borderColor = [UIColor colorWithRed:0.0 green:0.8 blue:1.0 alpha:0.6].CGColor;
    self.menuView.layer.borderWidth = 2;
    self.menuView.center = self.view.center;
    self.menuView.userInteractionEnabled = YES;
    self.menuView.clipsToBounds = YES;
    [self.view addSubview:self.menuView];
    
    // Gradient cho menu (đẹp hơn)
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.menuView.bounds;
    gradient.colors = @[
        (id)[UIColor colorWithWhite:0.05 alpha:0.95].CGColor,
        (id)[UIColor colorWithWhite:0.1 alpha:0.95].CGColor
    ];
    gradient.locations = @[@0.0, @1.0];
    [self.menuView.layer insertSublayer:gradient atIndex:0];
    
    // Title
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, menuWidth, 35)];
    title.text = @"⚡ Fluck Pro v1.0";
    title.textColor = [UIColor colorWithRed:0.0 green:0.8 blue:1.0 alpha:1.0];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont boldSystemFontOfSize:20];
    [self.menuView addSubview:title];
    
    // Subtitle
    UILabel *subtitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, menuWidth, 20)];
    subtitle.text = @"Free Fire | iOS 15+";
    subtitle.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    subtitle.textAlignment = NSTextAlignmentCenter;
    subtitle.font = [UIFont systemFontOfSize:12];
    [self.menuView addSubview:subtitle];
    
    // Separator
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, 65, menuWidth - 30, 1)];
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
        @"🎨 Chams",
        @"🔫 No Recoil",
        @"🎮 Trigger Bot"
    ];
    
    CGFloat y = 78;
    CGFloat spacing = 38;
    int cols = 2;
    CGFloat btnWidth = (menuWidth - 50) / 2;
    CGFloat btnHeight = 32;
    CGFloat margin = 15;
    
    for (int i = 0; i < features.count; i++) {
        int row = i / cols;
        int col = i % cols;
        CGFloat x = margin + col * (btnWidth + 10);
        CGFloat yPos = y + row * spacing;
        
        FluckButton *btn = [[FluckButton alloc] initWithFrame:CGRectMake(x, yPos, btnWidth, btnHeight)];
        [btn setTitle:features[i] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self.menuView addSubview:btn];
        [self.buttons addObject:btn];
    }
    
    // Close button
    UIButton *close = [UIButton buttonWithType:UIButtonTypeSystem];
    int totalRows = (features.count + cols - 1) / cols;
    CGFloat closeY = y + totalRows * spacing + 15;
    close.frame = CGRectMake(40, closeY, menuWidth - 80, 40);
    [close setTitle:@"✕ Close Menu" forState:UIControlStateNormal];
    [close setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    close.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    close.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
    close.layer.cornerRadius = 10;
    close.userInteractionEnabled = YES;
    [close addTarget:self action:@selector(closeMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:close];
    
    // Resize menu
    CGFloat totalHeight = closeY + 55;
    CGRect frame = self.menuView.frame;
    frame.size.height = totalHeight;
    self.menuView.frame = frame;
    self.menuView.center = self.view.center;
    
    // Draggable handle
    UIView *handle = [[UIView alloc] initWithFrame:CGRectMake((menuWidth - 40) / 2, 8, 40, 4)];
    handle.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    handle.layer.cornerRadius = 2;
    [self.menuView addSubview:handle];
    
    // Thêm gesture để kéo menu
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.delegate = self;
    [self.menuView addGestureRecognizer:pan];
    
    // Double tap để toggle visibility
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.menuView addGestureRecognizer:doubleTap];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.view];
    CGPoint newCenter = CGPointMake(self.menuView.center.x + translation.x, self.menuView.center.y + translation.y);
    
    // Giới hạn menu trong màn hình
    CGFloat halfWidth = self.menuView.frame.size.width / 2;
    CGFloat halfHeight = self.menuView.frame.size.height / 2;
    newCenter.x = MAX(halfWidth, MIN(self.view.bounds.size.width - halfWidth, newCenter.x));
    newCenter.y = MAX(halfHeight, MIN(self.view.bounds.size.height - halfHeight, newCenter.y));
    
    self.menuView.center = newCenter;
    [gesture setTranslation:CGPointZero inView:self.view];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture {
    [self toggle];
}

- (void)closeMenu {
    [self hideWithAnimation];
}

- (void)showWithAnimation {
    self.isVisible = YES;
    self.view.hidden = NO;
    self.view.userInteractionEnabled = YES;
    self.menuView.transform = CGAffineTransformMakeScale(0.5, 0.5);
    self.menuView.alpha = 0;
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:0 animations:^{
        self.menuView.transform = CGAffineTransformIdentity;
        self.menuView.alpha = 1;
    } completion:nil];
    [self startFPSMonitor];
}

- (void)hideWithAnimation {
    [UIView animateWithDuration:0.25 animations:^{
        self.menuView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        self.menuView.alpha = 0;
    } completion:^(BOOL finished) {
        self.isVisible = NO;
        self.view.hidden = YES;
        self.view.userInteractionEnabled = NO;
        [self stopFPSMonitor];
    }];
}

- (void)toggle {
    if (self.isVisible) {
        [self hideWithAnimation];
    } else {
        [self showWithAnimation];
    }
}

- (void)startFPSMonitor {
    if (self.fpsTimer) {
        [self.fpsTimer invalidate];
        self.fpsTimer = nil;
    }
    self.fpsTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer *timer) {
        // Mock FPS
        int fps = 30 + arc4random_uniform(31);
        self.fpsLabel.text = [NSString stringWithFormat:@"FPS: %d", fps];
    }];
}

- (void)stopFPSMonitor {
    if (self.fpsTimer) {
        [self.fpsTimer invalidate];
        self.fpsTimer = nil;
    }
}

- (void)dealloc {
    [self stopFPSMonitor];
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
- (BOOL)isMenuVisible;
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
        
        // Cấu hình window để nhận touch
        self.overlayWindow.windowLevel = UIWindowLevelStatusBar + 100;
        self.overlayWindow.backgroundColor = [UIColor clearColor];
        self.overlayWindow.userInteractionEnabled = YES;
        self.overlayWindow.hidden = NO;
        self.overlayWindow.opaque = NO;
        
        self.menuVC = [[FluckMenuViewController alloc] init];
        self.menuVC.view.frame = self.overlayWindow.bounds;
        self.menuVC.view.backgroundColor = [UIColor clearColor];
        self.menuVC.view.userInteractionEnabled = YES;
        self.overlayWindow.rootViewController = self.menuVC;
        self.menuVC.view.hidden = YES;
        
        // Show menu sau 0.3s
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
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
    NSLog(@"║   📱 Free Fire | iOS 15+                ║");
    NSLog(@"═══════════════════════════════════════════════");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[FluckManager shared] start];
    });
}

__attribute__((destructor))
static void fluck_destructor(void) {
    NSLog(@"Fluck Pro Unloaded");
    [[FluckManager shared] stop];
}

// ============================================================
// EXPORT FUNCTIONS
// ============================================================

extern "C" {
    void start_fluck(void) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[FluckManager shared] start];
        });
    }
    
    void stop_fluck(void) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[FluckManager shared] stop];
        });
    }
    
    void toggle_fluck_menu(void) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[FluckManager shared] toggleMenu];
        });
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
        [[NSRunLoop mainRunLoop] run];
    }
    return 0;
}
