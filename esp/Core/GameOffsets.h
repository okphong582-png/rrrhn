#ifndef GameOffsets_h
#define GameOffsets_h

#include <cstdint>

// Game fields supplied in ofs.txt. These values have not been verified against
// a running iOS build. Unity/IL2CPP internal layouts remain the original ARM64
// layouts because the supplied file does not describe them.
namespace GameOffsets {
constexpr uint64_t GameFacade_TypeInfo = 0xA3460EC;
constexpr uint64_t StaticClass = 0x60;
constexpr uint64_t CurrentMatch = 0x78;
constexpr uint64_t LocalPlayer = 0xC0;
constexpr uint64_t DictionaryEntities = 0x6C;
constexpr uint64_t Player_IsDead = 0x78;
constexpr uint64_t Player_Name = 0x2A0;
constexpr uint64_t Player_Data = 0x70;
constexpr uint64_t PlayerID = 0x260;
constexpr uint64_t MainCameraTransform = 0x28C;
constexpr uint64_t FollowCamera = 0x494;
constexpr uint64_t Camera = 0x18;
constexpr uint64_t ViewMatrix = 0xE8;
constexpr uint64_t Head = 0x49C;
constexpr uint64_t RightFoot = 0x4C4;
}

#endif
