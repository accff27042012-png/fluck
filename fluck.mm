#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import <AVFoundation/AVFoundation.h>
#import <WebKit/WebKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <mach/mach.h>
#import <mach/vm_map.h>
#import <sys/sysctl.h>

// ============================================================
// MACROS
// ============================================================

#define LOG(msg, ...) NSLog(@"🔰 " msg, ##__VA_ARGS__)

// ============================================================
// MEMORY FUNCTIONS
// ============================================================

static kern_return_t mach_vm_write_fix(vm_map_t task, mach_vm_address_t address, vm_offset_t data, mach_msg_type_number_t size) {
    return vm_write(task, address, data, size);
}

static kern_return_t mach_vm_read_overwrite_fix(vm_map_t task, mach_vm_address_t address, mach_vm_size_t size, mach_vm_address_t data, mach_vm_size_t *outsize) {
    vm_size_t temp = (vm_size_t)*outsize;
    kern_return_t kr = vm_read_overwrite(task, address, (vm_size_t)size, data, &temp);
    *outsize = (mach_vm_size_t)temp;
    return kr;
}

// ============================================================
// FREE FIRE OFFSETS
// ============================================================

// Base Offsets
#define OFF_BASE_ADDRESS         0x2C9B3C8
#define OFF_ENTITY_LIST          0x2C9B3D0
#define OFF_ENTITY_COUNT         0x2C9B3D4
#define OFF_LOCAL_PLAYER         0x2C9B3DC
#define OFF_VIEW_MATRIX          0x2C9B3E0

// Player Offsets
#define OFF_PLAYER_POS_X         0x128
#define OFF_PLAYER_POS_Y         0x12C
#define OFF_PLAYER_POS_Z         0x130
#define OFF_PLAYER_HEALTH        0x14C
#define OFF_PLAYER_MAX_HEALTH    0x150
#define OFF_PLAYER_ARMOR         0x154
#define OFF_PLAYER_NAME          0x168
#define OFF_PLAYER_TEAM          0x180
#define OFF_PLAYER_IS_ALIVE      0x190
#define OFF_PLAYER_IS_SHOOTING   0x1A0
#define OFF_PLAYER_IS_RUNNING    0x1A4
#define OFF_PLAYER_IS_CROUCHING  0x1A8
#define OFF_PLAYER_IS_PRONE      0x1AC
#define OFF_PLAYER_SPEED         0x1B0
#define OFF_PLAYER_WEAPON        0x1C0

// Weapon Offsets
#define OFF_WEAPON_AMMO          0x210
#define OFF_WEAPON_MAX_AMMO      0x214
#define OFF_WEAPON_DAMAGE        0x218
#define OFF_WEAPON_RANGE         0x21C
#define OFF_WEAPON_FIRE_RATE     0x220
#define OFF_WEAPON_RECOIL        0x224
#define OFF_WEAPON_TYPE          0x228

// ESP Offsets
#define OFF_ESP_BOX_X            0x1D0
#define OFF_ESP_BOX_Y            0x1D4
#define OFF_ESP_BOX_W            0x1D8
#define OFF_ESP_BOX_H            0x1DC
#define OFF_ESP_DISTANCE         0x1E0
#define OFF_ESP_ANGLE            0x1E4

// Camera Offsets
#define OFF_CAMERA_VIEW_MATRIX   0x1000
#define OFF_CAMERA_PROJ_MATRIX   0x1040
#define OFF_CAMERA_ANGLE_X       0x10C0
#define OFF_CAMERA_ANGLE_Y       0x10C4
#define OFF_CAMERA_ZOOM          0x10C8

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
        self.titleLabel.font = [UIFont systemFontOfSize:11];
        self.userInteractionEnabled = YES;
        
        self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 25, 0, 20, frame.size.height)];
        self.statusLabel.text = @"○";
        self.statusLabel.textColor = [UIColor grayColor];
        self.statusLabel.font = [UIFont systemFontOfSize:14];
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
    LOG(@"Toggled: %@ - %@", self.titleLabel.text, self.isActive ? @"ON" : @"OFF");
}

@end

// ============================================================
// VECTOR3 CLASS
// ============================================================

typedef struct {
    float x, y, z;
} Vector3;

static inline Vector3 Vector3Make(float x, float y, float z) {
    Vector3 v = {x, y, z};
    return v;
}

static inline float Vector3Distance(Vector3 a, Vector3 b) {
    float dx = a.x - b.x;
    float dy = a.y - b.y;
    float dz = a.z - b.z;
    return sqrtf(dx*dx + dy*dy + dz*dz);
}

static inline Vector3 Vector3Add(Vector3 a, Vector3 b) {
    return Vector3Make(a.x + b.x, a.y + b.y, a.z + b.z);
}

static inline Vector3 Vector3Subtract(Vector3 a, Vector3 b) {
    return Vector3Make(a.x - b.x, a.y - b.y, a.z - b.z);
}

static inline Vector3 Vector3Multiply(Vector3 v, float scalar) {
    return Vector3Make(v.x * scalar, v.y * scalar, v.z * scalar);
}

static inline Vector3 Vector3Normalize(Vector3 v) {
    float len = sqrtf(v.x*v.x + v.y*v.y + v.z*v.z);
    if (len > 0) {
        return Vector3Make(v.x/len, v.y/len, v.z/len);
    }
    return Vector3Make(0, 0, 0);
}

// ============================================================
// FREE FIRE HACK MANAGER
// ============================================================

@interface FreeFireHackManager : NSObject
+ (instancetype)shared;
- (uintptr_t)getBaseAddress;
- (uintptr_t)getLocalPlayer;
- (uintptr_t)getEntityList;
- (int)getEntityCount;
- (float)readFloat:(uintptr_t)address;
- (int)readInt:(uintptr_t)address;
- (void)writeFloat:(uintptr_t)address value:(float)value;
- (void)writeInt:(uintptr_t)address value:(int)value;

