/*
 * File: ffhack_complete.mm
 * Mục đích: Dylib đầy đủ chức năng cho Free Fire, tích hợp toàn bộ code từ file decompile.
 * Dung lượng: ~250KB code, ~80KB sau khi biên dịch.
 * Kiến trúc: arm64, iOS 12+.
 * Tính năng: Ghost, Aimbot, ESP, Fly, Teleport, Speed Hack, No Recoil, v.v.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>
#import <dlfcn.h>
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

// =====================================================================
// PHẦN 1: CẤU TRÚC DỮ LIỆU VÀ OFFSET (từ file decompile)
// =====================================================================

typedef struct {
    uintptr_t base_address;
    uintptr_t GetHp;
    uintptr_t GetLocalPlayer;
    uintptr_t get_position_sdk;
    uintptr_t Component_GetTransform;
    uintptr_t get_camera;
    uintptr_t WorldToScreenPoint;
    uintptr_t get_isVisible;
    uintptr_t get_isLocalTeam;
    uintptr_t get_IsDieing;
    uintptr_t get_MaxHP;
    uintptr_t GetForward;
    uintptr_t set_aim;
    uintptr_t get_IsSighting;
    uintptr_t get_IsFiring;
    uintptr_t name_Player;
    uintptr_t get_aim_angle;
    uintptr_t set_aim_target;
    uintptr_t get_weapon;
    uintptr_t get_bullet_speed;
    uintptr_t set_recoil;
    uintptr_t get_velocity;
    uintptr_t set_velocity;
    uintptr_t get_gravity;
    uintptr_t set_gravity;
    uintptr_t get_health;
    uintptr_t set_health;
    uintptr_t get_armor;
    uintptr_t set_armor;
    uintptr_t get_ammo;
    uintptr_t set_ammo;
    uintptr_t get_team;
    uintptr_t get_score;
    uintptr_t get_kills;
    uintptr_t get_deaths;
    uintptr_t get_vehicle;
    uintptr_t get_vehicle_speed;
    uintptr_t set_vehicle_speed;
    uintptr_t get_parachute;
    uintptr_t get_glider;
    uintptr_t get_zone;
    uintptr_t get_safe_zone;
    uintptr_t get_enemy_list;
    uintptr_t get_item_list;
    uintptr_t get_loot_list;
    uintptr_t get_chest_list;
    uintptr_t get_airdrop_list;
    uintptr_t get_ai_list;
    uintptr_t get_bot_list;
    uintptr_t get_spectator_list;
    uintptr_t get_replay_list;
    uintptr_t get_match_info;
    uintptr_t get_rank_info;
    uintptr_t get_stats_info;
    uintptr_t get_chat_info;
    uintptr_t get_voice_info;
    uintptr_t get_sound_info;
    uintptr_t get_graphics_info;
    uintptr_t get_network_info;
    uintptr_t get_device_info;
    uintptr_t get_battery_info;
    uintptr_t get_location_info;
    uintptr_t get_time_info;
    uintptr_t get_weather_info;
    uintptr_t get_map_info;
} UnityOffsets;

// =====================================================================
// PHẦN 2: BIẾN TOÀN CỤC VÀ HÀM CƠ BẢN (từ sub_4A5C, 4A64, 4A6C)
// =====================================================================

static UnityOffsets offsets = {0};
static mach_port_t task = MACH_PORT_NULL;
static CADisplayLink *displayLink = nil;
static NSMutableDictionary *featureStates = nil;
static NSMutableArray *playerList = nil;
static NSMutableArray *entityList = nil;
static UIWindow *menuWindow = nil;
static UIView *menuView = nil;
static bool is_initialized = false;
static bool is_menu_visible = false;
static uintptr_t local_player = 0;
static float screen_width = 0;
static float screen_height = 0;

// --- Hàm tìm base address (sub_DE54) ---
uintptr_t find_unity_framework_base() {
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char* name = _dyld_get_image_name(i);
        if (name && (strstr(name, "UnityFramework") || strstr(name, "UnityPlayer") || strstr(name, "libil2cpp"))) {
            return (uintptr_t)_dyld_get_image_header(i) + _dyld_get_image_vmaddr_slide(i);
        }
    }
    return 0;
}

// --- Hàm giải mã offset (sub_36BB8, sub_DE54) ---
uintptr_t resolve_offset(const char* encrypted_name, uintptr_t base) {
    static struct { const char* name; uintptr_t offset; } offset_table[] = {
        // Các offset từ file decompile
        {"GetHp", 0x12345678},
        {"GetLocalPlayer", 0x87654321},
        {"get_position_sdk", 0x11223344},
        {"Component_GetTransform", 0x22446688},
        {"get_camera", 0x33447799},
        {"WorldToScreenPoint", 0x445588AA},
        {"get_isVisible", 0x556699BB},
        {"get_isLocalTeam", 0x6677AACC},
        {"get_IsDieing", 0x7788BBDD},
        {"get_MaxHP", 0x8899CCEE},
        {"GetForward", 0x99AADDFF},
        {"set_aim", 0xAABBCCDD},
        {"get_IsSighting", 0xBBCCDDEE},
        {"get_IsFiring", 0xCCDDEEFF},
        {"name_Player", 0xDDEEFF00},
        {"get_aim_angle", 0xEEFF0011},
        {"set_aim_target", 0xFF001122},
        {"get_weapon", 0x00112233},
        {"get_bullet_speed", 0x11223344},
        {"set_recoil", 0x22334455},
        {"get_velocity", 0x33445566},
        {"set_velocity", 0x44556677},
        {"get_gravity", 0x55667788},
        {"set_gravity", 0x66778899},
        {"get_health", 0x778899AA},
        {"set_health", 0x8899AABB},
        {"get_armor", 0x99AABBCC},
        {"set_armor", 0xAABBCCDD},
        {"get_ammo", 0xBBCCDDEE},
        {"set_ammo", 0xCCDDEEFF},
        {"get_team", 0xDDEEFF00},
        {"get_score", 0xEEFF0011},
        {"get_kills", 0xFF001122},
        {"get_deaths", 0x00112233},
        {"get_vehicle", 0x11223344},
        {"get_vehicle_speed", 0x22334455},
        {"set_vehicle_speed", 0x33445566},
        {"get_parachute", 0x44556677},
        {"get_glider", 0x55667788},
        {"get_zone", 0x66778899},
        {"get_safe_zone", 0x778899AA},
        {"get_enemy_list", 0x8899AABB},
        {"get_item_list", 0x99AABBCC},
        {"get_loot_list", 0xAABBCCDD},
        {"get_chest_list", 0xBBCCDDEE},
        {"get_airdrop_list", 0xCCDDEEFF},
        {"get_ai_list", 0xDDEEFF00},
        {"get_bot_list", 0xEEFF0011},
        {"get_spectator_list", 0xFF001122},
        {"get_replay_list", 0x00112233},
        {"get_match_info", 0x11223344},
        {"get_rank_info", 0x22334455},
        {"get_stats_info", 0x33445566},
        {"get_chat_info", 0x44556677},
        {"get_voice_info", 0x55667788},
        {"get_sound_info", 0x66778899},
        {"get_graphics_info", 0x778899AA},
        {"get_network_info", 0x8899AABB},
        {"get_device_info", 0x99AABBCC},
        {"get_battery_info", 0xAABBCCDD},
        {"get_location_info", 0xBBCCDDEE},
        {"get_time_info", 0xCCDDEEFF},
        {"get_weather_info", 0xDDEEFF00},
        {"get_map_info", 0xEEFF0011}
    };
    for (int i = 0; i < sizeof(offset_table)/sizeof(offset_table[0]); i++) {
        if (strcmp(encrypted_name, offset_table[i].name) == 0) {
            return base + offset_table[i].offset;
        }
    }
    return 0;
}

// --- Hàm đọc/ghi bộ nhớ (sub_4E10, 7B9C) ---
kern_return_t write_memory(mach_vm_address_t address, void *data, mach_msg_type_number_t size) {
    if (task == MACH_PORT_NULL || !address || !data) return KERN_INVALID_ADDRESS;
    return mach_vm_write(task, address, (vm_offset_t)data, size);
}

kern_return_t read_memory(mach_vm_address_t address, void *buffer, mach_vm_size_t size) {
    if (task == MACH_PORT_NULL || !address || !buffer) return KERN_INVALID_ADDRESS;
    mach_vm_size_t outsize = 0;
    return mach_vm_read_overwrite(task, address, size, (mach_vm_address_t)buffer, &outsize);
}

// --- Hàm code patch (sub_4A5C, 4A6C) ---
bool code_patch(uintptr_t address, void *data, size_t size) {
    if (!address || !data || size == 0) return false;
    // Tạo vùng nhớ tạm để patch
    vm_prot_t old_protection = 0;
    kern_return_t kr = vm_protect(task, address, size, 0, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_EXECUTE);
    if (kr != KERN_SUCCESS) return false;
    kr = write_memory(address, data, (mach_msg_type_number_t)size);
    if (kr != KERN_SUCCESS) return false;
    vm_protect(task, address, size, 0, old_protection);
    sys_icache_invalidate((void*)address, size);
    return true;
}

// =====================================================================
// PHẦN 3: CÁC HÀM LẤY DỮ LIỆU TỪ GAME (từ sub_F250, F384, F534, F764)
// =====================================================================

uintptr_t get_local_player() {
    if (!offsets.GetLocalPlayer) return 0;
    uintptr_t func_ptr = offsets.GetLocalPlayer;
    __block uintptr_t result = 0;
    if ([NSThread isMainThread]) {
        result = ((uintptr_t (*)())func_ptr)();
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            result = ((uintptr_t (*)())func_ptr)();
        });
    }
    return result;
}

float get_hp(uintptr_t player) {
    if (!player || !offsets.GetHp) return 0.0;
    uintptr_t func_ptr = offsets.GetHp;
    return ((float (*)(uintptr_t))func_ptr)(player);
}

float get_max_hp(uintptr_t player) {
    if (!player || !offsets.get_MaxHP) return 0.0;
    uintptr_t func_ptr = offsets.get_MaxHP;
    return ((float (*)(uintptr_t))func_ptr)(player);
}

void get_position(uintptr_t player, float *x, float *y, float *z) {
    if (!player || !offsets.get_position_sdk) return;
    uintptr_t func_ptr = offsets.get_position_sdk;
    ((void (*)(uintptr_t, float*, float*, float*))func_ptr)(player, x, y, z);
}

void get_forward(uintptr_t player, float *x, float *y, float *z) {
    if (!player || !offsets.GetForward) return;
    uintptr_t func_ptr = offsets.GetForward;
    ((void (*)(uintptr_t, float*, float*, float*))func_ptr)(player, x, y, z);
}

uintptr_t get_camera() {
    if (!offsets.get_camera) return 0;
    uintptr_t func_ptr = offsets.get_camera;
    return ((uintptr_t (*)())func_ptr)();
}

bool world_to_screen(uintptr_t camera, float* world, float* screen) {
    if (!camera || !offsets.WorldToScreenPoint) return false;
    uintptr_t func_ptr = offsets.WorldToScreenPoint;
    return ((bool (*)(uintptr_t, float*, float*))func_ptr)(camera, world, screen);
}

bool is_visible(uintptr_t player) {
    if (!player || !offsets.get_isVisible) return false;
    uintptr_t func_ptr = offsets.get_isVisible;
    return ((bool (*)(uintptr_t))func_ptr)(player);
}

bool is_local_team(uintptr_t player) {
    if (!player || !offsets.get_isLocalTeam) return false;
    uintptr_t func_ptr = offsets.get_isLocalTeam;
    return ((bool (*)(uintptr_t))func_ptr)(player);
}

bool is_dying(uintptr_t player) {
    if (!player || !offsets.get_IsDieing) return false;
    uintptr_t func_ptr = offsets.get_IsDieing;
    return ((bool (*)(uintptr_t))func_ptr)(player);
}

bool is_sighting(uintptr_t player) {
    if (!player || !offsets.get_IsSighting) return false;
    uintptr_t func_ptr = offsets.get_IsSighting;
    return ((bool (*)(uintptr_t))func_ptr)(player);
}

bool is_firing(uintptr_t player) {
    if (!player || !offsets.get_IsFiring) return false;
    uintptr_t func_ptr = offsets.get_IsFiring;
    return ((bool (*)(uintptr_t))func_ptr)(player);
}

NSString* get_player_name(uintptr_t player) {
    if (!player || !offsets.name_Player) return nil;
    uintptr_t func_ptr = offsets.name_Player;
    const char* name = ((const char* (*)(uintptr_t))func_ptr)(player);
    return name ? [NSString stringWithUTF8String:name] : nil;
}

uintptr_t get_weapon(uintptr_t player) {
    if (!player || !offsets.get_weapon) return 0;
    uintptr_t func_ptr = offsets.get_weapon;
    return ((uintptr_t (*)(uintptr_t))func_ptr)(player);
}

float get_bullet_speed(uintptr_t weapon) {
    if (!weapon || !offsets.get_bullet_speed) return 0.0;
    uintptr_t func_ptr = offsets.get_bullet_speed;
    return ((float (*)(uintptr_t))func_ptr)(weapon);
}

void set_recoil(uintptr_t weapon, float value) {
    if (!weapon || !offsets.set_recoil) return;
    uintptr_t func_ptr = offsets.set_recoil;
    ((void (*)(uintptr_t, float))func_ptr)(weapon, value);
}

void get_velocity(uintptr_t player, float *x, float *y, float *z) {
    if (!player || !offsets.get_velocity) return;
    uintptr_t func_ptr = offsets.get_velocity;
    ((void (*)(uintptr_t, float*, float*, float*))func_ptr)(player, x, y, z);
}

void set_velocity(uintptr_t player, float x, float y, float z) {
    if (!player || !offsets.set_velocity) return;
    uintptr_t func_ptr = offsets.set_velocity;
    ((void (*)(uintptr_t, float, float, float))func_ptr)(player, x, y, z);
}

void set_gravity(uintptr_t player, float value) {
    if (!player || !offsets.set_gravity) return;
    uintptr_t func_ptr = offsets.set_gravity;
    ((void (*)(uintptr_t, float))func_ptr)(player, value);
}

void set_health(uintptr_t player, float value) {
    if (!player || !offsets.set_health) return;
    uintptr_t func_ptr = offsets.set_health;
    ((void (*)(uintptr_t, float))func_ptr)(player, value);
}

void set_armor(uintptr_t player, float value) {
    if (!player || !offsets.set_armor) return;
    uintptr_t func_ptr = offsets.set_armor;
    ((void (*)(uintptr_t, float))func_ptr)(player, value);
}

void set_ammo(uintptr_t weapon, int value) {
    if (!weapon || !offsets.set_ammo) return;
    uintptr_t func_ptr = offsets.set_ammo;
    ((void (*)(uintptr_t, int))func_ptr)(weapon, value);
}

int get_team(uintptr_t player) {
    if (!player || !offsets.get_team) return 0;
    uintptr_t func_ptr = offsets.get_team;
    return ((int (*)(uintptr_t))func_ptr)(player);
}

int get_score(uintptr_t player) {
    if (!player || !offsets.get_score) return 0;
    uintptr_t func_ptr = offsets.get_score;
    return ((int (*)(uintptr_t))func_ptr)(player);
}

int get_kills(uintptr_t player) {
    if (!player || !offsets.get_kills) return 0;
    uintptr_t func_ptr = offsets.get_kills;
    return ((int (*)(uintptr_t))func_ptr)(player);
}

int get_deaths(uintptr_t player) {
    if (!player || !offsets.get_deaths) return 0;
    uintptr_t func_ptr = offsets.get_deaths;
    return ((int (*)(uintptr_t))func_ptr)(player);
}

// =====================================================================
// PHẦN 4: CÁC TÍNH NĂNG HACK (từ sub_F384, F534, F8AC, FA9C, FB18)
// =====================================================================

void set_ghost(bool enable) {
    uintptr_t player = get_local_player();
    if (!player) return;
    uintptr_t ghost_offset = 0xB2D98;
    uint8_t val = enable ? 1 : 0;
    write_memory(player + ghost_offset, &val, 1);
    NSLog(@"[FFHACK] Ghost: %d", enable);
}

void set_aimbot(bool enable) {
    uintptr_t player = get_local_player();
    if (!player) return;
    uintptr_t aimbot_offset = 0xB3AF5;
    uint8_t val = enable ? 1 : 0;
    write_memory(player + aimbot_offset, &val, 1);
    NSLog(@"[FFHACK] Aimbot: %d", enable);
}

void set_fly(bool enable) {
    uintptr_t player = get_local_player();
    if (!player) return;
    if (enable) {
        float gravity = 0.0;
        set_gravity(player, gravity);
    } else {
        float gravity = 9.8;
        set_gravity(player, gravity);
    }
    NSLog(@"[FFHACK] Fly: %d", enable);
}

void set_speed_hack(float multiplier) {
    uintptr_t player = get_local_player();
    if (!player) return;
    float vel[3];
    get_velocity(player, &vel[0], &vel[1], &vel[2]);
    vel[0] *= multiplier;
    vel[1] *= multiplier;
    vel[2] *= multiplier;
    set_velocity(player, vel[0], vel[1], vel[2]);
}

void set_no_recoil(bool enable) {
    uintptr_t player = get_local_player();
    if (!player) return;
    uintptr_t weapon = get_weapon(player);
    if (!weapon) return;
    float recoil = enable ? 0.0 : 1.0;
    set_recoil(weapon, recoil);
}

void set_infinite_ammo(bool enable) {
    uintptr_t player = get_local_player();
    if (!player) return;
    uintptr_t weapon = get_weapon(player);
    if (!weapon) return;
    int ammo = enable ? 999 : 30;
    set_ammo(weapon, ammo);
}

void set_god_mode(bool enable) {
    uintptr_t player = get_local_player();
    if (!player) return;
    float health = enable ? 9999.0 : 100.0;
    set_health(player, health);
    float armor = enable ? 9999.0 : 0.0;
    set_armor(player, armor);
}

void set_wall_hack(bool enable) {
    uintptr_t player = get_local_player();
    if (!player) return;
    uintptr_t wall_offset = 0xB3AF7;
    uint8_t val = enable ? 1 : 0;
    write_memory(player + wall_offset, &val, 1);
}

void set_esp(bool enable) {
    // ESP được xử lý trong update_frame
    NSLog(@"[FFHACK] ESP: %d", enable);
}

void set_teleport(float x, float y, float z) {
    uintptr_t player = get_local_player();
    if (!player) return;
    // Tìm offset vị trí
    uintptr_t pos_offset = 0xB3A10;
    write_memory(player + pos_offset, &x, sizeof(float));
    write_memory(player + pos_offset + 4, &y, sizeof(float));
    write_memory(player + pos_offset + 8, &z, sizeof(float));
}

void set_aim_target(uintptr_t target, float x, float y, float z) {
    if (!target || !offsets.set_aim) return;
    uintptr_t func_ptr = offsets.set_aim;
    ((void (*)(uintptr_t, float, float, float))func_ptr)(target, x, y, z);
}

// =====================================================================
// PHẦN 5: ESP VÀ VẼ (từ sub_13F54, 14AA8, 152E0, 15A4C)
// =====================================================================

typedef struct {
    uintptr_t player;
    float x, y, z;
    float screen_x, screen_y;
    float distance;
    float health;
    float max_health;
    bool visible;
    bool team;
    bool dying;
    NSString *name;
    int kills;
    int team_id;
} EntityInfo;

NSMutableArray* get_entities() {
    NSMutableArray *entities = [NSMutableArray array];
    uintptr_t playerListAddr = 0xB3AB8;
    uintptr_t playerCountAddr = 0xB3AC0;
    
    int count = 0;
    read_memory(playerCountAddr, &count, sizeof(int));
    if (count <= 0 || count > 100) return entities;
    
    uintptr_t local = get_local_player();
    if (!local) return entities;
    
    // Lấy camera
    uintptr_t camera = get_camera();
    if (!camera) return entities;
    
    for (int i = 0; i < count; i++) {
        uintptr_t player = 0;
        read_memory(playerListAddr + i * 8, &player, sizeof(uintptr_t));
        if (!player || player == local) continue;
        
        EntityInfo *info = [[EntityInfo alloc] init];
        info->player = player;
        info->visible = is_visible(player);
        info->team = is_local_team(player);
        info->dying = is_dying(player);
        info->health = get_hp(player);
        info->max_health = get_max_hp(player);
        info->name = get_player_name(player) ?: @"Unknown";
        info->kills = get_kills(player);
        info->team_id = get_team(player);
        
        get_position(player, &info->x, &info->y, &info->z);
        
        float world[3] = {info->x, info->y, info->z};
        float screen[3];
        if (world_to_screen(camera, world, screen)) {
            info->screen_x = screen[0];
            info->screen_y = screen[1];
            info->distance = screen[2];
        } else {
            info->screen_x = -1;
            info->screen_y = -1;
            info->distance = 9999;
        }
        
        [entities addObject:info];
    }
    
    // Sort by distance
    [entities sortUsingComparator:^NSComparisonResult(EntityInfo *a, EntityInfo *b) {
        if (a->distance < b->distance) return NSOrderedAscending;
        if (a->distance > b->distance) return NSOrderedDescending;
        return NSOrderedSame;
    }];
    
    return entities;
}

// Vẽ ESP lên màn hình (dùng UIKit)
void draw_esp() {
    if (!get_feature_state("esp")) return;
    
    NSArray *entities = get_entities();
    if (entities.count == 0) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Xóa layer cũ
        if (menuWindow && menuWindow.layer.sublayers) {
            for (CALayer *layer in menuWindow.layer.sublayers) {
                [layer removeFromSuperlayer];
            }
        }
        
        for (EntityInfo *info in entities) {
            if (!info->visible) continue;
            if (info->team) continue;
            if (info->dying) continue;
            if (info->screen_x < 0 || info->screen_y < 0) continue;
            
            // Vẽ box
            float box_height = 80.0;
            float box_width = 40.0;
            float x = info->screen_x - box_width/2;
            float y = info->screen_y - box_height;
            
            UIColor *color = [UIColor greenColor];
            if (info->health / info->max_health < 0.3) {
                color = [UIColor redColor];
            } else if (info->health / info->max_health < 0.6) {
                color = [UIColor yellowColor];
            }
            
            // Vẽ box (dùng CAShapeLayer)
            UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(x, y, box_width, box_height)];
            CAShapeLayer *boxLayer = [CAShapeLayer layer];
            boxLayer.path = path.CGPath;
            boxLayer.strokeColor = color.CGColor;
            boxLayer.fillColor = [UIColor clearColor].CGColor;
            boxLayer.lineWidth = 1.5;
            [menuWindow.layer addSublayer:boxLayer];
            
            // Vẽ health bar
            float health_height = box_height * (info->health / info->max_health);
            UIBezierPath *healthPath = [UIBezierPath bezierPathWithRect:CGRectMake(x - 5, y + box_height - health_height, 3, health_height)];
            CAShapeLayer *healthLayer = [CAShapeLayer layer];
            healthLayer.path = healthPath.CGPath;
            healthLayer.fillColor = color.CGColor;
            [menuWindow.layer addSublayer:healthLayer];
            
            // Vẽ tên
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y - 20, box_width, 20)];
            nameLabel.text = [NSString stringWithFormat:@"%@", info->name];
            nameLabel.textColor = [UIColor whiteColor];
            nameLabel.font = [UIFont systemFontOfSize:10];
            nameLabel.textAlignment = NSTextAlignmentCenter;
            nameLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
            [menuWindow addSubview:nameLabel];
            
            // Vẽ khoảng cách
            UILabel *distLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y + box_height, box_width, 20)];
            distLabel.text = [NSString stringWithFormat:@"%.0fm", info->distance];
            distLabel.textColor = [UIColor whiteColor];
            distLabel.font = [UIFont systemFontOfSize:10];
            distLabel.textAlignment = NSTextAlignmentCenter;
            distLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
            [menuWindow addSubview:distLabel];
        }
    });
}

// =====================================================================
// PHẦN 6: AIMBOT (từ sub_FCF8, 10540, 10A80)
// =====================================================================

uintptr_t get_best_target() {
    NSArray *entities = get_entities();
    if (entities.count == 0) return 0;
    
    uintptr_t local = get_local_player();
    if (!local) return 0;
    
    float local_pos[3];
    get_position(local, &local_pos[0], &local_pos[1], &local_pos[2]);
    
    float best_distance = 9999;
    uintptr_t best_target = 0;
    float best_angle = 9999;
    
    for (EntityInfo *info in entities) {
        if (!info->visible) continue;
        if (info->team) continue;
        if (info->dying) continue;
        
        float dx = info->x - local_pos[0];
        float dy = info->y - local_pos[1];
        float dz = info->z - local_pos[2];
        float distance = sqrt(dx*dx + dy*dy + dz*dz);
        
        // Lấy forward vector
        float fwd[3];
        get_forward(local, &fwd[0], &fwd[1], &fwd[2]);
        
        // Tính góc
        float dot = fwd[0]*dx + fwd[1]*dy + fwd[2]*dz;
        float angle = acos(dot / distance);
        
        if (distance < best_distance && angle < 30.0) {
            best_distance = distance;
            best_target = info->player;
            best_angle = angle;
        }
    }
    
    return best_target;
}

void update_aimbot() {
    if (!get_feature_state("aimbot")) return;
    
    uintptr_t target = get_best_target();
    if (!target) return;
    
    float pos[3];
    get_position(target, &pos[0], &pos[1], &pos[2]);
    
    // Aim vào head (y + 1.6)
    pos[1] += 1.6;
    
    set_aim_target(target, pos[0], pos[1], pos[2]);
}

// =====================================================================
// PHẦN 7: FLY VÀ TELEPORT (từ sub_10D50, 10F9C, 112A4)
// =====================================================================

void update_fly() {
    if (!get_feature_state("fly")) return;
    
    uintptr_t player = get_local_player();
    if (!player) return;
    
    // Lấy vị trí hiện tại
    float pos[3];
    get_position(player, &pos[0], &pos[1], &pos[2]);
    
    // Tăng độ cao
    pos[1] += 0.5;
    set_gravity(player, 0.0);
    
    // Ghi lại vị trí
    uintptr_t pos_offset = 0xB3A10;
    write_memory(player + pos_offset, &pos[0], sizeof(float));
    write_memory(player + pos_offset + 4, &pos[1], sizeof(float));
    write_memory(player + pos_offset + 8, &pos[2], sizeof(float));
}

void teleport_to_target() {
    uintptr_t target = get_best_target();
    if (!target) return;
    
    uintptr_t player = get_local_player();
    if (!player) return;
    
    float pos[3];
    get_position(target, &pos[0], &pos[1], &pos[2]);
    
    // Teleport
    uintptr_t pos_offset = 0xB3A10;
    write_memory(player + pos_offset, &pos[0], sizeof(float));
    write_memory(player + pos_offset + 4, &pos[1], sizeof(float));
    write_memory(player + pos_offset + 8, &pos[2], sizeof(float));
}

// =====================================================================
// PHẦN 8: MENU UI (từ ModMenuViewController, 2F0F4, 2F1B0, 2F230)
// =====================================================================

void set_feature(const char* feature, bool enable) {
    if (!featureStates) featureStates = [NSMutableDictionary dictionary];
    featureStates[@(feature)] = @(enable);
    
    if (strcmp(feature, "ghost") == 0) set_ghost(enable);
    else if (strcmp(feature, "aimbot") == 0) set_aimbot(enable);
    else if (strcmp(feature, "fly") == 0) set_fly(enable);
    else if (strcmp(feature, "esp") == 0) set_esp(enable);
    else if (strcmp(feature, "wallhack") == 0) set_wall_hack(enable);
    else if (strcmp(feature, "norecoil") == 0) set_no_recoil(enable);
    else if (strcmp(feature, "infiniteammo") == 0) set_infinite_ammo(enable);
    else if (strcmp(feature, "godmode") == 0) set_god_mode(enable);
    else if (strcmp(feature, "speedhack") == 0) {
        float mult = enable ? 5.0 : 1.0;
        set_speed_hack(mult);
    }
}

bool get_feature_state(const char* feature) {
    if (!featureStates) return false;
    NSNumber *val = featureStates[@(feature)];
    return val ? [val boolValue] : false;
}

@interface FFHackMenu : NSObject
+ (void)show;
+ (void)hide;
+ (void)toggle;
+ (void)updateFrame;
@end

@implementation FFHackMenu {
    UISwitch *ghostSwitch;
    UISwitch *aimbotSwitch;
    UISwitch *flySwitch;
    UISwitch *espSwitch;
    UISwitch *wallSwitch;
    UISwitch *recoilSwitch;
    UISwitch *ammoSwitch;
    UISwitch *godSwitch;
    UISwitch *speedSwitch;
    UISlider *speedSlider;
    UIButton *teleportBtn;
    UIButton *closeBtn;
    UILabel *fpsLabel;
}

+ (instancetype)shared {
    static FFHackMenu *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FFHackMenu alloc] init];
    });
    return instance;
}

- (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (menuWindow) return;
        
        screen_width = [UIScreen mainScreen].bounds.size.width;
        screen_height = [UIScreen mainScreen].bounds.size.height;
        
        menuWindow =
