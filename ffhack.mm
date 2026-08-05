// ============================================================================
// ModMenuViewController.h
// ============================================================================

// ModMenuViewController.h
#import <UIKit/UIKit.h>

@class _F1oatM3nuV;

@interface ModMenuViewController : UIViewController

// Properties
@property (nonatomic, strong) UIColor *currentThemeColor;
@property (nonatomic, strong) _F1oatM3nuV *floatingMenu;
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

// State management
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

// Feature actions
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

// Toggle visibility
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

// Button helpers
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

// Menu building
- (NSArray *)buildMenuTabs;

// Class methods
+ (void)toggleMenuFromFloatingButton;

@end
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

// State management
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

// Feature actions
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

// Toggle visibility
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

// Button helpers
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

// Menu building
- (NSArray *)buildMenuTabs;

// Class methods
+ (void)toggleMenuFromFloatingButton;

@end

// ============================================================================
// ModMenuViewController.m
// ============================================================================

#import "ModMenuViewController.h"
#import "_F1oatM3nuV.h"
#import <sys/sysctl.h>

// ============================================================================
// Global Variables (from decompilation)
// ============================================================================

// Feature enable/disable
static char byte_B2D5C = 1;
static char byte_B2D7C = 0;        // Ghost
static char byte_B2D82 = 0;        // TeleVIP
static char byte_B2D86 = 0;        // Underground Kill
static char byte_B2D8D = 0;        // AI Telekill
static char byte_B2D4A = 0;        // Ninja Run
static char byte_B2D9B = 0;        // Fly Altura
static char byte_B2D9C = 0;        // Fly Normal
static char byte_B3A7E = 0;        // Fly Altura Switch
static char byte_B3B55 = 0;        // Fly Normal Switch
static char byte_B3B14 = 0;        // Flyv2 Switch
static char byte_B3B0C = 0;        // Save Pos Switch
static char byte_B3B0E = 0;        // Go Teleport State Switch
static char byte_B3AF8 = 0;        // Stop Move Switch
static char byte_B3A7F = 0;        // Horizontal Speed Switch
static char byte_B3B0A = 0;        // Clear Antiu Switch
static char byte_B3AF5 = 0;        // Clear Antiu (also aimkill)
static char byte_B2E2C = 0;        // Magnet Kill Switch
static char byte_B3B0F = 0;        // Mark Teleport Switch

// UI visibility
static char byte_B2D98 = 1;        // Show Ghost UI
static char byte_B2DC5 = 1;        // Show TeleVIP UI
static char byte_B2DD4 = 1;        // Show Underground UI
static char byte_B2D64 = 1;        // Show AI Telekill UI
static char byte_B2D85 = 1;        // Show Ninja Run UI
static char byte_B3358 = 1;        // Show Go Teleport State UI
static char byte_B3359 = 1;        // Show Stop Move UI
static char byte_B335A = 1;        // Show Horizontal Speed UI
static char byte_B2E24 = 1;        // Show Save Pos UI
static char byte_B2E25 = 1;        // Show Clear Antiu UI
static char byte_B2E2D = 1;        // Show Magnet Kill UI
static char byte_B335C = 1;        // Show Mark Teleport UI
static char byte_B335B = 1;        // Show Flyv2 UI
static char byte_B335D = 1;        // Show all buttons

// ESP settings
static char byte_B2DD5 = 0;        // Box
static char byte_B2D7B = 0;        // Lines
static char byte_B2DEE = 0;        // Skeleton
static char byte_B2DEB = 0;        // Health
static char byte_B2DEC = 0;        // Distance
static char byte_B2DEA = 0;        // Name
static char byte_B2DE9 = 0;        // Outline
static char byte_B2E26 = 0;        // Glow
static char byte_B2E08 = 0;        // Enemy Count
static char byte_B2CE8 = 0;        // Blood Visibility