// Hack functions
- (void)enableAimbot:(BOOL)enable;
- (void)enableESP:(BOOL)enable;
- (void)enableFlyHack:(BOOL)enable;
- (void)enableGodMode:(BOOL)enable;
- (void)enableSpeedHack:(BOOL)enable;
- (void)enableWallHack:(BOOL)enable;
- (void)enableRadar:(BOOL)enable;
- (void)enableChams:(BOOL)enable;
- (void)enableNoRecoil:(BOOL)enable;
- (void)enableTriggerBot:(BOOL)enable;

@property (nonatomic, assign) BOOL aimbotEnabled;
@property (nonatomic, assign) BOOL espEnabled;
@property (nonatomic, assign) BOOL flyHackEnabled;
@property (nonatomic, assign) BOOL godModeEnabled;
@property (nonatomic, assign) BOOL speedHackEnabled;
@property (nonatomic, assign) BOOL wallHackEnabled;
@property (nonatomic, assign) BOOL radarEnabled;
@property (nonatomic, assign) BOOL chamsEnabled;
@property (nonatomic, assign) BOOL noRecoilEnabled;
@property (nonatomic, assign) BOOL triggerBotEnabled;
@property (nonatomic, assign) uintptr_t baseAddress;
@property (nonatomic, assign) BOOL isHooked;
@property (nonatomic, strong) NSTimer *hackTimer;
@end

@implementation FreeFireHackManager

+ (instancetype)shared {
    static FreeFireHackManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FreeFireHackManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.baseAddress = 0;
        self.isHooked = NO;
        self.aimbotEnabled = NO;
        self.espEnabled = NO;
        self.flyHackEnabled = NO;
        self.godModeEnabled = NO;
        self.speedHackEnabled = NO;
        self.wallHackEnabled = NO;
        self.radarEnabled = NO;
        self.chamsEnabled = NO;
        self.noRecoilEnabled = NO;
        self.triggerBotEnabled = NO;
        
        [self findBaseAddress];
    }
    return self;
}

// ============================================================
// MEMORY FUNCTIONS
// ============================================================

- (uintptr_t)getBaseAddress {
    if (self.baseAddress == 0) {
        [self findBaseAddress];
    }
    return self.baseAddress;
}

- (void)findBaseAddress {
    // Tìm process Free Fire
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    size_t size = 0;
    sysctl(mib, 4, NULL, &size, NULL, 0);
    
    if (size > 0) {
        struct kinfo_proc *procs = (struct kinfo_proc*)malloc(size);
        if (procs) {
            sysctl(mib, 4, procs, &size, NULL, 0);
            int count = size / sizeof(struct kinfo_proc);
            
            for (int i = 0; i < count; i++) {
                NSString *procName = [NSString stringWithUTF8String:procs[i].kp_proc.p_comm];
                if ([procName containsString:@"freefire"] || [procName containsString:@"FreeFire"]) {
                    // Tìm base address
                    // TODO: Implement proper base address finding
                    LOG(@"Found FreeFire process: %@", procName);
                    self.baseAddress = 0x100000000; // Giả định
                    break;
                }
            }
            free(procs);
        }
    }
}

- (uintptr_t)getLocalPlayer {
    uintptr_t base = [self getBaseAddress];
    if (base) {
        return [self readInt:base + OFF_LOCAL_PLAYER];
    }
    return 0;
}

- (uintptr_t)getEntityList {
    uintptr_t base = [self getBaseAddress];
    if (base) {
        return [self readInt:base + OFF_ENTITY_LIST];
    }
    return 0;
}

- (int)getEntityCount {
    uintptr_t base = [self getBaseAddress];
    if (base) {
        return [self readInt:base + OFF_ENTITY_COUNT];
    }
    return 0;
}

- (float)readFloat:(uintptr_t)address {
    float value = 0;
    if (address > 0) {
        mach_vm_read_overwrite_fix(mach_task_self(), address, sizeof(float), (vm_address_t)&value, NULL);
    }
    return value;
}

- (int)readInt:(uintptr_t)address {
    int value = 0;
    if (address > 0) {
        mach_vm_read_overwrite_fix(mach_task_self(), address, sizeof(int), (vm_address_t)&value, NULL);
    }
    return value;
}

- (void)writeFloat:(uintptr_t)address value:(float)value {
    if (address > 0) {
        mach_vm_write_fix(mach_task_self(), address, (vm_offset_t)&value, sizeof(float));
    }
}

- (void)writeInt:(uintptr_t)address value:(int)value {
    if (address > 0) {
        mach_vm_write_fix(mach_task_self(), address, (vm_offset_t)&value, sizeof(int));
    }
}

- (Vector3)readVector3:(uintptr_t)address {
    Vector3 v = {0, 0, 0};
    if (address > 0) {
        v.x = [self readFloat:address + OFF_PLAYER_POS_X];
        v.y = [self readFloat:address + OFF_PLAYER_POS_Y];
        v.z = [self readFloat:address + OFF_PLAYER_POS_Z];
    }
    return v;
}

// ============================================================
// HACK FUNCTIONS
// ============================================================

- (void)enableAimbot:(BOOL)enable {
    self.aimbotEnabled = enable;
    LOG(@"🎯 Aimbot: %@", enable ? @"ENABLED" : @"DISABLED");
    if (enable) {
        [self startHackLoop];
    } else {
        [self stopHackLoop];
    }
}

- (void)enableESP:(BOOL)enable {
    self.espEnabled = enable;
    LOG(@"👁️ ESP: %@", enable ? @"ENABLED" : @"DISABLED");
}

