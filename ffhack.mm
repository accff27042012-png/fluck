// ============================================================================
// ffhack.mm - Mod Menu Hack hoàn chỉnh
// ============================================================================

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <sys/sysctl.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>

// ============================================================================
// ĐỊNH NGHĨA CLASS ModMenuViewController
// ============================================================================

@interface ModMenuViewController : UIViewController

// Properties
@property (nonatomic, strong) UIColor *currentThemeColor;
@property (nonatomic, strong) id floatingMenu;
@property (nonatomic, strong) NSArray *menuTabs;
@property (nonatomic, assign) BOOL isMenuOpen;
@property (nonatomic, assign) BOOL isBackendStarted;

// Feature buttons
@property (nonatomic, strong) UIButton *ghostButtonView;
@property (nonatomic, strong) UISwitch *ghostSwitch;
@property (nonatomic, strong) UIButton *teleVIPButtonView;
@property (nonatomic, strong) UISwitch *teleVIPSwitch;
@property (nonatomic, strong) UIButton *undergroundButtonView;
@property (nonatomic, strong) UISwitch *undergroundSwitch;
@property (nonatomic, strong) UIButton *aiTelekillButtonView;
@property (nonatomic, strong) UISwitch *aiTelekillSwitch;
@property (nonatomic, strong) UIButton *ninjaRunButtonView;
@property (nonatomic, strong) UISwitch *ninjaRunSwitch;
@property (nonatomic, strong) UIButton *flyAlturaButtonView;
@property (nonatomic, strong) UISwitch *flyAlturaSwitch;
@property (nonatomic, strong) UIButton *flyNormalButtonView;
@property (nonatomic, strong) UISwitch *flyNormalSwitch;
@property (nonatomic, strong) UIButton *flyv2ButtonView;
@property (nonatomic, strong) UISwitch *flyv2Switch;
@property (nonatomic, strong) UIButton *savePosButtonView;
@property (nonatomic, strong) UISwitch *savePosSwitch;
@property (nonatomic, strong) UIButton *goTeleportStateButtonView;
@property (nonatomic, strong) UISwitch *goTeleportStateSwitch;
@property (nonatomic, strong) UIButton *stopMoveButtonView;
@property (nonatomic, strong) UISwitch *stopMoveSwitch;
@property (nonatomic, strong) UIButton *horizontalSpeedButtonView;
@property (nonatomic, strong) UISwitch *horizontalSpeedSwitch;
@property (nonatomic, strong) UIButton *clearAntiuButtonView;
@property (nonatomic, strong) UISwitch *clearAntiuSwitch;
@property (nonatomic, strong) UIButton *magnetKillButtonView;
@property (nonatomic, strong) UISwitch *magnetKillSwitch;
@property (nonatomic, strong) UIButton *markTeleportButtonView;
@property (nonatomic, strong) UISwitch *markTeleportSwitch;

// FPS
@property (nonatomic, strong) NSTimer *fpsTimer;
@property (nonatomic, assign) NSInteger frameCount;
@property (nonatomic, assign) double currentFPS;

// UI Elements
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UISwitch *firstSwitch;
@property (nonatomic, strong) UISwitch *secondSwitch;
@property (nonatomic, strong) UIButton *submitButton;

// Methods
- (void)setupBackend;
- (void)setupUI;
- (void)initializeMenu;
- (void)viewDidLoad;
- (void)setupDisplayLink;
- (void)startFPSTimer;
- (void)updateFrame;
- (void)dealloc;

- (void)createAllFeatureButtons;
- (void)removeAllFeatureButtons;
- (void)updateUIButtonVisibility;
- (void)updateFeatureButtonTheme:(UIButton *)button;
- (void)updateAllFeatureButtonThemes;
- (void)createFloatingMenu;
- (void)showMenu;
- (void)hideMenu;
- (void)toggleMenu;

- (void)saveUIState;
- (void)loadUIState;
- (void)saveMenuState;
- (void)loadMenuState;
- (id)uiStateJSONPath;
- (id)readUIStateJSON;
- (void)writeUIStateJSON:(id)data;
- (id)serializeColor:(UIColor *)color;
- (id)deserializeColor:(id)colorData fallback:(UIColor *)fallback;
- (UIColor *)loadSavedThemeColor;

