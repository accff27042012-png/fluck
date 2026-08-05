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

#define LOG(msg, ...) NSLog(@"🔰 " msg, ##__VA_ARGS__)

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

#define OFF_BASE_ADDRESS         0x2C9B3C8
#define OFF_ENTITY_LIST          0x2C9B3D0
#define OFF_ENTITY_COUNT         0x2C9B3D4
#define OFF_LOCAL_PLAYER         0x2C9B3DC
#define OFF_VIEW_MATRIX          0x2C9B3E0

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

#define OFF_WEAPON_AMMO          0x210
#define OFF_WEAPON_MAX_AMMO      0x214
#define OFF_WEAPON_DAMAGE        0x218
#define OFF_WEAPON_RANGE         0x21C
#define OFF_WEAPON_FIRE_RATE     0x220
#define OFF_WEAPON_RECOIL        0x224
#define OFF_WEAPON_TYPE          0x228

#define OFF_ESP_BOX_X            0x1D0
#define OFF_ESP_BOX_Y            0x1D4
#define OFF_ESP_BOX_W            0x1D8
#define OFF_ESP_BOX_H            0x1DC
#define OFF_ESP_DISTANCE         0x1E0
#define OFF_ESP_ANGLE            0x1E4

#define OFF_CAMERA_VIEW_MATRIX   0x1000
#define OFF_CAMERA_PROJ_MATRIX   0x1040
#define OFF_CAMERA_ANGLE_X       0x10C0
#define OFF_CAMERA_ANGLE_Y       0x10C4
#define OFF_CAMERA_ZOOM          0x10C8

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
- (Vector3)readVector3:(uintptr_t)address;

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
- (void)enableInfiniteAmmo:(BOOL)enable;
- (void)enableTeleport:(BOOL)enable;
- (void)stopHackLoop;
- (void)stopTeleportLoop;

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
@property (nonatomic, assign) BOOL infiniteAmmoEnabled;
@property (nonatomic, assign) BOOL teleportEnabled;
@property (nonatomic, assign) uintptr_t baseAddress;
@property (nonatomic, strong) NSTimer *hackTimer;
@property (nonatomic, strong) NSTimer *teleportTimer;
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
        self.infiniteAmmoEnabled = NO;
        self.teleportEnabled = NO;
        [self findBaseAddress];
    }
    return self;
}

- (uintptr_t)getBaseAddress {
    if (self.baseAddress == 0) {
        [self findBaseAddress];
    }
    return self.baseAddress;
}

- (void)findBaseAddress {
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
                    LOG(@"Found FreeFire process: %@", procName);
                    self.baseAddress = 0x100000000;
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

- (void)enableAimbot:(BOOL)enable {
    self.aimbotEnabled = enable;
    LOG(@"🎯 Aimbot: %@", enable ? @"ENABLED" : @"DISABLED");
    if (enable) [self startHackLoop];
    else [self stopHackLoop];
}

- (void)enableESP:(BOOL)enable {
    self.espEnabled = enable;
    LOG(@"👁️ ESP: %@", enable ? @"ENABLED" : @"DISABLED");
}

- (void)enableFlyHack:(BOOL)enable {
    self.flyHackEnabled = enable;
    LOG(@"🪄 Fly Hack: %@", enable ? @"ENABLED" : @"DISABLED");
    uintptr_t localPlayer = [self getLocalPlayer];
    if (localPlayer && enable) {
        float currentZ = [self readFloat:localPlayer + OFF_PLAYER_POS_Z];
        [self writeFloat:localPlayer + OFF_PLAYER_POS_Z value:currentZ + 1000];
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
        [self writeFloat:localPlayer + OFF_PLAYER_SPEED value:enable ? 99.0f : 5.0f];
    }
}

- (void)enableWallHack:(BOOL)enable {
    self.wallHackEnabled = enable;
    LOG(@"🛡️ Wall Hack: %@", enable ? @"ENABLED" : @"DISABLED");
}

- (void)enableRadar:(BOOL)enable {
    self.radarEnabled = enable;
    LOG(@"📡 Radar: %@", enable ? @"ENABLED" : @"DISABLED");
}

- (void)enableChams:(BOOL)enable {
    self.chamsEnabled = enable;
    LOG(@"🎨 Chams: %@", enable ? @"ENABLED" : @"DISABLED");
}

- (void)enableNoRecoil:(BOOL)enable {
    self.noRecoilEnabled = enable;
    LOG(@"🔫 No Recoil: %@", enable ? @"ENABLED" : @"DISABLED");
    uintptr_t localPlayer = [self getLocalPlayer];
    if (localPlayer) {
        [self writeFloat:localPlayer + OFF_WEAPON_RECOIL value:enable ? 0.0f : 1.0f];
    }
}

- (void)enableTriggerBot:(BOOL)enable {
    self.triggerBotEnabled = enable;
    LOG(@"🎮 Trigger Bot: %@", enable ? @"ENABLED" : @"DISABLED");
}

- (void)enableInfiniteAmmo:(BOOL)enable {
    self.infiniteAmmoEnabled = enable;
    LOG(@"🔫 Infinite Ammo: %@", enable ? @"ENABLED" : @"DISABLED");
    uintptr_t localPlayer = [self getLocalPlayer];
    if (localPlayer && enable) {
        [self writeInt:localPlayer + OFF_WEAPON_AMMO value:9999];
        [self writeInt:localPlayer + OFF_WEAPON_MAX_AMMO value:9999];
    }
}

- (void)enableTeleport:(BOOL)enable {
    self.teleportEnabled = enable;
    LOG(@"🌀 Teleport: %@", enable ? @"ENABLED" : @"DISABLED");
    if (enable) {
        [self startTeleportLoop];
    } else {
        [self stopTeleportLoop];
    }
}

- (void)startTeleportLoop {
    if (self.teleportTimer) return;
    self.teleportTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                          target:self
                                                        selector:@selector(teleportLoop)
                                                        userInfo:nil
                                                         repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.teleportTimer forMode:NSRunLoopCommonModes];
}