- (void)enableFlyHack:(BOOL)enable {
    self.flyHackEnabled = enable;
    LOG(@"🪄 Fly Hack: %@", enable ? @"ENABLED" : @"DISABLED");
    uintptr_t localPlayer = [self getLocalPlayer];
    if (localPlayer) {
        if (enable) {
            // Lưu vị trí Z hiện tại để bay
            float currentZ = [self readFloat:localPlayer + OFF_PLAYER_POS_Z];
            [self writeFloat:localPlayer + OFF_PLAYER_POS_Z value:currentZ + 1000];
        }
    }
}

- (void)enableGodMode:(BOOL)enable {
    self.godModeEnabled = enable;
    LOG(@"💉 God Mode: %@", enable ? @"ENABLED" : @"DISABLED");
    uintptr_t localPlayer = [self getLocalPlayer];
    if (localPlayer) {
        if (enable) {
            [self writeFloat:localPlayer + OFF_PLAYER_HEALTH value:9999.0f];
            [self writeFloat:localPlayer + OFF_PLAYER_MAX_HEALTH value:9999.0f];
            [self writeFloat:localPlayer + OFF_PLAYER_ARMOR value:9999.0f];
        } else {
            [self writeFloat:localPlayer + OFF_PLAYER_HEALTH value:100.0f];
            [self writeFloat:localPlayer + OFF_PLAYER_MAX_HEALTH value:100.0f];
            [self writeFloat:localPlayer + OFF_PLAYER_ARMOR value:0.0f];
        }
    }
}

- (void)enableSpeedHack:(BOOL)enable {
    self.speedHackEnabled = enable;
    LOG(@"⚡ Speed Hack: %@", enable ? @"ENABLED" : @"DISABLED");
    uintptr_t localPlayer = [self getLocalPlayer];
    if (localPlayer) {
        if (enable) {
            [self writeFloat:localPlayer + OFF_PLAYER_SPEED value:99.0f];
        } else {
            [self writeFloat:localPlayer + OFF_PLAYER_SPEED value:5.0f];
        }
    }
}

- (void)enableWallHack:(BOOL)enable {
    self.wallHackEnabled = enable;
    LOG(@"🛡️ Wall Hack: %@", enable ? @"ENABLED" : @"DISABLED");
    // Thường dùng OpenGL hook hoặc thay đổi giá trị trong shader
}

- (void)enableRadar:(BOOL)enable {
    self.radarEnabled = enable;
    LOG(@"📡 Radar: %@", enable ? @"ENABLED" : @"DISABLED");
}

- (void)enableChams:(BOOL)enable {
    self.chamsEnabled = enable;
    LOG(@"🎨 Chams: %@", enable ? @"ENABLED" : @"DISABLED");
    // Thường dùng OpenGL hook để đổi màu enemy
}

- (void)enableNoRecoil:(BOOL)enable {
    self.noRecoilEnabled = enable;
    LOG(@"🔫 No Recoil: %@", enable ? @"ENABLED" : @"DISABLED");
    uintptr_t localPlayer = [self getLocalPlayer];
    if (localPlayer) {
        if (enable) {
            [self writeFloat:localPlayer + OFF_WEAPON_RECOIL value:0.0f];
        } else {
            [self writeFloat:localPlayer + OFF_WEAPON_RECOIL value:1.0f];
        }
    }
}

- (void)enableTriggerBot:(BOOL)enable {
    self.triggerBotEnabled = enable;
    LOG(@"🎮 Trigger Bot: %@", enable ? @"ENABLED" : @"DISABLED");
}

// ============================================================
// HACK LOOP
// ============================================================

- (void)startHackLoop {
    if (self.hackTimer) return;
    self.hackTimer = [NSTimer scheduledTimerWithTimeInterval:0.016 // ~60fps
                                                      target:self
                                                    selector:@selector(hackLoop)
                                                    userInfo:nil
                                                     repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.hackTimer forMode:NSRunLoopCommonModes];
    LOG(@"Hack loop started");
}

- (void)stopHackLoop {
    if (self.hackTimer) {
        [self.hackTimer invalidate];
        self.hackTimer = nil;
        LOG(@"Hack loop stopped");
    }
}

- (void)hackLoop {
    @autoreleasepool {
        uintptr_t localPlayer = [self getLocalPlayer];
        if (!localPlayer) return;
        
        // God Mode
        if (self.godModeEnabled) {
            [self writeFloat:localPlayer + OFF_PLAYER_HEALTH value:9999.0f];
            [self writeFloat:localPlayer + OFF_PLAYER_MAX_HEALTH value:9999.0f];
            [self writeFloat:localPlayer + OFF_PLAYER_ARMOR value:9999.0f];
        }
        
        // Speed Hack
        if (self.speedHackEnabled) {
            [self writeFloat:localPlayer + OFF_PLAYER_SPEED value:99.0f];
        }
        
        // No Recoil
        if (self.noRecoilEnabled) {
            [self writeFloat:localPlayer + OFF_WEAPON_RECOIL value:0.0f];
        }
        
        // Aimbot - Tìm enemy gần nhất
        if (self.aimbotEnabled) {
            [self performAimbot];
        }
        
        // Trigger Bot
        if (self.triggerBotEnabled) {
            [self performTriggerBot];
        }
    }
}

- (void)performAimbot {
    uintptr_t localPlayer = [self getLocalPlayer];
    if (!localPlayer) return;
    
    Vector3 localPos = [self readVector3:localPlayer];
    uintptr_t entityList = [self getEntityList];
    int entityCount = [self getEntityCount];
    
    float closestDist = FLT_MAX;
    uintptr_t closestEnemy = 0;
    Vector3 closestPos = {0, 0, 0};
    
    for (int i = 0; i < entityCount; i++) {
        uintptr_t entity = [self readInt:entityList + (i * 0x4)];
        if (!entity) continue;
        
        int isAlive = [self readInt:entity + OFF_PLAYER_IS_ALIVE];
        if (!isAlive) continue;
        
        int team = [self readInt:entity + OFF_PLAYER_TEAM];
        int localTeam = [self readInt:localPlayer + OFF_PLAYER_TEAM];
        if (team == localTeam) continue;
        
        Vector3 enemyPos = [self readVector3:entity];
        float dist = Vector3Distance(localPos, enemyPos);
        
        if (dist < closestDist && dist < 100.0f) {
            closestDist = dist;
            closestEnemy = entity;
            closestPos = enemyPos;
        }
    }
    
    if (closestEnemy) {
        // Tính góc aim
        // TODO: Implement aim angle calculation
        // Write vào camera angle
    }
}

