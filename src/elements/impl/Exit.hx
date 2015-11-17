package elements.impl;
import flixel.FlxG;
import flixel.system.FlxSound;
import flixel.addons.editors.tiled.TiledObject;

class Exit extends Element implements Lightable {

  public static inline var OPEN_ANIMATION_KEY = "open";
  public static inline var CLOSE_ANIMATION_KEY = "close";
  public static inline var VICTORY_ANIMATION_KEY = "victory";

  private static inline var ANIMATION_SPEED = 10;

  public var isOpen(default, set) : Bool;

  public var isLit(default, null) : Bool;

  public var lightInDirection(default, null) : Array<Direction>;

  private var openCloseSound : FlxSound;

/** Constructs an exit, with the given level, and initial row and col */
  public function new(level : GameState, o : TiledObject) {
    super(level, o);
    isOpen = false;
    loadGraphic(AssetPaths.gate_sheet__png, true, PMain.SPRITE_SIZE, PMain.SPRITE_SIZE);
    animation.add(OPEN_ANIMATION_KEY, [0,2,4,5,6,8], ANIMATION_SPEED, false);
    animation.add(CLOSE_ANIMATION_KEY, [8,6,5,4,2,0], ANIMATION_SPEED, false);
    animation.add(VICTORY_ANIMATION_KEY, [9, 10, 3, 1, 8], ANIMATION_SPEED + 5, false);

    openCloseSound = FlxG.sound.load(AssetPaths.gateOpenClose__wav, 1.0);
    resetLightInDirection();
  }

  public function playVictoryAnimation() {
    animation.play(VICTORY_ANIMATION_KEY);
  }

  public function set_isOpen(open : Bool) : Bool {
    if(isOpen != open){
      if(open) {
        animation.play(OPEN_ANIMATION_KEY);
      } else {
        animation.play(CLOSE_ANIMATION_KEY);
      }
      openCloseSound.play(true);
    }
    return this.isOpen = open;
  }

  override public function update() {
    super.update();
  }

/** Returns true iff this is giving out light from the given side */
  public function isLightingTo(directionOut : Direction) : Bool {
    return false;
  }

/** Returns the directions light should be outputted if this is hit with light from the given direction */
  public function getReflection(directionIn : Direction) : Array<Direction> {
    return [];
  }

  public function resetLightInDirection() {
    lightInDirection = [];
  }

/** Set to Direction.None or null to turn off light */
  public function addLightInDirection(d : Direction) {
    if(d == null || d == Direction.None) {
      return;
    }
    lightInDirection.push(d);
  }
}
