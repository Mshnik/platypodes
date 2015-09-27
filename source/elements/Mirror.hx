package elements;
import flixel.addons.editors.tiled.TiledObject;
class Mirror extends Element {

  private static inline var DEFAULT_SPRITE = AssetPaths.mirror_img__png;

  public var directionFacing : Direction;

  public function new(level : TiledLevel, x : Int, y : Int, o : TiledObject) {
    super(level, x, y, o, 0, DEFAULT_SPRITE);

    this.directionFacing = Direction.Up_Left;
  }
}