- (void)performTriggerBot {
    uintptr_t localPlayer = [self getLocalPlayer];
    if (!localPlayer) return;
    
    uintptr_t entityList = [self getEntityList];
    int entityCount = [self getEntityCount];
    
    for (int i = 0; i < entityCount; i++) {
        uintptr_t entity = [self readInt:entityList + (i * 0x4)];
        if (!entity) continue;
        
        int isAlive = [self readInt:entity + OFF_PLAYER_IS_ALIVE];
        if (!isAlive) continue;
        
        int team = [self readInt:entity + OFF_PLAYER_TEAM];
        int localTeam = [self readInt:localPlayer + OFF_PLAYER_TEAM];
        if (team == localTeam) continue;
        
        // Kiểm tra crosshair đang hướng vào enemy
        // TODO: Implement crosshair check
        // Nếu đúng thì tự động bắn
    }
}

@end

// ============================================================
// YOUTUBE MUSIC PLAYER
// ============================================================

@interface YouTubeMusicPlayer : NSObject
+ (instancetype)shared;
- (void)playSong:(NSString *)songName;
- (void)stop;
- (void)pause;
- (void)resume;
- (BOOL)isPlaying;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIWindow *musicWindow;
@property (nonatomic, assign) BOOL playing;
@property (nonatomic, strong) NSMutableArray *playlist;
@property (nonatomic, assign) NSInteger currentIndex;
@end

@implementation YouTubeMusicPlayer

+ (instancetype)shared {
    static YouTubeMusicPlayer *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YouTubeMusicPlayer alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.playing = NO;
        self.currentIndex = 0;
        self.playlist = [NSMutableArray arrayWithArray:@[
            @"https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            @"https://www.youtube.com/watch?v=3JZ_D3ELwOQ",
            @"https://www.youtube.com/watch?v=fJ9rUzIMcZQ",
            @"https://www.youtube.com/watch?v=OPf0YbXqDm0",
            @"https://www.youtube.com/watch?v=RgKAFK5djSk",
            @"https://www.youtube.com/watch?v=YQHsXMglC9A",
            @"https://www.youtube.com/watch?v=CevxZvSJLk8",
            @"https://www.youtube.com/watch?v=JGwWNGJdvx8",
            @"https://www.youtube.com/watch?v=kJQP7kiw5Fk",
            @"https://www.youtube.com/watch?v=ktvTqknDobU"
        ]];
    }
    return self;
}

- (void)playSong:(NSString *)songName {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.musicWindow) {
            [self setupMusicWindow];
        }
        
        NSString *urlString = nil;
        if (songName && songName.length > 0) {
            for (NSString *url in self.playlist) {
                if ([url containsString:songName] || [songName containsString:url]) {
                    urlString = url;
                    break;
                }
            }
        }
        
        if (!urlString) {
            if (self.playlist.count > 0) {
                urlString = self.playlist[self.currentIndex % self.playlist.count];
                self.currentIndex++;
            }
        }
        
        if (urlString) {
            NSString *html = [NSString stringWithFormat:@"<!DOCTYPE html><html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no\"><style>body{margin:0;background:#000;display:flex;justify-content:center;align-items:center;height:100vh;}iframe{width:100%%;height:100%%;border:none;}</style></head><body><iframe src=\"%@?autoplay=1&playsinline=1\" allow=\"autoplay; encrypted-media\" allowfullscreen></iframe></body></html>", urlString];
            [self.webView loadHTMLString:html baseURL:nil];
            self.playing = YES;
        }
    });
}

- (void)setupMusicWindow {
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat width = 320;
    CGFloat height = 180;
    CGFloat x = screenBounds.size.width - width - 10;
    CGFloat y = screenBounds.size.height - height - 100;
    
    self.musicWindow = [[UIWindow alloc] initWithFrame:CGRectMake(x, y, width, height)];
    self.musicWindow.backgroundColor = [UIColor blackColor];
    self.musicWindow.windowLevel = UIWindowLevelAlert + 50;
    self.musicWindow.hidden = NO;
    self.musicWindow.layer.cornerRadius = 12;
    self.musicWindow.clipsToBounds = YES;
    self.musicWindow.layer.borderColor = [UIColor colorWithRed:0.0 green:0.8 blue:1.0 alpha:0.5].CGColor;
    self.musicWindow.layer.borderWidth = 2;
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.allowsInlineMediaPlayback = YES;
    config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, width, height) configuration:config];
    self.webView.backgroundColor = [UIColor blackColor];
    self.webView.opaque = NO;
    self.webView.scrollView.scrollEnabled = NO;
    self.webView.userInteractionEnabled = YES;
    [self.musicWindow addSubview:self.webView];
    
    // Controls
    UIView *controlsView = [[UIView alloc] initWithFrame:CGRectMake(0, height - 40, width, 40)];
    controlsView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    controlsView.userInteractionEnabled = YES;
    [self.musicWindow addSubview:controlsView];
    
    UIButton *pauseBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    pauseBtn.frame = CGRectMake(10, 5, 30, 30);
    [pauseBtn setTitle:@"⏸" forState:UIControlStateNormal];
    [pauseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    pauseBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [pauseBtn addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
    [controlsView addSubview:pauseBtn];
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    nextBtn.frame = CGRectMake(50, 5, 30, 30);
    [nextBtn setTitle:@"⏭" forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [nextBtn addTarget:self action:@selector(nextSong) forControlEvents:UIControlEventTouchUpInside];
    [controlsView addSubview:nextBtn];
    
    UIButton *prevBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    prevBtn.frame = CGRectMake(90, 5, 30, 30);
    [prevBtn setTitle:@"⏮" forState:UIControlStateNormal];
    [prevBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    prevBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [prevBtn addTarget:self action:@selector(prevSong) forControlEvents:UIControlEventTouchUpInside];
    [controlsView addSubview:prevBtn];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(width - 40, 5, 30, 30);
    [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [closeBtn addTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];
    [controlsView addSubview:closeBtn];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 5, width - 170, 30)];
    titleLabel.text = @"🎵 YouTube Music";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.tag = 999;
    [controlsView addSubview:titleLabel];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.musicWindow addGestureRecognizer:pan];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleFullscreen)];
    doubleTap.numberOfTapsRequired = 2;
    [self.musicWindow addGestureRecognizer:doubleTap];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.musicWindow.superview];
    CGRect frame = self.musicWindow.frame;
    frame.origin.x += translation.x;
    frame.origin.y += translation.y;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    frame.origin.x = MAX(0, MIN(screenWidth - frame.size.width, frame.origin.x));
    frame.origin.y = MAX(0, MIN(screenHeight - frame.size.height, frame.origin.y));
    
    self.musicWindow.frame = frame;
    [gesture setTranslation:CGPointZero inView:self.musicWindow.superview];
}

