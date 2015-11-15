package;
import logging.ActionElement;
import flixel.util.FlxPoint;
import flixel.addons.display.FlxExtendedSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxRect;
import flixel.FlxSprite;
import elements.*;
import elements.impl.*;

class Tooltip extends FlxGroup {

  private var game:GameState;

  private var cwArrowButton:FlxExtendedSprite; //clockwise Arrow
  private var ccwArrowButton:FlxExtendedSprite; //counter clock-wise arrow
  private var pullArrowButton:FlxExtendedSprite; //pull arrow
  private var pushArrowButton:FlxExtendedSprite; //push arrow
  private var pushMirrorDirection:Direction;
  private var pullMirrorDirection:Direction;

  /** Rotation arrow graphic **/
  private inline static var ROTATE_ARROW_PATH = AssetPaths.rotate_arrow__png; //clockwise

  /** Pull/push arrow graphic **/
  private inline static var PUSH_ARROW_PATH = AssetPaths.push_arrow__png; //pointing up


  /** Animated sheet for A  key (rotate clockwise) **/
  private inline static var A_KEY_SHEET = AssetPaths.contraleft__png;

  /** Animated sheet for Z key (rotate counterclockwise) **/
  private inline static var Z_KEY_SHEET = AssetPaths.contraright__png;

  /** Scale factor for arrow and key sprite images **/
  private inline static var A_VERSION_ARROW_SPRITE_SCALE = 0.9;

  /** A and D Key sprites **/
  private inline static var KEY_ANIMATION_SPEED = 7;
  private inline static var KEY_GLOW_ANIMATION_KEY = "glow";
  private inline static var KEY_SPRITE_SIZE = 150; //(unscaled)

  public function new(currGame:GameState) {
    super();
    this.visible = false;

    pullArrowButton = new FlxExtendedSprite();
    pullArrowButton.loadRotatedGraphic(PUSH_ARROW_PATH, 4); //Create 4 rotations for the push/pull arrow.
    if(PMain.A_VERSION)
    {
      pullArrowButton.scale.set(A_VERSION_ARROW_SPRITE_SCALE, A_VERSION_ARROW_SPRITE_SCALE);
    }
    pullArrowButton.updateHitbox();
    pullArrowButton.centerOrigin();

    pushArrowButton = new FlxExtendedSprite();
    pushArrowButton.loadRotatedGraphic(PUSH_ARROW_PATH, 4);
    if(PMain.A_VERSION)
    {
      pushArrowButton.scale.set(A_VERSION_ARROW_SPRITE_SCALE, A_VERSION_ARROW_SPRITE_SCALE);
    }
    pushArrowButton.updateHitbox();
    pushArrowButton.centerOrigin();

    cwArrowButton = new FlxExtendedSprite();
    cwArrowButton.loadRotatedGraphic(ROTATE_ARROW_PATH, 4); //Create 4 rotations for the rotate arrows
    if(PMain.A_VERSION)
    {
      cwArrowButton.scale.set(A_VERSION_ARROW_SPRITE_SCALE, A_VERSION_ARROW_SPRITE_SCALE);
    }
    cwArrowButton.updateHitbox();
    cwArrowButton.centerOrigin();

    ccwArrowButton = new FlxExtendedSprite();
    ccwArrowButton.loadRotatedGraphic(ROTATE_ARROW_PATH, 4);
    ccwArrowButton.flipX = true;
    if(PMain.A_VERSION)
    {
      ccwArrowButton.scale.set(A_VERSION_ARROW_SPRITE_SCALE, A_VERSION_ARROW_SPRITE_SCALE);
    }
    ccwArrowButton.updateHitbox();
    ccwArrowButton.centerOrigin();


    if(! PMain.A_VERSION){
      pushArrowButton.enableMouseClicks(true);
      pullArrowButton.enableMouseClicks(true);
      ccwArrowButton.enableMouseClicks(true);
      cwArrowButton.enableMouseClicks(true);

      pullArrowButton.mousePressedCallback = pullMirrorCallback;
      pushArrowButton.mousePressedCallback = pushMirrorCallback;
      cwArrowButton.mouseReleasedCallback = rotateCWCallback;
      ccwArrowButton.mouseReleasedCallback = rotateCCWCallback;
    }

    this.add(pullArrowButton);
    this.add(pushArrowButton);
    this.add(cwArrowButton);
    this.add(ccwArrowButton);

    game = currGame;


  }

