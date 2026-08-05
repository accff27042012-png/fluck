// ============================================================================
// ffhack.mm - Mod Menu Hack
// ============================================================================

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <sys/sysctl.h>

// ============================================================================
// GLOBAL VARIABLES (từ decompilation)
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
static char byte_B3A83 = 0;
static char byte_B3B12 = 0;
static char byte_B3B54 = 0;
static char byte_B3AF2 = 0;
static char byte_B3A81 = 0;
static char byte_B3A82 = 0;
static char byte_B2E1F = 0;
static char byte_B3AF6 = 0;
static char byte_B3AF7 = 0;
static char byte_B3AF4 = 0;
static char byte_B2D4B = 0;
static char byte_B2D4C = 0;

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

// Protection
static char byte_B3B72 = 0;

// ============================================================================
// FORWARD DECLARATION - Khai báo class
// ============================================================================

@class ModMenuViewController;
@class _F1oatM3nuV;

// ============================================================================
// CATEGORY INTERFACE - Khai báo các method
// ============================================================================

@interface ModMenuViewController (FFHack)

// Lifecycle
- (void)setupBackend;
- (void)setupUI;
- (void)initializeMenu;
- (void)viewDidLoad;
- (void)setupDisplayLink;
- (void)startFPSTimer;
- (void)updateFrame;
- (void)dealloc;

// Feature Buttons
- (void)createAllFeatureButtons;
- (void)removeAllFeatureButtons;
- (void)updateUIButtonVisibility;
- (void)updateFeatureButtonTheme:(UIButton *)button;
- (void)updateAllFeatureButtonThemes;
- (void)createFloatingMenu;
- (void)showMenu;
- (void)hideMenu;
- (void)toggleMenu;

// State Management
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

// Feature Actions
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

// Toggle Visibility
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

// Protection
- (void)protectAllFeatureButtons;
- (void)unprotectAllFeatureButtons;
- (void)screenCaptureStatusChanged:(NSNotification *)notification;
- (void)toggleStreamMode:(UISwitch *)sender;

// Gestures
- (void)addMasterToggleGesture;
- (void)toggleMasterVisibility:(UITapGestureRecognizer *)gesture;
- (void)handleFeatureDrag:(UIPanGestureRecognizer *)gesture;

// Button Helpers
- (id)createFeatureButton:(NSString *)title withTag:(NSInteger)tag;
- (id)createFeatureSwitchContainer;
- (CGPoint)loadButtonPosition:(NSInteger)tag defaultX:(CGFloat)defaultX defaultY:(CGFloat)defaultY;
- (void)saveButtonPosition:(UIButton *)button;
- (void)setAllButtonsVisible:(BOOL)visible;

// Theme
- (UIColor *)accentColor;
- (UIColor *)textColor;
- (UIColor *)glowColor;
- (UIColor *)pillColor;
- (UIColor *)checkboxOffColor;

// Settings
- (NSString *)settingsFilePath;
- (void)loadResolutionAndLineOriginFromSettingsFile;

// Menu Building
- (NSArray *)buildMenuTabs;

// Class Methods
+ (void)toggleMenuFromFloatingButton;

@end

// ============================================================================
// CATEGORY IMPLEMENTATION - Code của các method
// ============================================================================

@implementation ModMenuViewController (FFHack)

#pragma mark - Lifecycle Methods

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
        
        UIView *container = [self createFeatureSwitchContainer];
        UISwitch *switchControl = [container viewWithTag:400];
        switchControl.frame = CGRectMake((90 - container.frame.size.width) / 2, 24, 
                                         container.frame.size.width, container.frame.size.height);
        [button addSubview:container];
        
        [self configureSwitch:switchControl forTag:tag withSelector:config[@"sel"]];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleFeatureDrag:)];
        [button addGestureRecognizer:pan];
        [keyWindow addSubview:button];
    }
}