// Aimbot settings
static char byte_B3B71 = 0;        // Aimbot
static char byte_B2E2E = 0;        // Aimkill
static char byte_B2D5D = 0;        // AutoFire
static char byte_B3B74 = 0;        // Speed Hack
static char byte_B2D99 = 0;        // Up Player
static char byte_B2D7A = 0;        // Telekill
static char byte_B2D7F = 0;        // Underground Kill2
static char byte_B3B73 = 0;        // Reset Guest
static char byte_B2D4B = 0;        // Ninja Run Speed (slow)
static char byte_B2D4C = 0;        // Ninja Run Speed (fast)
static char byte_B3A83 = 0;        // PhyxState
static char byte_B3B12 = 0;        // Fast
static char byte_B3B54 = 0;        // Mideum
static char byte_B3AF2 = 0;        // Swap Weapon
static char byte_B3A81 = 0;        // Second Phase
static char byte_B3A82 = 0;        // First Phase
static char byte_B2E1F = 0;        // Aimsilent
static char byte_B3AF6 = 0;        // AimAssist Rotation
static char byte_B3AF7 = 0;        // Damage Reflect
static char byte_B3AF4 = 0;        // Ignore Wall

// Integer settings
static int dword_B2CD4 = 5;        // Take damage timer min
static int dword_B2CD8 = 120;      // Take damage timer max
static float dword_B2CE4 = 8.0;    // Go teleport state radius
static float dword_B2D60 = 1.0;    // Aim FOV
static int dword_B39D0 = 0;        // Line Origin
static int dword_B3B58 = 0;        // Blood Type
static int dword_B3B5C = 0;        // Target Priority
static int dword_B2D74 = 0;        // Trigger When
static int dword_B39DC = 0;        // Target Bone

// Resolution settings
static char byte_B2CC4 = 0;        // Resolution Fullscreen
static int dword_B2CC8 = 120;      // Preferred Refresh Rate
static char byte_B2CCC = 0;        // Reset Resolution On Open
static int dword_B39D4 = 0;        // Resolution Width
static int dword_B39D8 = 0;        // Resolution Height

// Protection
static char byte_B3B72 = 0;        // Stream Mode

// ============================================================================
// Implementation
// ============================================================================

@implementation ModMenuViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBackend];
}

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
    
    // Resolution settings
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
    
    // Screen capture notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(screenCaptureStatusChanged:)
                                                 name:UIScreenCapturedDidChangeNotification
                                               object:nil];
    
    // Save state on app lifecycle events
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
    // Game state updates would go here
    self.frameCount++;
}

