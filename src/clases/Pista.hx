package clases;

import luxe.Sprite;
import luxe.Color;
import luxe.Vector;

import ingameConfig.Config;
import componentes.*;


class Pista extends Sprite
{
	public var listaFichas : Array<Sprite>;
	public var acum : Float = 0;
	public var reserva:Reserva;	
	private var altoFichas : Float = Config.altoFichas;//*-------
	private var anchoFichas : Float = Config.anchoFichas;
	private var recursos : Recursos;
	

	override function init():Void{
		listaFichas = new Array<Sprite>();

	}

	public function setReserva(posicion:Vector){
		reserva = new Reserva({
	        pos: posicion,
	        color: new Color(0,0,255,1.0),            
	        size: new Vector(anchoFichas*1.3, Config.fichas.tipos[0].alto*4+4)
		});
	}

	public function setRecursos(rec:Recursos){
		this.recursos=rec;
	}

	public function colocar(alto : Float, color : Color):Bool{
		if(!estaLlena()){
			listaFichas.push(
				new Sprite({
				pos: new phoenix.Vector(this.pos.x, (this.size.y+Luxe.screen.h)/2-(acum+alto/2),0,0),
				color: color,
				size: new Vector(anchoFichas, alto), 
		    }));
		    acum=acum+alto+1;
		    var componenteColor= new componentes.SensorClick({ name:'sensor' });
		    componenteColor.colorInicial(color);
		    listaFichas[listaFichas.length-1].add(componenteColor);

		    return true;
		}return false;
	    
	}

	public function estaLlena():Bool{
		if(this.acum<this.size.y)return false;
		else return true;
	}

	//retorna true si logra reemplazar
	public function identificarReemplazo(block : Sprite, turno:Int):Bool{
		var largo : Float = block.size.y;
		var col : Color = block.color;
		var acumu : Float=0;
	    var primero : Int = -1;
	    var ultimo : Int = -1;
	    var exito: Bool = false;

	    //se suman los anchos de lo que se quiera reemplazar, 
	    for(a in 0...listaFichas.length){
	      if(block.point_inside(listaFichas[a].pos)) {
	        if(listaFichas[a].size.y+1<largo){
	          acumu=acumu+listaFichas[a].size.y+1;
	          if(primero==-1){
	            primero=a;
	          }else ultimo=a;
	        }
	      }
	    }
	    acumu=acumu-1;
	    if(acumu==largo){     //si cooinciden el ancho del sprite arrastrado con los de origen

			if(primero!=-1 && ultimo != -1){     	

				for(a in primero...ultimo+1){     //regreso los recursos
					recursos.restituir(recursos.identificarTipoAlto(listaFichas[a].size.y),turno);					            
				} 					          
		          
				for(a in primero...ultimo+1){     //destruyo graficamente las fichas que son tapadas
					acum=acum-listaFichas[a].size.y-1;
					listaFichas[a].destroy();            
				} 

				listaFichas.splice(primero,ultimo-primero+1);     //las elimino del array               

				//pongo una nueva, el sprite que reemplaza al final del array

				colocar(largo,col);

				//despues de ponerla, la coloco en la posicion donde estaban las otras
				listaFichas.insert(primero,listaFichas.pop());

				ajustarFichas();
				exito=true;
			}
		}
		
		return exito;
	}

	public function obtenerFichasAcumuladas():Float{
		return acum/25;
	}
	
	public function intercambiar(indice1 : Int, indice2 : Int){
		var aux :Sprite=listaFichas[indice1];

        listaFichas[indice1]=listaFichas[indice2];
        listaFichas[indice2]=aux;
        listaFichas[indice1].get('sensor').quitarSeleccion();
        listaFichas[indice2].get('sensor').quitarSeleccion();

        ajustarFichas();
        
	}

	//decide si se coloca la ficha en la pista o en la reserva
	public function anadirFicha(tipo : Int, posicion : Vector):Bool{
		if(this.point_inside(posicion)){
			return colocar(Config.fichas.tipos[tipo].alto,new Color().rgb(Config.fichas.tipos[tipo].color));
		}else if(this.reserva.point_inside(posicion)){
			return this.reserva.colocar(Config.fichas.tipos[tipo].alto,new Color().rgb(Config.fichas.tipos[tipo].color));
		}
		return false;
	}

	private function ajustarFichas(){ //ordena las fichas graficamente

		acum=0;
        //reposicionando
        for(a in 0...listaFichas.length){ //--se puede optimizar no partiendo de 0
          var extra= listaFichas[a].size.y;
          listaFichas[a].pos.y=(this.size.y+Luxe.screen.h)/2-acum-extra/2;
          acum=acum+extra+1;
        }

	}

}



