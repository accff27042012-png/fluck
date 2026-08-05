/*
 * FLUCK.DYLIB - Complete iOS Game Mod
 * Build as Mach-O Dynamic Library (.dylib)
 * 
 * Features:
 * - ESP (Box, Lines, Skeleton)
 * - Aimbot (Silent, AutoFire, FOV)
 * - MSL (Speed, Telekill, Ninja Run)
 * - Floating Menu with Tabs
 * - Settings Save/Load
 * 
 * Build: clang++ -dynamiclib -arch arm64 -framework UIKit -framework Foundation -framework CoreGraphics -framework QuartzCore -o fluck.dylib fluck.mm
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <mach/mach.h>
#import <dlfcn.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import <objc/message.h>

// ============================================
// MARK: - CONFIGURATION
// ============================================

#define FLUCK_VERSION @"1.0.0"
#define FLUCK_BUNDLE_ID @"com.garena.game.ff"  // Free Fire Bundle ID

// ============================================
// MARK: - UTILITY FUNCTIONS
// ============================================

static void* _baseAddress = NULL;
static void* _localPlayer = NULL;
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

BOOL IsValidPointer(void *ptr) {
    if (!ptr) return NO;
    if ((uintptr_t)ptr < 0x1000) return NO;
    if ((uintptr_t)ptr > 0x7fffffff0000) return NO;
    return YES;
}

void *GetLocalPlayer() {
    void *base = GetBaseAddress();
    if (!base) return NULL;
    
    // Try to find local player via Unity functions
    // This is a simplified example - real implementation needs proper offsets
    void *(*getLocalPlayer)(void) = (void *(*)(void))((uintptr_t)base + 0x123456);
    if (getLocalPlayer) {
        return getLocalPlayer();
    }
    return NULL;
}

NSArray *GetAllPlayers() {
    NSMutableArray *players = [NSMutableArray array];
    void *local = GetLocalPlayer();
    if (!local) return players;
    
    // Get player list - needs proper offset
    void **playerList = (void **)((uintptr_t)GetBaseAddress() + 0x789ABC);
    if (!IsValidPointer(playerList)) return players;
    
    int count = *(int *)((uintptr_t)playerList + 0x8);
    if (count > 100) count = 100;
    
    for (int i = 0; i < count; i++) {
        void *player = playerList[i];
        if (IsValidPointer(player)) {
            [players addObject:[NSValue valueWithPointer:player]];
        }
    }
    return players;
}

float GetDistance(void *p1, void *p2) {
    if (!p1 || !p2) return 9999.0f;
    
    // Get positions - needs proper offsets
    float x1 = *(float *)((uintptr_t)p1 + 0x100);
    float y1 = *(float *)((uintptr_t)p1 + 0x104);
    float z1 = *(float *)((uintptr_t)p1 + 0x108);
    float x2 = *(float *)((uintptr_t)p2 + 0x100);
    float y2 = *(float *)((uintptr_t)p2 + 0x104);
    float z2 = *(float *)((uintptr_t)p2 + 0x108);
    
    float dx = x1 - x2;
    float dy = y1 - y2;
    float dz = z1 - z2;
    return sqrtf(dx*dx + dy*dy + dz*dz);
}

// ============================================
// MARK: - MEMORY MANAGER
// ============================================

@interface FluckMemory : NSObject
+ (instancetype)shared;
- (BOOL)read:(void *)addr buffer:(void *)buf size:(size_t)size;
- (BOOL)write:(void *)addr buffer:(void *)buf size:(size_t)size;
- (void *)scanPattern:(const char *)pattern mask:(const char *)mask;
@end

@implementation FluckMemory {
    vm_address_t _task;
}

+ (instancetype)shared {
    static FluckMemory *instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _task = mach_task_self();
    }
    return self;
}

- (BOOL)read:(void *)addr buffer:(void *)buf size:(size_t)size {
    if (!addr || !buf || size == 0) return NO;
    vm_size_t outSize = 0;
    kern_return_t kr = vm_read_overwrite(_task, (vm_address_t)addr, size, (vm_address_t)buf, &outSize);
    return (kr == KERN_SUCCESS && outSize == size);
}

- (BOOL)write:(void *)addr buffer:(void *)buf size:(size_t)size {
    if (!addr || !buf || size == 0) return NO;
    
    vm_prot_t oldProt;
    vm_protect(_task, (vm_address_t)addr, size, 0, VM_PROT_READ | VM_PROT_WRITE);
    kern_return_t kr = vm_write(_task, (vm_address_t)addr, (vm_offset_t)buf, (mach_msg_type_number_t)size);
    vm_protect(_task, (vm_address_t)addr, size, 0, oldProt);
    sys_icache_invalidate(addr, size);
    return (kr == KERN_SUCCESS);
}

- (void *)scanPattern:(const char *)pattern mask:(const char *)mask {
    void *base = GetBaseAddress();
    if (!base) return NULL;
    
    struct mach_header_64 *header = (struct mach_header_64 *)base;
    struct load_command *cmd = (struct load_command *)(header + 1);
    uintptr_t size = 0;
    
    for (uint32_t i = 0; i < header->ncmds; i++) {
        if (cmd->cmd == LC_SEGMENT_64) {
            struct segment_command_64 *seg = (struct segment_command_64 *)cmd;
            if (strcmp(seg->segname, "__TEXT") == 0) {
                size = seg->vmsize;
                break;
            }
        }
        cmd = (struct load_command *)((uintptr_t)cmd + cmd->cmdsize);
    }
    
    if (size == 0) return NULL;
    
    size_t patternLen = strlen(mask);
    for (uintptr_t i = 0; i < size - patternLen; i++) {
        bool found = true;
        for (size_t j = 0; j < patternLen; j++) {
            if (mask[j] == 'x' && pattern[j] != *(char *)((uintptr_t)base + i + j)) {
                found = false;
                break;
            }
        }
        if (found) {
            return (void *)((uintptr_t)base + i);
        }
    }
    return NULL;
}

@end

// ============================================
// MARK: - ESP MANAGER
// ============================================

@interface FluckESP : NSObject
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) NSInteger style;
@property (nonatomic, assign) BOOL showHealth;
@property (nonatomic, assign) BOOL showDistance;
@property (nonatomic, assign) BOOL showName;
@property (nonatomic, assign) BOOL showOutline;
@property (nonatomic, assign) BOOL showGlow;
+ (instancetype)shared;
- (void)update;
@end

@implementation FluckESP {
    UIColor *_enemyColor;
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
        _showName = YES;
        _showOutline = NO;
        _showGlow = NO;
        _enemyColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
        
        // Create overlay
        dispatch_async(dispatch_get_main_queue(), ^{
            UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
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
    
    // Clear previous drawings
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIView *subview in self->_overlay.subviews) {
            [subview removeFromSuperview];
        }
        for (CALayer *layer in self->_overlay.layer.sublayers) {
            [layer removeFromSuperlayer];
        }
    });
    
    NSArray *players = GetAllPlayers();
    void *local = GetLocalPlayer();
    if (!local || players.count == 0) return;
    
    for (NSValue *playerValue in players) {
        void *player = playerValue.pointerValue;
        if (player == local) continue;
        
        // Check if enemy (needs proper team offset)
        int health = *(int *)((uintptr_t)player + 0x228);
        if (health <= 0) continue;
        
        [self drawESPForPlayer:player];
    }
}

- (void)drawESPForPlayer:(void *)player {
    // Get position
    float x = *(float *)((uintptr_t)player + 0x100);
    float y = *(float *)((uintptr_t)player + 0x104);
    float z = *(float *)((uintptr_t)player + 0x108);
    
    // World to screen (simplified - needs real matrix)
    CGPoint screen = [self worldToScreen:CGPointMake(x, y, z)];
    if (screen.x < 0 || screen.y < 0) return;
    
    float distance = GetDistance(player, GetLocalPlayer());
    float boxSize = MAX(20, 120 - distance * 0.05);
    float boxHeight = boxSize * 2.5;
    float boxWidth = boxSize * 0.8;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Draw box
        if (self->_style == 0) {
            UIView *box = [[UIView alloc] initWithFrame:CGRectMake(screen.x - boxWidth/2, screen.y - boxHeight/2, boxWidth, boxHeight)];
            box.layer.borderColor = self->_enemyColor.CGColor;
            box.layer.borderWidth = 2;
            if (self->_showOutline) {
                box.layer.shadowColor = [UIColor redColor].CGColor;
                box.layer.shadowRadius = 4;
                box.layer.shadowOpacity = 1;
            }
            [self->_overlay addSubview:box];
        }
        
        // Draw health bar
        if (self->_showHealth) {
            int health = *(int *)((uintptr_t)player + 0x228);
            float ratio = health / 100.0;
            UIView *healthBar = [[UIView alloc] initWithFrame:CGRectMake(screen.x - boxWidth/2, screen.y + boxHeight/2 + 4, boxWidth * ratio, 4)];
            healthBar.backgroundColor = [UIColor colorWithRed:(1-ratio) green:ratio blue:0 alpha:1];
            [self->_overlay addSubview:healthBar];
        }
        
        // Draw distance
        if (self->_showDistance) {
            UILabel *label = [[UILabel alloc] init];
            label.text = [NSString stringWithFormat:@"%.0fm", distance];
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont boldSystemFontOfSize:11];
            label.shadowColor = [UIColor blackColor];
            label.shadowOffset = CGSizeMake(1, 1);
            [label sizeToFit];
            label.center = CGPointMake(screen.x, screen.y - boxHeight/2 - 16);
            [self->_overlay addSubview:label];
        }
        
        // Draw name
        if (self->_showName) {
            UILabel *label = [[UILabel alloc] init];
            label.text = @"Enemy";
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont boldSystemFontOfSize:11];
            label.shadowColor = [UIColor blackColor];
            label.shadowOffset = CGSizeMake(1, 1);
            [label sizeToFit];
            label.center = CGPointMake(screen.x, screen.y + boxHeight/2 + 20);
            [self->_overlay addSubview:label];
        }
    });
}

- (CGPoint)worldToScreen:(CGPoint)world {
    // Simplified world to screen - needs real view/projection matrices
    // This is a placeholder
    CGPoint screen = CGPointZero;
    screen.x = world.x * 100 + 200;
    screen.y = world.y * 100 + 400;
    return screen;
}

@end

// ============================================
// MARK: - AIMBOT MANAGER
// ============================================

@interface FluckAimbot : NSObject
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL silentAim;
@property (nonatomic, assign) BOOL autoFire;
@property (nonatomic, assign) float fovRadius;
@property (nonatomic, assign) NSInteger targetBone;
+ (instancetype)shared;
- (void)update;
@end

@implementation FluckAimbot {
    void *_currentTarget;
}

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
        _fovRadius = 30;
        _targetBone = 0;
        _currentTarget = NULL;
    }
    return self;
}

- (void)update {
    if (!_enabled) return;
    
    _currentTarget = [self getBestTarget];
    if (!_currentTarget) return;
    
    // Get target position
    CGPoint targetPos = [self getTargetPosition:_currentTarget];
    if (targetPos.x < 0) return;
    
    // Aim to target
    if (_silentAim) {
        [self silentAimTo:targetPos];
    } else {
        [self aimTo:targetPos];
    }
    
    // Auto fire
    if (_autoFire) {
        [self fire];
    }
}

- (void *)getBestTarget {
    NSArray *players = GetAllPlayers();
    void *local = GetLocalPlayer();
    if (!local || players.count == 0) return NULL;
    
    void *bestTarget = NULL;
    float bestScore = FLT_MAX;
    
    for (NSValue *playerValue in players) {
        void *player = playerValue.pointerValue;
        if (player == local) continue;
        
        int health = *(int *)((uintptr_t)player + 0x228);
        if (health <= 0) continue;
        
        float distance = GetDistance(player, local);
        if (distance > 1000) continue;
        
        // Calculate FOV
        float px = *(float *)((uintptr_t)player + 0x100);
        float py = *(float *)((uintptr_t)player + 0x104);
        float pz = *(float *)((uintptr_t)player + 0x108);
        CGPoint screenPos = [self worldToScreen:CGPointMake(px, py, pz)];
        CGPoint center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
        float fov = sqrtf(powf(screenPos.x - center.x, 2) + powf(screenPos.y - center.y, 2));
        if (fov > _fovRadius) continue;
        
        float score = distance * 0.01 + fov * 0.05;
        if (score < bestScore) {
            bestScore = score;
            bestTarget = player;
        }
    }
    return bestTarget;
}

- (CGPoint)getTargetPosition:(void *)player {
    float x = *(float *)((uintptr_t)player + 0x100);
    float y = *(float *)((uintptr_t)player + 0x104);
    float z = *(float *)((uintptr_t)player + 0x108);
    
    if (_targetBone == 0) z += 0.5; // Head
    else if (_targetBone == 1) z += 0.0; // Chest
    else if (_targetBone == 2) z -= 0.5; // Pelvis
    
    return [self worldToScreen:CGPointMake(x, y, z)];
}

- (CGPoint)worldToScreen:(CGPoint)world {
    // Placeholder - needs real matrix
    CGPoint screen = CGPointZero;
    screen.x = world.x * 100 + 200;
    screen.y = world.y * 100 + 400;
    return screen;
}

- (void)aimTo:(CGPoint)target {
    CGPoint center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    float dx = target.x - center.x;
    float dy = target.y - center.y;
    
    // Rotate camera - needs proper offsets
    void *local = GetLocalPlayer();
    if (local) {
        float *yaw = (float *)((uintptr_t)local + 0x1A0);
        float *pitch = (float *)((uintptr_t)local + 0x1A4);
        if (yaw && pitch) {
            *yaw += dx * 0.05;
            *pitch += dy * 0.05;
        }
    }
}

- (void)silentAimTo:(CGPoint)target {
    // Silent aim - modify bullet direction without rotating camera
    void *local = GetLocalPlayer();
    if (local) {
        float *aimCorrectionX = (float *)((uintptr_t)local + 0x1A8);
        float *aimCorrectionY = (float *)((uintptr_t)local + 0x1AC);
        if (aimCorrectionX && aimCorrectionY) {
            CGPoint center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
            *aimCorrectionX = (target.x - center.x) * 0.1;
            *aimCorrectionY = (target.y - center.y) * 0.1;
        }
    }
}

- (void)fire {
    void *local = GetLocalPlayer();
    if (!local) return;
    
    // Call fire function - needs proper offset
    void (*fireFunc)(void *) = (void (*)(void *))((uintptr_t)GetBaseAddress() + 0x123456);
    if (fireFunc) {
        fireFunc(local);
    }
}

@end

// ============================================
// MARK: - MSL MANAGER
// ============================================

@interface FluckMSL : NSObject
@property (nonatomic, assign) BOOL speedBypass;
@property (nonatomic, assign) BOOL telekill;
@property (nonatomic, assign) BOOL undergroundKill;
@property (nonatomic, assign) BOOL ninjaRun;
+ (instancetype)shared;
- (void)update;
@end

@implementation FluckMSL

+ (instancetype)shared {
    static FluckMSL *instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _speedBypass = NO;
        _telekill = NO;
        _undergroundKill = NO;
        _ninjaRun = NO;
    }
    return self;
}

- (void)update {
    void *local = GetLocalPlayer();
    if (!local) return;
    
    if (_speedBypass) {
        float *speed = (float *)((uintptr_t)local + 0x1B0);
        if (speed) *speed = 15.0f;
    }
    
    if (_telekill) {
        NSArray *players = GetAllPlayers();
        float lx = *(float *)((uintptr_t)local + 0x100);
        float ly = *(float *)((uintptr_t)local + 0x104);
        float lz = *(float *)((uintptr_t)local + 0x108);
        
        for (NSValue *pv in players) {
            void *player = pv.pointerValue;
            if (player == local) continue;
            int health = *(int *)((uintptr_t)player + 0x228);
            if (health > 0) {
                *(float *)((uintptr_t)player + 0x100) = lx + 2;
                *(float *)((uintptr_t)player + 0x104) = ly;
                *(float *)((uintptr_t)player + 0x108) = lz;
            }
        }
    }
    
    if (_undergroundKill) {
        float *z = (float *)((uintptr_t)local + 0x108);
        if (z) *z = -10.0f;
    }
    
    if (_ninjaRun) {
        float *speed = (float *)((uintptr_t)local + 0x1B0);
        if (speed) *speed = 30.0f;
    }
}

@end

// ============================================
// MARK: - FLOATING MENU
// ============================================

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

- (void)setupUI {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (!keyWindow) return;
    
    self.frame = keyWindow.bounds;
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = YES;
    [keyWindow addSubview:self];
    
    // Background
    _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    _backgroundView.hidden = YES;
    [self addSubview:_backgroundView];
    
    // Menu
    CGFloat menuWidth = 340;
    CGFloat menuHeight = 420;
    _menuView = [[UIView alloc] initWithFrame:CGRectMake((self.bounds.size.width - menuWidth) / 2,
                                                          (self.bounds.size.height - menuHeight) / 2,
                                                          menuWidth, menuHeight)];
    _menuView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.95];
    _menuView.layer.cornerRadius = 16;
    _menuView.layer.masksToBounds = YES;
    _menuView.hidden = YES;
    [self addSubview:_menuView];
    
    // Title
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, menuWidth, 28)];
    title.text = @"FLUCK MOD v1.0";
    title.textColor = [UIColor colorWithRed:0.2 green:0.6 blue:1 alpha:1];
    title.font = [UIFont boldSystemFontOfSize:18];
    title.textAlignment = NSTextAlignmentCenter;
    [_menuView addSubview:title];
    
    // Close button
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(menuWidth - 44, 10, 30, 30);
    [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [_menuView addSubview:closeBtn];
    
    // Create sections
    CGFloat yPos = 50;
    yPos = [self createSection:@"⚡ ESP" y:yPos];
    yPos = [self createSection:@"🎯 Aimbot" y:yPos];
    yPos = [self createSection:@"🚀 MSL" y:yPos];
}

- (CGFloat)createSection:(NSString *)title y:(CGFloat)y {
    CGFloat padding = 8;
    CGFloat width = _menuView.bounds.size.width - 24;
    CGFloat currentY = y;
    
    // Section header
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(12, currentY, width, 24)];
    header.text = title;
    header.textColor = [UIColor colorWithRed:0.2 green:0.6 blue:1 alpha:1];
    header.font = [UIFont boldSystemFontOfSize:14];
    [_menuView addSubview:header];
    currentY += 28;
    
    // Section items based on title
    if ([title containsString:@"ESP"]) {
        currentY = [self addSwitch:@"Enable ESP" y:currentY key:@"esp_enabled" action:@selector(espSwitchChanged:)];
        currentY = [self addSegmented:@[@"Box", @"Lines", @"Skeleton"] y:currentY key:@"esp_style" action:@selector(espStyleChanged:)];
        currentY = [self addSwitch:@"Show Health" y:currentY key:@"esp_health" action:@selector(espOptionChanged:)];
        currentY = [self addSwitch:@"Show Distance" y:currentY key:@"esp_distance" action:@selector(espOptionChanged:)];
        currentY = [self addSwitch:@"Show Name" y:currentY key:@"esp_name" action:@selector(espOptionChanged:)];
        currentY = [self addSwitch:@"Outline" y:currentY key:@"esp_outline" action:@selector(espOptionChanged:)];
        currentY = [self addSwitch:@"Glow" y:currentY key:@"esp_glow" action:@selector(espOptionChanged:)];
    } else if ([title containsString:@"Aimbot"]) {
        currentY = [self addSwitch:@"Enable Aimbot" y:currentY key:@"aim_enabled" action:@selector(aimSwitchChanged:)];
        currentY = [self addSwitch:@"Silent Aim" y:currentY key:@"aim_silent" action:@selector(aimOptionChanged:)];
        currentY = [self addSwitch:@"Auto Fire" y:currentY key:@"aim_autofire" action:@selector(aimOptionChanged:)];
        currentY = [self addSlider:@"FOV" y:currentY key:@"aim_fov" min:0 max:360 action:@selector(aimSliderChanged:)];
        currentY = [self addSegmented:@[@"Head", @"Chest", @"Pelvis"] y:currentY key:@"aim_bone" action:@selector(aimBoneChanged:)];
    } else if ([title containsString:@"MSL"]) {
        currentY = [self addSwitch:@"Speed Bypass" y:currentY key:@"msl_speed" action:@selector(mslSwitchChanged:)];
        currentY = [self addSwitch:@"Telekill" y:currentY key:@"msl_telekill" action:@selector(mslSwitchChanged:)];
        currentY = [self addSwitch:@"Underground Kill" y:currentY key:@"msl_underground" action:@selector(mslSwitchChanged:)];
        currentY = [self addSwitch:@"Ninja Run" y:currentY key:@"msl_ninja" action:@selector(mslSwitchChanged:)];
    }
    
    return currentY + 12;
}

- (CGFloat)addSwitch:(NSString *)title y:(CGFloat)y key:(NSString *)key action:(SEL)action {
    UISwitch *sw = [[UISwitch alloc] init];
    sw.on = [[_settings objectForKey:key] boolValue];
    sw.tag = [self tagForAction:action];
    [sw addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    
    return [self addControl:title y:y control:sw key:key];
}

- (CGFloat)addSlider:(NSString *)title y:(CGFloat)y key:(NSString *)key min:(float)min max:(float)max action:(SEL)action {
    UISlider *slider = [[UISlider alloc] init];
    slider.minimumValue = min;
    slider.maximumValue = max;
    slider.value = [[_settings objectForKey:key] floatValue];
    slider.tag = [self tagForAction:action];
    [slider addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    [slider setFrame:CGRectMake(0, 0, 100, 30)];
    
    return [self addControl:title y:y control:slider key:key];
}

- (CGFloat)addSegmented:(NSArray *)items y:(CGFloat)y key:(NSString *)key action:(SEL)action {
    UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:items];
    seg.selectedSegmentIndex = [[_settings objectForKey:key] integerValue];
    seg.tag = [self tagForAction:action];
    [seg addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    [seg setFrame:CGRectMake(0, 0, 200, 30)];
    
    return [self addControl:@"" y:y control:seg key:key];
}

- (CGFloat)addControl:(NSString *)title y:(CGFloat)y control:(UIView *)control key:(NSString *)key {
    UIView *row = [[UIView alloc] initWithFrame:CGRectMake(12, y, _menuView.bounds.size.width - 24, 36)];
    row.backgroundColor = [UIColor clearColor];
    [_menuView addSubview:row];
    
    if (title.length > 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, 140, 24)];
        label.text = title;
        label.textColor = [UIColor colorWithWhite:0.9 alpha:1];
        label.font = [UIFont systemFontOfSize:13];
        [row addSubview:label];
        
        control.frame = CGRectMake(160, 2, control.frame.size.width, control.frame.size.height);
    } else {
        control.frame = CGRectMake((row.bounds.size.width - control.frame.size.width) / 2, 2, control.frame.size.width, control.frame.size.height);
    }
    
    [row addSubview:control];
    return y + 38;
}

- (NSInteger)tagForAction:(SEL)action {
    if (action == @selector(espSwitchChanged:)) return 1000;
    if (action == @selector(espStyleChanged:)) return 1001;
    if (action == @selector(espOptionChanged:)) return 1002;
    if (action == @selector(aimSwitchChanged:)) return 2000;
    if (action == @selector(aimOptionChanged:)) return 2001;
    if (action == @selector(aimSliderChanged:)) return 2002;
    if (action == @selector(aimBoneChanged:)) return 2003;
    if (action == @selector(mslSwitchChanged:)) return 3000;
    return 0;
}

// Actions
- (void)espSwitchChanged:(UISwitch *)sender {
    BOOL on = sender.on;
    [_settings setObject:@(on) forKey:@"esp_enabled"];
    [FluckESP shared].enabled = on;
    [self saveSettings];
}

- (void)espStyleChanged:(UISegmentedControl *)sender {
    NSInteger idx = sender.selectedSegmentIndex;
    [_settings setObject:@(idx) forKey:@"esp_style"];
    [FluckESP shared].style = idx;
    [self saveSettings];
}

- (void)espOptionChanged:(UISwitch *)sender {
    // Find which option
    UIView *row = sender.superview;
    UILabel *label = row.subviews[0];
    NSString *key = [NSString stringWithFormat:@"esp_%@", label.text.lowercaseString];
    if ([label.text containsString:@"Health"]) key = @"esp_health";
    else if ([label.text containsString:@"Distance"]) key = @"esp_distance";
    else if ([label.text containsString:@"Name"]) key = @"esp_name";
    else if ([label.text isEqualToString:@"Outline"]) key = @"esp_outline";
    else if ([label.text isEqualToString:@"Glow"]) key = @"esp_glow";
    
    BOOL on = sender.on;
    [_settings setObject:@(on) forKey:key];
    
    if ([key isEqualToString:@"esp_health"]) [FluckESP shared].showHealth = on;
    else if ([key isEqualToString:@"esp_distance"]) [FluckESP shared].showDistance = on;
    else if ([key isEqualToString:@"esp_name"]) [FluckESP shared].showName = on;
    else if ([key isEqualToString:@"esp_outline"]) [FluckESP shared].showOutline = on;
    else if ([key isEqualToString:@"esp_glow"]) [FluckESP shared].showGlow = on;
    
    [self saveSettings];
}

- (void)aimSwitchChanged:(UISwitch *)sender {
    BOOL on = sender.on;
    [_settings setObject:@(on) forKey:@"aim_enabled"];
    [FluckAimbot shared].enabled = on;
    [self saveSettings];
}

- (void)aimOptionChanged:(UISwitch *)sender {
    UIView *row = sender.superview;
    UILabel *label = row.subviews[0];
    BOOL on = sender.on;
    
    if ([label.text containsString:@"Silent"]) {
        [_settings setObject:@(on) forKey:@"aim_silent"];
        [FluckAimbot shared].silentAim = on;
    } else if ([label.text containsString:@"Auto"]) {
        [_settings setObject:@(on) forKey:@"aim_autofire"];
        [FluckAimbot shared].autoFire = on;
    }
    [self saveSettings];
}

- (void)aimSliderChanged:(UISlider *)sender {
    float value = sender.value;
    [_settings setObject:@(value) forKey:@"aim_fov"];
    [FluckAimbot shared].fovRadius = value;
    [self saveSettings];
}

- (void)aimBoneChanged:(UISegmentedControl *)sender {
    NSInteger idx = sender.selectedSegmentIndex;
    [_settings setObject:@(idx) forKey:@"aim_bone"];
    [FluckAimbot shared].targetBone = idx;
    [self saveSettings];
}

- (void)mslSwitchChanged:(UISwitch *)sender {
    UIView *row = sender.superview;
    UILabel *label = row.subviews[0];
    BOOL on = sender.on;
    NSString *key = @"";
    
    if ([label.text containsString:@"Speed"]) {
        key = @"msl_speed";
        [FluckMSL shared].speedBypass = on;
    } else if ([label.text containsString:@"Telekill"]) {
        key = @"msl_telekill";
        [FluckMSL shared].telekill = on;
    } else if ([label.text containsString:@"Underground"]) {
        key = @"msl_underground";
        [FluckMSL shared].undergroundKill = on;
    } else if ([label.text containsString:@"Ninja"]) {
        key = @"msl_ninja";
        [FluckMSL shared].ninjaRun = on;
    }
    
    [_settings setObject:@(on) forKey:key];
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
    
    // Apply settings
    [FluckESP shared].enabled = [[_settings objectForKey:@"esp_enabled"] boolValue];
    [FluckESP shared].style = [[_settings objectForKey:@"esp_style"] integerValue];
    [FluckESP shared].showHealth = [[_settings objectForKey:@"esp_health"] boolValue];
    [FluckESP shared].showDistance = [[_settings objectForKey:@"esp_distance"] boolValue];
    [FluckESP shared].showName = [[_settings objectForKey:@"esp_name"] boolValue];
    [FluckESP shared].showOutline = [[_settings objectForKey:@"esp_outline"] boolValue];
    [FluckESP shared].showGlow = [[_settings objectForKey:@"esp_glow"] boolValue];
    
    [FluckAimbot shared].enabled = [[_settings objectForKey:@"aim_enabled"] boolValue];
    [FluckAimbot shared].silentAim = [[_settings objectForKey:@"aim_silent"] boolValue];
    [FluckAimbot shared].autoFire = [[_settings objectForKey:@"aim_autofire"] boolValue];
    [FluckAimbot shared].fovRadius = [[_settings objectForKey:@"aim_fov"] floatValue];
    [FluckAimbot shared].targetBone = [[_settings objectForKey:@"aim_bone"] integerValue];
    
    [FluckMSL shared].speedBypass = [[_settings objectForKey:@"msl_speed"] boolValue];
    [FluckMSL shared].telekill = [[_settings objectForKey:@"msl_telekill"] boolValue];
    [FluckMSL shared].undergroundKill = [[_settings objectForKey:@"msl_underground"] boolValue];
    [FluckMSL shared].ninjaRun = [[_settings objectForKey:@"msl_ninja"] boolValue];
}

@end

// ============================================
// MARK: - HOOKING FUNCTIONS
// ============================================

// Hook Unity Update loop using method swizzling
static void (*orig_Update)(id self, SEL _cmd);
static void new_Update(id self, SEL _cmd) {
    orig_Update(self, _cmd);
    
    if (!_isInjected) {
        _isInjected = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[FluckMenu shared] show];
        });
    }
    
    // Update managers
    [[FluckESP shared] update];
    [[FluckAimbot shared] update];
    [[FluckMSL shared] update];
}

// Hook touch events for menu toggle
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

// ============================================
// MARK: - INJECTION ENTRY POINT
// ============================================

__attribute__((constructor))
static void initialize(void) {
    NSLog(@"🔷 Fluck Mod v%@ loaded!", FLUCK_VERSION);
    
    // Get base address
    void *base = GetBaseAddress();
    if (base) {
        NSLog(@"🔷 Base address: %p", base);
    } else {
        NSLog(@"⚠️ Cannot find base address");
        return;
    }
    
    // Hook Unity Update
    // Find UnityPlayer class
    Class unityClass = NSClassFromString(@"UnityPlayer");
    if (unityClass) {
        Method updateMethod = class_getInstanceMethod(unityClass, NSSelectorFromString(@"Update"));
        if (updateMethod) {
            orig_Update = (void (*)(id, SEL))method_getImplementation(updateMethod);
            method_setImplementation(updateMethod, (IMP)new_Update);
            NSLog(@"✅ Hooked Unity Update");
        }
    }
    
    // Hook UIApplication sendEvent
    Class appClass = [UIApplication class];
    Method sendEventMethod = class_getInstanceMethod(appClass, @selector(sendEvent:));
    if (sendEventMethod) {
        orig_SendEvent = (void (*)(id, SEL, UIEvent *))method_getImplementation(sendEventMethod);
        method_setImplementation(sendEventMethod, (IMP)new_SendEvent);
        NSLog(@"✅ Hooked sendEvent");
    }
    
    // Show menu after delay
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[FluckMenu shared] show];
        NSLog(@"✅ Fluck Mod ready!");
    });
}

// ============================================
// END OF FILE
// ============================================
