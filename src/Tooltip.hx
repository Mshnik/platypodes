package;
import flixel.FlxObject;
import flixel.util.FlxPoint;
import flixel.addons.display.FlxExtendedSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxRect;
import flixel.FlxSprite;
import flixel.FlxG;
import elements.Character;
import elements.Mirror;

class Tooltip extends FlxGroup {

    private var game : GameState;

    private var cwArrowButton : FlxExtendedSprite; //clockwise Arrow
    private var ccwArrowButton : FlxExtendedSprite; //counter clock-wise arrow
    private var pullArrowButton : FlxExtendedSprite; //pull arrow
    private var pushArrowButton : FlxExtendedSprite; //push arrow
    private var aKeySprite : FlxExtendedSprite; //A key CORRESPONDS TO CLOCKWISE ARROW
    private var zKeySprite : FlxExtendedSprite; //Z key CORRESPONDS TO COUNTERCLOCKWISE ARROW

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

    /** A and Z Key sprites **/
    private inline static var KEY_ANIMATION_SPEED = 7;
    private inline static var KEY_GLOW_ANIMATION_KEY = "glow";
    private inline static var KEY_SPRITE_SIZE = 150; //(unscaled)

    /** THE PIXELS OF SPACE BETWEEN EACH PIECE OF THE TOOL TIP **/
    private inline static var PIXEL_SPACE_LARGE = 100;
    private inline static var PIXEL_SPACE_SMALL = 50;


    public function new(currGame : GameState) {
        super();
        this.visible = false;


        pullArrowButton = new FlxExtendedSprite();
        pullArrowButton.enableMouseClicks(true);
        pullArrowButton.loadRotatedGraphic(PUSH_ARROW_PATH, 4); //Create 4 rotations for the push/pull arrow.
        pullArrowButton.scale.set(ARROW_SPRITE_SCALE, ARROW_SPRITE_SCALE);

        pushArrowButton = new FlxExtendedSprite();
        pushArrowButton.enableMouseClicks(true);
        pushArrowButton.loadRotatedGraphic(PUSH_ARROW_PATH, 4);
        pushArrowButton.scale.set(ARROW_SPRITE_SCALE, ARROW_SPRITE_SCALE);

        cwArrowButton = new FlxExtendedSprite();
        cwArrowButton.enableMouseClicks(true);
        cwArrowButton.loadRotatedGraphic(ROTATE_ARROW_PATH, 4); //Create 4 rotations for the rotate arrows
        cwArrowButton.scale.set(ARROW_SPRITE_SCALE, ARROW_SPRITE_SCALE);
        cwArrowButton.mouseReleasedCallback = rotateCW;

        ccwArrowButton = new FlxExtendedSprite();
        ccwArrowButton.enableMouseClicks(true);
        ccwArrowButton.loadRotatedGraphic(ROTATE_ARROW_PATH, 4);
        ccwArrowButton.flipX = true;
        ccwArrowButton.scale.set(ARROW_SPRITE_SCALE, ARROW_SPRITE_SCALE);
        ccwArrowButton.mouseReleasedCallback = rotateCCW;

        aKeySprite = new FlxExtendedSprite();
        aKeySprite.enableMouseClicks(true);
        aKeySprite.loadGraphic(A_KEY_SHEET, true, KEY_SPRITE_SIZE, KEY_SPRITE_SIZE, false);
        aKeySprite.scale.set(KEY_SPRITE_SCALE, KEY_SPRITE_SCALE);
        aKeySprite.animation.add(KEY_GLOW_ANIMATION_KEY,[0,1,2,3], KEY_ANIMATION_SPEED);
        aKeySprite.mouseReleasedCallback = rotateCW;

        zKeySprite  = new FlxExtendedSprite();
        zKeySprite.enableMouseClicks(true);
        zKeySprite.loadGraphic(Z_KEY_SHEET, true,  KEY_SPRITE_SIZE, KEY_SPRITE_SIZE, false);
        zKeySprite.scale.set(KEY_SPRITE_SCALE, KEY_SPRITE_SCALE);
        zKeySprite.animation.add(KEY_GLOW_ANIMATION_KEY, [0, 1, 2, 3], KEY_ANIMATION_SPEED);
        zKeySprite.mouseReleasedCallback = rotateCCW;

        this.add(pullArrowButton);
        this.add(pushArrowButton);
        this.add(cwArrowButton);
        this.add(ccwArrowButton);
        this.add(aKeySprite);
        this.add(zKeySprite);


        game = currGame;


    }

