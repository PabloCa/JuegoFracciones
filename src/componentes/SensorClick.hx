package componentes;

import luxe.Component;
import luxe.Sprite;
import luxe.Input;
import luxe.Color;
import luxe.Vector;


class SensorClick extends Component {

    var sprite : Sprite;
	var fondo : Sprite;
    var setColorDefault : Color;
    var isOver:Bool = false;
    var seleccionado:Bool = false;

    override function init() {
        sprite = cast entity;        
    }

    override public function onmousemove(event:MouseEvent):Void
    {
        if( sprite.point_inside(event.pos) && !isOver )
        {
            onover();
        }
        if( !sprite.point_inside(event.pos) && isOver )
        {
            onout();
        }
    }

    public function colorInicial(col:Color):Void{
        setColorDefault=col;
    }

    override public function onmousedown(event:MouseEvent):Void
    {
        if(isOver)
        {   
            if(seleccionado){
                quitarSeleccion();
            }else{
                ponerSeleccion();
            }       
        }
    }

    public function ponerSeleccion():Void{
        seleccionado=true;
    }

    public function quitarSeleccion():Void{
        seleccionado = false;
    }


    function onover():Void
    {
        isOver = true;
        //overcolor
    }


    function onout():Void
    {
        isOver = false;
        //color normal
    }

    function estaSeleccionado():Bool
    {
        return seleccionado;
    }
}