- (void)configureSwitch:(UISwitch *)switchControl forTag:(NSInteger)tag withSelector:(NSString *)selector {
    switch (tag) {
        case 88801:
            switchControl.on = byte_B2D7C;
            [switchControl addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventValueChanged];
            self.ghostButtonView = (UIButton *)switchControl.superview.superview;
            self.ghostSwitch = switchControl;
            break;
        case 88802:
            switchControl.on = byte_B2D82;
            [switchControl addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventValueChanged];
            self.teleVIPButtonView = (UIButton *)switchControl.superview.superview;
            self.teleVIPSwitch = switchControl;
            break;
        case 88803:
            switchControl.on = byte_B2D86;
            [switchControl addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventValueChanged];
            self.undergroundButtonView = (UIButton *)switchControl.superview.superview;
            self.undergroundSwitch = switchControl;
            break;
        case 88804:
            switchControl.on = byte_B2D8D;
            [switchControl addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventValueChanged];
            self.aiTelekillButtonView = (UIButton *)switchControl.superview.superview;
            self.aiTelekillSwitch = switchControl;
            break;
        case 88805:
            switchControl.on = byte_B2D4A;
            [switchControl addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventValueChanged];
            self.ninjaRunButtonView = (UIButton *)switchControl.superview.superview;
            self.ninjaRunSwitch = switchControl;
            break;
        case 88806:
            switchControl.on = 0;
            [switchControl addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventValueChanged];
            self.flyAlturaButtonView = (UIButton *)switchControl.superview.superview;
            self.flyAlturaSwitch = switchControl;
            break;
        case 88807:
            switchControl.on = byte_B3B55;
            [switchControl addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventValueChanged];
            self.flyNormalButtonView = (UIButton *)switchControl.superview.superview;
            self.flyNormalSwitch = switchControl;
            break;
        case 88808:
            switchControl.on = byte_B3B0C;
            [switchControl addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventValueChanged];
            self.savePosButtonView = (UIButton *)switchControl.superview.superview;
            self.savePosSwitch = switchControl;
            break;
        case 88809:
            switchControl.on = byte_B3B0A;
            [switchControl addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventValueChanged];
            self.clearAntiuButtonView = (UIButton *)switchControl.superview.superview;
            self.clearAntiuSwitch = switchControl;
            break;
        case 88810:
            switchControl.on = byte_B2E2C;
            [switchControl addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventValueChanged];
            self.magnetKillButtonView = (UIButton *)switchControl.superview.superview;
            self.magnetKillSwitch = switchControl;
            break;
        case 88813:
            switchControl.on = byte_B3B0E;
            [switchControl addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventValueChanged];
            self.goTeleportStateButtonView = (UIButton *)switchControl.superview.superview;
            self.goTeleportStateSwitch = switchControl;
            break;
        case 88814:
            switchControl.on = byte_B3AF8;
            [switchControl addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventValueChanged];
            self.stopMoveButtonView = (UIButton *)switchControl.superview.superview;
            self.stopMoveSwitch = switchControl;
            break;
        case 88815:
            switchControl.on = byte_B3A7F;
            [switchControl addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventValueChanged];
            self.horizontalSpeedButtonView = (UIButton *)switchControl.superview.superview;
            self.horizontalSpeedSwitch = switchControl;
            break;
        case 88816:
            switchControl.on = byte_B3B14;
            [switchControl addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventValueChanged];
            self.flyv2ButtonView = (UIButton *)switchControl.superview.superview;
            self.flyv2Switch = switchControl;
            break;
        case 88817:
            switchControl.on = byte_B3B0F;
            [switchControl addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventValueChanged];
            self.markTeleportButtonView = (UIButton *)switchControl.superview.superview;
            self.markTeleportSwitch = switchControl;
            break;
    }
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
    // Implementation sẽ được thêm sau
}

- (void)showMenu {
    self.isMenuOpen = YES;
    self.floatingMenu.hidden = NO;
    [self.floatingMenu reloadData];
    [self saveUIState];
}

