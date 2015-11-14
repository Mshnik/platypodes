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
  private var aKeySprite:FlxExtendedSprite; //A key CORRESPONDS TO CLOCKWISE ARROW
  private var dKeySprite:FlxExtendedSprite; //D key CORRESPONDS TO COUNTERCLOCKWISE ARROW
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
  private inline static var ARROW_SPRITE_SCALE = 0.7;
  private inline static var KEY_SPRITE_SCALE = 0.4;

/** A and D Key sprites **/
  private inline static var KEY_ANIMATION_SPEED = 7;
  private inline static var KEY_GLOW_ANIMATION_KEY = "glow";
  private inline static var KEY_SPRITE_SIZE = 150; //(unscaled)

  public function new(currGame:GameState) {
    super();
    this.visible = false;

    pullArrowButton = new FlxExtendedSprite();
    pullArrowButton.loadRotatedGraphic(PUSH_ARROW_PATH, 4); //Create 4 rotations for the push/pull arrow.
    pullArrowButton.scale.set(ARROW_SPRITE_SCALE, ARROW_SPRITE_SCALE);
    pullArrowButton.updateHitbox();
    pullArrowButton.centerOrigin();

    pushArrowButton = new FlxExtendedSprite();
    pushArrowButton.loadRotatedGraphic(PUSH_ARROW_PATH, 4);
    pushArrowButton.scale.set(ARROW_SPRITE_SCALE, ARROW_SPRITE_SCALE);
    pushArrowButton.updateHitbox();
    pushArrowButton.centerOrigin();

    cwArrowButton = new FlxExtendedSprite();
    cwArrowButton.loadRotatedGraphic(ROTATE_ARROW_PATH, 4); //Create 4 rotations for the rotate arrows
    cwArrowButton.scale.set(ARROW_SPRITE_SCALE, ARROW_SPRITE_SCALE);
    cwArrowButton.updateHitbox();
    cwArrowButton.centerOrigin();

    ccwArrowButton = new FlxExtendedSprite();
    ccwArrowButton.loadRotatedGraphic(ROTATE_ARROW_PATH, 4);
    ccwArrowButton.flipX = true;
    ccwArrowButton.scale.set(ARROW_SPRITE_SCALE, ARROW_SPRITE_SCALE);
    ccwArrowButton.updateHitbox();
    ccwArrowButton.centerOrigin();

    aKeySprite = new FlxExtendedSprite();
    aKeySprite.loadGraphic(A_KEY_SHEET, true, KEY_SPRITE_SIZE, KEY_SPRITE_SIZE, false);
    aKeySprite.scale.set(KEY_SPRITE_SCALE, KEY_SPRITE_SCALE);
    aKeySprite.animation.add(KEY_GLOW_ANIMATION_KEY, [0, 1, 2, 3], KEY_ANIMATION_SPEED);
    aKeySprite.updateHitbox();
    aKeySprite.centerOrigin();

    dKeySprite = new FlxExtendedSprite();
    dKeySprite.loadGraphic(Z_KEY_SHEET, true, KEY_SPRITE_SIZE, KEY_SPRITE_SIZE, false);
    dKeySprite.scale.set(KEY_SPRITE_SCALE, KEY_SPRITE_SCALE);
    dKeySprite.animation.add(KEY_GLOW_ANIMATION_KEY, [0, 1, 2, 3], KEY_ANIMATION_SPEED);
    dKeySprite.updateHitbox();
    dKeySprite.centerOrigin();

    if(! PMain.A_VERSION){
      pushArrowButton.enableMouseClicks(true);
      pullArrowButton.enableMouseClicks(true);
      ccwArrowButton.enableMouseClicks(true);
      cwArrowButton.enableMouseClicks(true);
      aKeySprite.enableMouseClicks(true);
      dKeySprite.enableMouseClicks(true);

      pullArrowButton.mousePressedCallback = pullMirrorCallback;
      pushArrowButton.mousePressedCallback = pushMirrorCallback;
      cwArrowButton.mouseReleasedCallback = rotateCWCallback;
      aKeySprite.mouseReleasedCallback = rotateCWCallback;
      ccwArrowButton.mouseReleasedCallback = rotateCCWCallback;
      dKeySprite.mouseReleasedCallback = rotateCCWCallback;
    }

    this.add(pullArrowButton);
    this.add(pushArrowButton);
    this.add(cwArrowButton);
    this.add(ccwArrowButton);
    this.add(aKeySprite);
    this.add(dKeySprite);

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
    aKeySprite.animation.play(KEY_GLOW_ANIMATION_KEY);
    dKeySprite.animation.play(KEY_GLOW_ANIMATION_KEY);

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
    if (d.equals(Direction.Right)) {
      cwArrowButton.setPosition(mBox.left, mBox.top - cwArrowButton.height);
      cwArrowButton.angle = 90;

      ccwArrowButton.setPosition(mBox.left, mBox.bottom);
      ccwArrowButton.angle = 270;

      aKeySprite.setPosition(cwArrowButton.x, cwArrowButton.y - aKeySprite.height);
      dKeySprite.setPosition(ccwArrowButton.x, ccwArrowButton.y + ccwArrowButton.height);
    } else if (d.equals(Direction.Left)) {
      ccwArrowButton.setPosition(mBox.right - ccwArrowButton.width, mBox.top - cwArrowButton.height);
      ccwArrowButton.angle = 90;

      cwArrowButton.setPosition(mBox.right - ccwArrowButton.width, mBox.bottom);
      cwArrowButton.angle = 270;

      aKeySprite.setPosition(cwArrowButton.x, cwArrowButton.y + cwArrowButton.height);
      dKeySprite.setPosition(ccwArrowButton.x, ccwArrowButton.y - dKeySprite.height);
    } else if (d.equals(Direction.Up)) {
      cwArrowButton.setPosition(mBox.left - cwArrowButton.width, mBox.bottom - cwArrowButton.height);
      cwArrowButton.angle = 0;

      ccwArrowButton.setPosition(mBox.right, mBox.bottom - ccwArrowButton.height);
      ccwArrowButton.angle = 0;

      aKeySprite.setPosition(cwArrowButton.x - aKeySprite.width, cwArrowButton.y);
      dKeySprite.setPosition(ccwArrowButton.x + ccwArrowButton.width, ccwArrowButton.y);
    } else {
      cwArrowButton.setPosition(mBox.right, mBox.top);
      cwArrowButton.angle = 180;

      ccwArrowButton.setPosition(mBox.left - ccwArrowButton.width, mBox.top);
      ccwArrowButton.angle = 180;

      aKeySprite.setPosition(cwArrowButton.x + cwArrowButton.width, cwArrowButton.y);
      dKeySprite.setPosition(ccwArrowButton.x - dKeySprite.width, ccwArrowButton.y);
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