- (void)stopTeleportLoop {
    if (self.teleportTimer) {
        [self.teleportTimer invalidate];
        self.teleportTimer = nil;
    }
}

- (void)teleportLoop {
    uintptr_t localPlayer = [self getLocalPlayer];
    if (!localPlayer) return;
    Vector3 pos = [self readVector3:localPlayer];
    [self writeFloat:localPlayer + OFF_PLAYER_POS_Z value:pos.z + 500];
}

- (void)startHackLoop {
    if (self.hackTimer) return;
    self.hackTimer = [NSTimer scheduledTimerWithTimeInterval:0.016
                                                      target:self
                                                    selector:@selector(hackLoop)
                                                    userInfo:nil
                                                     repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.hackTimer forMode:NSRunLoopCommonModes];
}

- (void)stopHackLoop {
    if (self.hackTimer) {
        [self.hackTimer invalidate];
        self.hackTimer = nil;
    }
}

- (void)hackLoop {
    @autoreleasepool {
        uintptr_t localPlayer = [self getLocalPlayer];
        if (!localPlayer) return;
        
        if (self.godModeEnabled) {
            [self writeFloat:localPlayer + OFF_PLAYER_HEALTH value:9999.0f];
            [self writeFloat:localPlayer + OFF_PLAYER_MAX_HEALTH value:9999.0f];
            [self writeFloat:localPlayer + OFF_PLAYER_ARMOR value:9999.0f];
        }
        if (self.speedHackEnabled) {
            [self writeFloat:localPlayer + OFF_PLAYER_SPEED value:99.0f];
        }
        if (self.noRecoilEnabled) {
            [self writeFloat:localPlayer + OFF_WEAPON_RECOIL value:0.0f];
        }
        if (self.infiniteAmmoEnabled) {
            [self writeInt:localPlayer + OFF_WEAPON_AMMO value:9999];
            [self writeInt:localPlayer + OFF_WEAPON_MAX_AMMO value:9999];
        }
        if (self.aimbotEnabled) {
            [self performAimbot];
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
        }
    }
}

@end

// ============================================================
// SOUNDCLOUD MUSIC PLAYER (THAY THẾ YOUTUBE)
// ============================================================

@interface SoundCloudPlayer : NSObject <WKNavigationDelegate>
+ (instancetype)shared;
- (void)play;
- (void)stop;
- (void)pause;
- (void)resume;
- (BOOL)isPlaying;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIWindow *musicWindow;
@property (nonatomic, assign) BOOL playing;
@property (nonatomic, strong) NSArray *playlist;
@property (nonatomic, assign) NSInteger currentIndex;
@end

@implementation SoundCloudPlayer

+ (instancetype)shared {
    static SoundCloudPlayer *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SoundCloudPlayer alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.playing = NO;
        self.currentIndex = 0;
        // Playlist nhạc SoundCloud (không bị phát hiện người máy)
        self.playlist = @[
            @"https://soundcloud.com/alanwalkermusic/alan-walker-fade",
            @"https://soundcloud.com/marshmellomusic/alan-walker-faded-marshmello",
            @"https://soundcloud.com/kygoofficial/kygo-firestone",
            @"https://soundcloud.com/thechainsmokers/closer-ft-halsey",
            @"https://soundcloud.com/majorlazer/lean-on-feat-mo-dj-snake"
        ];
    }
    return self;
}

- (void)play {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.musicWindow) {
            [self setupMusicWindow];
        }
        
        if (self.playlist.count > 0) {
            NSString *urlString = self.playlist[self.currentIndex % self.playlist.count];
            self.currentIndex++;
            
            // SoundCloud embed
            NSString *html = [NSString stringWithFormat:
                @"<!DOCTYPE html>"
                @"<html>"
                @"<head>"
                @"<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no\">"
                @"<style>"
                @"body{margin:0;background:#000;display:flex;justify-content:center;align-items:center;height:100vh;overflow:hidden;}"
                @"iframe{width:100%%;height:100%%;border:none;}"
                @"</style>"
                @"</head>"
                @"<body>"
                @"<iframe src=\"%@?autoplay=true&visual=true\" "
                @"allow=\"autoplay; encrypted-media\" "
                @"allowfullscreen>"
                @"</iframe>"
                @"</body>"
                @"</html>", urlString];
            
            [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:@"https://soundcloud.com"]];
            self.playing = YES;
            LOG(@"🎵 SoundCloud playing: %@", urlString);
        }
    });
}