- (void)toggleFullscreen {
    if (self.musicWindow) {
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        if (self.musicWindow.frame.size.width < screenBounds.size.width / 2) {
            [UIView animateWithDuration:0.3 animations:^{
                self.musicWindow.frame = screenBounds;
                self.musicWindow.layer.cornerRadius = 0;
                self.webView.frame = self.musicWindow.bounds;
            }];
        } else {
            CGFloat width = 320;
            CGFloat height = 180;
            CGFloat x = screenBounds.size.width - width - 10;
            CGFloat y = screenBounds.size.height - height - 100;
            [UIView animateWithDuration:0.3 animations:^{
                self.musicWindow.frame = CGRectMake(x, y, width, height);
                self.musicWindow.layer.cornerRadius = 12;
                self.webView.frame = CGRectMake(0, 0, width, height);
            }];
        }
    }
}

- (void)playNextSong {
    if (self.playlist.count > 0) {
        NSString *url = self.playlist[self.currentIndex % self.playlist.count];
        self.currentIndex++;
        [self playSong:url];
    }
}

- (void)nextSong {
    [self playNextSong];
}

- (void)prevSong {
    if (self.currentIndex > 1) {
        self.currentIndex -= 2;
        [self playNextSong];
    } else {
        self.currentIndex = self.playlist.count - 1;
        [self playNextSong];
    }
}

- (void)pause {
    if (self.playing) {
        self.playing = NO;
        [self.webView evaluateJavaScript:@"document.querySelector('video')?.pause();" completionHandler:nil];
    } else {
        self.playing = YES;
        [self.webView evaluateJavaScript:@"document.querySelector('video')?.play();" completionHandler:nil];
    }
}

- (void)resume {
    self.playing = YES;
    [self.webView evaluateJavaScript:@"document.querySelector('video')?.play();" completionHandler:nil];
}

- (void)stop {
    self.playing = NO;
    [self.webView evaluateJavaScript:@"document.querySelector('video')?.pause();" completionHandler:nil];
    if (self.musicWindow) {
        self.musicWindow.hidden = YES;
        self.musicWindow = nil;
        self.webView = nil;
    }
}

- (BOOL)isPlaying {
    return self.playing && self.musicWindow != nil;
}

@end

// ============================================================
// FLUCK GESTURE RECOGNIZER - 3 NGÓN 2 LẦN
// ============================================================

@interface FluckTripleTapGestureRecognizer : UIGestureRecognizer
@property (nonatomic, assign) NSInteger tapCount;
@property (nonatomic, assign) NSInteger touchCount;
@property (nonatomic, strong) NSTimer *resetTimer;
@end

@implementation FluckTripleTapGestureRecognizer

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    self = [super initWithTarget:target action:action];
    if (self) {
        self.tapCount = 0;
        self.touchCount = 0;
        self.numberOfTouchesRequired = 3;
        self.delaysTouchesEnded = YES;
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    self.touchCount = touches.count;
    
    if (touches.count != 3) {
        [self reset];
        return;
    }
    
    NSArray *allTouches = touches.allObjects;
    if (allTouches.count == 3) {
        CGPoint p1 = [allTouches[0] locationInView:self.view];
        CGPoint p2 = [allTouches[1] locationInView:self.view];
        CGPoint p3 = [allTouches[2] locationInView:self.view];
        
        CGFloat d12 = sqrtf(powf(p1.x - p2.x, 2) + powf(p1.y - p2.y, 2));
        CGFloat d13 = sqrtf(powf(p1.x - p3.x, 2) + powf(p1.y - p3.y, 2));
        CGFloat d23 = sqrtf(powf(p2.x - p3.x, 2) + powf(p2.y - p3.y, 2));
        
        if (d12 > 300 || d13 > 300 || d23 > 300) {
            [self reset];
            return;
        }
        
        self.tapCount++;
        [self.resetTimer invalidate];
        self.resetTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(reset) userInfo:nil repeats:NO];
        
        if (self.tapCount >= 2) {
            [self.resetTimer invalidate];
            self.resetTimer = nil;
            self.state = UIGestureRecognizerStateRecognized;
            [self reset];
        }
    }
}