- (void)hideMenu {
    self.isMenuOpen = NO;
    self.floatingMenu.hidden = YES;
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

- (void)saveButtonState:(NSMutableDictionary *)dict tag:(NSInteger)tag value:(BOOL)value {
    NSString *key = [NSString stringWithFormat:@"%ld", (long)tag];
    dict[key] = @{@"visible": @(value)};
}

- (void)loadUIState {
    NSMutableDictionary *state = [[self readUIStateJSON] mutableCopy];
    
    UIColor *defaultColor = [UIColor colorWithRed:0.2 green:0.6 blue:0.9 alpha:1.0];
    id themeColorData = state[@"themeColor"];
    UIColor *loadedColor = [self deserializeColor:themeColorData fallback:defaultColor];
    self.currentThemeColor = loadedColor;
    
    NSDictionary *buttons = state[@"buttons"];
    if (buttons) {
        byte_B2D98 = [self loadButtonState:buttons tag:88801 defaultValue:byte_B2D98];
        byte_B2DC5 = [self loadButtonState:buttons tag:88802 defaultValue:byte_B2DC5];
        byte_B2DD4 = [self loadButtonState:buttons tag:88803 defaultValue:byte_B2DD4];
        byte_B2D64 = [self loadButtonState:buttons tag:88804 defaultValue:byte_B2D64];
        byte_B2D85 = [self loadButtonState:buttons tag:88805 defaultValue:byte_B2D85];
        byte_B2D9B = [self loadButtonState:buttons tag:88806 defaultValue:byte_B2D9B];
        byte_B2D9C = [self loadButtonState:buttons tag:88807 defaultValue:byte_B2D9C];
        byte_B2E24 = [self loadButtonState:buttons tag:88808 defaultValue:byte_B2E24];
        byte_B3358 = [self loadButtonState:buttons tag:88813 defaultValue:byte_B3358];
        byte_B3359 = [self loadButtonState:buttons tag:88814 defaultValue:byte_B3359];
        byte_B335A = [self loadButtonState:buttons tag:88815 defaultValue:byte_B335A];
        byte_B335B = [self loadButtonState:buttons tag:88816 defaultValue:byte_B335B];
        byte_B2E25 = [self loadButtonState:buttons tag:88809 defaultValue:byte_B2E25];
        byte_B2E2D = [self loadButtonState:buttons tag:88810 defaultValue:byte_B2E2D];
        byte_B335C = [self loadButtonState:buttons tag:88817 defaultValue:byte_B335C];
    }
    
    NSNumber *showAll = state[@"showAllButtons"];
    byte_B335D = showAll ? [showAll boolValue] : 1;
    
    NSNumber *aimFov = state[@"AimFov"];
    if (aimFov) dword_B2D60 = [aimFov floatValue];
    
    NSNumber *timerMin = state[@"TakeDamageTimerMin"];
    if (timerMin) dword_B2CD4 = [timerMin intValue];
    
    NSNumber *timerMax = state[@"TakeDamageTimerMax"];
    if (timerMax) dword_B2CD8 = [timerMax intValue];
    
    NSNumber *teleportRadius = state[@"goTeleportStateRadius"];
    if (teleportRadius) dword_B2CE4 = [teleportRadius floatValue];
    
    [self loadMenuState];
}

- (BOOL)loadButtonState:(NSDictionary *)buttons tag:(NSInteger)tag defaultValue:(BOOL)defaultValue {
    NSString *key = [NSString stringWithFormat:@"%ld", (long)tag];
    NSDictionary *buttonData = buttons[key];
    if (!buttonData) return defaultValue;
    
    NSNumber *visible = buttonData[@"visible"];
    if (!visible) return defaultValue;
    
    return [visible boolValue];
}

- (void)saveMenuState {
    NSMutableDictionary *state = [[self readUIStateJSON] mutableCopy];
    NSMutableDictionary *menuState = [NSMutableDictionary dictionary];
    
    menuState[@"isOpen"] = @(self.isMenuOpen);
    
    if (self.floatingMenu) {
        menuState[@"selectedTab"] = @(self.floatingMenu.selectedTabIndex);
        
        NSMutableDictionary *position = [NSMutableDictionary dictionary];
        position[@"x"] = @(self.floatingMenu.frame.origin.x);
        position[@"y"] = @(self.floatingMenu.frame.origin.y);
        menuState[@"position"] = position;
    }
    
    state[@"floatingMenu"] = menuState;
    [self writeUIStateJSON:state];
}

- (void)loadMenuState {
    NSDictionary *state = [self readUIStateJSON];
    NSDictionary *menuState = state[@"floatingMenu"];
    
    if (menuState) {
        self.isMenuOpen = [menuState[@"isOpen"] boolValue];
        
        NSNumber *selectedTab = menuState[@"selectedTab"];
        if (selectedTab && self.floatingMenu) {
            self.floatingMenu.selectedTabIndex = [selectedTab integerValue];
            [self.floatingMenu updateTabSelection];
            [self.floatingMenu reloadData];
        }
    } else {
        self.isMenuOpen = YES;
    }
    
    if (self.floatingMenu) {
        self.floatingMenu.hidden = !self.isMenuOpen;
    }
}

- (id)uiStateJSONPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths firstObject] stringByAppendingPathComponent:@"menu_ui_state.json"];
}

