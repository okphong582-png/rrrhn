#import "GameLogic.h"

#pragma mark - Function Game

uint64_t getMatchGame(uint64_t Moudule_Base) {
    uint64_t GameFacade_TypeInfo = ReadAddr<uint64_t>(Moudule_Base + GameOffsets::GameFacade::TypeInfo);
    return ReadAddr<uint64_t>(GameFacade_TypeInfo + GameOffsets::GameFacade::StaticClass);
}

uint64_t getMatch(uint64_t matchgame) {
    return ReadAddr<uint64_t>(matchgame + GameOffsets::GameFacade::CurrentMatch);
}

uint64_t CameraMain(uint64_t localPlayer) {
    uint64_t followCamera = ReadAddr<uint64_t>(localPlayer + GameOffsets::Camera::FollowCamera);
    return ReadAddr<uint64_t>(followCamera + GameOffsets::Camera::CameraObject);
}

float* GetViewMatrix(uint64_t cameraMain) {
    static float matrix[16];
    for (int i = 0; i < 16; i++) {
        matrix[i] = ReadAddr<float>(cameraMain + GameOffsets::Camera::ViewMatrix + i * sizeof(float));
    }
    
    return matrix;
}

uint64_t getTransNode(uint64_t BodyPart) {
    return ReadAddr<uint64_t>(BodyPart + GameOffsets::RuntimeLayout::TransformNode);
}

uint64_t getBoneNode(uint64_t player, uintptr_t boneOffset) {
    uint64_t BodyPart = ReadAddr<uint64_t>(player + boneOffset);
    return getTransNode(BodyPart);
}

uint64_t getHead(uint64_t player) {
    return getBoneNode(player, GameOffsets::Bones::Head);
}

uint64_t getRightToeNode(uint64_t player) {
    // The supplied list has no toe field; RightFoot is the closest bounding-box anchor.
    return getBoneNode(player, GameOffsets::Bones::RightFoot);
}

uint64_t getLocalPlayer(uint64_t match) {
    return ReadAddr<uint64_t>(match + GameOffsets::GameFacade::LocalPlayer);
}

bool isLocalTeamMate(uint64_t localPlayer, uint64_t Player) {
    COW_GamePlay_PlayerID_o myPlayerID = ReadAddr<COW_GamePlay_PlayerID_o>(localPlayer + GameOffsets::Player::ID);
    COW_GamePlay_PlayerID_o PlayerID = ReadAddr<COW_GamePlay_PlayerID_o>(Player + GameOffsets::Player::ID);
    
    int myTeamID = myPlayerID.m_TeamID;
    int TeamID = PlayerID.m_TeamID;
    
    return myTeamID == TeamID;
}

int GetDataUInt16(uint64_t player, int varID) {
    uint64_t IPRIDataPool = ReadAddr<uint64_t>(player + GameOffsets::Player::Data);
    if (isVaildPtr(IPRIDataPool)) {
        uint64_t v2 = ReadAddr<uint64_t>(IPRIDataPool + GameOffsets::RuntimeLayout::DataPoolObject);
        uint64_t v4 = ReadAddr<uint64_t>(v2
                    + GameOffsets::RuntimeLayout::DataPoolEntryStride * varID
                    + GameOffsets::RuntimeLayout::DataPoolArrayData);
        int v6 = ReadAddr<int>(v4 + GameOffsets::RuntimeLayout::DataPoolEntryValue);
        return v6;
    }
    return 0;
}

int get_CurHP(uint64_t Player) {
    return GetDataUInt16(Player, 0);
}

int get_MaxHP(uint64_t Player) {
    return GetDataUInt16(Player, 1);
}
