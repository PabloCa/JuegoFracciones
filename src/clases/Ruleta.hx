package clases;

import luxe.Sprite;
import luxe.Color;
import luxe.Vector;
import luxe.Text;

import states.GameState;
class Ruleta extends Sprite
{
	public var rectangulos : Array<Sprite>;
	public var textos : Array<Text>;
	private var seleccion:Sprite;
	private var colorDefalut:Color=new Color(255,255,0,1.0);
	private var colorSeleccion:Color=new Color().rgb( 0x808b96 );
	private var indiceSeleccionado:Int=0;
	private var fichasRestantes:Int=0;
	private var periodo:Float;
	private var tiempoAcumulado:Float=0;
	private var encendido:Bool=false;
	private var gameState:GameState;


	override function init():Void{
		rectangulos = new Array<Sprite>();
		textos = new Array<Text>();
		for(i in 0...3){
			rectangulos.push(new Sprite({
		        pos: new phoenix.Vector(this.pos.x+((i-1)*50),this.pos.y,0,0),
		        color: colorDefalut,            
		        size: new Vector(40, 40)
		    }));
		    textos.push(new luxe.Text({
		        color : new Color(0,0,0,1).rgb(0x000000),
		        pos : new Vector(this.pos.x+((i-1)*50)-4,this.pos.y-7),
		        font : Luxe.renderer.font,
		        point_size : 14,
		        text: (i+1)+''
		    }));

		}
	    seleccionar(rectangulos[0]);
	}

	public function setGamestate(game:GameState){
		this.gameState=game;
	}
	private function seleccionar(rectangulo:Sprite){
		seleccion = new Sprite({
	        pos: rectangulo.pos,
	        color: colorDefalut,            
	        size: new Vector(30, 30)
	    });
	    rectangulo.color=colorSeleccion;
	}

	private function resetear(rectangulo:Sprite){
		seleccion.destroy();
		rectangulo.size.x=40;
		rectangulo.size.y=40;
		rectangulo.color=colorDefalut;
		  
	}

	public function seleccionarSiguiente(){
		resetear(rectangulos[indiceSeleccionado%3]);
		indiceSeleccionado=(indiceSeleccionado+1)%3;
		seleccionar(rectangulos[indiceSeleccionado%3]);
	}

	public function encender(){
		var random: Int = Luxe.utils.random.int(0,3);
		resetear(rectangulos[indiceSeleccionado]);		
		indiceSeleccionado=random;
		seleccionar(rectangulos[indiceSeleccionado]);
		encendido=true;
		periodo=0.1;
	}

	private function apagar(){
		encendido=false;
		gameState.fichasRestantes=indiceSeleccionado+1;
    	gameState.text1.text='fichas restantes: '+(indiceSeleccionado+1);
	}

	override function update( dt:Float ) {
		if(encendido){
			tiempoAcumulado=tiempoAcumulado+dt;
			if(tiempoAcumulado>=periodo){
				periodo=periodo*1.15;
				tiempoAcumulado=0;
				seleccionarSiguiente();
				if(periodo>=0.6)apagar();
			}
		}
		


  	}

	
}



