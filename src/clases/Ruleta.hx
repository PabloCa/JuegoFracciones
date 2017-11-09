package clases;

import luxe.Sprite;
import luxe.Color;
import luxe.Vector;
import luxe.Text;

import states.GameState;
class Ruleta extends Sprite
{

	private var indiceSeleccionado:Int=0;
	private var fichasRestantes:Int=0;
	private var periodo:Float;
	private var tiempoAcumulado:Float=0;
	public var encendido:Bool=false;
	private var gameState:GameState;
	private var orientacion:Int;


	override function init():Void{

	}

	public function setGamestate(game:GameState){
		this.gameState=game;
	}


	public function seleccionarSiguiente(){
		indiceSeleccionado=(indiceSeleccionado+1)%3;
		this.texture=Luxe.resources.texture('assets/ruleta'+orientacion+(indiceSeleccionado+1)+'.png');

	}

	public function encender(){
		orientacion=gameState.turno;
				
		var random: Int = Luxe.utils.random.int(0,3);
	
		indiceSeleccionado=random;

		this.texture=Luxe.resources.texture('assets/ruleta'+orientacion+(indiceSeleccionado+1)+'.png');
		encendido=true;
		periodo=0.1;
	}

	private function apagar(){
		encendido=false;
		gameState.fichasRestantes=indiceSeleccionado+1;
    	gameState.etFichasRestantes.text='Fichas restantes: '+(indiceSeleccionado+1);
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