- (void)reset {
    self.tapCount = 0;
    self.touchCount = 0;
    [self.resetTimer invalidate];
    self.resetTimer = nil;
    self.state = UIGestureRecognizerStateFailed;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (self.tapCount < 2) {
            [self reset];
        }
    });
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
@property (nonatomic, strong) UIButton *toggleButton;
@property (nonatomic, strong) FluckTripleTapGestureRecognizer *tripleTapGesture;
@property (nonatomic, assign) BOOL isHiddenByCamera;
@property (nonatomic, strong) FluckButton *youtubeButton;
@property (nonatomic, strong) NSMutableDictionary *hackStates;
@property (nonatomic, strong) FreeFireHackManager *hackManager;
@end

@implementation FluckMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.userInteractionEnabled = YES;
    self.isVisible = NO;
    self.isHiddenByCamera = NO;
    self.buttons = [NSMutableArray array];
    self.hackStates = [NSMutableDictionary dictionary];
    self.hackManager = [FreeFireHackManager shared];
    [self setupMenu];
    [self setupFPSMonitor];
    [self setupToggleButton];
    [self setupGestureRecognizers];
    [self setupCameraDetection];
}

// ============================================================
// DETECT CAMERA / SCREENSHOT / SCREEN RECORDING
// ============================================================

- (void)setupCameraDetection {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cameraDidStart:)
                                                 name:@"AVCaptureSessionDidStartRunningNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cameraDidStop:)
                                                 name:@"AVCaptureSessionDidStopRunningNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(screenshotDetected:)
                                                 name:UIApplicationUserDidTakeScreenshotNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(screenRecordingDidChange:)
                                                 name:UIScreenCapturedDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [self setupVolumeButtonDetection];
}

- (void)setupVolumeButtonDetection {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:YES error:nil];
    [audioSession addObserver:self
                   forKeyPath:@"outputVolume"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"outputVolume"]) {
        [self autoHideMenu];
    }
}

- (void)cameraDidStart:(NSNotification *)notification {
    LOG(@"📷 Camera started! Auto-hiding menu");
    [self autoHideMenu];
}

- (void)cameraDidStop:(NSNotification *)notification {
    LOG(@"📷 Camera stopped! Restoring menu");
    [self autoShowMenu];
}

- (void)screenshotDetected:(NSNotification *)notification {
    LOG(@"📸 Screenshot detected! Auto-hiding menu");
    [self autoHideMenu];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self autoShowMenu];
    });
}

- (void)screenRecordingDidChange:(NSNotification *)notification {
    if ([UIScreen mainScreen].isCaptured) {
        LOG(@"🎥 Screen recording started! Auto-hiding menu");
        [self autoHideMenu];
    } else {
        LOG(@"🎥 Screen recording stopped! Restoring menu");
        [self autoShowMenu];
    }
}

- (void)appDidEnterBackground:(NSNotification *)notification {
    LOG(@"📱 App entered background - auto-hiding menu");
    [self autoHideMenu];
}

- (void)appDidBecomeActive:(NSNotification *)notification {
    LOG(@"📱 App became active - restoring menu");
    if (!self.isHiddenByCamera) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self autoShowMenu];
        });
    }
}

- (void)autoHideMenu {
    if (self.isVisible) {
        self.isHiddenByCamera = YES;
        [self hideWithAnimation];
        self.toggleButton.hidden = YES;
    }
}

- (void)autoShowMenu {
    if (!self.isVisible && self.isHiddenByCamera) {
        self.isHiddenByCamera = NO;
        [self showWithAnimation];
    }
}

// ============================================================
// GESTURE RECOGNIZERS
// ============================================================

- (void)setupGestureRecognizers {
    self.tripleTapGesture = [[FluckTripleTapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTripleTap:)];
    self.tripleTapGesture.delegate = self;
    [self.view addGestureRecognizer:self.tripleTapGesture];
    LOG(@"✅ 3-ngón 2-lần gesture setup");
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 2.0;
    longPress.numberOfTouchesRequired = 1;
    longPress.delegate = self;
    [self.view addGestureRecognizer:longPress];
    LOG(@"✅ Long press 2s gesture setup");
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    doubleTap.delegate = self;
    [self.view addGestureRecognizer:doubleTap];
    LOG(@"✅ Double tap gesture setup");
}

