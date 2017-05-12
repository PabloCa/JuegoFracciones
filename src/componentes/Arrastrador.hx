package componentes;

import luxe.Component;
import luxe.Sprite;
import luxe.Input;


class Arrastrador extends Component {

	var sprite : Sprite;
	var meta : Sprite;
	var posicionMouse : luxe.Vector;
	var arrastrando : Bool = false;
	

    override function init() {
        sprite = cast entity;
    }

    override function onmousemove( event:MouseEvent ) {    	
        posicionMouse=event.pos;
    }


	public function setMeta( m:Sprite ) {
        meta=m;
    }

    override function update( delta:Float ){
    	if(posicionMouse!=null){
            if(sprite.point_inside(posicionMouse)) {
                if(Luxe.input.mousedown(luxe.MouseButton.left)) {
                    sprite.pos.x=posicionMouse.x;
                    sprite.pos.y=posicionMouse.y;
                    arrastrando=true;                                    
                }          
            }           
        }
        if(Luxe.input.mousereleased(luxe.MouseButton.left)){   

            if(arrastrando && meta.point_inside(posicionMouse)){
                sprite.pos.x=meta.pos.x;
                sprite.pos.y=meta.pos.y;

            }
            arrastrando=false;
        }
    }
}