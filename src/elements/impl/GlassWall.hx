package elements.impl;
import flixel.addons.editors.tiled.TiledObject;
class GlassWall extends Element implements Lightable{

  private static inline var SPR_ANIMATION = "spr";

  private static inline var FIRST_GID = 93; //First GID of a wall tile. Should be kept up to date

  /** The variable that denotes lighting status. Get access must be public, but set can or can not be */
  public var isLit(default, set) : Bool;

  /** The direction this is lit from. Set whenever lighting is recalculated */
  public var lightInDirection(default, null) : Array<Direction>;

  public function new(level : GameState, o : TiledObject) {
    super(level, o);
    isLit = false;

    loadGraphic(AssetPaths.glass_wall_sheet__png, true, PMain.SPRITE_SIZE, PMain.SPRITE_SIZE);
    animation.add(SPR_ANIMATION, [gID  - FIRST_GID], 0, false);
    animation.play(SPR_ANIMATION);
  }

  public function set_isLit(lit : Bool) {
    if(lit) {
      loadGraphic(AssetPaths.light_wall_sheet__png, true, PMain.SPRITE_SIZE, PMain.SPRITE_SIZE);
      animation.play(SPR_ANIMATION);
    } else {
      loadGraphic(AssetPaths.glass_wall_sheet__png, true, PMain.SPRITE_SIZE, PMain.SPRITE_SIZE);
      animation.play(SPR_ANIMATION);
    }
    return this.isLit = lit;
  }

  /** Resets the lightInDirection to an empty array */
  public function resetLightInDirection() {
    lightInDirection = [];
    isLit = false;
  }

/** Adds the given direction to the lightInDirection */
  public function addLightInDirection(d : Direction) {
    if(d == null || d.equals(Direction.None)) return;
    lightInDirection.push(d);
    isLit = true;
  }

/** Returns true iff this is giving out light from the given side */
  public function isLightingTo(directionOut : Direction) {
    for(d in lightInDirection) {
      if(d.opposite().equals(directionOut)) {
        return true;
      }
    }
    return false;
  }

/** Returns the directions light should be outputted if this is hit with light from the given direction */
  public function getReflection(directionIn : Direction) {
    if (directionIn == null || directionIn.equals(Direction.None)) {
      return [];
    } else {
      return [directionIn.opposite()];
    }
  }
}