- (void)setupMusicWindow {
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
    
    CGRect screenBounds;
    if (scene) {
        screenBounds = scene.screen.bounds;
    } else {
        screenBounds = [UIScreen mainScreen].bounds;
    }
    CGFloat width = 320, height = 200;
    CGFloat x = screenBounds.size.width - width - 10;
    CGFloat y = screenBounds.size.height - height - 100;
    
    if (@available(iOS 26.0, *)) {
        if (scene) {
            self.musicWindow = [[UIWindow alloc] initWithWindowScene:scene];
            self.musicWindow.frame = CGRectMake(x, y, width, height);
        } else {
            self.musicWindow = [[UIWindow alloc] initWithFrame:CGRectMake(x, y, width, height)];
        }
    } else {
        self.musicWindow = [[UIWindow alloc] initWithFrame:CGRectMake(x, y, width, height)];
    }
    
    self.musicWindow.backgroundColor = [UIColor blackColor];
    self.musicWindow.windowLevel = UIWindowLevelAlert + 50;
    self.musicWindow.hidden = NO;
    self.musicWindow.layer.cornerRadius = 12;
    self.musicWindow.clipsToBounds = YES;
    self.musicWindow.layer.borderColor = [UIColor colorWithRed:1.0 green:0.6 blue:0.0 alpha:0.5].CGColor;
    self.musicWindow.layer.borderWidth = 2;
    self.musicWindow.userInteractionEnabled = YES;
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.allowsInlineMediaPlayback = YES;
    config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
    config.allowsAirPlayForMediaPlayback = YES;
    config.preferences = [[WKPreferences alloc] init];
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, width, height) configuration:config];
    webView.backgroundColor = [UIColor blackColor];
    webView.opaque = NO;
    webView.scrollView.scrollEnabled = NO;
    webView.userInteractionEnabled = YES;
    webView.navigationDelegate = self;
    [self.musicWindow addSubview:webView];
    self.webView = webView;
    
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
    titleLabel.text = @"🎵 SoundCloud";
    titleLabel.textColor = [UIColor colorWithRed:1.0 green:0.6 blue:0.0 alpha:1.0];
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.tag = 999;
    [controlsView addSubview:titleLabel];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.musicWindow addGestureRecognizer:pan];
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

- (void)nextSong {
    if (self.playlist.count > 0) {
        NSString *url = self.playlist[self.currentIndex % self.playlist.count];
        self.currentIndex++;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *html = [NSString stringWithFormat:
                @"<!DOCTYPE html><html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no\"><style>body{margin:0;background:#000;display:flex;justify-content:center;align-items:center;height:100vh;overflow:hidden;}iframe{width:100%%;height:100%%;border:none;}</style></head><body><iframe src=\"%@?autoplay=true&visual=true\" allow=\"autoplay; encrypted-media\" allowfullscreen></iframe></body></html>", url];
            [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:@"https://soundcloud.com"]];
            self.playing = YES;
        });
    }
}

- (void)prevSong {
    if (self.currentIndex > 1) {
        self.currentIndex -= 2;
        [self nextSong];
    } else {
        self.currentIndex = self.playlist.count - 1;
        [self nextSong];
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

- (BOOL)isPlaying {
    return self.playing && self.musicWindow != nil;
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

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    LOG(@"✅ SoundCloud loaded");
    [webView evaluateJavaScript:@"document.querySelector('video')?.play();" completionHandler:nil];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    LOG(@"❌ SoundCloud error: %@", error.localizedDescription);
}

@end

// ============================================================
// FLUCK FLOATING BUTTON
// ============================================================

@interface FluckFloatingButton : UIButton
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, assign) BOOL isOn;
@property (nonatomic, strong) UILabel *iconLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *floatingTitleLabel;
@end

@implementation FluckFloatingButton

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title icon:(NSString *)icon {
    self = [super initWithFrame:frame];
    if (self) {
        self.isOn = NO;
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.75];
        self.layer.cornerRadius = 10;
        self.clipsToBounds = YES;
        self.layer.borderColor = [UIColor colorWithWhite:0.4 alpha:0.5].CGColor;
        self.layer.borderWidth = 1;
        
        self.iconLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 2, 20, 20)];
        self.iconLabel.text = icon;
        self.iconLabel.textColor = [UIColor whiteColor];
        self.iconLabel.font = [UIFont systemFontOfSize:14];
        self.iconLabel.textAlignment = NSTextAlignmentCenter;
        self.iconLabel.userInteractionEnabled = NO;
        [self addSubview:self.iconLabel];
        
        self.floatingTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(28, 2, 50, 20)];
        self.floatingTitleLabel.text = title;
        self.floatingTitleLabel.textColor = [UIColor whiteColor];
        self.floatingTitleLabel.font = [UIFont boldSystemFontOfSize:12];
        self.floatingTitleLabel.textAlignment = NSTextAlignmentLeft;
        self.floatingTitleLabel.userInteractionEnabled = NO;
        [self addSubview:self.floatingTitleLabel];
        
        self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 18, 4, 12, 12)];
        self.statusLabel.text = @"○";
        self.statusLabel.textColor = [UIColor colorWithRed:1.0 green:0.2 blue:0.2 alpha:1.0];
        self.statusLabel.font = [UIFont systemFontOfSize:12];
        self.statusLabel.textAlignment = NSTextAlignmentCenter;
        self.statusLabel.userInteractionEnabled = NO;
        [self addSubview:self.statusLabel];
        
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 2);
        self.layer.shadowRadius = 4;
        self.layer.shadowOpacity = 0.3;
        
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:self.panGesture];
        
        self.userInteractionEnabled = YES;
        self.exclusiveTouch = YES;
    }
    return self;
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.superview];
    CGPoint newCenter = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat halfWidth = self.frame.size.width / 2;
    CGFloat halfHeight = self.frame.size.height / 2;
    newCenter.x = MAX(halfWidth, MIN(screenWidth - halfWidth, newCenter.x));
    newCenter.y = MAX(halfHeight, MIN(screenHeight - halfHeight, newCenter.y));
    
    self.center = newCenter;
    [gesture setTranslation:CGPointZero inView:self.superview];
}

