#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <mach/mach.h>
#import <mach/vm_map.h>
#import <sys/sysctl.h>
#import <sys/types.h>
#import <sys/stat.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <zlib.h>
#import <CommonCrypto/CommonCrypto.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <WebKit/WebKit.h>
#import <SceneKit/SceneKit.h>
#import <SpriteKit/SpriteKit.h>
#import <Metal/Metal.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <pthread.h>
#import <dlfcn.h>
#import <objc/runtime.h>

// Silence deprecated warnings
#define GLES_SILENCE_DEPRECATION 1

// ============================================================
// PHẦN 1: DỮ LIỆU GIẢ LỚN
// ============================================================

static const unsigned char _dummyData1[16384] = {0};
static const unsigned char _dummyData2[16384] = {0};
static const unsigned char _dummyData3[16384] = {0};
static const unsigned char _dummyData4[16384] = {0};
static const unsigned char _dummyData5[16384] = {0};
static const unsigned char _dummyData6[16384] = {0};

// ============================================================
// PHẦN 2: FIX LỖI CỐT LÕI
// ============================================================

static inline kern_return_t mach_vm_write_fix(vm_map_t task, mach_vm_address_t address, vm_offset_t data, mach_msg_type_number_t size) {
    return vm_write(task, address, data, size);
}

static inline kern_return_t mach_vm_read_overwrite_fix(vm_map_t task, mach_vm_address_t address, mach_vm_size_t size, mach_vm_address_t data, mach_vm_size_t *outsize) {
    vm_size_t temp = (vm_size_t)*outsize;
    kern_return_t kr = vm_read_overwrite(task, address, (vm_size_t)size, data, &temp);
    *outsize = (mach_vm_size_t)temp;
    return kr;
}

static inline void sys_icache_invalidate_fix(void *addr, size_t len) {
    #ifdef __arm64__
    __asm__ volatile("icache ivau, %0" : : "r"(addr));
    #endif
}

// ============================================================
// PHẦN 3: HÀM DUMMY (TĂNG DUNG LƯỢNG)
// ============================================================

// 3.1 Crypto - Sử dụng kCCAlgorithmAES thay vì kCCAlgorithmAES256
static void _dummy_crypto_aes(void) {
    for (int round = 0; round < 10; round++) {
        unsigned char key[32] = {0};
        unsigned char iv[16] = {0};
        unsigned char input[2048] = {0};
        unsigned char output[2048] = {0};
        size_t outLen = 0;
        CCCryptorRef cryptor;
        CCCryptorCreate(kCCEncrypt, kCCAlgorithmAES, kCCOptionPKCS7Padding,
                        key, sizeof(key), iv, &cryptor);
        CCCryptorUpdate(cryptor, input, sizeof(input), output, sizeof(output), &outLen);
        CCCryptorFinal(cryptor, output, sizeof(output), &outLen);
        CCCryptorRelease(cryptor);
    }
}

static void _dummy_crypto_sha(void) {
    for (int i = 0; i < 100; i++) {
        unsigned char data[1024] = {0};
        unsigned char hash[CC_SHA256_DIGEST_LENGTH];
        CC_SHA256(data, sizeof(data), hash);
    }
}

static void _dummy_crypto_hmac(void) {
    unsigned char key[32] = {0};
    unsigned char data[1024] = {0};
    unsigned char hmac[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, key, sizeof(key), data, sizeof(data), hmac);
}

// 3.2 Compression
static void _dummy_compress_zlib(void) {
    for (int i = 0; i < 5; i++) {
        unsigned char input[8192] = {0};
        unsigned char output[8192] = {0};
        z_stream stream = {0};
        deflateInit(&stream, Z_BEST_COMPRESSION);
        stream.next_in = input;
        stream.avail_in = sizeof(input);
        stream.next_out = output;
        stream.avail_out = sizeof(output);
        deflate(&stream, Z_FINISH);
        deflateEnd(&stream);
    }
}

// 3.3 JSON
static void _dummy_json_parse(void) {
    NSString *json = @"{\"users\":[{\"id\":1,\"name\":\"User1\"},{\"id\":2,\"name\":\"User2\"},{\"id\":3,\"name\":\"User3\"}]}";
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (dict) {
        NSArray *users = dict[@"users"];
        for (NSDictionary *user in users) {
            NSLog(@"User: %@", user[@"name"]);
        }
    }
}

// 3.4 Network
static void _dummy_network_request(void) {
    NSURL *url = [NSURL URLWithString:@"https://httpbin.org/get"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data) {
            NSLog(@"Network done");
        }
    }];
    [task resume];
}

// 3.5 Location
static void _dummy_location(void) {
    CLLocationManager *manager = [[CLLocationManager alloc] init];
    [manager startUpdatingLocation];
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:10.0 + arc4random_uniform(100) longitude:10.0 + arc4random_uniform(100)];
    NSLog(@"Location: %f, %f", loc.coordinate.latitude, loc.coordinate.longitude);
}

