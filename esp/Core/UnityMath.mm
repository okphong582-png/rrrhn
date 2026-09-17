#import "UnityMath.h"
#import "GameOffsets.h"
#include <cmath>

#pragma mark - Function Unity

Vector3 WorldToScreen(Vector3 obj, float *matrix, float screenX, float screenY) {
    Vector3 screen;
    if (matrix == nullptr) return screen;
    float w = matrix[3] * obj.x + matrix[7] * obj.y + matrix[11] * obj.z + matrix[15];
    if (!std::isfinite(w) || w < 0.5f) return screen;
    
    float x = (screenX / 2) + (matrix[0] * obj.x + matrix[4] * obj.y + matrix[8] * obj.z + matrix[12]) / w * (screenX / 2);
    float y = (screenY / 2) - (matrix[1] * obj.x + matrix[5] * obj.y + matrix[9] * obj.z + matrix[13]) / w * (screenY / 2);
    if (!std::isfinite(x) || !std::isfinite(y)) return screen;
    screen.x = x;
    screen.y = y;
    screen.z = w;
    return screen;
}

bool getPositionExt(uint64_t transObj2, Vector3 &position) {
    position = Vector3::zero();
    if (!isVaildPtr(transObj2)) return false;
    // Original ARM64 Unity transform layout; not supplied by ofs.txt.
    uint64_t transObj = ReadAddr<uint64_t>(transObj2 + 0x10);
    if (!isVaildPtr(transObj)) return false;
    
    uint64_t matrix = ReadAddr<uint64_t>(transObj + 0x38);
    int32_t index = -1;
    if (!isVaildPtr(matrix) || !_read(transObj + 0x40, &index, sizeof(index))) return false;
    // Sanity limits prevent corrupt offsets/parent cycles from freezing the HUD.
    constexpr int32_t maxTransformCount = 65536;
    if (index < 0 || index >= maxTransformCount) return false;
    
    uint64_t matrix_list = ReadAddr<uint64_t>(matrix + 0x18);
    uint64_t matrix_indices = ReadAddr<uint64_t>(matrix + 0x20);
    if (!isVaildPtr(matrix_list) || !isVaildPtr(matrix_indices)) return false;
    
    Vector3 result;
    int32_t transformIndex = -1;
    if (!_read(matrix_list + sizeof(TMatrix) * index, &result, sizeof(result)) ||
        !_read(matrix_indices + sizeof(int32_t) * index, &transformIndex, sizeof(transformIndex))) return false;
    
    int depth = 0;
    while (transformIndex >= 0) {
        if (transformIndex >= maxTransformCount || depth++ >= 256) return false;
        TMatrix tMatrix{};
        if (!_read(matrix_list + sizeof(TMatrix) * transformIndex, &tMatrix, sizeof(tMatrix))) return false;
        
        float rotX = tMatrix.rotation.x;
        float rotY = tMatrix.rotation.y;
        float rotZ = tMatrix.rotation.z;
        float rotW = tMatrix.rotation.w;
        
        float scaleX = result.x * tMatrix.scale.x;
        float scaleY = result.y * tMatrix.scale.y;
        float scaleZ = result.z * tMatrix.scale.z;
        
        result.x = tMatrix.position.x + scaleX +
                    (scaleX * ((rotY * rotY * -2.0) - (rotZ * rotZ * 2.0))) +
                    (scaleY * ((rotW * rotZ * -2.0) - (rotY * rotX * -2.0))) +
                    (scaleZ * ((rotZ * rotX * 2.0) - (rotW * rotY * -2.0)));
        result.y = tMatrix.position.y + scaleY +
                    (scaleX * ((rotX * rotY * 2.0) - (rotW * rotZ * -2.0))) +
                    (scaleY * ((rotZ * rotZ * -2.0) - (rotX * rotX * 2.0))) +
                    (scaleZ * ((rotW * rotX * -2.0) - (rotZ * rotY * -2.0)));
        result.z = tMatrix.position.z + scaleZ +
                    (scaleX * ((rotW * rotY * -2.0) - (rotX * rotZ * -2.0))) +
                    (scaleY * ((rotY * rotZ * 2.0) - (rotW * rotX * -2.0))) +
                    (scaleZ * ((rotX * rotX * -2.0) - (rotY * rotY * 2.0)));
        
        if (!_read(matrix_indices + sizeof(int32_t) * transformIndex, &transformIndex, sizeof(transformIndex))) return false;
    }
    
    if (transformIndex != -1 || !std::isfinite(result.x) ||
        !std::isfinite(result.y) || !std::isfinite(result.z)) return false;
    position = result;
    return true;
}

NSString *GetNickName(uint64_t PawnObject) {
    uint64_t name = ReadAddr<uint64_t>(PawnObject + GameOffsets::Player_Name);
    
    UTF8 PlayerName[32] = "";
    UTF16 buf16[16] = {0};
    
    if (!_read(name + 0x14, buf16, 28)) return @"";
    Utf16_To_Utf8(buf16, PlayerName, 28, strictConversion);
    
    return [NSString stringWithUTF8String:(const char *)PlayerName];
}