- (void)ghostSwitchChanged:(UISwitch *)sender;
- (void)teleVIPSwitchChanged:(UISwitch *)sender;
- (void)undergroundSwitchChanged:(UISwitch *)sender;
- (void)aiTelekillSwitchChanged:(UISwitch *)sender;
- (void)ninjaRunSwitchChanged:(UISwitch *)sender;
- (void)flyAlturaSwitchChanged:(UISwitch *)sender;
- (void)flyNormalSwitchChanged:(UISwitch *)sender;
- (void)flyv2SwitchChanged:(UISwitch *)sender;
- (void)savePosSwitchChanged:(UISwitch *)sender;
- (void)goTeleportStateSwitchChanged:(UISwitch *)sender;
- (void)stopMoveSwitchChanged:(UISwitch *)sender;
- (void)horizontalSpeedSwitchChanged:(UISwitch *)sender;
- (void)clearAntiuSwitchChanged:(UISwitch *)sender;
- (void)magnetKillSwitchChanged:(UISwitch *)sender;
- (void)markTeleportSwitchChanged:(UISwitch *)sender;

- (void)toggleShowGhostUI:(UISwitch *)sender;
- (void)toggleShowTeleVIPUI:(UISwitch *)sender;
- (void)toggleShowUndergroundUI:(UISwitch *)sender;
- (void)toggleShowAITelekillUI:(UISwitch *)sender;
- (void)toggleShowNinjaRunUI:(UISwitch *)sender;
- (void)toggleShowFlyAlturaUI:(UISwitch *)sender;
- (void)toggleUIFlyNormal:(UISwitch *)sender;
- (void)toggleShowFlyv2UI:(UISwitch *)sender;
- (void)toggleShowSavePosUI:(UISwitch *)sender;
- (void)toggleShowGoTeleportStateUI:(UISwitch *)sender;
- (void)toggleShowStopMoveUI:(UISwitch *)sender;
- (void)toggleShowHorizontalSpeedUI:(UISwitch *)sender;
- (void)toggleShowClearAntiuUI:(UISwitch *)sender;
- (void)toggleShowMagnetKillUI:(UISwitch *)sender;
- (void)toggleShowMarkTeleportUI:(UISwitch *)sender;

- (void)protectAllFeatureButtons;
- (void)unprotectAllFeatureButtons;
- (void)screenCaptureStatusChanged:(NSNotification *)notification;
- (void)toggleStreamMode:(UISwitch *)sender;

- (void)addMasterToggleGesture;
- (void)toggleMasterVisibility:(UITapGestureRecognizer *)gesture;
- (void)handleFeatureDrag:(UIPanGestureRecognizer *)gesture;

- (id)createFeatureButton:(NSString *)title withTag:(NSInteger)tag;
- (id)createFeatureSwitchContainer;
- (CGPoint)loadButtonPosition:(NSInteger)tag defaultX:(CGFloat)defaultX defaultY:(CGFloat)defaultY;
- (void)saveButtonPosition:(UIButton *)button;
- (void)setAllButtonsVisible:(BOOL)visible;

- (UIColor *)accentColor;
- (UIColor *)textColor;
- (UIColor *)glowColor;
- (UIColor *)pillColor;
- (UIColor *)checkboxOffColor;

- (NSString *)settingsFilePath;
- (void)loadResolutionAndLineOriginFromSettingsFile;

- (NSArray *)buildMenuTabs;

+ (void)toggleMenuFromFloatingButton;

@end

// ============================================================================
// GLOBAL VARIABLES
// ============================================================================

// Feature enable/disable
static char byte_B2D5C = 1;
static char byte_B2D7C = 0;
static char byte_B2D82 = 0;
static char byte_B2D86 = 0;
static char byte_B2D8D = 0;
static char byte_B2D4A = 0;
static char byte_B2D9B = 0;
static char byte_B2D9C = 0;
static char byte_B3A7E = 0;
static char byte_B3B55 = 0;
static char byte_B3B14 = 0;
static char byte_B3B0C = 0;
static char byte_B3B0E = 0;
static char byte_B3AF8 = 0;
static char byte_B3A7F = 0;
static char byte_B3B0A = 0;
static char byte_B3AF5 = 0;
static char byte_B2E2C = 0;
static char byte_B3B0F = 0;

