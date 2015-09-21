package ;

import elements.Character;
import elements.Direction;
import elements.Mirror;
import elements.Wall;


import sys.io.FileInput;

class Level extends AbsLevel{

    //Give the level a template. Use this after constructing a Level object but before calling create().
    //See README.TXT in assets/levels to see the schema for a level
    //path is the path of the .txt file. They should all be stored in /assets/levels



    public function setTemplate(path : String) : Void
    {
        var f = sys.io.File.read(path, false);
        set_rows(Std.parseInt(f.readLine()));
        set_cols(Std.parseInt(f.readLine()));
        

    }

    //Create the level
    override public function create():Void
    {
        super.create();
    }
}