- (void)dealloc {
    [self.fpsTimer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Feature Button Management

- (void)createAllFeatureButtons {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (!keyWindow) return;
    
    [self removeAllFeatureButtons];
    if (!byte_B335D) return;
    
    UIScreen *screen = [UIScreen mainScreen];
    CGFloat screenWidth = screen.bounds.size.width;
    CGFloat screenHeight = screen.bounds.size.height;
    CGFloat defaultX = (screenWidth - 90.0) * 0.5;
    CGFloat defaultY = (screenHeight - 90.0) * 0.5;
    
    NSArray *buttonConfigs = @[
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
    
    for (NSDictionary *config in buttonConfigs) {
        if (![config[@"var"] boolValue]) continue;
        
        NSInteger tag = [config[@"tag"] integerValue];
        NSString *title = config[@"title"];
        NSString *selector = config[@"sel"];
        
        CGPoint position = [self loadButtonPosition:tag defaultX:defaultX defaultY:defaultY];
        
        UIButton *button = [self createFeatureButton:title withTag:tag];
        button.frame = CGRectMake(position.x, position.y, 90, 90);
        
        UILabel *titleLabel = [button viewWithTag:200];
        titleLabel.frame = CGRectMake(0, 5, 90, 16);
        
        UIView *switchContainer = [self createFeatureSwitchContainer];
        UISwitch *switchControl = [switchContainer viewWithTag:400];
        switchControl.frame = CGRectMake((90 - switchContainer.frame.size.width) / 2, 
                                         titleLabel.frame.origin.y + titleLabel.frame.size.height + 3,
                                         switchContainer.frame.size.width,
                                         switchContainer.frame.size.height);
        [button addSubview:switchContainer];
        
        switch (tag) {
            case 88801: // Ghost
                switchControl.on = byte_B2D7C;
                [switchControl addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventValueChanged];
                self.ghostButtonView = button;
                self.ghostSwitch = switchControl;
                break;
            case 88802: // TeleVIP
                switchControl.on = byte_B2D82;
                [switchControl addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventValueChanged];
                self.teleVIPButtonView = button;
                self.teleVIPSwitch = switchControl;
                break;
            case 88803: // Underground
                switchControl.on = byte_B2D86;
                [switchControl addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventValueChanged];
                self.undergroundButtonView = button;
                self.undergroundSwitch = switchControl;
                break;
            case 88804: // AI Telekill
                switchControl.on = byte_B2D8D;
                [switchControl addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventValueChanged];
                self.aiTelekillButtonView = button;
                self.aiTelekillSwitch = switchControl;
                break;
            case 88805: // Ninja Run
                switchControl.on = byte_B2D4A;
                [switchControl addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventValueChanged];
                self.ninjaRunButtonView = button;
                self.ninjaRunSwitch = switchControl;
                break;
            case 88806: // Fly Altura
                switchControl.on = 0;
                [switchControl addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventValueChanged];
                self.flyAlturaButtonView = button;
                self.flyAlturaSwitch = switchControl;
                break;
            case 88807: // Fly Normal
                switchControl.on = byte_B3B55;
                [switchControl addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventValueChanged];
                self.flyNormalButtonView = button;
                self.flyNormalSwitch = switchControl;
                break;
            case 88808: // Save Pos
                switchControl.on = byte_B3B0C;
                [switchControl addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventValueChanged];
                self.savePosButtonView = button;
                self.savePosSwitch = switchControl;
                break;
            case 88809: // Clear Antiu
                switchControl.on = byte_B3B0A;
                [switchControl addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventValueChanged];
                self.clearAntiuButtonView = button;
                self.clearAntiuSwitch = switchControl;
                break;
            case 88810: // Magnet Kill
                switchControl.on = byte_B2E2C;
                [switchControl addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventValueChanged];
                self.magnetKillButtonView = button;
                self.magnetKillSwitch = switchControl;
                break;
            case 88813: // Go Teleport State
                switchControl.on = byte_B3B0E;
                [switchControl addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventValueChanged];
                self.goTeleportStateButtonView = button;
                self.goTeleportStateSwitch = switchControl;
                break;
            case 88814: // Stop Move
                switchControl.on = byte_B3AF8;
                [switchControl addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventValueChanged];
                self.stopMoveButtonView = button;
                self.stopMoveSwitch = switchControl;
                break;
            case 88815: // Horizontal Speed
                switchControl.on = byte_B3A7F;
                [switchControl addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventValueChanged];
                self.horizontalSpeedButtonView = button;
                self.horizontalSpeedSwitch = switchControl;
                break;
            case 88816: // Flyv2
                switchControl.on = byte_B3B14;
                [switchControl addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventValueChanged];
                self.flyv2ButtonView = button;
                self.flyv2Switch = switchControl;
                break;
            case 88817: // Mark Teleport
                switchControl.on = byte_B3B0F;
                [switchControl addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventValueChanged];
                self.markTeleportButtonView = button;
                self.markTeleportSwitch = switchControl;
                break;
        }
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleFeatureDrag:)];
        [button addGestureRecognizer:panGesture];
        [keyWindow addSubview:button];
    }
}

- (id)createFeatureButton:(NSString *)title withTag:(NSInteger)tag {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
    button.tag = tag;
    button.backgroundColor = [UIColor clearColor];
    button.layer.cornerRadius = 0;
    button.clipsToBounds = NO;
    button.layer.borderWidth = 0;
    button.layer.shadowOpacity = 0;
    button.layer.masksToBounds = NO;
    
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
    container.clipsToBounds = NO;
    
    UISwitch *switchControl = [[UISwitch alloc] init];
    switchControl.onTintColor = [self accentColor];
    switchControl.thumbTintColor = [UIColor whiteColor];
    switchControl.backgroundColor = [UIColor clearColor];
    switchControl.clipsToBounds = NO;
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

- (void)removeAllFeatureButtons {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (!keyWindow) return;
    
    NSArray *tags = @[@88801, @88802, @88803, @88804, @88805, @88806, @88807, @88808, 
                      @88813, @88814, @88815, @88816, @88809, @88810, @88817];
    
    for (NSNumber *tag in tags) {
        UIView *view = [keyWindow viewWithTag:[tag integerValue]];
        [view removeFromSuperview];
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
    button.layer.shadowRadius = 0;
    button.layer.borderColor = nil;
    
    UILabel *titleLabel = [button viewWithTag:200];
    if (titleLabel) {
        titleLabel.textColor = [self accentColor];
    }
    
    for (UIView *subview in button.subviews) {
        if (subview.tag == 401) {
            UISwitch *switchControl = [subview viewWithTag:400];
            if (switchControl) {
                switchControl.onTintColor = [self accentColor];
            }
            
            UIColor *accent = [self accentColor];
            CGFloat r, g, b, a;
            [accent getRed:&r green:&g blue:&b alpha:&a];
            UIColor *borderColor = [UIColor colorWithRed:r * 0.7 green:g * 0.7 blue:b * 0.7 alpha:1.0];
            subview.layer.borderColor = borderColor.CGColor;
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

#pragma mark - Floating Menu

- (void)createFloatingMenu {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (!keyWindow) return;
    
    [self.floatingMenu removeFromSuperview];
    
    NSArray *tabs = [self buildMenuTabs];
    self.menuTabs = tabs;
    
    CGFloat width = keyWindow.bounds.size.width;
    CGFloat height = keyWindow.bounds.size.height;
    
    _F1oatM3nuV *menu = [[_F1oatM3nuV alloc] initWithFrame:CGRectMake((width - 340) * 0.5,
                                                                       (height - 320) * 0.5,
                                                                       340, 320)
                                                       tabs:tabs];
    menu.accentColor = [self accentColor];
    menu.autoresizingMask = 0;
    menu.userInteractionEnabled = YES;
    menu.hidden = !self.isMenuOpen;
    
    __weak typeof(self) weakSelf = self;
    menu.onClose = ^{
        [weakSelf hideMenu];
    };
    menu.onLoadSaved = ^{
        [weakSelf loadUIState];
        [weakSelf.floatingMenu reloadData];
        [weakSelf updateUIButtonVisibility];
    };
    menu.onItemChanged = ^(id item, NSNumber *value) {
        [weakSelf saveUIState];
    };
    
    [keyWindow addSubview:menu];
    self.floatingMenu = menu;
    
    CGPoint position = [self loadButtonPosition:99998 defaultX:(width - 340) * 0.5 defaultY:(height - 320) * 0.5];
    menu.frame = CGRectMake(position.x, position.y, 340, 320);
    [self loadMenuState];
}

- (NSArray *)buildMenuTabs {
    NSMutableArray *tabs = [NSMutableArray array];
    
    // ========================================================================
    // ESP Tab
    // ========================================================================
    NSMutableArray *espItems = [NSMutableArray array];
    
    [espItems addObject:[_F1oatM3nuBool itemWithKey:@"Enable" title:@"Enable" getter:^BOOL{
        return byte_B2D5C;
    } setter:^(BOOL value) {
        byte_B2D5C = value;
    }]];
    
    [espItems addObject:[_F1oatM3nuMulti itemWithKey:@"espMulti1" titles:@[@"Box", @"Lines", @"Skeleton"] getters:^NSArray *{
        return @[@(byte_B2DD5), @(byte_B2D7B), @(byte_B2DEE)];
    } setters:^(NSInteger index, BOOL value) {
        switch (index) {
            case 0: byte_B2DD5 = value; break;
            case 1: byte_B2D7B = value; break;
            case 2: byte_B2DEE = value; break;
        }
    }]];
    
    [espItems addObject:[_F1oatM3nuMulti itemWithKey:@"espMulti2" titles:@[@"Health", @"Distance"] getters:^NSArray *{
        return @[@(byte_B2DEB), @(byte_B2DEC)];
    } setters:^(NSInteger index, BOOL value) {
        switch (index) {
            case 0: byte_B2DEB = value; break;
            case 1: byte_B2DEC = value; break;
        }
    }]];
    
    [espItems addObject:[_F1oatM3nuMulti itemWithKey:@"espMulti3" titles:@[@"Name", @"Outline", @"Glow"] getters:^NSArray *{
        return @[@(byte_B2DEA), @(byte_B2DE9), @(byte_B2E26)];
    } setters:^(NSInteger index, BOOL value) {
        switch (index) {
            case 0: byte_B2DEA = value; break;
            case 1: byte_B2DE9 = value; break;
            case 2: byte_B2E26 = value; break;
        }
    }]];
    
    [espItems addObject:[_F1oatM3nuBool itemWithKey:@"EnemyCount" title:@"Enemy Count" getter:^BOOL{
        return byte_B2E08;
    } setter:^(BOOL value) {
        byte_B2E08 = value;
    }]];
    
    [espItems addObject:[_F1oatM3nuBool itemWithKey:@"BloodVisibility" title:@"Blood Visibility" getter:^BOOL{
        return byte_B2CE8;
    } setter:^(BOOL value) {
        byte_B2CE8 = value;
    }]];
    
    [espItems addObject:[_F1oatM3nuSeg itemWithKey:@"LineOrigin" title:@"Line from" options:@[@"Bottom", @"Head", @"Custom"] getter:^NSInteger{
        return dword_B39D0;
    } setter:^(NSInteger value) {
        dword_B39D0 = (int)value;
    }]];
    
    [espItems addObject:[_F1oatM3nuSeg itemWithKey:@"BloodType" title:@"Blood Type" options:@[@"Default", @"Green", @"None"] getter:^NSInteger{
        return dword_B3B58;
    } setter:^(NSInteger value) {
        dword_B3B58 = (int)value;
    }]];
    
    [espItems addObject:[_F1oatM3nuSeg itemWithKey:@"TargetPriority" title:@"Target Priority" options:@[@"Distance", @"Health", @"Angle"] getter:^NSInteger{
        return dword_B3B5C;
    } setter:^(NSInteger value) {
        dword_B3B5C = (int)value;
    }]];
    
    [tabs addObject:[_F1oatM3nuTab tabWithTitle:@"ESP" items:espItems]];
    
    // ========================================================================
    // Aimbot Tab
    // ========================================================================
    NSMutableArray *aimbotItems = [NSMutableArray array];
    
    [aimbotItems addObject:[_F1oatM3nuBool itemWithKey:@"Aimbot" title:@"Aimbot" getter:^BOOL{
        return byte_B3B71;
    } setter:^(BOOL value) {
        byte_B3B71 = value;
    }]];
    
    [aimbotItems addObject:[_F1oatM3nuBool itemWithKey:@"AimSilent2" title:@"Aimkill" getter:^BOOL{
        return byte_B2E2E;
    } setter:^(BOOL value) {
        byte_B2E2E = value;
    }]];
    
    [aimbotItems addObject:[_F1oatM3nuBool itemWithKey:@"AutoFire" title:@"AutoFire" getter:^BOOL{
        return byte_B2D5D;
    } setter:^(BOOL value) {
        byte_B2D5D = value;
    }]];
    
    [aimbotItems addObject:[_F1oatM3nuBool itemWithKey:@"RateOfFire" title:@"Rate of Fire" getter:^BOOL{
        return byte_B3AF5;
    } setter:^(BOOL value) {
        byte_B3AF5 = value;
        byte_B3B0A = value;
    }]];
    
    [aimbotItems addObject:[_F1oatM3nuFloat itemWithKey:@"AimFov" title:@"FOV Radius" min:0 max:45 getter:^float{
        return *(float *)&dword_B2D60;
    } setter:^(float value) {
        dword_B2D60 = *(int *)&value;
        byte_B2D79 = value > 0;
    }]];
    
    [aimbotItems addObject:[_F1oatM3nuMulti itemWithKey:@"aimMulti1" titles:@[@"Aimsilent", @"AimAssist Rotation"] getters:^NSArray *{
        return @[@(byte_B2E1F), @(byte_B3AF6)];
    } setters:^(NSInteger index, BOOL value) {
        switch (index) {
            case 0: byte_B2E1F = value; break;
            case 1: byte_B3AF6 = value; break;
        }
    }]];
    
    [aimbotItems addObject:[_F1oatM3nuMulti itemWithKey:@"aimMulti2" titles:@[@"Damage Reflect", @"Ignore Wall"] getters:^NSArray *{
        return @[@(byte_B3AF7), @(byte_B3AF4)];
    } setters:^(NSInteger index, BOOL value) {
        switch (index) {
            case 0: byte_B3AF7 = value; break;
            case 1: byte_B3AF4 = value; break;
        }
    }]];
    
    [aimbotItems addObject:[_F1oatM3nuMulti itemWithKey:@"aimMulti3" titles:@[@"Swap Weapon", @"Second Phase", @"First Phase"] getters:^NSArray *{
        return @[@(byte_B3AF2), @(byte_B3A81), @(byte_B3A82)];
    } setters:^(NSInteger index, BOOL value) {
        switch (index) {
            case 0: byte_B3AF2 = value; break;
            case 1: byte_B3A81 = value; break;
            case 2: byte_B3A82 = value; break;
        }
    }]];
    
    [aimbotItems addObject:[_F1oatM3nuMulti itemWithKey:@"aimMulti4" titles:@[@"PhyxState", @"Fast", @"Mideum"] getters:^NSArray *{
        return @[@(byte_B3A83), @(byte_B3B12), @(byte_B3B54)];
    } setters:^(NSInteger index, BOOL value) {
        switch (index) {
            case 0: byte_B3A83 = value; break;
            case 1: byte_B3B12 = value; break;
            case 2: byte_B3B54 = value; break;
        }
    }]];
    
    [aimbotItems addObject:[_F1oatM3nuFloat itemWithKey:@"TakeDamageTimerMin" title:@"Aim Kill Timer Min" min:1 max:50 getter:^float{
        return dword_B2CD4;
    } setter:^(float value) {
        dword_B2CD4 = (int)value;
    }]];
    
    [aimbotItems addObject:[_F1oatM3nuFloat itemWithKey:@"TakeDamageTimerMax" title:@"Aim Kill Timer Max" min:2 max:40 getter:^float{
        return dword_B2CD8;
    } setter:^(float value) {
        dword_B2CD8 = (int)value;
    }]];
    
    [aimbotItems addObject:[_F1oatM3nuFloat itemWithKey:@"goTeleportStateRadius" title:@"Go Teleport Radius" min:0 max:10 getter:^float{
        return *(float *)&dword_B2CE4;
    } setter:^(float value) {
        dword_B2CE4 = *(int *)&value;
    }]];
    
    [aimbotItems addObject:[_F1oatM3nuSeg itemWithKey:@"TriggerWhen" title:@"Trigger When" options:@[@"Always", @"When Firing", @"When Scoping"] getter:^NSInteger{
        return dword_B2D74;
    } setter:^(NSInteger value) {
        dword_B2D74 = (int)value;
    }]];
    
    [aimbotItems addObject:[_F1oatM3nuSeg itemWithKey:@"TargetBone" title:@"Target Bone" options:@[@"Head", @"Chest", @"Pelvis"] getter:^NSInteger{
        return dword_B39DC;
    } setter:^(NSInteger value) {
        dword_B39DC = (int)value;
    }]];
    
    [tabs addObject:[_F1oatM3nuTab tabWithTitle:@"Aimbot" items:aimbotItems]];
    
    // ========================================================================
    // MSL Tab
    // ========================================================================
    NSMutableArray *mslItems = [NSMutableArray array];
    
    [mslItems addObject:[_F1oatM3nuBool itemWithKey:@"SpeedHack" title:@"Speed Bypass" getter:^BOOL{
        return byte_B3B74;
    } setter:^(BOOL value) {
        byte_B3B74 = value;
    }]];
    
    [mslItems addObject:[_F1oatM3nuMulti itemWithKey:@"mslMulti1" titles:@[@"Up Player", @"Telekill", @"Underground Kill2"] getters:^NSArray *{
        return @[@(byte_B2D99), @(byte_B2D7A), @(byte_B2D7F)];
    } setters:^(NSInteger index, BOOL value) {
        switch (index) {
            case 0: byte_B2D99 = value; break;
            case 1: byte_B2D7A = value; break;
            case 2: byte_B2D7F = value; break;
        }
    }]];
    
    [mslItems addObject:[_F1oatM3nuMulti itemWithKey:@"mslMulti2" titles:@[@"Ninja Run", @"Reset Guest"] getters:^NSArray *{
        return @[@(byte_B2D4A), @(byte_B3B73)];
    } setters:^(NSInteger index, BOOL value) {
        switch (index) {
            case 0: byte_B2D4A = value; break;
            case 1: byte_B3B73 = value; break;
        }
    }]];
    
    [mslItems addObject:[_F1oatM3nuSeg itemWithKey:@"NinjaRunSpeed" title:@"Ninja Run Speed" options:@[@"Slow", @"Fast"] getter:^NSInteger{
        return byte_B2D4B ? 1 : 0;
    } setter:^(NSInteger value) {
        byte_B2D4B = value == 0;
        byte_B2D4C = value == 1;
    }]];
    
    [tabs addObject:[_F1oatM3nuTab tabWithTitle:@"MSL" items:mslItems]];
    
    // ========================================================================
    // Buttons Tab
    // ========================================================================
    NSMutableArray *buttonItems = [NSMutableArray array];
    
    [buttonItems addObject:[_F1oatM3nuBool itemWithKey:@"Show All" title:@"Show All" getter:^BOOL{
        return byte_B335D;
    } setter:^(BOOL value) {
        byte_B335D = value;
        [self updateUIButtonVisibility];
    }]];
    
    [buttonItems addObject:[_F1oatM3nuMulti itemWithKey:@"btnMulti1" titles:@[@"Ghost", @"Tele VIP", @"KILL"] getters:^NSArray *{
        return @[@(byte_B2D98), @(byte_B2DC5), @(byte_B2DD4)];
    } setters:^(NSInteger index, BOOL value) {
        switch (index) {
            case 0: [self toggleShowGhostUI:nil]; break;
            case 1: [self toggleShowTeleVIPUI:nil]; break;
            case 2: [self toggleShowUndergroundUI:nil]; break;
        }
        [self updateUIButtonVisibility];
    }]];
    
    [buttonItems addObject:[_F1oatM3nuMulti itemWithKey:@"btnMulti2" titles:@[@"AI KILL", @"NINJA"] getters:^NSArray *{
        return @[@(byte_B2D64), @(byte_B2D85)];
    } setters:^(NSInteger index, BOOL value) {
        switch (index) {
            case 0: [self toggleShowAITelekillUI:nil]; break;
            case 1: [self toggleShowNinjaRunUI:nil]; break;
        }
        [self updateUIButtonVisibility];
    }]];
    
    [buttonItems addObject:[_F1oatM3nuMulti itemWithKey:@"btnMulti3" titles:@[@"FLY ALT", @"Invisible", @"FLYV2"] getters:^NSArray *{
        return @[@(byte_B2D9B), @(byte_B2D9C), @(byte_B335B)];
    } setters:^(NSInteger index, BOOL value) {
        switch (index) {
            case 0: [self toggleShowFlyAlturaUI:nil]; break;
            case 1: [self toggleUIFlyNormal:nil]; break;
            case 2: [self toggleShowFlyv2UI:nil]; break;
        }
        [self updateUIButtonVisibility];
    }]];
    
    [buttonItems addObject:[_F1oatM3nuMulti itemWithKey:@"btnMulti4" titles:@[@"FlyGLD", @"GO TELEPORT"] getters:^NSArray *{
        return @[@(byte_B2E24), @(byte_B3358)];
    } setters:^(NSInteger index, BOOL value) {
        switch (index) {
            case 0: [self toggleShowSavePosUI:nil]; break;
            case 1: [self toggleShowGoTeleportStateUI:nil]; break;
        }
        [self updateUIButtonVisibility];
    }]];
    
    [buttonItems addObject:[_F1oatM3nuMulti itemWithKey:@"btnMulti5" titles:@[@"STOP MOVE", @"HORIZ SPEED", @"Aimkill"] getters:^NSArray *{
        return @[@(byte_B3359), @(byte_B335A), @(byte_B2E25)];
    } setters:^(NSInteger index, BOOL value) {
        switch (index) {
            case 0: [self toggleShowStopMoveUI:nil]; break;
            case 1: [self toggleShowHorizontalSpeedUI:nil]; break;
            case 2: [self toggleShowClearAntiuUI:nil]; break;
        }
        [self updateUIButtonVisibility];
    }]];
    
    [buttonItems addObject:[_F1oatM3nuMulti itemWithKey:@"btnMulti6" titles:@[@"MAGNET KILL", @"MARK TP"] getters:^NSArray *{
        return @[@(byte_B2E2D), @(byte_B335C)];
    } setters:^(NSInteger index, BOOL value) {
        switch (index) {
            case 0: [self toggleShowMagnetKillUI:nil]; break;
            case 1: [self toggleShowMarkTeleportUI:nil]; break;
        }
        [self updateUIButtonVisibility];
    }]];
    
    [tabs addObject:[_F1oatM3nuTab tabWithTitle:@"Buttons" items:buttonItems]];
    
    return tabs;
}

#pragma mark - Menu Management

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

+ (void)toggleMenuFromFloatingButton {
    // Called from floating button
}

#pragma mark - State Management

- (NSString *)uiStateJSONPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject;
    return [documentsDirectory stringByAppendingPathComponent:@"menu_ui_state.json"];
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
    NSNumber *a = dict[@"a"];
    
    if (!r || !g || !b) return fallback;
    
    CGFloat alpha = a ? [a floatValue] : 1.0;
    return [UIColor colorWithRed:[r floatValue] green:[g floatValue] blue:[b floatValue] alpha:alpha];
}

- (UIColor *)loadSavedThemeColor {
    id state = [self readUIStateJSON];
    id colorData = state[@"themeColor"];
    return [self deserializeColor:colorData fallback:[UIColor colorWithRed:0.2 green:0.6 blue:0.9 alpha:1.0]];
}

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

#pragma mark - Button Position Management

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
    
    posX = MAX(0, MIN(posX, maxX));
    posY = MAX(0, MIN(posY, maxY));
    
    return CGPointMake(posX, posY);
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

#pragma mark - Settings

- (NSString *)settingsFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject;
    return [documentsDirectory stringByAppendingPathComponent:@"settings.fluck"];
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
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        content = [defaults stringForKey:@"FluckSettingsBackup"];
    }
    
    if (!content || content.length == 0) return;
    
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    NSArray *lines = [content componentsSeparatedByString:@"\n"];
    
    for (NSString *line in lines) {
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
    
    NSNumber *fullscreen = settings[@"ResolutionFullscreen"];
    if (fullscreen) byte_B2CC4 = [fullscreen intValue] == 1;
    
    NSNumber *refreshRate = settings[@"PreferredRefreshRate"];
    if (refreshRate) {
        int value = [refreshRate intValue];
        if (value >= 60 && value <= 120) dword_B2CC8 = value;
    }
    
    NSNumber *resetOnOpen = settings[@"ResetResolutionOnOpen"];
    if (resetOnOpen) byte_B2CCC = [resetOnOpen intValue] == 1;
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

#pragma mark - Protection

- (void)protectAllFeatureButtons {
    // Protection implementation
}

- (void)unprotectAllFeatureButtons {
    // Unprotect implementation
}

- (void)screenCaptureStatusChanged:(NSNotification *)notification {
    // Handle screen capture
}

- (void)toggleStreamMode:(UISwitch *)sender {
    // Stream mode toggle
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

@end