// UI visibility
static char byte_B2D98 = 1;
static char byte_B2DC5 = 1;
static char byte_B2DD4 = 1;
static char byte_B2D64 = 1;
static char byte_B2D85 = 1;
static char byte_B3358 = 1;
static char byte_B3359 = 1;
static char byte_B335A = 1;
static char byte_B2E24 = 1;
static char byte_B2E25 = 1;
static char byte_B2E2D = 1;
static char byte_B335C = 1;
static char byte_B335B = 1;
static char byte_B335D = 1;

// ESP settings
static char byte_B2DD5 = 0;
static char byte_B2D7B = 0;
static char byte_B2DEE = 0;
static char byte_B2DEB = 0;
static char byte_B2DEC = 0;
static char byte_B2DEA = 0;
static char byte_B2DE9 = 0;
static char byte_B2E26 = 0;
static char byte_B2E08 = 0;
static char byte_B2CE8 = 0;

// Aimbot settings
static char byte_B3B71 = 0;
static char byte_B2E2E = 0;
static char byte_B2D5D = 0;
static char byte_B3B74 = 0;
static char byte_B2D99 = 0;
static char byte_B2D7A = 0;
static char byte_B2D7F = 0;
static char byte_B3B73 = 0;

// Integer settings
static int dword_B2CD4 = 5;
static int dword_B2CD8 = 120;
static float dword_B2CE4 = 8.0;
static float dword_B2D60 = 1.0;
static int dword_B39D0 = 0;
static int dword_B3B58 = 0;
static int dword_B3B5C = 0;
static int dword_B2D74 = 0;
static int dword_B39DC = 0;

// Resolution settings
static char byte_B2CC4 = 0;
static int dword_B2CC8 = 120;
static char byte_B2CCC = 0;
static int dword_B39D4 = 0;
static int dword_B39D8 = 0;

static UIWindow *g_keyWindow = nil;
static UIButton *g_floatingButton = nil;
static ModMenuViewController *g_modMenuVC = nil;

// ============================================================================
// CATEGORY INTERFACE
// ============================================================================

@interface ModMenuViewController (FFHack)
- (void)configureSwitch:(UISwitch *)switchControl forTag:(NSInteger)tag withSelector:(NSString *)selector;
- (void)saveButtonState:(NSMutableDictionary *)dict tag:(NSInteger)tag value:(BOOL)value;
- (BOOL)loadButtonState:(NSDictionary *)buttons tag:(NSInteger)tag defaultValue:(BOOL)defaultValue;
@end

// ============================================================================
// CATEGORY IMPLEMENTATION
// ============================================================================

@implementation ModMenuViewController (FFHack)

#pragma mark - Lifecycle

- (void)setupBackend {
    if (!self.isBackendStarted) {
        self.isBackendStarted = YES;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            byte_B2D5C = 1;
        });
        
        [self setupDisplayLink];
        [self startFPSTimer];
    }
}

- (void)setupUI {
    [self loadUIState];
    
    UIColor *savedColor = [self loadSavedThemeColor];
    self.currentThemeColor = savedColor ?: [UIColor colorWithRed:0.2 green:0.6 blue:0.9 alpha:1.0];
    
    [self loadResolutionAndLineOriginFromSettingsFile];
    
    if (byte_B2CCC) {
        UIScreen *screen = [UIScreen mainScreen];
        CGRect nativeBounds = screen.nativeBounds;
        dword_B39D4 = (int)nativeBounds.size.width;
        dword_B39D8 = (int)nativeBounds.size.height;
        byte_B2CC4 = 1;
        dword_B2CC8 = 120;
    } else {
        if (dword_B39D4 <= 0 || dword_B39D8 <= 0) {
            UIScreen *screen = [UIScreen mainScreen];
            CGRect nativeBounds = screen.nativeBounds;
            dword_B39D4 = (int)nativeBounds.size.width;
            dword_B39D8 = (int)nativeBounds.size.height;
        }
        if (dword_B2CC8 <= 0) {
            dword_B2CC8 = 120;
        }
    }
    
    [self setAllButtonsVisible:byte_B335D];
    [self addMasterToggleGesture];
    [self createFloatingMenu];
    [self loadMenuState];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(screenCaptureStatusChanged:)
                                                 name:UIScreenCapturedDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveUIState)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveUIState)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveUIState)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
}

- (void)initializeMenu {
    [self setupBackend];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBackend];
}

- (void)setupDisplayLink {
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateFrame)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)startFPSTimer {
    __weak typeof(self) weakSelf = self;
    self.fpsTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer *timer) {
        weakSelf.currentFPS = weakSelf.frameCount;
        weakSelf.frameCount = 0;
    }];
}