- (id)readUIStateJSON {
    NSString *path = [self uiStateJSONPath];
    if (!path) return [NSMutableDictionary dictionary];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data || data.length == 0) return [NSMutableDictionary dictionary];
    
    NSError *error;
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error || ![json isKindOfClass:[NSDictionary class]]) {
        return [NSMutableDictionary dictionary];
    }
    return [json mutableCopy];
}

- (void)writeUIStateJSON:(id)data {
    if (!data) return;
    
    NSString *path = [self uiStateJSONPath];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&error];
    if (jsonData && !error) {
        [jsonData writeToFile:path atomically:YES];
    }
}

- (id)serializeColor:(UIColor *)color {
    if (!color) return nil;
    
    CGFloat r, g, b, a;
    if ([color getRed:&r green:&g blue:&b alpha:&a]) {
        return @{@"r": @(r), @"g": @(g), @"b": @(b), @"a": @(a)};
    }
    return nil;
}

- (id)deserializeColor:(id)colorData fallback:(UIColor *)fallback {
    if (![colorData isKindOfClass:[NSDictionary class]]) return fallback;
    
    NSDictionary *dict = colorData;
    NSNumber *r = dict[@"r"];
    NSNumber *g = dict[@"g"];
    NSNumber *b = dict[@"b"];
    
    if (!r || !g || !b) return fallback;
    
    CGFloat alpha = dict[@"a"] ? [dict[@"a"] floatValue] : 1.0;
    return [UIColor colorWithRed:[r floatValue] green:[g floatValue] blue:[b floatValue] alpha:alpha];
}

- (UIColor *)loadSavedThemeColor {
    id state = [self readUIStateJSON];
    return [self deserializeColor:state[@"themeColor"] 
                         fallback:[UIColor colorWithRed:0.2 green:0.6 blue:0.9 alpha:1.0]];
}

#pragma mark - Feature Actions

- (void)ghostSwitchChanged:(UISwitch *)sender {
    byte_B2D7C = sender.isOn;
}

- (void)teleVIPSwitchChanged:(UISwitch *)sender {
    byte_B2D82 = sender.isOn;
    if (!sender.isOn) byte_B3A7E = 0;
}

- (void)undergroundSwitchChanged:(UISwitch *)sender {
    byte_B2D86 = sender.isOn;
}

- (void)aiTelekillSwitchChanged:(UISwitch *)sender {
    byte_B2D8D = sender.isOn;
}

- (void)ninjaRunSwitchChanged:(UISwitch *)sender {
    byte_B2D4A = sender.isOn;
}

- (void)flyAlturaSwitchChanged:(UISwitch *)sender {
    byte_B3A7E = sender.isOn;
}

- (void)flyNormalSwitchChanged:(UISwitch *)sender {
    byte_B3B55 = sender.isOn;
}

- (void)flyv2SwitchChanged:(UISwitch *)sender {
    byte_B3B14 = sender.isOn;
}

