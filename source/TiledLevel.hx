package ;
import elements.Character;
import openfl.Assets;
import haxe.io.Path;
import haxe.xml.Parser;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
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
  // For each "Tile Layer" in the map, you must define a "tileset" property which contains the name of a tile sheet image
  // used to draw tiles in that layer (without file extension). The image file must be located in the directory specified bellow.
  @final public inline static var c_PATH_LEVEL_TILESHEETS = "assets/images/";

  @final public inline static var FLOOR_LAYER_NAME = "Floor";
  @final public inline static var HOLE_LAYER_NAME = "Holes";
  @final public inline static var WALL_LAYER_NAME = "Walls";

  // Array of tilemaps used for collision
  public var floorTiles : FlxGroup;
  private var floorMap : FlxTilemap;
  public var holeTiles : FlxGroup;
  private var holeMap : FlxTilemap;
  public var wallTiles : FlxGroup;
  private var wallMap : FlxTilemap;

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
      var processedPath = c_PATH_LEVEL_TILESHEETS + imagePath.file + "." + imagePath.ext;

      var tilemap:FlxTilemap = new FlxTilemap();
      tilemap.widthInTiles = width;
      tilemap.heightInTiles = height;
      tilemap.loadMap(tileLayer.tileArray, processedPath, tileSet.tileWidth, tileSet.tileHeight, 0, 1, 1, 1);

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
    if (o.gid != -1)
      y -= g.map.getGidOwner(o.gid).tileHeight;

    processCallback(o, g, x, y);
  }

  public function collideWithLevel(obj:FlxObject, collideWithHoles : Bool = true, ?notifyCallback:FlxObject->FlxObject->Void, ?processCallback:FlxObject->FlxObject->Bool):Bool {

    // IMPORTANT: Always collide the map with objects, not the other way around.
    // 			  This prevents odd collision errors (collision separation code off by 1 px).
    var b = false;
    if (holeTiles != null && collideWithHoles) {
        b = FlxG.overlap(holeMap, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate) || b;
    }
    if (wallTiles != null) {
        b = FlxG.overlap(wallMap, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate) || b;
    }
    return b;
  }
}