- (void)updateFrame {
    if (!byte_B2D5C) return;
    self.frameCount++;
}

- (void)dealloc {
    [self.fpsTimer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Feature Buttons

- (void)createAllFeatureButtons {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (!keyWindow || !byte_B335D) return;
    
    [self removeAllFeatureButtons];
    
    UIScreen *screen = [UIScreen mainScreen];
    CGFloat defaultX = (screen.bounds.size.width - 90) * 0.5;
    CGFloat defaultY = (screen.bounds.size.height - 90) * 0.5;
    
    NSArray *configs = @[
        @{@"title": @"GHOST", @"tag": @88801, @"var": @(byte_B2D98), @"sel": @"ghostSwitchChanged:"},
        @{@"title": @"TELE VIP", @"tag": @88802, @"var": @(byte_B2DC5), @"sel": @"teleVIPSwitchChanged:"},
        @{@"title": @"KILL", @"tag": @88803, @"var": @(byte_B2DD4), @"sel": @"undergroundSwitchChanged:"},
        @{@"title": @"AI KILL", @"tag": @88804, @"var": @(byte_B2D64), @"sel": @"aiTelekillSwitchChanged:"},
        @{@"title": @"NINJA", @"tag": @88805, @"var": @(byte_B2D85), @"sel": @"ninjaRunSwitchChanged:"},
        @{@"title": @"FLY ALT", @"tag": @88806, @"var": @(byte_B2D9B), @"sel": @"flyAlturaSwitchChanged:"},
        @{@"title": @"Invisible", @"tag": @88807, @"var": @(byte_B2D9C), @"sel": @"flyNormalSwitchChanged:"},
        @{@"title": @"Flyv2", @"tag": @88816, @"var": @(byte_B335B), @"sel": @"flyv2SwitchChanged:"},
        @{@"title": @"FlyGLD", @"tag": @88808, @"var": @(byte_B2E24), @"sel": @"savePosSwitchChanged:"},
        @{@"title": @"GO TELEPORT STATE", @"tag": @88813, @"var": @(byte_B3358), @"sel": @"goTeleportStateSwitchChanged:"},
        @{@"title": @"STOP MOVE", @"tag": @88814, @"var": @(byte_B3359), @"sel": @"stopMoveSwitchChanged:"},
        @{@"title": @"HORIZ SPEED", @"tag": @88815, @"var": @(byte_B335A), @"sel": @"horizontalSpeedSwitchChanged:"},
        @{@"title": @"Aimkill", @"tag": @88809, @"var": @(byte_B2E25), @"sel": @"clearAntiuSwitchChanged:"},
        @{@"title": @"MAGNET KILL", @"tag": @88810, @"var": @(byte_B2E2D), @"sel": @"magnetKillSwitchChanged:"},
        @{@"title": @"MARK TP", @"tag": @88817, @"var": @(byte_B335C), @"sel": @"markTeleportSwitchChanged:"}
    ];
    
    for (NSDictionary *config in configs) {
        if (![config[@"var"] boolValue]) continue;
        
        NSInteger tag = [config[@"tag"] integerValue];
        CGPoint position = [self loadButtonPosition:tag defaultX:defaultX defaultY:defaultY];
        
        UIButton *button = [self createFeatureButton:config[@"title"] withTag:tag];
        button.frame = CGRectMake(position.x, position.y, 90, 90);
        [keyWindow addSubview:button];
        
        UIView *container = [self createFeatureSwitchContainer];
        UISwitch *switchControl = [container viewWithTag:400];
        switchControl.frame = CGRectMake((90 - container.frame.size.width) / 2, 24, 
                                         container.frame.size.width, container.frame.size.height);
        [button addSubview:container];
        
        [self configureSwitch:switchControl forTag:tag withSelector:config[@"sel"]];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleFeatureDrag:)];
        [button addGestureRecognizer:pan];
        
        // Lưu reference
        [self storeButtonReference:button switchControl:switchControl forTag:tag];
    }
}

