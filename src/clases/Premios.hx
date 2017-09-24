package clases;

import luxe.Sprite;
import luxe.Color;
import luxe.Vector;
import luxe.Text;

import ingameConfig.Config;


class Premios
{

	private var posiciones : Array<Int>;
	private var fueUsadoPista1: Array<Bool>;
	private var fueUsadoPista2 : Array<Bool>;
	private var textos : Array<Text>;
	private var martillosl: Array<Sprite>;
	private var martillosr: Array<Sprite>;
	private var lineas: Array<Sprite>;
	public var premioMerecido: Bool=false;


	public function new(){

		posiciones=new Array<Int>();
		textos=new Array<Text>();
		fueUsadoPista1=new Array<Bool>();
		martillosl=new Array<Sprite>();
		martillosr=new Array<Sprite>();
		lineas=new Array<Sprite>();

		fueUsadoPista1.push(false);
		fueUsadoPista1.push(false);
		fueUsadoPista1.push(false);
		fueUsadoPista1.push(false);

		fueUsadoPista2=new Array<Bool>();
		fueUsadoPista2.push(false);
		fueUsadoPista2.push(false);
		fueUsadoPista2.push(false);
		fueUsadoPista2.push(false);


		for(i in 0...4){			
			anadirPremio();
		}
		for(i in 0...posiciones.length){
		    lineas.push( new Sprite({
		    	texture: Luxe.resources.texture('assets/basePremio.png'),
		    	size: new Vector(176,1,0,0),
		    	pos: new Vector(Luxe.screen.w/2,637-(posiciones[i]*25),0,0)
		    }));
		    
		    martillosl.push( new Sprite({
		    	texture: Luxe.resources.texture('assets/martillol0.png'),
		    	size: new Vector(39,48,0,0),
		    	pos: new Vector(Luxe.screen.w/2-40,637-(posiciones[i]*25),0,0)
		    }));
		    martillosr.push( new Sprite({
		    	texture: Luxe.resources.texture('assets/martillor0.png'),
		    	size: new Vector(39,48,0,0),
		    	pos: new Vector(Luxe.screen.w/2+40,637-(posiciones[i]*25),0,0)
		    }));


		    dibujarFraccion(posiciones[i]);
		}


	}
	private function anadirPremio(){
		var random: Int = Luxe.utils.random.int(2,15);
		while(!comprobar(random)){
			random=Luxe.utils.random.int(2,15);
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
	        pos : new Vector(473,637-(posicion*25)-16),
	        font : Luxe.renderer.font,
	        point_size : 14,
	        text: nominador+''
	    }));

	    textos.push(new luxe.Text({
	        color : new Color(0,0,0,1).rgb(0x000000),
	        pos : new Vector(473,637-(posicion*25)-15),
	        font : Luxe.renderer.font,
	        point_size : 14,
	        text: '_'
	    }));

	    //dibujando denominador
	    textos.push(new luxe.Text({
	        color : new Color(0,0,0,1).rgb(0x000000),
	        pos : new Vector(473,637-(posicion*25)),
	        font : Luxe.renderer.font,
	        point_size : 14,
	        text: denominador+''
	    }));
	}

	public function preguntarPremio(fichas:Float,turno:Int):Bool{
		for(i in 0...posiciones.length){
			if(fichas==posiciones[i]&&premioMerecido){

				if(turno==1 && !fueUsadoPista1[i]){
					fueUsadoPista1[i]=true;
					martillosl[i].texture=Luxe.resources.texture('assets/martillol3.png');
					return true;
				}else if(turno==2 && !fueUsadoPista2[i]){
					fueUsadoPista2[i]=true;
					martillosr[i].texture=Luxe.resources.texture('assets/martillor3.png');
					return true;
				}		
			}
		}
		return false;
	}

	public function cambiarMartillo(fichas:Float, turno:Int):Bool{
		for(i in 0...posiciones.length){
			if(fichas==posiciones[i]){
				if(turno==1 && !fueUsadoPista1[i]){
					martillosl[i].texture=Luxe.resources.texture('assets/martillol1.png');
				}else if(turno==2 && !fueUsadoPista2[i]){
					martillosr[i].texture=Luxe.resources.texture('assets/martillor1.png');
				}	
				return true;
			}
		}
		return false;
	}

	public function merecePremio(fichas:Float, turno:Int):Bool{
		for(i in 0...posiciones.length){
			if(fichas==posiciones[i]){
				if(turno==1 && !fueUsadoPista1[i]){
					martillosl[i].texture=Luxe.resources.texture('assets/martillol2.png');
				}else if(turno==2 && !fueUsadoPista2[i]){
					martillosr[i].texture=Luxe.resources.texture('assets/martillor2.png');
				}	
				premioMerecido=true;
				return true;

			}
		}
		return false;
	}

	public function eliminarTodo(){
		for(i in 0...posiciones.length){
		    lineas[i].destroy();		    
		    martillosl[i].destroy();
		    martillosr[i].destroy();
		}
		for(i in 0...textos.length){
			textos[i].destroy();
		}
		textos=null;
		lineas=null;
		martillosl=null;
		martillosr=null;
	}
}