// 3.6 Web
static void _dummy_webview(void) {
    WKWebView *web = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://example.com"]]];
}

// 3.7 Metal
static void _dummy_metal(void) {
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    if (device) {
        MTLTextureDescriptor *desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm width:512 height:512 mipmapped:NO];
        id<MTLTexture> texture = [device newTextureWithDescriptor:desc];
        MTLRenderPassDescriptor *renderPass = [MTLRenderPassDescriptor renderPassDescriptor];
        renderPass.colorAttachments[0].texture = texture;
        renderPass.colorAttachments[0].loadAction = MTLLoadActionClear;
        renderPass.colorAttachments[0].clearColor = MTLClearColorMake(0.2, 0.3, 0.5, 1.0);
        NSLog(@"Metal ready");
    }
}

// 3.8 SceneKit
static void _dummy_scenekit(void) {
    SCNScene *scene = [SCNScene scene];
    SCNNode *node = [SCNNode node];
    SCNBox *box = [SCNBox boxWithWidth:1 height:2 length:3 chamferRadius:0.1];
    node.geometry = box;
    SCNMaterial *mat = [SCNMaterial material];
    mat.diffuse.contents = [UIColor redColor];
    box.materials = @[mat];
    [scene.rootNode addChildNode:node];
}

// 3.9 SpriteKit
static void _dummy_spritekit(void) {
    SKScene *scene = [[SKScene alloc] initWithSize:CGSizeMake(300, 300)];
    for (int i = 0; i < 50; i++) {
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithHue:((float)i/50) saturation:1.0 brightness:1.0 alpha:1.0] size:CGSizeMake(20, 20)];
        sprite.position = CGPointMake(arc4random_uniform(300), arc4random_uniform(300));
        [scene addChild:sprite];
    }
}

// 3.10 Image Processing
static void _dummy_image_processing(void) {
    for (int i = 0; i < 10; i++) {
        UIGraphicsBeginImageContext(CGSizeMake(256, 256));
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithHue:((float)i/10) saturation:0.8 brightness:0.8 alpha:1.0].CGColor);
        CGContextFillRect(ctx, CGRectMake(0, 0, 256, 256));
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImageJPEGRepresentation(img, 0.9);
    }
}

// 3.11 Audio
static void _dummy_audio(void) {
    NSURL *url = [NSURL URLWithString:@"dummy"];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [player prepareToPlay];
    [player play];
}

// 3.12 Map
static void _dummy_map(void) {
    MKMapView *map = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    map.showsUserLocation = YES;
    map.mapType = MKMapTypeSatellite;
    MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(10, 10), MKCoordinateSpanMake(0.5, 0.5));
    [map setRegion:region animated:YES];
}

// 3.13 File I/O
static void _dummy_file_io(void) {
    for (int i = 0; i < 20; i++) {
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"dummy_%d.dat", i]];
        NSData *data = [NSData dataWithBytes:_dummyData1 length:16384];
        [data writeToFile:path atomically:YES];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

// 3.14 UserDefaults
static void _dummy_user_defaults(void) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for (int i = 0; i < 50; i++) {
        [defaults setObject:[NSString stringWithFormat:@"value_%d", i] forKey:[NSString stringWithFormat:@"key_%d", i]];
        [defaults setInteger:i forKey:[NSString stringWithFormat:@"int_%d", i]];
        [defaults setBool:(i % 2 == 0) forKey:[NSString stringWithFormat:@"bool_%d", i]];
    }
    [defaults synchronize];
}

// 3.15 Thread
static void* _dummy_thread_func(void *arg) {
    for (int i = 0; i < 100; i++) {
        [NSThread sleepForTimeInterval:0.01];
    }
    return NULL;
}

static void _dummy_threads(void) {
    pthread_t threads[5];
    for (int i = 0; i < 5; i++) {
        pthread_create(&threads[i], NULL, _dummy_thread_func, NULL);
    }
    for (int i = 0; i < 5; i++) {
        pthread_join(threads[i], NULL);
    }
}

// 3.16 Math
static void _dummy_math_compute(void) {
    float result = 0;
    for (int i = 0; i < 10000; i++) {
        result += sinf(i * 0.001) * cosf(i * 0.002) * sqrtf(i * 1.0);
        result += atan2f(sinf(i * 0.003), cosf(i * 0.004));
        result += expf(i * 0.0001) * logf(i + 1);
        result += powf(i * 0.01, 2) * 3.14159;
    }
    if (result > 0) {
        NSLog(@"Math result: %f", result);
    }
}

