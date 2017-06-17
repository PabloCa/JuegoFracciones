package componentes;

import luxe.Component;
import luxe.Sprite;
import luxe.Input;


class Arrastrador extends Component {

	var sprite : Sprite;
	var posicionMouse : luxe.Vector;
	var arrastrando : Bool = true;

    override function init() {
        sprite = cast entity;
    }

    override function onmousemove( event:MouseEvent ) {    	
        if(arrastrando){
            sprite.pos.x=normalizarX(event.x);
            sprite.pos.y=normalizarY(event.y);
        }
    }


    override public function onmousedown(event:MouseEvent):Void
    {
        if(posicionMouse!=null){
            if(sprite.point_inside(posicionMouse)) {
                arrastrando=true;
            }
        }
    }
    override public function onmouseup(event:MouseEvent):Void
    {
        arrastrando=false;
    }

    function normalizarX(x: Float):Float{
        if(x<0)return 0;
        if(x>Luxe.screen.w)return Luxe.screen.w-1;
        return x;
    }

    function normalizarY(y: Float):Float{
        if(y<0)return 0;
        if(y>Luxe.screen.h)return Luxe.screen.h-1;
        return y;
    }
}