package ;
import flixel.FlxBasic;
import haxe.io.Path;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectGroup;
import flixel.addons.editors.tiled.TiledTileSet;

/**
 * @author Samuel Batista
 */
class TiledLevel extends TiledMap {

  @final public inline static var FLOOR_LAYER_NAME = "Floor";
  @final public inline static var HOLE_LAYER_NAME = "Holes";
  @final public inline static var WALL_LAYER_NAME = "Walls";

  public var floorTiles : FlxGroup;
  private var floorMap : FlxTilemap;
  public var holeTiles : FlxGroup;
  private var holeMap : FlxTilemap;
  public var wallTiles : FlxGroup;
  private var wallMap : FlxTilemap;

  /** For non -1 gids, upper 4 bits are flags for flipping. Remove those bits for regular Gid */
  public static function fixGid(gid : Int) : Int {
    return gid == -1 ? -1 : gid & 0x3fffffff;
  }

  /** Does correct horizontal flipping detection. Built in cast doesn't handle non-1 true values correctly.
   * Use this instead of o.flippedHorizontally.
   **/
  public static function isFlippedX(o : TiledObject) : Bool {
    return o.gid != -1 && o.gid & TiledObject.FLIPPED_HORIZONTALLY_FLAG != 0;
  }

  /** Does correct horizontal flipping detection. Built in cast doesn't handle non-1 true values correctly.
   * Use this instead of o.flippedVertically.
   **/
  public static function isFlippedY(o : TiledObject) : Bool {
    return o.gid != -1 && o.gid & TiledObject.FLIPPED_VERTICALLY_FLAG != 0;
  }

  public function new(tiledLevel:Dynamic) {
    super(tiledLevel);

    floorTiles = new FlxGroup();
    holeTiles = new FlxGroup();
    wallTiles = new FlxGroup();

    FlxG.camera.setBounds(0, 0, fullWidth, fullHeight, true);

    // Load Tile Maps
    for (tileLayer in layers) {
      var tileSheetName:String = tileLayer.properties.get("tileset");

      if (tileSheetName == null)
        throw "'tileset' property not defined for the '" + tileLayer.name + "' layer. Please add the property to the layer.";

      var tileSet:TiledTileSet = null;
      for (ts in tilesets) {
        if (ts.name == tileSheetName) {
          tileSet = ts;
          break;
        }
      }

      if (tileSet == null)
        throw "Tileset '" + tileSheetName + " not found. Did you mispell the 'tilesheet' property in " + tileLayer.name + "' layer?";

      var imagePath = new Path(tileSet.imageSource);
      var processedPath = AssetPaths.IMAGE_ROOT + imagePath.file + "." + imagePath.ext;

      var tilemap:FlxTilemap = new FlxTilemap();
      tilemap.widthInTiles = width;
      tilemap.heightInTiles = height;
      var fixedArray = tileLayer.tileArray.map(function(i) {
        var v = tileSet.fromGid(i);
        return v >= 0 ? v : -1;
      });
      tilemap.loadMap(fixedArray, processedPath, tileSet.tileWidth, tileSet.tileHeight, 0, 1, 1, 1);

      switch(tileLayer.name) {
        case FLOOR_LAYER_NAME:
          floorTiles.add(tilemap);
          floorMap = tilemap;

        case HOLE_LAYER_NAME:
          holeTiles.add(tilemap);
          holeMap = tilemap;

        case WALL_LAYER_NAME:
          wallTiles.add(tilemap);
          wallMap = tilemap;

        default:
          throw "Unexpected tilelayer name " + tileLayer.name;
      }
    }
  }

  public function loadObjects(processCallback:TiledObject->TiledObjectGroup->Int->Int->Void) {
    for (group in objectGroups) {
      for (o in group.objects) {
        loadObject(o, group, processCallback);
      }
    }
  }

  private function loadObject(o:TiledObject, g:TiledObjectGroup, processCallback:TiledObject->TiledObjectGroup->Int->Int->Void) {
    var x:Int = o.x;
    var y:Int = o.y;

    // objects in tiled are aligned bottom-left (top-left in flixel)
    var gid = fixGid(o.gid);
    if (o.gid != -1) {
      y -= g.map.getGidOwner(gid).tileHeight;
    }

    processCallback(o, g, x, y);
  }

  public function collideWithLevel(objOrGroup:FlxBasic, collideWithHoles : Bool = true, ?notifyCallback:FlxObject->FlxObject->Void, ?processCallback:FlxObject->FlxObject->Bool):Bool {

    // IMPORTANT: Always collide the map with objects, not the other way around.
    // 			  This prevents odd collision errors (collision separation code off by 1 px).
    var b = false;
    if (holeTiles != null && collideWithHoles) {
        b = FlxG.overlap(holeMap, objOrGroup, notifyCallback, processCallback != null ? processCallback : FlxObject.separate) || b;
    }
    if (wallTiles != null) {
        b = FlxG.overlap(wallMap, objOrGroup, notifyCallback, processCallback != null ? processCallback : FlxObject.separate) || b;
    }
    return b;
  }

  public function hasFloorAt(x : Int, y : Int) : Bool {
    return floorMap.getTile(x,y) == -1;
  }

  public function hasHoleAt(x : Int, y : Int) : Bool {
    return holeMap.getTile(x,y) == -1;
  }

  public function hasWallAt(x : Int, y : Int) : Bool {
    return wallMap.getTile(x,y) == -1;
  }
}