// 3.17 Memory
static void _dummy_memory_ops(void) {
    for (int i = 0; i < 20; i++) {
        size_t size = 1024 * 1024 * (1 + arc4random_uniform(3));
        void *ptr = malloc(size);
        if (ptr) {
            memset(ptr, 0xAA, size);
            memcpy(ptr, _dummyData1, (size > 16384) ? 16384 : size);
            free(ptr);
        }
    }
}

// 3.18 Process Info
static void _dummy_process_info(void) {
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    size_t size = 0;
    sysctl(mib, 4, NULL, &size, NULL, 0);
    if (size > 0) {
        struct kinfo_proc *procs = (struct kinfo_proc*)malloc(size);
        if (procs) {
            sysctl(mib, 4, procs, &size, NULL, 0);
            int count = size / sizeof(struct kinfo_proc);
            for (int i = 0; i < count && i < 10; i++) {
                NSLog(@"Process: %s", procs[i].kp_proc.p_comm);
            }
            free(procs);
        }
    }
}

// 3.19 System Info
static void _dummy_system_info(void) {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char*)malloc(size);
    if (machine) {
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        NSLog(@"Device: %s", machine);
        free(machine);
    }
    
    int64_t memsize;
    size = sizeof(memsize);
    sysctlbyname("hw.memsize", &memsize, &size, NULL, 0);
    NSLog(@"Memory: %lld MB", memsize / (1024 * 1024));
}

// 3.20 Animation
static void _dummy_animation(void) {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{
        view.transform = CGAffineTransformMakeRotation(M_PI);
    } completion:nil];
    [view.layer addAnimation:[CABasicAnimation animationWithKeyPath:@"opacity"] forKey:@"opacity"];
}

// 3.21 Gesture
static void _dummy_gesture(void) {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:nil action:nil];
    tap.numberOfTapsRequired = 2;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:nil action:nil];
    longPress.minimumPressDuration = 1.0;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:nil action:nil];
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:nil action:nil];
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:nil action:nil];
    swipe.direction = UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft;
}

// 3.22 Notification
static void _dummy_notification(void) {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FFHackNotification" object:nil userInfo:@{@"message": @"Hello"}];
}

// 3.23 Timer
static void _dummy_timer(void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        NSLog(@"Timer fired");
    });
}

// ============================================================
// PHẦN 4: FFHACK MENU
// ============================================================

@interface FFHackButton : UIButton
@property (nonatomic, assign) BOOL isActive;
@end

@implementation FFHackButton
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.isActive = NO;
        [self addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
        [self updateAppearance];
    }
    return self;
}
- (void)toggle {
    self.isActive = !self.isActive;
    [self updateAppearance];
    NSLog(@"Button toggled: %@", self.titleLabel.text);
}
- (void)updateAppearance {
    if (self.isActive) {
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.6 blue:0.0 alpha:1.0];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        self.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
        [self setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
}
@end

@interface FFHackMenuViewController : UIViewController
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, assign) BOOL isVisible;
@end

@implementation FFHackMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.isVisible = NO;
    self.buttons = [NSMutableArray array];
    [self setupMenu];
}