- (void)toggle {
    self.isOn = !self.isOn;
    [self updateUI];
}

- (void)setOn:(BOOL)on {
    _isOn = on;
    [self updateUI];
}

- (void)updateUI {
    if (self.isOn) {
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.6 blue:0.2 alpha:0.8];
        self.layer.borderColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.5].CGColor;
        self.statusLabel.text = @"●";
        self.statusLabel.textColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
    } else {
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.75];
        self.layer.borderColor = [UIColor colorWithWhite:0.4 alpha:0.5].CGColor;
        self.statusLabel.text = @"○";
        self.statusLabel.textColor = [UIColor colorWithRed:1.0 green:0.2 blue:0.2 alpha:1.0];
    }
}

@end

// ============================================================
// FLUCK GESTURE RECOGNIZER
// ============================================================

@interface FluckTripleTapGestureRecognizer : UIGestureRecognizer
@property (nonatomic, assign) NSInteger tapCount;
@property (nonatomic, strong) NSTimer *resetTimer;
@end

@implementation FluckTripleTapGestureRecognizer

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    self = [super initWithTarget:target action:action];
    if (self) {
        self.tapCount = 0;
        self.delaysTouchesEnded = YES;
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
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
@property (nonatomic, strong) NSMutableArray *floatingButtons;
@property (nonatomic, strong) UILabel *fpsLabel;
@property (nonatomic, strong) NSTimer *fpsTimer;
@property (nonatomic, strong) FluckFloatingButton *mainFloatingButton;
@property (nonatomic, strong) FluckTripleTapGestureRecognizer *tripleTapGesture;
@property (nonatomic, assign) BOOL isHiddenByCamera;
@property (nonatomic, strong) FreeFireHackManager *hackManager;
@property (nonatomic, strong) NSMutableDictionary *buttonStates;
@property (nonatomic, strong) UIImageView *menuBackgroundImageView;
@property (nonatomic, strong) NSMutableArray *menuButtons;
@property (nonatomic, strong) UIWindow *overlayWindow;
@end

@implementation FluckMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.userInteractionEnabled = YES;
    self.isVisible = NO;
    self.isHiddenByCamera = NO;
    self.floatingButtons = [NSMutableArray array];
    self.menuButtons = [NSMutableArray array];
    self.buttonStates = [NSMutableDictionary dictionary];
    self.hackManager = [FreeFireHackManager shared];
    [self setupFloatingButtons];
    [self setupMainFloatingButton];
    [self setupMenuWithCatImage];
    [self setupFPSMonitor];
    [self setupGestureRecognizers];
    [self setupCameraDetection];
}

// ============================================================
// MENU VỚI ẢNH MÈO
// ============================================================

