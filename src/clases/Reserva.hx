package clases;

import luxe.Sprite;
import luxe.Color;
import luxe.Vector;

import ingameConfig.Config;


class Reserva extends Sprite
{
	public var listaFichas : Array<Sprite>;
	public var acum : Float = 0;
	private var anchoFichas : Float = Config.anchoFichas;
	private var recursos : Recursos;

	override function init():Void{
		listaFichas = new Array<Sprite>();
	}


	public function colocar(alto : Float, color : Color, turno:Int):Bool{
		if(acum<this.size.y){
			listaFichas.push(
				new Sprite({
				texture: Config.imagenes.orientacion[turno-1].alto[0].imagen,
				pos: new phoenix.Vector(this.pos.x,this.pos.y+this.size.y/2-acum-alto/2,0,0),
				size: new Vector(anchoFichas, alto), 
		    }));
		    acum=acum+alto+1;
		    return true;
		}return false;
	    
	}


	public function quitarReserva(pos:Vector):Bool{
		for(i in 0...listaFichas.length){
			if(listaFichas[i].point_inside(pos)){
				listaFichas[listaFichas.length-1].destroy();
				listaFichas.pop();
				acum=acum-Config.fichas.tipos[0].alto-1;
				return true;
			}
		}
		return false;
	}
	public function eliminarTodo(){
		for(i in 0...listaFichas.length){
			if(listaFichas[i].point_inside(pos)){
				listaFichas[i].destroy();
			}
		}
		listaFichas=null;
		this.destroy();
	}
}



