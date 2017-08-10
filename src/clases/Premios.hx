package clases;

import luxe.Sprite;
import luxe.Color;
import luxe.Vector;
import luxe.Text;

import ingameConfig.Config;


class Premios
{

	private var posiciones : Array<Int>;
	private var textos : Array<Text>;
	public function new(){

		posiciones=new Array<Int>();
		textos=new Array<Text>();
		posiciones.push(1);

		for(i in 0...3){			
			anadirPremio();
		}
		for(i in 0...posiciones.length){
		    var geometry = Luxe.draw.box({
				x : 430, y : 520-(posiciones[i]*25),
				w : 100,
				h : 1,
				color : new Color().rgb(0xff8000)
		    });

		    dibujarFraccion(posiciones[i]);
		}


	}
	private function anadirPremio(){
		var random: Int = Luxe.utils.random.int(1,15);
		while(!comprobar(random)){
			random=Luxe.utils.random.int(1,15);
		}
		posiciones.push(random);
	}

	private function comprobar(r:Int):Bool{
		for(i in 0...posiciones.length){
			if(r==posiciones[i]||r-1==posiciones[i]||r+1==posiciones[i])return false;
		}
		return true;
	}

	private function dibujarFraccion(posicion:Float):Void{
		var nominador:Float=posicion;
		var denominador:Float=8;
		while(nominador%2==0){
			nominador=nominador/2;
			denominador=denominador/2;
		}
		//dibujando el nominador
		textos.push(new luxe.Text({
	        color : new Color(0,0,0,1).rgb(0x000000),
	        pos : new Vector(473,520-(posicion*25)-16),
	        font : Luxe.renderer.font,
	        point_size : 14,
	        text: nominador+''
	    }));

	    textos.push(new luxe.Text({
	        color : new Color(0,0,0,1).rgb(0x000000),
	        pos : new Vector(473,520-(posicion*25)-15),
	        font : Luxe.renderer.font,
	        point_size : 14,
	        text: '_'
	    }));

	    //dibujando denominador
	    textos.push(new luxe.Text({
	        color : new Color(0,0,0,1).rgb(0x000000),
	        pos : new Vector(473,520-(posicion*25)),
	        font : Luxe.renderer.font,
	        point_size : 14,
	        text: denominador+''
	    }));
	}

	public function preguntarPremio(fichas:Float):Bool{
		for(i in 0...posiciones.length){
			if(fichas==posiciones[i])return true;
		}
		return false;
	}

	
}



