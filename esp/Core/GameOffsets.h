#ifndef GameOffsets_h
#define GameOffsets_h

#include <stdint.h>

// Centralized offsets imported from ofs.txt.
// Update this file when the target game version changes.
namespace GameOffsets {

namespace GameFacade {
constexpr uintptr_t TypeInfo = 0xA3460EC;
constexpr uintptr_t StaticClass = 0x60;
constexpr uintptr_t CurrentMatch = 0x78;
constexpr uintptr_t MatchStatus = 0x8C;
constexpr uintptr_t LocalPlayer = 0xC0;
constexpr uintptr_t DictionaryEntities = 0x6C;
}

namespace Player {
constexpr uintptr_t IsDead = 0x78;
constexpr uintptr_t Name = 0x2A0;
constexpr uintptr_t Data = 0x70;
constexpr uintptr_t ShadowBase = 0x1A60;
constexpr uintptr_t XPose = 0x7C;
constexpr uintptr_t AvatarManager = 0x504;
constexpr uintptr_t Avatar = 0xB0;
constexpr uintptr_t AvatarIsVisible = 0x95;
constexpr uintptr_t AvatarData = 0x14;
constexpr uintptr_t AvatarDataIsTeam = 0x59;
constexpr uintptr_t ID = 0x260;
constexpr uintptr_t BaseProfileInfo = 0x1A74;
constexpr uintptr_t IsClientBot = 0x324;
}

namespace Camera {
constexpr uintptr_t MainCameraTransform = 0x28C;
constexpr uintptr_t FollowCamera = 0x494;
constexpr uintptr_t CameraObject = 0x18;
constexpr uintptr_t AimRotation = 0x440;
constexpr uintptr_t FollowCameraRightOffset = 0x6C;
constexpr uintptr_t FollowCameraUpOffset = 0x70;
constexpr uintptr_t FollowCameraVisionSpeed = 0x70;
constexpr uintptr_t ViewMatrix = 0xE8;
constexpr uintptr_t RightOffset = 0x44;
constexpr uintptr_t FOVOffset = 0x50;
constexpr uintptr_t BackOffset = 0x4C;
constexpr uintptr_t UpOffset = 0x48;
constexpr uintptr_t Phase1EulerAnglesY = 0x4C;
}

namespace Observer {
constexpr uintptr_t CurrentObserver = 0xB8;
constexpr uintptr_t ObserverPlayer = 0x28;
}

namespace Weapon {
constexpr uintptr_t Current = 0x434;
constexpr uintptr_t Data = 0x5C;
constexpr uintptr_t Recoil = 0xC;
constexpr uintptr_t UnknownPlayerWeaponInfoClass = 0x4EC;
constexpr uintptr_t IsCombineWeapon = 0xDC;
constexpr uintptr_t OnHand = 0x58;
constexpr uintptr_t CombineWeaponOnHand = 0x5C;
constexpr uintptr_t Info = 0x64;
constexpr uintptr_t ID = 0x14;
constexpr uintptr_t Reload = 0x98;
constexpr uintptr_t Ammo = 0x4D0;
constexpr uintptr_t OreonWu = 0x268;
constexpr uintptr_t FireColliders = 0x4F0;
constexpr uintptr_t SwapWeaponCooldown = 0x1FC;
constexpr uintptr_t LastAimingInfo = 0x87C;
constexpr uintptr_t IsFiring = 0x53D;
constexpr uintptr_t StartPosition = 0x38;
constexpr uintptr_t RayDirection = 0x2C;
constexpr uintptr_t LockedAimingCollider = 0x58;
constexpr uintptr_t Collider = 0x4E8;
}

namespace Attributes {
constexpr uintptr_t PlayerAttributes = 0x500;
constexpr uintptr_t NoReload = 0xC1;
constexpr uintptr_t RunSpeedUpScale = 0x210;
constexpr uintptr_t HealingIncreaseEnabled = 0x60;
constexpr uintptr_t HealingIncreaseRatio = 0x6C;
constexpr uintptr_t EatSpeedScale = 0x74;
constexpr uintptr_t DriveSpeedScale = 0x44;
constexpr uintptr_t FireScaleTwo = 0x194;
constexpr uintptr_t InfinitySkyler = 0x110;
constexpr uintptr_t GhostMode = 0x38;
constexpr uintptr_t Vida = 0x10;
constexpr uintptr_t MedikitFasterRate = 0x8C;
constexpr uintptr_t BuffDamage = 0xF8;
constexpr uintptr_t FireIntervalScaleSkill = 0x194;
}

namespace Timing {
constexpr uintptr_t GameTimer = 0x10;
constexpr uintptr_t GameVariables = 0xB4;
constexpr uintptr_t FixedDeltaTime = 0x24;
}

namespace Bones {
constexpr uintptr_t Head = 0x49C;
constexpr uintptr_t Neck = 0x4A4;
constexpr uintptr_t Hip = 0x4A0;
constexpr uintptr_t Pelvis = 0x4A8;
constexpr uintptr_t Root = 0x4B0;
constexpr uintptr_t LeftShoulder = 0x4D0;
constexpr uintptr_t RightShoulder = 0x4D4;
constexpr uintptr_t LeftElbow = 0x4E4;
constexpr uintptr_t RightElbow = 0x4E0;
constexpr uintptr_t LeftHand = 0x4DC;
constexpr uintptr_t RightHand = 0x4D8;
constexpr uintptr_t RightWrist = 0x4D8;
constexpr uintptr_t LeftWrist = 0x4DC;
constexpr uintptr_t LeftCalf = 0x4B4;
constexpr uintptr_t RightCalf = 0x4B4;
constexpr uintptr_t LeftFoot = 0x4C0;
constexpr uintptr_t RightFoot = 0x4C4;
constexpr uintptr_t LeftAnkle = 0x4B8;
constexpr uintptr_t RightAnkle = 0x4BC;
}

// IL2CPP collection/transform layout values retained from the original project.
namespace RuntimeLayout {
constexpr uintptr_t DictionaryEntries = 0x18;
constexpr uintptr_t DictionaryCount = 0x20;
constexpr uintptr_t ArrayData = 0x20;
constexpr uintptr_t DictionaryEntryStride = 0x18;
constexpr uintptr_t DictionaryEntryValue = 0x10;
constexpr uintptr_t TransformNode = 0x10;
constexpr uintptr_t TransformMatrix = 0x38;
constexpr uintptr_t TransformIndex = 0x40;
constexpr uintptr_t MatrixList = 0x18;
constexpr uintptr_t MatrixIndices = 0x20;
constexpr uintptr_t ManagedStringData = 0x14;
constexpr uintptr_t DataPoolObject = 0x10;
constexpr uintptr_t DataPoolArrayData = 0x20;
constexpr uintptr_t DataPoolEntryStride = 0x8;
constexpr uintptr_t DataPoolEntryValue = 0x18;
}

} // namespace GameOffsets

#endif