- (void)savePosSwitchChanged:(UISwitch *)sender {
    byte_B3B0C = sender.isOn;
}

- (void)goTeleportStateSwitchChanged:(UISwitch *)sender {
    byte_B3B0E = sender.isOn;
}

- (void)stopMoveSwitchChanged:(UISwitch *)sender {
    byte_B3AF8 = sender.isOn;
}

- (void)horizontalSpeedSwitchChanged:(UISwitch *)sender {
    byte_B3A7F = sender.isOn;
}

- (void)clearAntiuSwitchChanged:(UISwitch *)sender {
    byte_B3B0A = sender.isOn;
    byte_B3AF5 = sender.isOn;
}

- (void)magnetKillSwitchChanged:(UISwitch *)sender {
    byte_B2E2C = sender.isOn;
}

- (void)markTeleportSwitchChanged:(UISwitch *)sender {
    byte_B3B0F = sender.isOn;
}

#pragma mark - Toggle Visibility

- (void)toggleShowGhostUI:(UISwitch *)sender {
    byte_B2D98 = sender ? sender.isOn : !byte_B2D98;
    [self updateUIButtonVisibility];
}

- (void)toggleShowTeleVIPUI:(UISwitch *)sender {
    byte_B2DC5 = sender ? sender.isOn : !byte_B2DC5;
    [self updateUIButtonVisibility];
}

- (void)toggleShowUndergroundUI:(UISwitch *)sender {
    byte_B2DD4 = sender ? sender.isOn : !byte_B2DD4;
    [self updateUIButtonVisibility];
}

- (void)toggleShowAITelekillUI:(UISwitch *)sender {
    byte_B2D64 = sender ? sender.isOn : !byte_B2D64;
    [self updateUIButtonVisibility];
}

- (void)toggleShowNinjaRunUI:(UISwitch *)sender {
    byte_B2D85 = sender ? sender.isOn : !byte_B2D85;
    [self updateUIButtonVisibility];
}

- (void)toggleShowFlyAlturaUI:(UISwitch *)sender {
    byte_B2D9B = sender ? sender.isOn : !byte_B2D9B;
    [self updateUIButtonVisibility];
}

- (void)toggleUIFlyNormal:(UISwitch *)sender {
    byte_B2D9C = sender ? sender.isOn : !byte_B2D9C;
    [self updateUIButtonVisibility];
}

- (void)toggleShowFlyv2UI:(UISwitch *)sender {
    byte_B335B = sender ? sender.isOn : !byte_B335B;
    [self updateUIButtonVisibility];
}

- (void)toggleShowSavePosUI:(UISwitch *)sender {
    byte_B2E24 = sender ? sender.isOn : !byte_B2E24;
    [self updateUIButtonVisibility];
}

- (void)toggleShowGoTeleportStateUI:(UISwitch *)sender {
    byte_B3358 = sender ? sender.isOn : !byte_B3358;
    [self updateUIButtonVisibility];
}

- (void)toggleShowStopMoveUI:(UISwitch *)sender {
    byte_B3359 = sender ? sender.isOn : !byte_B3359;
    [self updateUIButtonVisibility];
}

- (void)toggleShowHorizontalSpeedUI:(UISwitch *)sender {
    byte_B335A = sender ? sender.isOn : !byte_B335A;
    [self updateUIButtonVisibility];
}

- (void)toggleShowClearAntiuUI:(UISwitch *)sender {
    byte_B2E25 = sender ? sender.isOn : !byte_B2E25;
    [self updateUIButtonVisibility];
}

- (void)toggleShowMagnetKillUI:(UISwitch *)sender {
    byte_B2E2D = sender ? sender.isOn : !byte_B2E2D;
    [self updateUIButtonVisibility];
}

- (void)toggleShowMarkTeleportUI:(UISwitch *)sender {
    byte_B335C = sender ? sender.isOn : !byte_B335C;
    [self updateUIButtonVisibility];
}

#pragma mark - Protection

- (void)protectAllFeatureButtons {
    // Implementation
}

