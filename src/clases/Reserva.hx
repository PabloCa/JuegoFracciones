package clases;

import luxe.Sprite;
import luxe.Color;
import luxe.Vector;

import ingameConfig.Config;


class Reserva extends Sprite
{
	public var listaFichas : Array<Sprite>;
	public var acum : Float = 0;
	private var altoFichas : Float = Config.altoFichas;
	private var recursos : Recursos;

	override function init():Void{
		listaFichas = new Array<Sprite>();
	}


	public function colocar(ancho : Float, color : Color):Bool{
		if(acum<this.size.x){
			listaFichas.push(
				new Sprite({
				pos: new phoenix.Vector(acum+ancho/2-this.size.x/2+this.pos.x,this.pos.y,0,0),
				color: color,
				size: new Vector(ancho, altoFichas), 
		    }));
		    acum=acum+ancho+1;
		    return true;
		}return false;
	    
	}


	public function quitarReserva(pos:Vector):Bool{
		for(i in 0...listaFichas.length){
			if(listaFichas[i].point_inside(pos)){
				listaFichas[listaFichas.length-1].destroy();
				listaFichas.pop();
				acum=acum-Config.fichas.tipos[0].ancho-1;
				return true;
			}
		}
		return false;
	}
}