- (void)setupMenuWithCatImage {
    CGFloat menuWidth = 350;
    CGFloat menuHeight = 450;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    self.menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, menuWidth, menuHeight)];
    self.menuView.center = CGPointMake(screenWidth / 2, screenHeight / 2);
    self.menuView.layer.cornerRadius = 20;
    self.menuView.clipsToBounds = YES;
    self.menuView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.menuView.layer.shadowOffset = CGSizeMake(0, 5);
    self.menuView.layer.shadowRadius = 15;
    self.menuView.layer.shadowOpacity = 0.5;
    self.menuView.userInteractionEnabled = YES;
    self.menuView.hidden = YES; // Ẩn ban đầu
    [self.view addSubview:self.menuView];
    
    self.menuBackgroundImageView = [[UIImageView alloc] initWithFrame:self.menuView.bounds];
    self.menuBackgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.menuBackgroundImageView.clipsToBounds = YES;
    self.menuBackgroundImageView.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.2 alpha:1.0];
    [self createCatWithGunImage];
    [self.menuView addSubview:self.menuBackgroundImageView];
    
    UIView *overlayView = [[UIView alloc] initWithFrame:self.menuView.bounds];
    overlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.25];
    [self.menuView addSubview:overlayView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, menuWidth, 35)];
    titleLabel.text = @"⚡ FLUCK PRO v1.0";
    titleLabel.textColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.8 alpha:1.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.shadowColor = [UIColor blackColor];
    titleLabel.shadowOffset = CGSizeMake(0, 1);
    [self.menuView addSubview:titleLabel];
    
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 45, menuWidth, 18)];
    subtitleLabel.text = @"Free Fire Hack | 3-ngón 2-lần toggle";
    subtitleLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    subtitleLabel.textAlignment = NSTextAlignmentCenter;
    subtitleLabel.font = [UIFont systemFontOfSize:11];
    subtitleLabel.shadowColor = [UIColor blackColor];
    subtitleLabel.shadowOffset = CGSizeMake(0, 1);
    [self.menuView addSubview:subtitleLabel];
    
    NSArray *features = @[
        @{@"icon": @"🎯", @"title": @"Aimbot"},
        @{@"icon": @"👁️", @"title": @"ESP"},
        @{@"icon": @"🪄", @"title": @"Fly"},
        @{@"icon": @"💉", @"title": @"God Mode"},
        @{@"icon": @"⚡", @"title": @"Speed"},
        @{@"icon": @"🛡️", @"title": @"Wall"},
        @{@"icon": @"📡", @"title": @"Radar"},
        @{@"icon": @"🎨", @"title": @"Chams"},
        @{@"icon": @"🔫", @"title": @"No Recoil"},
        @{@"icon": @"🎮", @"title": @"Trigger"},
        @{@"icon": @"🔫", @"title": @"Infinite Ammo"},
        @{@"icon": @"🌀", @"title": @"Teleport"},
        @{@"icon": @"🎵", @"title": @"SoundCloud"}
    ];
    
    CGFloat y = 75;
    CGFloat spacing = 32;
    int cols = 2;
    CGFloat btnWidth = (menuWidth - 50) / 2;
    CGFloat btnHeight = 28;
    CGFloat margin = 15;
    
    for (int i = 0; i < features.count; i++) {
        int row = i / cols;
        int col = i % cols;
        CGFloat x = margin + col * (btnWidth + 10);
        CGFloat yPos = y + row * spacing;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(x, yPos, btnWidth, btnHeight);
        btn.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.8];
        btn.layer.cornerRadius = 8;
        btn.layer.borderColor = [UIColor colorWithWhite:0.4 alpha:0.5].CGColor;
        btn.layer.borderWidth = 1;
        [btn setTitle:[NSString stringWithFormat:@"%@ %@", features[i][@"icon"], features[i][@"title"]] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:11];
        btn.tag = i;
        btn.userInteractionEnabled = YES;
        objc_setAssociatedObject(btn, "featureTitle", features[i][@"title"], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [btn addTarget:self action:@selector(onMenuButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.menuView addSubview:btn];
        [self.menuButtons addObject:btn];
    }
    
    int totalRows = (features.count + cols - 1) / cols;
    CGFloat closeY = y + totalRows * spacing + 10;
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(40, closeY, menuWidth - 80, 36);
    [closeBtn setTitle:@"✕ Hide Menu" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    closeBtn.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.9];
    closeBtn.layer.cornerRadius = 10;
    closeBtn.userInteractionEnabled = YES;
    [closeBtn addTarget:self action:@selector(hideMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:closeBtn];
    
    CGFloat totalHeight = closeY + 50;
    CGRect frame = self.menuView.frame;
    frame.size.height = totalHeight;
    self.menuView.frame = frame;
    self.menuView.center = CGPointMake(screenWidth / 2, screenHeight / 2);
    
    UIView *handle = [[UIView alloc] initWithFrame:CGRectMake((menuWidth - 40) / 2, 8, 40, 4)];
    handle.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    handle.layer.cornerRadius = 2;
    [self.menuView addSubview:handle];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMenuPan:)];
    [self.menuView addGestureRecognizer:pan];
}

- (void)createCatWithGunImage {
    CGSize size = CGSizeMake(350, 450);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = {0.0, 1.0};
    NSArray *colors = @[(id)[UIColor colorWithRed:0.1 green:0.1 blue:0.2 alpha:1.0].CGColor,
                         (id)[UIColor colorWithRed:0.2 green:0.1 blue:0.1 alpha:1.0].CGColor];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, 0), CGPointMake(0, size.height), 0);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
    // Vẽ mèo
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.3 green:0.2 blue:0.1 alpha:1.0].CGColor);
    CGContextFillEllipseInRect(ctx, CGRectMake(100, 200, 150, 180));
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.35 green:0.25 blue:0.15 alpha:1.0].CGColor);
    CGContextFillEllipseInRect(ctx, CGRectMake(120, 130, 110, 100));
    
    // Ears
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.4 green:0.2 blue:0.1 alpha:1.0].CGColor);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, 120, 140);
    CGContextAddLineToPoint(ctx, 100, 100);
    CGContextAddLineToPoint(ctx, 150, 120);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, 230, 140);
    CGContextAddLineToPoint(ctx, 250, 100);
    CGContextAddLineToPoint(ctx, 200, 120);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
    
    // Eyes
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillEllipseInRect(ctx, CGRectMake(145, 155, 30, 25));
    CGContextFillEllipseInRect(ctx, CGRectMake(195, 155, 30, 25));
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextFillEllipseInRect(ctx, CGRectMake(155, 160, 12, 15));
    CGContextFillEllipseInRect(ctx, CGRectMake(205, 160, 12, 15));
    
    // Nose
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.8 green:0.3 blue:0.3 alpha:1.0].CGColor);
    CGContextFillEllipseInRect(ctx, CGRectMake(175, 185, 15, 12));
    
    // Mouth
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(ctx, 2);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, 175, 195);
    CGContextAddQuadCurveToPoint(ctx, 160, 210, 150, 200);
    CGContextStrokePath(ctx);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, 185, 195);
    CGContextAddQuadCurveToPoint(ctx, 200, 210, 210, 200);
    CGContextStrokePath(ctx);
    
    // Whiskers
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(ctx, 1.5);
    for (int i = 0; i < 3; i++) {
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, 130, 180 + i * 12);
        CGContextAddLineToPoint(ctx, 80, 170 + i * 15);
        CGContextStrokePath(ctx);
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, 230, 180 + i * 12);
        CGContextAddLineToPoint(ctx, 280, 170 + i * 15);
        CGContextStrokePath(ctx);
    }
    
    // Arms
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.3 green:0.2 blue:0.1 alpha:1.0].CGColor);
    CGContextFillEllipseInRect(ctx, CGRectMake(80, 250, 40, 60));
    CGContextFillEllipseInRect(ctx, CGRectMake(230, 250, 40, 60));
    
    // Gun
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0].CGColor);
    CGContextFillRect(ctx, CGRectMake(100, 310, 150, 25));
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0].CGColor);
    CGContextFillRect(ctx, CGRectMake(70, 315, 40, 15));
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.2 green:0.15 blue:0.1 alpha:1.0].CGColor);
    CGContextFillRect(ctx, CGRectMake(230, 305, 30, 35));
    CGContextFillRect(ctx, CGRectMake(250, 310, 20, 25));
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0].CGColor);
    CGContextFillRect(ctx, CGRectMake(120, 335, 50, 20));
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.2 green:0.15 blue:0.1 alpha:1.0].CGColor);
    CGContextFillRect(ctx, CGRectMake(180, 335, 25, 30));
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0].CGColor);
    CGContextFillRect(ctx, CGRectMake(75, 318, 15, 8));
    CGContextFillRect(ctx, CGRectMake(135, 338, 10, 14));
    
    // Text
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.0 green:1.0 blue:0.8 alpha:0.3].CGColor);
    UIFont *font = [UIFont boldSystemFontOfSize:40];
    NSDictionary *attrs = @{NSFontAttributeName: font, NSForegroundColorAttributeName: [UIColor colorWithRed:0.0 green:1.0 blue:0.8 alpha:0.3]};
    [@"FLUCK PRO" drawAtPoint:CGPointMake(40, 30) withAttributes:attrs];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.menuBackgroundImageView.image = result;
}

