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
  private static inline var UNLIT_SPRITE_ONE_SIDED = AssetPaths.light_sheet_0_2__png;

  /** The sprite for a lit one sided mirror */
  private static inline var LIT_SPRITE_ONE_SIDED = AssetPaths.light_sheet_1_2__png;

  /** Constructs a TopBar mirror belonging to the given game state and representing the given TiledObject */
  public function new(state : GameState, o : TiledObject) {
    super(state, o, UNLIT_SPRITE_ONE_SIDED);
  }

  /** Sets the value of isLit. Updates the sprite to reflect the TopBar lit status */
  public function set_isLit(lit : Bool) : Bool {
    if(lit) {
      loadGraphic(LIT_SPRITE_ONE_SIDED, false, Std.int(width), Std.int(height));
    } else {
      loadGraphic(UNLIT_SPRITE_ONE_SIDED, false, Std.int(width), Std.int(height));
    }
    return this.isLit = lit;
  }

  public override function getReflection(directionIn : Direction) : Array<Direction> {
    var comD = directionIn.simpleString + " - " + directionFacing.simpleString;
    switch (comD) {
      case "Left - Up_Left": return [Direction.Up];
      case "Left - Down_Left" : return [Direction.Down];
      case "Up - Up_Left" : return [Direction.Left];
      case "Up - Up_Right" : return [Direction.Right];
      case "Right - Up_Right" : return [Direction.Up];
      case "Right - Down_Right" : return [Direction.Down];
      case "Down - Down_Right" : return [Direction.Right];
      case "Down - Down_Left" : return [Direction.Left];
      default: return [];
    }
  }
}
