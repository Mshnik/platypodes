package;

@:build(flixel.system.FlxAssets.buildFileReferences("assets/images/friends_release", true))
@:build(flixel.system.FlxAssets.buildFileReferences("assets/levels/friends_release", true))
@:build(flixel.system.FlxAssets.buildFileReferences("assets/music", true))
@:build(flixel.system.FlxAssets.buildFileReferences("assets/sounds", true))
class AssetPaths {

  /** The current root for images. Should change by version */
  @final static public var IMAGE_ROOT = "assets/images/newgrounds_release/";

}