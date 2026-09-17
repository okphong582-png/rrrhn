#import "GameLogic.h"

#pragma mark - Function Game

uint64_t getMatchGame(uint64_t Moudule_Base) {
    uint64_t GameFacade_TypeInfo = ReadAddr<uint64_t>(Moudule_Base + GameOffsets::GameFacade_TypeInfo);
    uint64_t GameFacade_Static = ReadAddr<uint64_t>(GameFacade_TypeInfo + GameOffsets::StaticClass);
    return ReadAddr<uint64_t>(GameFacade_Static + 0x0);
}

uint64_t getMatch(uint64_t matchgame) {
    return ReadAddr<uint64_t>(matchgame + GameOffsets::CurrentMatch);
}

uint64_t CameraMain(uint64_t localPlayer) {
    // ofs.txt supplies the player FollowCamera chain, not the old match-game
    // CameraControllerManager field. Validate this chain on the target build.
    uint64_t followCamera = ReadAddr<uint64_t>(localPlayer + GameOffsets::FollowCamera);
    return ReadAddr<uint64_t>(followCamera + GameOffsets::Camera);
}

float* GetViewMatrix(uint64_t cameraMain) {
    // Native Unity camera pointer: original ARM64 layout, not in ofs.txt.
    uint64_t v1 = ReadAddr<uint64_t>(cameraMain + 0x10);
    
    static float matrix[16];
    if (!_read(v1 + GameOffsets::ViewMatrix, matrix, sizeof(matrix))) return nullptr;
    
    return matrix;
}

uint64_t getTransNode(uint64_t BodyPart) {
    return ReadAddr<uint64_t>(BodyPart + 0x10);
}

uint64_t getHead(uint64_t player) {
    uint64_t BodyPart = ReadAddr<uint64_t>(player + GameOffsets::Head);
    return getTransNode(BodyPart);
}

uint64_t getRightFoot(uint64_t player) {
    uint64_t BodyPart = ReadAddr<uint64_t>(player + GameOffsets::RightFoot);
    return getTransNode(BodyPart);
}

uint64_t getLocalPlayer(uint64_t match) {
    return ReadAddr<uint64_t>(match + GameOffsets::LocalPlayer);
}

bool isLocalTeamMate(uint64_t localPlayer, uint64_t Player) {
    COW_GamePlay_PlayerID_o myPlayerID{};
    COW_GamePlay_PlayerID_o PlayerID{};
    // Skip entities whose team cannot be read instead of comparing invented IDs.
    if (!_read(localPlayer + GameOffsets::PlayerID, &myPlayerID, sizeof(myPlayerID)) ||
        !_read(Player + GameOffsets::PlayerID, &PlayerID, sizeof(PlayerID))) return true;
    
    int myTeamID = myPlayerID.m_TeamID;
    int TeamID = PlayerID.m_TeamID;
    
    return myTeamID == TeamID;
}

int GetDataUInt16(uint64_t player, int varID) {
    // Keep the original pool layout; ofs.txt only supplies the outer field.
    uint64_t IPRIDataPool = ReadAddr<uint64_t>(player + GameOffsets::Player_Data);
    if (isVaildPtr(IPRIDataPool)) {
        uint64_t v2 = ReadAddr<uint64_t>(IPRIDataPool + 0x10);
        uint64_t v4 = ReadAddr<uint64_t>(v2 + 0x8 * varID + 0x20);
        int v6 = ReadAddr<int>(v4 + 0x18);
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