- (void)storeButtonReference:(UIButton *)button switchControl:(UISwitch *)switchControl forTag:(NSInteger)tag {
    switch (tag) {
        case 88801: self.ghostButtonView = button; self.ghostSwitch = switchControl; break;
        case 88802: self.teleVIPButtonView = button; self.teleVIPSwitch = switchControl; break;
        case 88803: self.undergroundButtonView = button; self.undergroundSwitch = switchControl; break;
        case 88804: self.aiTelekillButtonView = button; self.aiTelekillSwitch = switchControl; break;
        case 88805: self.ninjaRunButtonView = button; self.ninjaRunSwitch = switchControl; break;
        case 88806: self.flyAlturaButtonView = button; self.flyAlturaSwitch = switchControl; break;
        case 88807: self.flyNormalButtonView = button; self.flyNormalSwitch = switchControl; break;
        case 88808: self.savePosButtonView = button; self.savePosSwitch = switchControl; break;
        case 88809: self.clearAntiuButtonView = button; self.clearAntiuSwitch = switchControl; break;
        case 88810: self.magnetKillButtonView = button; self.magnetKillSwitch = switchControl; break;
        case 88813: self.goTeleportStateButtonView = button; self.goTeleportStateSwitch = switchControl; break;
        case 88814: self.stopMoveButtonView = button; self.stopMoveSwitch = switchControl; break;
        case 88815: self.horizontalSpeedButtonView = button; self.horizontalSpeedSwitch = switchControl; break;
        case 88816: self.flyv2ButtonView = button; self.flyv2Switch = switchControl; break;
        case 88817: self.markTeleportButtonView = button; self.markTeleportSwitch = switchControl; break;
    }
}

- (void)configureSwitch:(UISwitch *)switchControl forTag:(NSInteger)tag withSelector:(NSString *)selector {
    switch (tag) {
        case 88801: switchControl.on = byte_B2D7C; break;
        case 88802: switchControl.on = byte_B2D82; break;
        case 88803: switchControl.on = byte_B2D86; break;
        case 88804: switchControl.on = byte_B2D8D; break;
        case 88805: switchControl.on = byte_B2D4A; break;
        case 88806: switchControl.on = 0; break;
        case 88807: switchControl.on = byte_B3B55; break;
        case 88808: switchControl.on = byte_B3B0C; break;
        case 88809: switchControl.on = byte_B3B0A; break;
        case 88810: switchControl.on = byte_B2E2C; break;
        case 88813: switchControl.on = byte_B3B0E; break;
        case 88814: switchControl.on = byte_B3AF8; break;
        case 88815: switchControl.on = byte_B3A7F; break;
        case 88816: switchControl.on = byte_B3B14; break;
        case 88817: switchControl.on = byte_B3B0F; break;
    }
    [switchControl addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventValueChanged];
}

- (void)removeAllFeatureButtons {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (!keyWindow) return;
    
    NSArray *tags = @[@88801, @88802, @88803, @88804, @88805, @88806, @88807, @88808, 
                      @88813, @88814, @88815, @88816, @88809, @88810, @88817];
    
    for (NSNumber *tag in tags) {
        [[keyWindow viewWithTag:[tag integerValue]] removeFromSuperview];
    }
    
    self.ghostButtonView = nil;
    self.teleVIPButtonView = nil;
    self.undergroundButtonView = nil;
    self.aiTelekillButtonView = nil;
    self.ninjaRunButtonView = nil;
    self.flyAlturaButtonView = nil;
    self.flyNormalButtonView = nil;
    self.flyv2ButtonView = nil;
    self.savePosButtonView = nil;
    self.goTeleportStateButtonView = nil;
    self.stopMoveButtonView = nil;
    self.horizontalSpeedButtonView = nil;
    self.clearAntiuButtonView = nil;
    self.magnetKillButtonView = nil;
    self.markTeleportButtonView = nil;
}

- (void)updateUIButtonVisibility {
    [self createAllFeatureButtons];
}

- (void)updateFeatureButtonTheme:(UIButton *)button {
    if (!button) return;
    
    [[button viewWithTag:5011] removeFromSuperview];
    [[button viewWithTag:5012] removeFromSuperview];
    
    button.backgroundColor = [UIColor clearColor];
    button.layer.borderWidth = 0;
    button.layer.shadowOpacity = 0;
    
    UILabel *titleLabel = [button viewWithTag:200];
    if (titleLabel) {
        titleLabel.textColor = [self accentColor];
    }
    
    for (UIView *subview in button.subviews) {
        if (subview.tag == 401) {
            UISwitch *switchControl = [subview viewWithTag:400];
            switchControl.onTintColor = [self accentColor];
            
            UIColor *accent = [self accentColor];
            CGFloat r, g, b, a;
            [accent getRed:&r green:&g blue:&b alpha:&a];
            subview.layer.borderColor = [UIColor colorWithRed:r * 0.7 green:g * 0.7 blue:b * 0.7 alpha:1.0].CGColor;
            subview.layer.shadowColor = accent.CGColor;
        }
    }
}

