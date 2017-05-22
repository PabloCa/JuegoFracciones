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
        posicionMouse=event.pos;
    }


    override function update( delta:Float ){
    	if(posicionMouse!=null){
            if(sprite.point_inside(posicionMouse)) {
                if(Luxe.input.mousedown(luxe.MouseButton.left)) {

                    sprite.pos.x=normalizarX(posicionMouse.x);
                    sprite.pos.y=normalizarY(posicionMouse.y);
                    arrastrando=true;                                    
                }          
            }           
        }

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