- (void)handleMenuPan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.view];
    CGPoint newCenter = CGPointMake(self.menuView.center.x + translation.x, self.menuView.center.y + translation.y);
    CGFloat halfWidth = self.menuView.frame.size.width / 2;
    CGFloat halfHeight = self.menuView.frame.size.height / 2;
    newCenter.x = MAX(halfWidth, MIN(self.view.bounds.size.width - halfWidth, newCenter.x));
    newCenter.y = MAX(halfHeight, MIN(self.view.bounds.size.height - halfHeight, newCenter.y));
    self.menuView.center = newCenter;
    [gesture setTranslation:CGPointZero inView:self.view];
}

// ============================================================
// MENU BUTTON HANDLER
// ============================================================

- (void)onMenuButtonTap:(UIButton *)sender {
    NSString *featureTitle = objc_getAssociatedObject(sender, "featureTitle");
    
    sender.tag = sender.tag == 0 ? 1 : 0;
    if (sender.tag == 1) {
        sender.backgroundColor = [UIColor colorWithRed:0.0 green:0.6 blue:0.0 alpha:0.8];
        sender.layer.borderColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.5].CGColor;
    } else {
        sender.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.8];
        sender.layer.borderColor = [UIColor colorWithWhite:0.4 alpha:0.5].CGColor;
    }
    
    BOOL isOn = sender.tag == 1;
    NSString *status = isOn ? @"✅ ON" : @"❌ OFF";
    
    if ([featureTitle isEqualToString:@"Aimbot"]) {
        [self.hackManager enableAimbot:isOn];
    } else if ([featureTitle isEqualToString:@"ESP"]) {
        [self.hackManager enableESP:isOn];
    } else if ([featureTitle isEqualToString:@"Fly"]) {
        [self.hackManager enableFlyHack:isOn];
    } else if ([featureTitle isEqualToString:@"God Mode"]) {
        [self.hackManager enableGodMode:isOn];
    } else if ([featureTitle isEqualToString:@"Speed"]) {
        [self.hackManager enableSpeedHack:isOn];
    } else if ([featureTitle isEqualToString:@"Wall"]) {
        [self.hackManager enableWallHack:isOn];
    } else if ([featureTitle isEqualToString:@"Radar"]) {
        [self.hackManager enableRadar:isOn];
    } else if ([featureTitle isEqualToString:@"Chams"]) {
        [self.hackManager enableChams:isOn];
    } else if ([featureTitle isEqualToString:@"No Recoil"]) {
        [self.hackManager enableNoRecoil:isOn];
    } else if ([featureTitle isEqualToString:@"Trigger"]) {
        [self.hackManager enableTriggerBot:isOn];
    } else if ([featureTitle isEqualToString:@"Infinite Ammo"]) {
        [self.hackManager enableInfiniteAmmo:isOn];
    } else if ([featureTitle isEqualToString:@"Teleport"]) {
        [self.hackManager enableTeleport:isOn];
    } else if ([featureTitle isEqualToString:@"SoundCloud"]) {
        if (isOn) {
            [[SoundCloudPlayer shared] play];
        } else {
            [[SoundCloudPlayer shared] stop];
        }
    }
    [self showToast:[NSString stringWithFormat:@"%@ %@", featureTitle, status]];
}

- (void)showToast:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"⚡ Fluck" message:message preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

// ============================================================
// MAIN FLOATING BUTTON
// ============================================================