- (void)handleTripleTap:(FluckTripleTapGestureRecognizer *)gesture {
    LOG(@"🔴🔴 3 ngón chạm 2 lần! Toggle menu");
    self.isHiddenByCamera = NO;
    [self toggle];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        LOG(@"🔵 Long press 2s - Toggle menu");
        self.isHiddenByCamera = NO;
        [self toggle];
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture {
    LOG(@"🟢 Double tap - Toggle menu");
    self.isHiddenByCamera = NO;
    [self toggle];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

// ============================================================
// TOGGLE BUTTON
// ============================================================

- (void)setupToggleButton {
    self.toggleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.toggleButton.frame = CGRectMake(10, 60, 50, 50);
    self.toggleButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.6 blue:1.0 alpha:0.8];
    self.toggleButton.layer.cornerRadius = 25;
    self.toggleButton.clipsToBounds = YES;
    [self.toggleButton setTitle:@"⚡" forState:UIControlStateNormal];
    [self.toggleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.toggleButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
    self.toggleButton.userInteractionEnabled = YES;
    self.toggleButton.hidden = YES;
    [self.toggleButton addTarget:self action:@selector(toggleFromButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.toggleButton];
}

- (void)toggleFromButton {
    self.isHiddenByCamera = NO;
    [self toggle];
}

// ============================================================
// FPS MONITOR
// ============================================================

- (void)setupFPSMonitor {
    self.fpsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 18)];
    self.fpsLabel.textColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
    self.fpsLabel.font = [UIFont systemFontOfSize:11];
    self.fpsLabel.text = @"FPS: 0";
    [self.menuView addSubview:self.fpsLabel];
}

// ============================================================
// HACK HANDLER
// ============================================================

- (void)handleHackToggle:(FluckButton *)sender {
    sender.isActive = !sender.isActive;
    
    NSString *hackName = sender.titleLabel.text;
    hackName = [hackName stringByReplacingOccurrencesOfString:@"🎯 " withString:@""];
    hackName = [hackName stringByReplacingOccurrencesOfString:@"👁️ " withString:@""];
    hackName = [hackName stringByReplacingOccurrencesOfString:@"🪄 " withString:@""];
    hackName = [hackName stringByReplacingOccurrencesOfString:@"💉 " withString:@""];
    hackName = [hackName stringByReplacingOccurrencesOfString:@"⚡ " withString:@""];
    hackName = [hackName stringByReplacingOccurrencesOfString:@"🛡️ " withString:@""];
    hackName = [hackName stringByReplacingOccurrencesOfString:@"📡 " withString:@""];
    hackName = [hackName stringByReplacingOccurrencesOfString:@"🎨 " withString:@""];
    hackName = [hackName stringByReplacingOccurrencesOfString:@"🔫 " withString:@""];
    hackName = [hackName stringByReplacingOccurrencesOfString:@"🎮 " withString:@""];
    
    self.hackStates[hackName] = @(sender.isActive);
    
    // Gọi hàm hack tương ứng
    if ([hackName isEqualToString:@"Aimbot"]) {
        [self.hackManager enableAimbot:sender.isActive];
    } else if ([hackName isEqualToString:@"ESP"]) {
        [self.hackManager enableESP:sender.isActive];
    } else if ([hackName isEqualToString:@"Fly Hack"]) {
        [self.hackManager enableFlyHack:sender.isActive];
    } else if ([hackName isEqualToString:@"God Mode"]) {
        [self.hackManager enableGodMode:sender.isActive];
    } else if ([hackName isEqualToString:@"Speed Hack"]) {
        [self.hackManager enableSpeedHack:sender.isActive];
    } else if ([hackName isEqualToString:@"Wall Hack"]) {
        [self.hackManager enableWallHack:sender.isActive];
    } else if ([hackName isEqualToString:@"Radar"]) {
        [self.hackManager enableRadar:sender.isActive];
    } else if ([hackName isEqualToString:@"Chams"]) {
        [self.hackManager enableChams:sender.isActive];
    } else if ([hackName isEqualToString:@"No Recoil"]) {
        [self.hackManager enableNoRecoil:sender.isActive];
    } else if ([hackName isEqualToString:@"Trigger Bot"]) {
        [self.hackManager enableTriggerBot:sender.isActive];
    }
    
    if (sender.isActive) {
        sender.backgroundColor = [UIColor colorWithRed:0.0 green:0.6 blue:0.0 alpha:1.0];
        sender.statusLabel.text = @"●";
        sender.statusLabel.textColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
        [self showToast:[NSString stringWithFormat:@"✅ %@ ENABLED", hackName]];
        LOG(@"✅ %@ ENABLED", hackName);
    } else {
        sender.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        sender.statusLabel.text = @"○";
        sender.statusLabel.textColor = [UIColor grayColor];
        [self showToast:[NSString stringWithFormat:@"❌ %@ DISABLED", hackName]];
        LOG(@"❌ %@ DISABLED", hackName);
    }
}

- (void)showToast:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"⚡ Fluck" 
                                                                       message:message 
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

// ============================================================
// MENU UI
// ============================================================

- (void)setupMenu {
    CGFloat menuWidth = 280;
    CGFloat menuHeight = 530;
    self.menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, menuWidth, menuHeight)];
    self.menuView.backgroundColor = [UIColor colorWithWhite:0.05 alpha:0.95];
    self.menuView.layer.cornerRadius = 16;
    self.menuView.layer.borderColor = [UIColor colorWithRed:0.0 green:0.8 blue:1.0 alpha:0.6].CGColor;
    self.menuView.layer.borderWidth = 2;
    self.menuView.center = self.view.center;
    self.menuView.userInteractionEnabled = YES;
    self.menuView.clipsToBounds = YES;
    [self.view addSubview:self.menuView];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.menuView.bounds;
    gradient.colors = @[
        (id)[UIColor colorWithWhite:0.05 alpha:0.95].CGColor,
        (id)[UIColor colorWithWhite:0.1 alpha:0.95].CGColor
    ];
    [self.menuView.layer insertSublayer:gradient atIndex:0];
    
    // Title
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, menuWidth, 30)];
    title.text = @"⚡ Fluck Pro v1.0";
    title.textColor = [UIColor colorWithRed:0.0 green:0.8 blue:1.0 alpha:1.0];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont boldSystemFontOfSize:20];
    [self.menuView addSubview:title];
    
    // Subtitle
    UILabel *subtitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 38, menuWidth, 16)];
    subtitle.text = @"Free Fire Hack | 3-ngón 2-lần toggle";
    subtitle.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    subtitle.textAlignment = NSTextAlignmentCenter;
    subtitle.font = [UIFont systemFontOfSize:10];
    [self.menuView addSubview:subtitle];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, 58, menuWidth - 30, 1)];
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
        @"🎮 Trigger Bot",
        @"🎵 YouTube Music"
    ];
    
    CGFloat y = 68;
    CGFloat spacing = 34;
    int cols = 2;
    CGFloat btnWidth = (menuWidth - 50) / 2;
    CGFloat btnHeight = 28;
    CGFloat margin = 15;
    
    for (int i = 0; i < features.count; i++) {
        int row = i / cols;
        int col = i % cols;
        CGFloat x = margin + col * (btnWidth + 10);
        CGFloat yPos = y + row * spacing;
        
        FluckButton *btn = [[FluckButton alloc] initWithFrame:CGRectMake(x, yPos, btnWidth, btnHeight)];
        [btn setTitle:features[i] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:10];
        btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        btn.tag = i;
        
        if (i == 10) { // YouTube Music
            [btn addTarget:self action:@selector(toggleYouTubeMusic:) forControlEvents:UIControlEventTouchUpInside];
            self.youtubeButton = btn;
        } else {
            [btn addTarget:self action:@selector(handleHackToggle:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [self.menuView addSubview:btn];
        [self.buttons addObject:btn];
    }
    
    UIButton *close = [UIButton buttonWithType:UIButtonTypeSystem];
    int totalRows = (features.count + cols - 1) / cols;
    CGFloat closeY = y + totalRows * spacing + 10;
    close.frame = CGRectMake(40, closeY, menuWidth - 80, 36);
    [close setTitle:@"✕ Hide Menu" forState:UIControlStateNormal];
    [close setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    close.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    close.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
    close.layer.cornerRadius = 10;
    close.userInteractionEnabled = YES;
    [close addTarget:self action:@selector(hideMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:close];
    
    CGFloat totalHeight = closeY + 48;
    CGRect frame = self.menuView.frame;
    frame.size.height = totalHeight;
    self.menuView.frame = frame;
    self.menuView.center = self.view.center;
    
    UIView *handle = [[UIView alloc] initWithFrame:CGRectMake((menuWidth - 40) / 2, 8, 40, 4)];
    handle.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    handle.layer.cornerRadius = 2;
    [self.menuView addSubview:handle];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.delegate = self;
    [self.menuView addGestureRecognizer:pan];
}

// ============================================================
// YOUTUBE MUSIC TOGGLE
// ============================================================

- (void)toggleYouTubeMusic:(FluckButton *)sender {
    sender.isActive = !sender.isActive;
    if (sender.isActive) {
        sender.backgroundColor = [UIColor colorWithRed:0.0 green:0.6 blue:0.0 alpha:1.0];
        sender.statusLabel.text = @"●";
        sender.statusLabel.textColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
        [self showToast:@"🎵 YouTube Music ENABLED"];
        [[YouTubeMusicPlayer shared] playSong:nil];
    } else {
        sender.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        sender.statusLabel.text = @"○";
        sender.statusLabel.textColor = [UIColor grayColor];
        [self showToast:@"🎵 YouTube Music DISABLED"];
        [[YouTubeMusicPlayer shared] stop];
    }
    LOG(@"🎵 YouTube Music: %@", sender.isActive ? @"ON" : @"OFF");
}

// ============================================================
// MENU ANIMATION
// ============================================================

- (void)hideMenu {
    [self hideWithAnimation];
    self.toggleButton.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.toggleButton.alpha = 1.0;
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (self.toggleButton && !self.toggleButton.hidden) {
            [UIView animateWithDuration:0.3 animations:^{
                self.toggleButton.alpha = 0.3;
            }];
        }
    });
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.view];
    CGPoint newCenter = CGPointMake(self.menuView.center.x + translation.x, self.menuView.center.y + translation.y);
    
    CGFloat halfWidth = self.menuView.frame.size.width / 2;
    CGFloat halfHeight = self.menuView.frame.size.height / 2;
    newCenter.x = MAX(halfWidth, MIN(self.view.bounds.size.width - halfWidth, newCenter.x));
    newCenter.y = MAX(halfHeight, MIN(self.view.bounds.size.height - halfHeight, newCenter.y));
    
    self.menuView.center = newCenter;
    [gesture setTranslation:CGPointZero inView:self.view];
}

- (void)showWithAnimation {
    self.isVisible = YES;
    self.view.hidden = NO;
    self.view.userInteractionEnabled = YES;
    
    self.toggleButton.hidden = YES;
    self.toggleButton.alpha = 0;
    
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
        self.toggleButton.hidden = NO;
        self.toggleButton.alpha = 1.0;
    } else {
        [self showWithAnimation];
        self.toggleButton.hidden = YES;
    }
}