- (void)updateAllFeatureButtonThemes {
    [self updateFeatureButtonTheme:self.ghostButtonView];
    [self updateFeatureButtonTheme:self.teleVIPButtonView];
    [self updateFeatureButtonTheme:self.undergroundButtonView];
    [self updateFeatureButtonTheme:self.aiTelekillButtonView];
    [self updateFeatureButtonTheme:self.ninjaRunButtonView];
    [self updateFeatureButtonTheme:self.flyAlturaButtonView];
    [self updateFeatureButtonTheme:self.flyNormalButtonView];
    [self updateFeatureButtonTheme:self.flyv2ButtonView];
    [self updateFeatureButtonTheme:self.savePosButtonView];
    [self updateFeatureButtonTheme:self.goTeleportStateButtonView];
    [self updateFeatureButtonTheme:self.stopMoveButtonView];
    [self updateFeatureButtonTheme:self.horizontalSpeedButtonView];
    [self updateFeatureButtonTheme:self.clearAntiuButtonView];
    [self updateFeatureButtonTheme:self.magnetKillButtonView];
    [self updateFeatureButtonTheme:self.markTeleportButtonView];
}

- (void)createFloatingMenu {
    // Tạo floating menu đơn giản
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (!keyWindow) return;
    
    // Tạo button floating
    if (!g_floatingButton) {
        g_floatingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        g_floatingButton.frame = CGRectMake(20, 100, 75, 30);
        g_floatingButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        g_floatingButton.layer.cornerRadius = 15;
        g_floatingButton.layer.masksToBounds = NO;
        g_floatingButton.layer.shadowColor = [UIColor blackColor].CGColor;
        g_floatingButton.layer.shadowOpacity = 0.3;
        g_floatingButton.layer.shadowRadius = 8;
        g_floatingButton.layer.shadowOffset = CGSizeMake(0, 2);
        [g_floatingButton setTitle:@"MOD" forState:UIControlStateNormal];
        [g_floatingButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        g_floatingButton.titleLabel.font = [UIFont italicSystemFontOfSize:12];
        [g_floatingButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
        [keyWindow addSubview:g_floatingButton];
    }
    
    // Tạo menu view đơn giản
    if (!self.floatingMenu) {
        UIView *menuView = [[UIView alloc] initWithFrame:CGRectMake((keyWindow.bounds.size.width - 300) / 2,
                                                                     (keyWindow.bounds.size.height - 400) / 2,
                                                                     300, 400)];
        menuView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.95];
        menuView.layer.cornerRadius = 20;
        menuView.layer.masksToBounds = YES;
        menuView.hidden = YES;
        menuView.tag = 99999;
        
        // Title
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 300, 30)];
        titleLabel.text = @"FLUCK MOD MENU";
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [menuView addSubview:titleLabel];
        
        // Close button
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        closeBtn.frame = CGRectMake(260, 10, 30, 30);
        [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
        [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(hideMenu) forControlEvents:UIControlEventTouchUpInside];
        [menuView addSubview:closeBtn];
        
        // Feature toggle buttons
        NSArray *features = @[
            @{@"title": @"GHOST", @"tag": @1001, @"var": &byte_B2D7C},
            @{@"title": @"TELE VIP", @"tag": @1002, @"var": &byte_B2D82},
            @{@"title": @"UNDERGROUND", @"tag": @1003, @"var": &byte_B2D86},
            @{@"title": @"AI KILL", @"tag": @1004, @"var": &byte_B2D8D},
            @{@"title": @"NINJA RUN", @"tag": @1005, @"var": &byte_B2D4A},
            @{@"title": @"FLY ALT", @"tag": @1006, @"var": &byte_B3A7E},
            @{@"title": @"INVISIBLE", @"tag": @1007, @"var": &byte_B3B55},
            @{@"title": @"FLYV2", @"tag": @1008, @"var": &byte_B3B14},
            @{@"title": @"SAVE POS", @"tag": @1009, @"var": &byte_B3B0C},
            @{@"title": @"TELEPORT", @"tag": @1010, @"var": &byte_B3B0E},
        ];
        
        for (int i = 0; i < features.count; i++) {
            NSDictionary *feature = features[i];
            char *var = (char *)[feature[@"var"] pointerValue];
            
            UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(230, 50 + i * 35, 50, 30)];
            sw.on = *var;
            sw.tag = [feature[@"tag"] integerValue];
            [sw addTarget:self action:@selector(toggleFeatureSwitch:) forControlEvents:UIControlEventValueChanged];
            [menuView addSubview:sw];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 50 + i * 35, 200, 30)];
            label.text = feature[@"title"];
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont systemFontOfSize:14];
            [menuView addSubview:label];
        }
        
        [keyWindow addSubview:menuView];
        self.floatingMenu = menuView;
    }
}