    override public function update():Void {

        var player = game.player;
        var mirror = game.player.mirrorHolding;

        if((mirror == null) || (player == null) || (Character.IS_MOVEMENT_KEY_PRESSED()) || (mirror.holdingPlayer == null)){
            this.visible = false;
            super.update();
            return;
        }

        this.visible = true;
        aKeySprite.animation.play(KEY_GLOW_ANIMATION_KEY);
        zKeySprite.animation.play(KEY_GLOW_ANIMATION_KEY);

        if(player.getRow() == mirror.getRow()){
            if(player.getCol() < mirror.getCol()){
                //PLAYER TO THE LEFT OF MIRROR

                pullArrowButton.setPosition(player.x - PIXEL_SPACE_LARGE, mirror.y);
                pullArrowButton.angle = 270;
                pullArrowButton.mouseReleasedCallback = pullFromLeft;

                pushArrowButton.setPosition(mirror.x + PIXEL_SPACE_LARGE, mirror.y);
                pushArrowButton.angle = 90;
                pushArrowButton.mouseReleasedCallback = pushFromLeft;

                configureRotateArrows(true);


            }
            else if (player.getCol() > mirror.getCol()){

                //PLAYER TO THE RIGHT OF MIRROR

                pullArrowButton.setPosition(player.x + PIXEL_SPACE_LARGE, mirror.y);
                pullArrowButton.angle = 90;
                pullArrowButton.mouseReleasedCallback = pullFromRight;

                pushArrowButton.setPosition(mirror.x - PIXEL_SPACE_LARGE, mirror.y);
                pushArrowButton.angle = 270;
                pushArrowButton.mouseReleasedCallback = pushFromRight;

                configureRotateArrows(true);

            }
        }
        else if (player.getCol() == mirror.getCol()){
            if(player.getRow() < mirror.getRow()){
                //PLAYER ABOVE MIRROR
                pullArrowButton.setPosition(mirror.x, player.y - PIXEL_SPACE_LARGE);
                pullArrowButton.angle = 0;
                pullArrowButton.mouseReleasedCallback = pullFromAbove;

                pushArrowButton.setPosition(mirror.x, mirror.y + PIXEL_SPACE_LARGE);
                pushArrowButton.angle = 180;
                pushArrowButton.mouseReleasedCallback = pushFromAbove;

                configureRotateArrows(false);

            }
            else if (player.getRow() > mirror.getRow()){
                //PLAYER BELOW MIRROR

                pullArrowButton.setPosition(mirror.x, player.y + PIXEL_SPACE_LARGE);
                pullArrowButton.angle = 180;
                pullArrowButton.mouseReleasedCallback = pullFromBelow;

                pushArrowButton.setPosition(mirror.x, mirror.y - PIXEL_SPACE_LARGE);
                pushArrowButton.angle = 0;
                pushArrowButton.mouseReleasedCallback = pushFromBelow;


                configureRotateArrows(false);

            }
        }
        super.update();
    }

    /** Configure the positions of the rotate arrows. If the player is horizontal to the mirror, horizontal = true.
    Otherwise, horizontal = false.***/
    private function configureRotateArrows(horizontal: Bool) : Void{
        var mirror = game.player.mirrorHolding;
        if(horizontal){
            cwArrowButton.setPosition(mirror.x, mirror.y - PIXEL_SPACE_LARGE);
            cwArrowButton.angle = 90;

            ccwArrowButton.setPosition(mirror.x, mirror.y + PIXEL_SPACE_LARGE);
            ccwArrowButton.angle= 270;

            aKeySprite.setPosition(mirror.x, cwArrowButton.y - PIXEL_SPACE_LARGE);
            zKeySprite.setPosition(mirror.x, ccwArrowButton.y + PIXEL_SPACE_SMALL);
        }
        else{
            cwArrowButton.setPosition(mirror.x - PIXEL_SPACE_LARGE, mirror.y);
            cwArrowButton.angle = 0;

            ccwArrowButton.setPosition(mirror.x + PIXEL_SPACE_LARGE, mirror.y);
            ccwArrowButton.angle = 0;

            aKeySprite.setPosition(cwArrowButton.x - PIXEL_SPACE_SMALL, mirror.y);
            zKeySprite.setPosition(ccwArrowButton.x + PIXEL_SPACE_SMALL, mirror.y);


        }
    }

    private function pullFromLeft(obj:FlxExtendedSprite, x: Int, y: Int) : Void{
            //TODO
    }

    private function pullFromRight(obj:FlxExtendedSprite, x: Int, y: Int) : Void{

    }

    private function pullFromAbove(obj:FlxExtendedSprite, x: Int, y: Int) : Void{

    }

    private function pullFromBelow(obj:FlxExtendedSprite, x: Int, y: Int) : Void{

    }

    private function pushFromLeft(obj:FlxExtendedSprite, x: Int, y: Int) : Void{

    }

    private function pushFromRight(obj:FlxExtendedSprite, x: Int, y: Int) : Void{

    }

    private function pushFromAbove(obj:FlxExtendedSprite, x: Int, y: Int) : Void{

    }

    private function pushFromBelow(obj:FlxExtendedSprite, x: Int, y: Int) : Void{

    }

    private function rotateCW(obj :FlxExtendedSprite, x: Int, y: Int) : Void{
        trace("HOWDY");
        var mirror = game.player.mirrorHolding;
        if (mirror != null){
            mirror.rotateClockwise();
        }
    }

    private function rotateCCW(obj :FlxExtendedSprite, x: Int, y: Int) : Void{
        var mirror = game.player.mirrorHolding;
        if (mirror != null){
            mirror.rotateCounterClockwise();
        }
    }

}
