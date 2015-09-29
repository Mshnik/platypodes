package elements;
class Lighting
{
    private var vertical=2;
    private var horizontal=1;
    private var light_trace:Array<Array<Int>>;
    public function new(){}
    public function trace(x:Int,y:Int,direction:Direction):Void{
        var e:Element=GameState.getElementAt(x,y);
        if(e==null){
            light_trace[x][y]+=HV(direction);
            trace(x+direction.x,y+direction.y,direction);}
        else if(Std.is(e,Mirror)){
            var m:Mirror=Std.instance(e,Mirror);
            if(direction.equals(Direction.Right)){
                if(m.directionFacing.equals(Direction.Up_Left)){
                    trace(x,y+1,Direction.Up);}
                else if(m.directionFacing.equals(Direction.Down_Left)){
                    trace(x,y-1,Direction.Down);}}
            else if(direction.equals(Direction.Left)){
                if(m.directionFacing.equals(Direction.Up_Left)){
                    trace(x,y-1,Direction.Down);}
                else if(m.directionFacing.equals(Direction.Down_Left)){
                    trace(x,y+1,Direction.Up);}}
            else if(direction.equals(Direction.Up)){
                if(m.directionFacing.equals(Direction.Up_Left)){
                    trace(x+1,y,Direction.Right);}
                else if(m.directionFacing.equals(Direction.Up_Right)){
                    trace(x-1,y,Direction.Left);}}
            else if(direction.equals(Direction.Down)){
                if(m.directionFacing.equals(Direction.Up_Left)){
                    trace(x-1,y,Direction.Left);}
                else if(m.directionFacing.equals(Direction.Up_Right)){
                    trace(x+1,y,Direction.Right);}}}}
    private function HV(direction:Direction):Int{
        if(direction.equals(Direction.Down)||direction.equals(Direction.Up)){
            return vertical;}
        else{return horizontal;}}
    private function light_exists(direction:Direction):Int{

    }}