package elements;
class Lighting
{
    private var light_trace:Array<Array<Int>>;
    public function new(){}
    public function trace(x,y,direction){
        Element e=getElementAt(x,y);
        if(e==null){
            light_trace[x][y]+=HV(direction);
            trace(x+direction.x,y+direction.y,direction);}
        else if(e=="mirror"){
            if(direction.equals(Direction.Right)){
                if(e.directionFacing.equals(Direction.Up_Left)){
                    trace(x,y+1,Direction.Up);}
                else if(e.directionFacing.equals(Direction.Down_Left)){
                    trace(x,y-1,Direction.Down);}}
            else if(direction.equals(Direction.Left)){
                if(e.directionFacing.equals(Direction.Up_Left)){
                    trace(x,y-1,Direction.Down);}
                else if(e.directionFacing.equals(Direction.Down_Left)){
                    trace(x,y+1,Direction.Up);}}
            else if(direction.equals(Direction.Up)){
                if(e.directionFacing.equals(Direction.Up_Left)){
                    trace(x+1,y,Direction.Right);}
                else if(e.directionFacing.equals(Direction.Up_Right)){
                    trace(x-1,y,Direction.Left);}}
            else if(direction.equals(Direction.Down)){
                if(e.directionFacing.equals(Direction.Up_Left)){
                    trace(x-1,y,Direction.Left);}
                else if(e.directionFacing.equals(Direction.Up_Right)){
                    trace(x+1,y,Direction.Right);}}}}}
