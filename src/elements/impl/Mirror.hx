package elements.impl;
import flixel.FlxG;
import flixel.system.FlxSound;
import openfl.Assets;
import flixel.addons.editors.tiled.TiledObject;

/** A mirror is a moveable element that reflects light.
 * It is tile locked, thus movement occurs in increments of tiles.
 * Each mirror has a reflective surface on either one or both of its sides, that
 * reflects light in 90 degree angles.
 **/
class Mirror extends AbsMirror {

  /** The sprite for an unlit one sided mirror */
  private static inline var UNLIT_SPRITE_ONE_SIDED = AssetPaths.mirror__png;

  /** The sprite for a lit one sided mirror */
  private static inline var LIT_SPRITE_ONE_SIDED = AssetPaths.mirror_reflection_1__png;

  /** Constructs a TopBar mirror belonging to the given game state and representing the given TiledObject */
  public function new(state : GameState, o : TiledObject) {
    super(state, o, UNLIT_SPRITE_ONE_SIDED);
  }

  public override function resetLightInDirection() {
    super.resetLightInDirection();
    isLit = false;
    loadGraphic(UNLIT_SPRITE_ONE_SIDED, false, Std.int(width), Std.int(height));
  }

  public override function addLightInDirection(d : Direction) {
    super.addLightInDirection(d);

    if (d.opposite().simpleDirec & directionFacing.simpleDirec != 0) {
      isLit = true;
      loadGraphic(LIT_SPRITE_ONE_SIDED, false, Std.int(width), Std.int(height));
    } else {
      isLit = false;
      loadGraphic(UNLIT_SPRITE_ONE_SIDED, false, Std.int(width), Std.int(height));
    }
  }

  public override function getReflection(directionIn : Direction) : Array<Direction> {
    var comD = directionIn.simpleString + " - " + directionFacing.simpleString;
    switch (comD) {
      case "Left - Up_Right": return [Direction.Up];
      case "Left - Down_Right" : return [Direction.Down];
      case "Up - Down_Left" : return [Direction.Left];
      case "Up - Down_Right" : return [Direction.Right];
      case "Right - Up_Left" : return [Direction.Up];
      case "Right - Down_Left" : return [Direction.Down];
      case "Down - Up_Right" : return [Direction.Right];
      case "Down - Up_Left" : return [Direction.Left];
      default: return [];
    }
  }
}