- (void)setupMenu {
    // Menu background
    self.menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 500)];
    self.menuView.backgroundColor = [UIColor colorWithWhite:0.05 alpha:0.92];
    self.menuView.layer.cornerRadius = 16;
    self.menuView.layer.borderColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.5].CGColor;
    self.menuView.layer.borderWidth = 2;
    self.menuView.center = self.view.center;
    [self.view addSubview:self.menuView];
    
    // Title
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 280, 35)];
    self.titleLabel.text = @"⚡ FFHack Pro v3.0";
    self.titleLabel.textColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.menuView addSubview:self.titleLabel];
    
    // Separator
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(20, 55, 240, 1)];
    line.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1.0];
    [self.menuView addSubview:line];
    
    // Features
    NSArray *features = @[
        @"🎯 Aimbot",
        @"👁️ ESP",
        @"🪄 Fly Hack",
        @"💉 God Mode",
        @"🔫 No Recoil",
        @"⚡ Speed Hack",
        @"🛡️ Wall Hack",
        @"📡 Radar Hack",
        @"🎯 Auto Aim",
        @"💀 Instant Kill",
        @"🔄 Rapid Fire",
        @"🎨 Chams",
        @"📦 Item ESP",
        @"🔮 Unlock All",
        @"🎮 Trigger Bot",
        @"📊 Stat Hack"
    ];
    
    CGFloat y = 70;
    CGFloat spacing = 38;
    int cols = 2;
    CGFloat btnWidth = 120;
    CGFloat btnHeight = 32;
    CGFloat margin = (280 - (btnWidth * 2 + 10)) / 2;
    
    for (int i = 0; i < features.count; i++) {
        int row = i / cols;
        int col = i % cols;
        CGFloat x = margin + col * (btnWidth + 10);
        CGFloat yPos = y + row * spacing;
        
        FFHackButton *btn = [[FFHackButton alloc] initWithFrame:CGRectMake(x, yPos, btnWidth, btnHeight)];
        [btn setTitle:features[i] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        btn.layer.cornerRadius = 6;
        btn.clipsToBounds = YES;
        [self.menuView addSubview:btn];
        [self.buttons addObject:btn];
    }
    
    // Close button
    self.closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    int totalRows = (features.count + cols - 1) / cols;
    CGFloat closeY = y + totalRows * spacing + 15;
    self.closeButton.frame = CGRectMake(40, closeY, 200, 40);
    [self.closeButton setTitle:@"✕ Close Menu" forState:UIControlStateNormal];
    [self.closeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.closeButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.closeButton.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
    self.closeButton.layer.cornerRadius = 8;
    [self.closeButton addTarget:self action:@selector(closeMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:self.closeButton];
    
    // Resize menu
    CGFloat totalHeight = closeY + 55;
    CGRect frame = self.menuView.frame;
    frame.size.height = totalHeight;
    self.menuView.frame = frame;
    self.menuView.center = self.view.center;
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
// PHẦN 5: FFHACK MANAGER
// ============================================================

@interface FFHackManager : NSObject
+ (instancetype)shared;
- (void)start;
- (void)stop;
- (void)toggleMenu;
- (BOOL)isMenuVisible;
@property (nonatomic, strong) UIWindow *overlayWindow;
@property (nonatomic, strong) FFHackMenuViewController *menuVC;
@property (nonatomic, assign) BOOL running;
@end

@implementation FFHackManager

+ (instancetype)shared {
    static FFHackManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FFHackManager alloc] init];
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
        
        self.overlayWindow.windowLevel = UIWindowLevelAlert + 1;
        self.overlayWindow.backgroundColor = [UIColor clearColor];
        self.overlayWindow.userInteractionEnabled = YES;
        self.overlayWindow.hidden = NO;
        
        self.menuVC = [[FFHackMenuViewController alloc] init];
        self.menuVC.view.frame = self.overlayWindow.bounds;
        self.overlayWindow.rootViewController = self.menuVC;
        self.menuVC.view.hidden = YES;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.menuVC showWithAnimation];
        });
        
        NSLog(@"✅ FFHack started successfully!");
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
        NSLog(@"⛔ FFHack stopped");
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
// PHẦN 6: EXPORT FUNCTIONS
// ============================================================

extern "C" {
    
    __attribute__((constructor))
    static void _ffhack_constructor(void) {
        NSLog(@"═══════════════════════════════════════════════════");
        NSLog(@"║   🔥 FFHack Pro v3.0 Loaded Successfully     ║");
        NSLog(@"║   📅 Build: %s %s", __DATE__, __TIME__);
        NSLog(@"║   📦 Size: Large Mode                        ║");
        NSLog(@"═══════════════════════════════════════════════════");
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            _dummy_crypto_aes();
            _dummy_crypto_sha();
            _dummy_crypto_hmac();
            _dummy_compress_zlib();
            _dummy_json_parse();
            _dummy_network_request();
            _dummy_location();
            _dummy_webview();
            _dummy_metal();
            _dummy_scenekit();
            _dummy_spritekit();
            _dummy_image_processing();
            _dummy_audio();
            _dummy_map();
            _dummy_file_io();
            _dummy_user_defaults();
            _dummy_threads();
            _dummy_math_compute();
            _dummy_memory_ops();
            _dummy_process_info();
            _dummy_system_info();
            _dummy_animation();
            _dummy_gesture();
            _dummy_notification();
            _dummy_timer();
        });
        
        [[FFHackManager shared] start];
    }
    
    __attribute__((destructor))
    static void _ffhack_destructor(void) {
        NSLog(@"FFHack Pro Unloaded");
        [[FFHackManager shared] stop];
    }
    
    void start_ffhack(void) {
        [[FFHackManager shared] start];
    }
    
    void stop_ffhack(void) {
        [[FFHackManager shared] stop];
    }
    
    void toggle_ffhack_menu(void) {
        [[FFHackManager shared] toggleMenu];
    }
    
    bool is_ffhack_menu_visible(void) {
        return [[FFHackManager shared] isMenuVisible];
    }
    
    void show_ffhack_menu(void) {
        [[FFHackManager shared] toggleMenu];
    }
    
    void hide_ffhack_menu(void) {
        if ([[FFHackManager shared] isMenuVisible]) {
            [[FFHackManager shared] toggleMenu];
        }
    }
}

// ============================================================
// PHẦN 7: MAIN
// ============================================================

int main(int argc, char *argv[]) {
    @autoreleasepool {
        start_ffhack();
        sleep(60);
        stop_ffhack();
    }
    return 0;
}
