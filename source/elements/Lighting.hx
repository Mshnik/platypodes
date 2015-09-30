package elements;
class Lighting
{
    private var vertical=2;
    private var horizontal=1;
    private var light_trace:Array<Array<Int>>;
    private var sx:Int;
    private var sy:Int;
    private var sd:Direction;
    public function new(xmax:Int,ymax:Int,sX:Int,sY:Int,sD:Direction){
        light_trace=new Array();
        for(x in 0...xmax+1){
            light_trace.push(new Array());
            for(y in 0...ymax+1){
                light_trace[x].push(0);}}
        sx=sX;
        sy=sY;
        sd=sD;
        draw_light();}
    public function redraw_light(){
        for(x in 0...light_trace.length){
            for(y in 0...light_trace[x].length){
                light_trace[x][y]=0;}}
        draw_light();}
    private function trace(x:Int,y:Int,direction:Direction):Void{
        var e:Element=GameState.getElementAt(x,y);
        if(e==null){
            light_trace[x][y]+=HV(direction);
            trace(x+direction.x,y+direction.y,direction);}
        else if(Std.is(e,Mirror)){
            // the mirror is assumed to only be one sided
            var m:Mirror=Std.instance(e,Mirror);
            if(direction.equals(Direction.Right)){
                if(m.directionFacing.equals(Direction.Up_Left)){
                    add_light(x,y,Direction.None);
                    trace(x,y+1,Direction.Up);}
                else if(m.directionFacing.equals(Direction.Down_Left)){
                    add_light(x,y,Direction.None);
                    trace(x,y-1,Direction.Down);}}
            else if(direction.equals(Direction.Left)){
                if(m.directionFacing.equals(Direction.Down_Right)){
                    add_light(x,y,Direction.None);
                    trace(x,y-1,Direction.Down);}
                else if(m.directionFacing.equals(Direction.Up_Right)){
                    add_light(x,y,Direction.None);
                    trace(x,y+1,Direction.Up);}}
            else if(direction.equals(Direction.Up)){
                if(m.directionFacing.equals(Direction.Down_Right)){
                    add_light(x,y,Direction.None);
                    trace(x+1,y,Direction.Right);}
                else if(m.directionFacing.equals(Direction.Down_Left)){
                    add_light(x,y,Direction.None);
                    trace(x-1,y,Direction.Left);}}
            else if(direction.equals(Direction.Down)){
                if(m.directionFacing.equals(Direction.Up_Left)){
                    add_light(x,y,Direction.None);
                    trace(x-1,y,Direction.Left);}
                else if(m.directionFacing.equals(Direction.Up_Right)){
                    add_light(x,y,Direction.None);
                    trace(x+1,y,Direction.Right);}}}}
    private function HV(direction:Direction):Int{
        if(direction.equals(Direction.Down)||direction.equals(Direction.Up)){
            return vertical;}
        else if(direction.equals(Direction.Left)||
                direction.equals(Direction.Right)){
            return horizontal;}
        else{ return -1;}}
    private function draw_light(){
        trace(sx+sd.x,sy+sd.y,sd);}
    public function check_light(x:Int,y:Int){
        //0:no light;-11:mirror lit up;1:horizontal only;2:vertical only;3:horizontal and vertical
        return light_trace[x][y];}
    private function add_light(x:Int,y:Int,direction:Direction):Void{
        if(direction.equals(Direction.None)){
            light_trace[x][y]=-1;
            return;}
        else if(direction.equals(Direction.Left)||
                direction.equals(Direction.Right)){
            if(light_trace[x][y]==0){
                light_trace[x][y]=1;
                return;}
            else if(light_trace[x][y]==2){
                light_trace[x][y]=3;
                return;}}
        else if(direction.equals(Direction.Up)||
                direction.equals(Direction.Down)){
            if(light_trace[x][y]==0){
                light_trace[x][y]=2;
                return;}
            else if(light_trace[x][y]==1){
                light_trace[x][y]=3;
                return;}}}
    private function light_exists(direction:Direction):Bool{
        //we shouldnt need this function until we implement crystal walls
        return false;}}