- (void)unprotectAllFeatureButtons {
    // Implementation
}

- (void)screenCaptureStatusChanged:(NSNotification *)notification {
    // Implementation
}

- (void)toggleStreamMode:(UISwitch *)sender {
    // Implementation
}

- (void)setAllButtonsVisible:(BOOL)visible {
    byte_B335D = visible;
    byte_B2DD4 = visible;
    byte_B2D64 = visible;
    byte_B2D9B = visible;
    byte_B3358 = visible;
    byte_B3359 = visible;
    byte_B335A = visible;
    byte_B2E25 = visible;
    [self createAllFeatureButtons];
}

#pragma mark - Gestures

- (void)addMasterToggleGesture {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (!keyWindow) return;
    
    UIViewController *rootVC = keyWindow.rootViewController;
    if (!rootVC) return;
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleMasterVisibility:)];
    gesture.numberOfTapsRequired = 3;
    gesture.numberOfTouchesRequired = 3;
    [rootVC.view addGestureRecognizer:gesture];
}

- (void)toggleMasterVisibility:(UITapGestureRecognizer *)gesture {
    BOOL newState = !byte_B335D;
    byte_B335D ^= 1;
    [self setAllButtonsVisible:newState];
    
    UIImpactFeedbackGenerator *feedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
    [feedback impactOccurred];
}

- (void)handleFeatureDrag:(UIPanGestureRecognizer *)gesture {
    UIButton *button = (UIButton *)gesture.view;
    UIView *superview = button.superview;
    
    CGPoint translation = [gesture translationInView:superview];
    CGPoint center = button.center;
    button.center = CGPointMake(center.x + translation.x, center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:superview];
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self saveButtonPosition:button];
        [self saveUIState];
    }
}

#pragma mark - Button Helpers

- (id)createFeatureButton:(NSString *)title withTag:(NSInteger)tag {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
    button.tag = tag;
    button.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 90, 16)];
    label.text = title;
    label.font = [UIFont systemFontOfSize:10 weight:UIFontWeightBold];
    label.textColor = [self accentColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.tag = 200;
    [button addSubview:label];
    
    return button;
}

- (id)createFeatureSwitchContainer {
    UIView *container = [[UIView alloc] init];
    container.backgroundColor = [UIColor clearColor];
    
    UISwitch *switchControl = [[UISwitch alloc] init];
    switchControl.onTintColor = [self accentColor];
    switchControl.thumbTintColor = [UIColor whiteColor];
    switchControl.tag = 400;
    
    container.frame = CGRectMake(0, 0, 58, 39.3);
    switchControl.frame = CGRectMake(4, 4.2, 51, 31);
    
    UIColor *accent = [self accentColor];
    CGFloat r, g, b, a;
    [accent getRed:&r green:&g blue:&b alpha:&a];
    UIColor *borderColor = [UIColor colorWithRed:r * 0.7 green:g * 0.7 blue:b * 0.7 alpha:1.0];
    
    container.layer.borderWidth = 4.0;
    container.layer.borderColor = borderColor.CGColor;
    container.layer.cornerRadius = 19.65;
    container.layer.shadowColor = accent.CGColor;
    container.layer.shadowOpacity = 1.0;
    container.layer.shadowRadius = 25.0;
    container.layer.shadowOffset = CGSizeZero;
    container.layer.masksToBounds = NO;
    container.tag = 401;
    
    [container addSubview:switchControl];
    return container;
}

- (CGPoint)loadButtonPosition:(NSInteger)tag defaultX:(CGFloat)defaultX defaultY:(CGFloat)defaultY {
    NSDictionary *state = [self readUIStateJSON];
    NSDictionary *buttons = state[@"buttons"];
    
    if (!buttons) return CGPointMake(defaultX, defaultY);
    
    NSString *key = [NSString stringWithFormat:@"%ld", (long)tag];
    NSDictionary *buttonData = buttons[key];
    if (!buttonData) return CGPointMake(defaultX, defaultY);
    
    NSNumber *x = buttonData[@"x"];
    NSNumber *y = buttonData[@"y"];
    if (!x || !y) return CGPointMake(defaultX, defaultY);
    
    CGFloat posX = [x floatValue];
    CGFloat posY = [y floatValue];
    
    UIScreen *screen = [UIScreen mainScreen];
    CGFloat maxX = screen.bounds.size.width - 90;
    CGFloat maxY = screen.bounds.size.height - 90;
    
    return CGPointMake(MAX(0, MIN(posX, maxX)), MAX(0, MIN(posY, maxY)));
}

