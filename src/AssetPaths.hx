package;

@:build(flixel.system.FlxAssets.buildFileReferences("assets/images/newgrounds_release", true))
@:build(flixel.system.FlxAssets.buildFileReferences("assets/levels/newgrounds_release", true))
@:build(flixel.system.FlxAssets.buildFileReferences("assets/music", true))
@:build(flixel.system.FlxAssets.buildFileReferences("assets/sounds", true))
class AssetPaths {

  /** The current root for images. Should change by version */
  @final static public var IMAGE_ROOT = "assets/images/frineds_release/";

}