- (void)toggleFeatureSwitch:(UISwitch *)sender {
    switch (sender.tag) {
        case 1001: byte_B2D7C = sender.isOn; break;
        case 1002: byte_B2D82 = sender.isOn; break;
        case 1003: byte_B2D86 = sender.isOn; break;
        case 1004: byte_B2D8D = sender.isOn; break;
        case 1005: byte_B2D4A = sender.isOn; break;
        case 1006: byte_B3A7E = sender.isOn; break;
        case 1007: byte_B3B55 = sender.isOn; break;
        case 1008: byte_B3B14 = sender.isOn; break;
        case 1009: byte_B3B0C = sender.isOn; break;
        case 1010: byte_B3B0E = sender.isOn; break;
    }
    [self saveUIState];
}

- (void)showMenu {
    self.isMenuOpen = YES;
    if (self.floatingMenu) {
        self.floatingMenu.hidden = NO;
        [self.floatingMenu.superview bringSubviewToFront:self.floatingMenu];
    }
    if (g_floatingButton) {
        g_floatingButton.hidden = YES;
    }
    [self saveUIState];
}

- (void)hideMenu {
    self.isMenuOpen = NO;
    if (self.floatingMenu) {
        self.floatingMenu.hidden = YES;
    }
    if (g_floatingButton) {
        g_floatingButton.hidden = NO;
    }
    [self saveUIState];
}

- (void)toggleMenu {
    if (self.isMenuOpen) {
        [self hideMenu];
    } else {
        [self showMenu];
    }
}

#pragma mark - State Management

- (void)saveUIState {
    NSMutableDictionary *state = [[self readUIStateJSON] mutableCopy];
    NSMutableDictionary *buttonStates = [NSMutableDictionary dictionary];
    
    [self saveButtonState:buttonStates tag:88801 value:byte_B2D98];
    [self saveButtonState:buttonStates tag:88802 value:byte_B2DC5];
    [self saveButtonState:buttonStates tag:88803 value:byte_B2DD4];
    [self saveButtonState:buttonStates tag:88804 value:byte_B2D64];
    [self saveButtonState:buttonStates tag:88805 value:byte_B2D85];
    [self saveButtonState:buttonStates tag:88806 value:byte_B2D9B];
    [self saveButtonState:buttonStates tag:88807 value:byte_B2D9C];
    [self saveButtonState:buttonStates tag:88808 value:byte_B2E24];
    [self saveButtonState:buttonStates tag:88813 value:byte_B3358];
    [self saveButtonState:buttonStates tag:88814 value:byte_B3359];
    [self saveButtonState:buttonStates tag:88815 value:byte_B335A];
    [self saveButtonState:buttonStates tag:88816 value:byte_B335B];
    [self saveButtonState:buttonStates tag:88809 value:byte_B2E25];
    [self saveButtonState:buttonStates tag:88810 value:byte_B2E2D];
    [self saveButtonState:buttonStates tag:88817 value:byte_B335C];
    
    state[@"buttons"] = buttonStates;
    
    if (self.currentThemeColor) {
        state[@"themeColor"] = [self serializeColor:self.currentThemeColor];
    }
    
    state[@"showAllButtons"] = @(byte_B335D);
    state[@"AimFov"] = @(*(float *)&dword_B2D60);
    state[@"TakeDamageTimerMin"] = @(dword_B2CD4);
    state[@"TakeDamageTimerMax"] = @(dword_B2CD8);
    state[@"goTeleportStateRadius"] = @(*(float *)&dword_B2CE4);
    
    [self writeUIStateJSON:state];
    [self saveMenuState];
}

- (void