  override public function update():Void {

    var player = game.player;
    var mirror = game.player.elmHolding;

    if ((mirror == null) || (player == null) || (mirror.holdingPlayer == null) || (mirror.moveDirection != Direction.None)) {
      this.visible = false;
      super.update();
      return;
    }

    this.visible = true;

    var mBox = mirror.getBoundingBox();
    var mWidthDiv2 = mBox.width/2;
    var mHeightDiv2 = mBox.height/2;

    if (player.getRow() == mirror.getRow()) {
      if (player.getCol() < mirror.getCol()) {
        //PLAYER TO THE LEFT OF MIRROR
        pullArrowButton.setPosition(player.x - pullArrowButton.width, mBox.top + pullArrowButton.height/2);
        pullArrowButton.angle = 270;
        pullMirrorDirection = Direction.Left;

        pushArrowButton.setPosition(mBox.right, mBox.top + pullArrowButton.height/2);
        pushArrowButton.angle = 90;
        pushMirrorDirection = Direction.Right;
      }
      else if (player.getCol() > mirror.getCol()) {

//PLAYER TO THE RIGHT OF MIRROR
        pullArrowButton.setPosition(player.x + player.width, mBox.top + pullArrowButton.height/2);
        pullArrowButton.angle = 90;
        pullMirrorDirection = Direction.Right;

        pushArrowButton.setPosition(mBox.left - pushArrowButton.width, mBox.top + pullArrowButton.height/2);
        pushArrowButton.angle = 270;
        pushMirrorDirection = Direction.Left;
      }
    }
    else if (player.getCol() == mirror.getCol()) {
      if (player.getRow() < mirror.getRow()) {
        //PLAYER ABOVE MIRROR
        pullArrowButton.setPosition(mBox.left + mWidthDiv2 - (pullArrowButton.width/2), player.y - player.offset.y - pullArrowButton.height);
        pullArrowButton.angle = 0;
        pullMirrorDirection = Direction.Up;

        pushArrowButton.setPosition(mBox.left + mWidthDiv2 - (pushArrowButton.width/2), mBox.bottom);
        pushArrowButton.angle = 180;
        pushMirrorDirection = Direction.Down;
      }
      else if (player.getRow() > mirror.getRow()) {
        //PLAYER BELOW MIRROR
        pullArrowButton.setPosition(mBox.left + mWidthDiv2 - (pullArrowButton.width/2), player.y + player.height);
        pullArrowButton.angle = 180;
        pullMirrorDirection = Direction.Down;

        pushArrowButton.setPosition(mBox.left+ mWidthDiv2 - (pushArrowButton.width/2), mBox.top - pushArrowButton.height);
        pushArrowButton.angle = 0;
        pushMirrorDirection = Direction.Up;
      }
    }
    configureRotateArrows(pushMirrorDirection, mBox);
    mBox.put();
    super.update();
  }

/** Configure the positions of the rotate arrows. If the player is horizontal to the mirror, horizontal = true.
    Otherwise, horizontal = false.***/

  private function configureRotateArrows(d:Direction, mBox : FlxRect):Void {
    var mirror = game.player.elmHolding;
    if (d.isHorizontal()) {
      cwArrowButton.setPosition(mBox.left, mBox.top - cwArrowButton.height);
      cwArrowButton.angle = 0;

      ccwArrowButton.setPosition(mBox.left, mBox.bottom);
      ccwArrowButton.angle = 180;

    } else if (d.isVertical()) {
      ccwArrowButton.setPosition(mBox.left - cwArrowButton.width, mBox.bottom - cwArrowButton.height);
      ccwArrowButton.angle = 270;

      cwArrowButton.setPosition(mBox.right, mBox.bottom - ccwArrowButton.height);
      cwArrowButton.angle = 90;
    }
  }

  private function pullMirrorCallback(obj:FlxExtendedSprite, x:Int, y:Int):Void {
    var mirror = game.player.elmHolding;
    if (mirror != null) {
      var pull:ActionElement = ActionElement.pushpull(game.player.getCol(), game.player.getRow(), game.player.directionFacing, mirror.getCol(), mirror.getRow(), pullMirrorDirection);
      game.executeAction(pull, true);
    }
  }

  private function pushMirrorCallback(obj:FlxExtendedSprite, x:Int, y:Int):Void {
    var mirror = game.player.elmHolding;
    if (mirror != null) {
      var pull:ActionElement = ActionElement.pushpull(game.player.getCol(), game.player.getRow(), game.player.directionFacing, mirror.getCol(), mirror.getRow(), pushMirrorDirection);
      game.executeAction(pull, true);
    }
  }


  private function rotateCWCallback(obj:FlxExtendedSprite, x:Int, y:Int):Void {
    var mirror = game.player.elmHolding;
    if (mirror != null) {
      var action:ActionElement = ActionElement.rotate(game.player.getCol(), game.player.getRow(), game.player.directionFacing, mirror.getCol(), mirror.getRow(), true);
      game.executeAction(action, true);
    }
  }

  private function rotateCCWCallback(obj:FlxExtendedSprite, x:Int, y:Int):Void {
    var mirror = game.player.elmHolding;
    if (mirror != null) {
      var action:ActionElement = ActionElement.rotate(game.player.getCol(), game.player.getRow(), game.player.directionFacing, mirror.getCol(), mirror.getRow(), false);
      game.executeAction(action, true);
    }
  }

}