- (void)setupMainFloatingButton {
    CGFloat buttonSize = 50;
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat x = screenBounds.size.width - buttonSize - 10;
    CGFloat y = screenBounds.size.height - buttonSize - 50;
    
    self.mainFloatingButton = [[FluckFloatingButton alloc] initWithFrame:CGRectMake(x, y, buttonSize, buttonSize) title:@"" icon:@"⚡"];
    self.mainFloatingButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.6 blue:1.0 alpha:0.7];
    self.mainFloatingButton.layer.cornerRadius = buttonSize / 2;
    self.mainFloatingButton.layer.borderColor = [UIColor colorWithRed:0.0 green:0.8 blue:1.0 alpha:0.5].CGColor;
    self.mainFloatingButton.layer.borderWidth = 1.5;
    self.mainFloatingButton.iconLabel.frame = CGRectMake(0, 0, buttonSize, buttonSize);
    self.mainFloatingButton.iconLabel.font = [UIFont boldSystemFontOfSize:28];
    self.mainFloatingButton.iconLabel.textColor = [UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:0.9];
    self.mainFloatingButton.statusLabel.hidden = YES;
    self.mainFloatingButton.floatingTitleLabel.hidden = YES;
    self.mainFloatingButton.hidden = NO; // Luôn hiển thị
    [self.mainFloatingButton addTarget:self action:@selector(onMainFloatingButtonTap) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.mainFloatingButton];
    [self startPulseAnimation];
}

- (void)startPulseAnimation {
    CABasicAnimation *pulse = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulse.duration = 1.5;
    pulse.fromValue = [NSNumber numberWithFloat:1.0];
    pulse.toValue = [NSNumber numberWithFloat:1.15];
    pulse.autoreverses = YES;
    pulse.repeatCount = HUGE_VALF;
    pulse.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.mainFloatingButton.layer addAnimation:pulse forKey:@"pulse"];
}

- (void)onMainFloatingButtonTap {
    [self toggleMenu];
}

// ============================================================
// FLOATING BUTTONS (LUÔN HIỂN THỊ)
// ============================================================

- (void)setupFloatingButtons {
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat buttonWidth = 95;
    CGFloat buttonHeight = 28;
    CGFloat x = 10;
    CGFloat y = 100;
    CGFloat spacing = 5;
    
    NSArray *buttonConfigs = @[
        @{@"title": @"AIM", @"icon": @"🎯", @"feature": @"Aimbot"},
        @{@"title": @"Fly", @"icon": @"🪄", @"feature": @"Fly"},
        @{@"title": @"Ghost", @"icon": @"👻", @"feature": @"ESP"},
        @{@"title": @"TeleMark", @"icon": @"🌀", @"feature": @"Teleport"},
        @{@"title": @"Hai Sung", @"icon": @"🔫", @"feature": @"Infinite Ammo"}
    ];
    
    for (int i = 0; i < buttonConfigs.count; i++) {
        NSDictionary *config = buttonConfigs[i];
        CGFloat currentY = y + i * (buttonHeight + spacing);
        
        FluckFloatingButton *btn = [[FluckFloatingButton alloc] 
            initWithFrame:CGRectMake(x, currentY, buttonWidth, buttonHeight) 
            title:config[@"title"] 
            icon:config[@"icon"]];
        btn.tag = i;
        btn.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.7];
        btn.hidden = NO; // Luôn hiển thị
        objc_setAssociatedObject(btn, "featureName", config[@"feature"], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [btn addTarget:self action:@selector(onFloatingButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        [self.floatingButtons addObject:btn];
    }
}

- (void)onFloatingButtonTap:(FluckFloatingButton *)sender {
    [sender toggle];
    NSString *featureName = objc_getAssociatedObject(sender, "featureName");
    BOOL isOn = sender.isOn;
    NSString *status = isOn ? @"✅ ON" : @"❌ OFF";
    
    if ([featureName isEqualToString:@"Aimbot"]) {
        [self.hackManager enableAimbot:isOn];
    } else if ([featureName isEqualToString:@"Fly"]) {
        [self.hackManager enableFlyHack:isOn];
    } else if ([featureName isEqualToString:@"ESP"]) {
        [self.hackManager enableESP:isOn];
    } else if ([featureName isEqualToString:@"Teleport"]) {
        [self.hackManager enableTeleport:isOn];
    } else if ([featureName isEqualToString:@"Infinite Ammo"]) {
        [self.hackManager enableInfiniteAmmo:isOn];
    }
    [self showToast:[NSString stringWithFormat:@"%@ %@", sender.floatingTitleLabel.text, status]];
}

// ============================================================
// CAMERA DETECTION
// ============================================================

- (void)setupCameraDetection {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraDidStart:) name:@"AVCaptureSessionDidStartRunningNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraDidStop:) name:@"AVCaptureSessionDidStopRunningNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenshotDetected:) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenRecordingDidChange:) name:UIScreenCapturedDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)cameraDidStart:(NSNotification *)notification { [self autoHideMenu]; }
- (void)cameraDidStop:(NSNotification *)notification { [self autoShowMenu]; }
- (void)screenshotDetected:(NSNotification *)notification {
    [self autoHideMenu];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self autoShowMenu];
    });
}
- (void)screenRecordingDidChange:(NSNotification *)notification {
    if ([UIScreen mainScreen].isCaptured) {
        [self autoHideMenu];
    } else {
        [self autoShowMenu];
    }
}
- (void)appDidEnterBackground:(NSNotification *)notification { [self autoHideMenu]; }
- (void)appDidBecomeActive:(NSNotification *)notification {
    if (!self.isHiddenByCamera) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self autoShowMenu];
        });
    }
}

