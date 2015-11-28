package;

@:build(flixel.system.FlxAssets.buildFileReferences("assets/images/kongregate_release", true))
@:build(flixel.system.FlxAssets.buildFileReferences("assets/levels/kongregate_release", true))
@:build(flixel.system.FlxAssets.buildFileReferences("assets/music", true))
@:build(flixel.system.FlxAssets.buildFileReferences("assets/sounds", true))
class AssetPaths {

  /** The current root for images. Should change by version */
  static public inline var IMAGE_ROOT = "assets/images/kongregate_release/";

}