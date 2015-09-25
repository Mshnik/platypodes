package elements;
import flixel.addons.editors.tiled.TiledObject;
class Mirror extends Element {
  public function new(level : TiledLevel, x : Int, y : Int, o : TiledObject, ?img:Dynamic) {
    super(level, x, y, o, 0, img);
  }
}
