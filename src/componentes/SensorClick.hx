package componentes;

import luxe.Component;
import luxe.Sprite;
import luxe.Input;
import luxe.Color;


class SensorClick extends Component {

	var sprite : Sprite;
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

    override public function onmousedown(event:MouseEvent):Void
    {
        if(isOver)
        {
            trace('el color es:'+sprite.color);
            seleccionado=true;
        }
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