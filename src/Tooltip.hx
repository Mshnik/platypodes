package;
import flixel.group.FlxGroup;
import flixel.util.FlxRect;
import flixel.addons.editors.tiled.TiledObject;
import flixel.util.FlxStringUtil;
import flixel.ui.FlxButton;
import elements.Character;
import elements.Mirror;

class Tooltip extends FlxGroup {

    private var game : GameState;

    private var cwArrowButton : FlxButton; //clockwise Arrow
    private var ccwArrowButton : FlxButton; //counter clock-wise arrow
    private var pullArrowButton : FlxButton; //pull arrow
    private var pushArrowButton : FlxButton; //push arrow
    private var aKeyButton : FlxButton; //A key CORRESPONDS TO CLOCKWISE ARROW
    private var zKeyButton : FlxButton; //Z key CORRESPONDS TO COUNTERCLOCKWISE ARROW

    /** Rotation arrow graphic **/
    private inline static var ROTATE_ARROW_PATH = AssetPaths.rotate_arrow__png; //clockwise

    /** Pull/push arrow graphic **/
    private inline static var PUSH_ARROW_PATH = AssetPaths.push_arrow__png; //pointing up

    /** Animated sheet for A  key (rotate clockwise) **/
    private inline static var A_KEY_SHEET = AssetPaths.contraleft__png;

    /** Animated sheet for Z key (rotate counterclockwise) **/
    private inline static var Z_KEY_SHEET = AssetPaths.contraright__png;

    /** The speed for glowing animatino of the keys **/
    private inline static var KEY_ANIMATION_SPEED = 7;
    private inline static var KEY_SPRITE_SIZE = 128; //(unscaled)

    /** THE PIXELS OF SPACE BETWEEN EACH PIECE OF THE TOOL TIP **/
    private inline static var PIXEL_SPACE = 15;


    public function new(currGame : GameState) {
        super();
        //Keep it invisible first
        this.visible = false;
        //Four possible configurations: Player is [above, below, left of, right of] mirror.
        game = currGame;


    }

    override public function update():Void {

        var player = game.player;
        var mirror = game.player.mirrorHolding;

        if((mirror == null) || (player == null) || (mirror.destTile != null)){
            this.visible = false;
            super.update();
            return;
        }

        this.visible = true;
        this.clear();

        if(player.getRow() == mirror.getRow()){
            if(player.getCol() < mirror.getCol()){
                //LEFT OF
                pullArrowButton = new FlxButton(player.x - PIXEL_SPACE, player.y);
                pullArrowButton.loadRotatedGraphic(PUSH_ARROW_PATH, 4); //Create 4 rotations for the arrow.
                pullArrowButton.x = player.x - PIXEL_SPACE;
                pullArrowButton.y = player.y;
                this.add(pullArrowButton);

            }
            else if (player.getCol() > mirror.getCol()){
                //RIGHT OF
            }
        }
        else if (player.getCol() == mirror.getCol()){
            if(player.getRow() < mirror.getRow()){
                //ABOVE

            }
            else if (player.getRow() > mirror.getRow()){
                //BELOW


            }
        }
        super.update();
    }
}
