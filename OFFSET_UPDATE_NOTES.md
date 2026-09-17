# Offset update notes

The values from the supplied `ofs.txt` are centralized in `esp/Core/GameOffsets.h`.

## Runtime paths used by the project

- Current match: `module base -> GameFacade TypeInfo -> StaticClass -> CurrentMatch`
- Local player: `current match -> LocalPlayer`
- Camera: `local player -> FollowCamera -> CameraObject`
- View matrix: `camera -> ViewMatrix`
- Entity collection: `current match -> DictionaryEntities`
- Player name: `player -> Name`
- Player ID/team: `player -> ID`
- HP data pool: `player -> Data`
- Box anchors: `player -> Head` and `player -> RightFoot`

## Important source-data notes

- The supplied list does not contain a `RightToe` field. The existing `getRightToeNode` API now uses `RightFoot` as the lower box anchor.
- `FollowCameraUpOffset` and `FollowCameraVisionSpeed` both use `0x70` in the supplied data.
- `LeftCalf` and `RightCalf` both use `0x4B4` in the supplied data.
- Collection and transform layout offsets were not present in `ofs.txt`; the project keeps its existing IL2CPP runtime-layout values in `GameOffsets::RuntimeLayout`.
- Offset values are version-specific and are not proof that a particular game build will work.
