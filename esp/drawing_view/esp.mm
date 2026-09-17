#import "esp.h"
#include <cmath>

@interface ESP_View ()
@property (nonatomic, strong) NSMutableArray<CALayer *> *layers;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) CADisplayLink *displayLinkDATA;
@property (nonatomic, strong) NSArray<NSValue *> *boxesData;
@property (nonatomic, assign) CFTimeInterval lastAttachAttempt;
- (NSArray<NSValue *> *)collectBoxes;
@end

uint64_t Moudule_Base = 0;

@implementation ESP_View

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layers = [NSMutableArray array];
        self.backgroundColor = [UIColor clearColor];

        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateBoxes)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        
        self.displayLinkDATA = [CADisplayLink displayLinkWithTarget:self selector:@selector(update_data)];
        [self.displayLinkDATA addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.superview) {
        self.frame = self.superview.bounds;
    }
    [self updateBoxes];
}

- (void)setBoxes:(NSArray<NSValue *> *)boxes
{
    _boxesData = [boxes copy];
    [self updateBoxes];
}

- (void)updateBoxes {
    if (!self.window) return;
    NSUInteger count = self.boxesData.count;
    
    if (count == 0)
    {
        for (CALayer *layer in self.layers)
        {
            [layer removeFromSuperlayer];
        }
        [self.layers removeAllObjects];
        return;
    }
    
    while (self.layers.count < count)
    {
        CALayer *layer = [CALayer layer];
        layer.borderColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.8].CGColor;
        layer.borderWidth = 2.0;
        layer.cornerRadius = 3.0;
        [self.layer addSublayer:layer];
        [self.layers addObject:layer];
    }

    for (NSUInteger i = 0; i < self.layers.count; i++)
    {
        CALayer *layer = self.layers[i];

        if (i < count)
        {
            ESPBox box;
            [self.boxesData[i] getValue:&box];
            layer.hidden = NO;
            
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            layer.frame = CGRectMake(box.pos.x, box.pos.y, box.width, box.height);
            [CATransaction commit];

        } else {
            layer.hidden = YES;
        }
    }
}

- (void)dealloc {
    [self.displayLink invalidate];
    [self.displayLinkDATA invalidate];
    self.displayLink = nil;
    self.displayLinkDATA = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)update_data
{
    // Always publish the result so failed reads clear boxes from the old match.
    self.boxes = [self collectBoxes];
}

- (NSArray<NSValue *> *)collectBoxes
{
    CGSize size = self.bounds.size;
    if (size.width <= 0 || size.height <= 0) return @[];

    if (Moudule_Base == 0) {
        CFTimeInterval now = CACurrentMediaTime();
        if (now - self.lastAttachAttempt < 1.0) return @[];
        self.lastAttachAttempt = now;
        Moudule_Base = (uint64_t)GetGameModule_Base((char*)"freefireth");
        if (Moudule_Base == 0) return @[];
    }

    uint64_t typeInfo = 0;
    if (!_read(Moudule_Base + GameOffsets::GameFacade_TypeInfo, &typeInfo, sizeof(typeInfo))) {
        Moudule_Base = 0;
        return @[];
    }

    uint64_t matchGame = getMatchGame(Moudule_Base);
    if (!isVaildPtr(matchGame)) return @[];

    uint64_t match = getMatch(matchGame);
    if (!isVaildPtr(match)) return @[];

    uint64_t myPawnObject = getLocalPlayer(match);
    if (!isVaildPtr(myPawnObject)) return @[];

    uint64_t camera = CameraMain(myPawnObject);
    if (!isVaildPtr(camera)) return @[];
    
    uint64_t mainCameraTransform = ReadAddr<uint64_t>(myPawnObject + GameOffsets::MainCameraTransform);
    Vector3 myLocation;
    if (!getPositionExt(mainCameraTransform, myLocation)) return @[];
    
    uint64_t player = ReadAddr<uint64_t>(match + GameOffsets::DictionaryEntities);
    if (!isVaildPtr(player)) return @[];
    // Original ARM64 collection/array layout; ofs.txt only names the field.
    uint64_t tValue = ReadAddr<uint64_t>(player + 0x28);
    if (!isVaildPtr(tValue)) return @[];
    int coutValue = ReadAddr<int>(tValue + 0x18);
    if (coutValue <= 0 || coutValue > 1024) return @[];
    
    float *matrix = GetViewMatrix(camera);
    if (matrix == nullptr) return @[];
    for (int i = 0; i < 16; ++i) {
        if (!std::isfinite(matrix[i])) return @[];
    }

    NSMutableArray<NSValue *> *boxesMutable = [NSMutableArray arrayWithCapacity:coutValue];

    for (int i = 0; i < coutValue; i++) {
        uint64_t PawnObject = ReadAddr<uint64_t>(tValue + 0x20 + sizeof(uint64_t) * i);
        if (!isVaildPtr(PawnObject) || PawnObject == myPawnObject) continue;
        if (ReadAddr<uint8_t>(PawnObject + GameOffsets::Player_IsDead) != 0) continue;

        bool isLocalTeam = isLocalTeamMate(myPawnObject, PawnObject);
        if (isLocalTeam) continue;
        
        // Names and HP are not rendered by this box-only view. A failed name
        // read must not suppress an otherwise valid box.
        Vector3 HeadLocation;
        Vector3 RightFootPos;
        if (!getPositionExt(getHead(PawnObject), HeadLocation) ||
            !getPositionExt(getRightFoot(PawnObject), RightFootPos)) continue;
        HeadLocation.y           += 0.2f;
        
        Vector3 w2sHeadLocation = WorldToScreen(HeadLocation, matrix, size.width, size.height);
        Vector3 w2sRightFootPos = WorldToScreen(RightFootPos, matrix, size.width, size.height);
        if (w2sHeadLocation.z < 0.5f || w2sRightFootPos.z < 0.5f) continue;
        
        float dis = Vector3::Distance(myLocation, HeadLocation);
        if (!std::isfinite(dis) || dis > 220.0f) continue;

        float boxHeight = std::fabs(w2sHeadLocation.y - w2sRightFootPos.y);
        float boxWidth = boxHeight * 0.5f;
        float x = w2sHeadLocation.x - boxWidth * 0.5f;
        float y = w2sHeadLocation.y;
        if (!std::isfinite(x) || !std::isfinite(y) ||
            !std::isfinite(boxHeight) || boxHeight <= 0.0f) continue;

        ESPBox espBox;
        espBox.pos.x = x;
        espBox.pos.y = y;
        espBox.width = boxWidth;
        espBox.height = boxHeight;
        
        NSValue *val = [NSValue valueWithBytes:&espBox objCType:@encode(ESPBox)];
        [boxesMutable addObject:val];
    }

    return boxesMutable;
}


@end