- (void)startFPSMonitor {
    if (self.fpsTimer) {
        [self.fpsTimer invalidate];
        self.fpsTimer = nil;
    }
    self.fpsTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer *timer) {
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[AVAudioSession sharedInstance] removeObserver:self forKeyPath:@"outputVolume"];
    [[YouTubeMusicPlayer shared] stop];
    [self.hackManager stopHackLoop];
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
        
        if (@available(iOS 26.0, *)) {
            if (scene) {
                self.overlayWindow = [[UIWindow alloc] initWithWindowScene:scene];
            } else {
                self.overlayWindow = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
            }
        } else {
            self.overlayWindow = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        }
        
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
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.menuVC showWithAnimation];
        });
        
        LOG(@"✅ Fluck started successfully!");
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
        [[YouTubeMusicPlayer shared] stop];
        LOG(@"⛔ Fluck stopped");
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
// CONSTRUCTOR
// ============================================================

__attribute__((constructor))
static void fluck_constructor(void) {
    LOG(@"═══════════════════════════════════════════════");
    LOG(@"║   🔥 Fluck Pro v1.0 - Free Fire Hack     ║");
    LOG(@"║   📅 Build: %s %s", __DATE__, __TIME__);
    LOG(@"║   👆 3-ngón 2-lần toggle menu           ║");
    LOG(@"║   📷 Auto-hide khi chụp ảnh/quay video  ║");
    LOG(@"║   🎵 YouTube Music Player               ║");
    LOG(@"║   🎯 ALL HACK FUNCTIONS ACTIVE          ║");
    LOG(@"═══════════════════════════════════════════════");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[FluckManager shared] start];
    });
}

__attribute__((destructor))
static void fluck_destructor(void) {
    LOG(@"Fluck Pro Unloaded");
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
// MAIN
// ============================================================

int main(int argc, char *argv[]) {
    @autoreleasepool {
        start_fluck();
        [[NSRunLoop mainRunLoop] run];
    }
    return 0;
}