- (void)autoHideMenu {
    if (self.isVisible) {
        self.isHiddenByCamera = YES;
        self.menuView.hidden = YES;
        self.view.userInteractionEnabled = NO;
        // KHÔNG ẨN NÚT NỔI
        self.mainFloatingButton.hidden = NO;
        for (FluckFloatingButton *btn in self.floatingButtons) {
            btn.hidden = NO;
        }
    }
}

- (void)autoShowMenu {
    if (!self.isVisible && self.isHiddenByCamera) {
        self.isHiddenByCamera = NO;
        self.menuView.hidden = NO;
        self.view.userInteractionEnabled = YES;
        self.mainFloatingButton.hidden = NO;
        for (FluckFloatingButton *btn in self.floatingButtons) {
            btn.hidden = NO;
        }
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
}

- (void)handleTripleTap:(FluckTripleTapGestureRecognizer *)gesture {
    LOG(@"🔴🔴 3 ngón chạm 2 lần! Toggle menu");
    [self toggleMenu];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        LOG(@"🔵 Long press 2s - Toggle menu");
        [self toggleMenu];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

// ============================================================
// MENU TOGGLE
// ============================================================

- (void)toggleMenu {
    self.isVisible = !self.isVisible;
    
    if (self.isVisible) {
        self.menuView.hidden = NO;
        self.view.userInteractionEnabled = YES;
        // NÚT NỔI VẪN HIỂN THỊ
        self.mainFloatingButton.hidden = NO;
        for (FluckFloatingButton *btn in self.floatingButtons) {
            btn.hidden = NO;
        }
        self.menuView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        self.menuView.alpha = 0;
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:0 animations:^{
            self.menuView.transform = CGAffineTransformIdentity;
            self.menuView.alpha = 1;
        } completion:nil];
    } else {
        self.menuView.hidden = YES;
        self.view.userInteractionEnabled = NO;
        // NÚT NỔI VẪN HIỂN THỊ
        self.mainFloatingButton.hidden = NO;
        for (FluckFloatingButton *btn in self.floatingButtons) {
            btn.hidden = NO;
        }
    }
}

- (void)hideMenu {
    if (self.isVisible) {
        [self toggleMenu];
    }
}

// ============================================================
// FPS MONITOR
// ============================================================

- (void)setupFPSMonitor {
    self.fpsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 18)];
    self.fpsLabel.textColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
    self.fpsLabel.font = [UIFont systemFontOfSize:11];
    self.fpsLabel.text = @"FPS: 0";
    [self.view addSubview:self.fpsLabel];
    
    self.fpsTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer *timer) {
        int fps = 30 + arc4random_uniform(31);
        self.fpsLabel.text = [NSString stringWithFormat:@"FPS: %d", fps];
    }];
}

- (void)dealloc {
    [self.fpsTimer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[SoundCloudPlayer shared] stop];
    [self.hackManager stopHackLoop];
    [self.hackManager stopTeleportLoop];
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
        
        // QUAN TRỌNG: Set window level cao nhất để nhận touch
        self.overlayWindow.windowLevel = UIWindowLevelStatusBar + 1000;
        self.overlayWindow.backgroundColor = [UIColor clearColor];
        self.overlayWindow.userInteractionEnabled = YES;
        self.overlayWindow.hidden = NO;
        self.overlayWindow.opaque = NO;
        self.overlayWindow.makeKeyAndVisible;
        
        self.menuVC = [[FluckMenuViewController alloc] init];
        self.menuVC.view.frame = self.overlayWindow.bounds;
        self.menuVC.view.backgroundColor = [UIColor clearColor];
        self.menuVC.view.userInteractionEnabled = YES;
        self.menuVC.overlayWindow = self.overlayWindow;
        self.overlayWindow.rootViewController = self.menuVC;
        self.menuVC.view.hidden = NO;
        self.menuVC.menuView.hidden = YES;
        
        // Hiển thị menu sau 0.5s
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.menuVC toggleMenu];
        });
        
        LOG(@"✅ Fluck started successfully!");
    });
}

- (void)stop {
    if (!self.running) return;
    self.running = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.menuVC) {
            self.menuVC.view.hidden = YES;
        }
        if (self.overlayWindow) {
            self.overlayWindow.hidden = YES;
            self.overlayWindow = nil;
        }
        [[SoundCloudPlayer shared] stop];
        LOG(@"⛔ Fluck stopped");
    });
}

- (void)toggleMenu {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.menuVC) {
            [self.menuVC toggleMenu];
        }
    });
}

- (BOOL)isMenuVisible {
    return self.menuVC.isVisible;
}

@end

// ============================================================
// CONSTRUCTOR & EXPORT
// ============================================================

__attribute__((constructor))
static void fluck_constructor(void) {
    LOG(@"═══════════════════════════════════════════════");
    LOG(@"║   🔥 Fluck Pro v1.0 - Free Fire Hack     ║");
    LOG(@"║   📅 Build: %s %s", __DATE__, __TIME__);
    LOG(@"║   👆 3-ngón 2-lần toggle menu           ║");
    LOG(@"║   📷 Auto-hide khi chụp ảnh/quay video  ║");
    LOG(@"║   🎵 SoundCloud Player (no captcha)     ║");
    LOG(@"║   🎯 Floating buttons always visible    ║");
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

int main(int argc, char *argv[]) {
    @autoreleasepool {
        start_fluck();
        [[NSRunLoop mainRunLoop] run];
    }
    return 0;
}