- (void)saveButtonPosition:(UIButton *)button {
    if (!button) return;
    
    NSMutableDictionary *state = [[self readUIStateJSON] mutableCopy];
    NSMutableDictionary *buttons = [state[@"buttons"] mutableCopy] ?: [NSMutableDictionary dictionary];
    
    NSString *key = [NSString stringWithFormat:@"%ld", (long)button.tag];
    NSMutableDictionary *buttonData = [buttons[key] mutableCopy] ?: [NSMutableDictionary dictionary];
    
    buttonData[@"x"] = @(button.frame.origin.x);
    buttonData[@"y"] = @(button.frame.origin.y);
    buttons[key] = buttonData;
    
    state[@"buttons"] = buttons;
    [self writeUIStateJSON:state];
}

#pragma mark - Theme

- (UIColor *)accentColor {
    return self.currentThemeColor ?: [UIColor colorWithRed:0.2 green:0.6 blue:0.9 alpha:1.0];
}

- (UIColor *)textColor {
    return [UIColor whiteColor];
}

- (UIColor *)glowColor {
    return [[self accentColor] colorWithAlphaComponent:0.6];
}

- (UIColor *)pillColor {
    return [UIColor colorWithWhite:0.18 alpha:0.38];
}

- (UIColor *)checkboxOffColor {
    return [UIColor blackColor];
}

#pragma mark - Settings

- (NSString *)settingsFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths firstObject] stringByAppendingPathComponent:@"settings.fluck"];
}

- (void)loadResolutionAndLineOriginFromSettingsFile {
    NSString *path = [self settingsFilePath];
    if (!path) return;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *content = nil;
    
    if ([fileManager fileExistsAtPath:path]) {
        content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    }
    
    if (!content || content.length == 0) {
        content = [[NSUserDefaults standardUserDefaults] stringForKey:@"FluckSettingsBackup"];
    }
    
    if (!content || content.length == 0) return;
    
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    for (NSString *line in [content componentsSeparatedByString:@"\n"]) {
        NSArray *parts = [line componentsSeparatedByString:@"="];
        if (parts.count == 2) {
            NSString *key = [parts[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString *value = [parts[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            settings[key] = value;
        }
    }
    
    NSNumber *lineOrigin = settings[@"LineOrigin"];
    if (lineOrigin) {
        int value = [lineOrigin intValue];
        if (value >= 0 && value <= 2) dword_B39D0 = value;
    }
    
    NSNumber *resolutionWidth = settings[@"ResolutionWidth"];
    if (resolutionWidth) {
        int value = [resolutionWidth intValue];
        if (value >= 720 && value <= 2000) dword_B39D4 = value;
    }
    
    NSNumber *resolutionHeight = settings[@"ResolutionHeight"];
    if (resolutionHeight) {
        int value = [resolutionHeight intValue];
        if (value >= 720 && value <= 2000) dword_B39D8 = value;
    }
}

#pragma mark - Menu Building

- (NSArray *)buildMenuTabs {
    return @[];
}

#pragma mark - Class Methods

+ (void)toggleMenuFromFloatingButton {
    // Implementation
}

@end

// ============================================================================
// CONSTRUCTOR - Khởi tạo khi load
// ============================================================================

__attribute__((constructor))
static void initializeHack(void) {
    NSLog(@"[FFHack] ✅ Đã tải thành công!");
    NSLog(@"[FFHack] 🔥 Mod Menu đã sẵn sàng");
}

// ============================================================================
// END OF FILE
// ============================================================================
