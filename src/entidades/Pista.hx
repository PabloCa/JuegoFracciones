package entidades;

import luxe.Sprite;
import luxe.Color;
import luxe.Vector;

import ingameConfig.Config;
import componentes.*;


class Pista extends Sprite
{
	public var listaFichas : Array<Sprite>;
	public var acum : Float = 0;
	private var altoFichas : Float = Config.altoFichas;

	override function init():Void{
		listaFichas = new Array<Sprite>();
	}

	public function colocar(ancho : Float, color : Color):Bool{

	    listaFichas.push(
        	new Sprite({
	        pos: new phoenix.Vector(acum+ancho/2+(Luxe.screen.w-Config.longitudPista)/2,this.pos.y,0,0),
	        color: color,
	        size: new Vector(ancho, altoFichas), 
	      }));
	    acum=acum+ancho+1;
	    var componenteColor= new componentes.SensorClick({ name:'sensor' });
	    componenteColor.colorInicial(color);
	    listaFichas[listaFichas.length-1].add(componenteColor);

	    if(acum>=Config.longitudPista)return false;
	    else return true;
	}




	public function identificarReemplazo(block : Sprite){
		var ancho : Float = block.size.x;
		var col : Color = block.color;
		var acumu : Float=0;
	    var primero : Int = -1;
	    var ultimo : Int = -1;

	    //se suman los anchos de lo que se quiera reemplazar, 
	    for(a in 0...listaFichas.length){
	      if(block.point_inside(listaFichas[a].pos)) {
	        if(listaFichas[a].size.x+1<ancho){
	          acumu=acumu+listaFichas[a].size.x+1;
	          if(primero==-1){
	            primero=a;
	          }else ultimo=a;
	        }
	      }
	    }
	    acumu=acumu-1;
	    trace("--acumu:"+acumu+"-ancho:"+ancho);
	    if(acumu==ancho){     //si cooinciden el ancho del sprite arrastrado con los de origen

			if(primero!=-1 && ultimo != -1){     		          
		          
				for(a in primero...ultimo+1){     //destruyo graficamente las fichas que son tapadas
					acum=acum-listaFichas[a].size.x-1;
					listaFichas[a].destroy();            
				} 

				listaFichas.splice(primero,ultimo-primero+1);     //las elimino del array               

				//pongo una nueva, el sprite que reemplaza al final del array

				colocar(ancho,col);

				//despues de ponerla, la coloco en la posicion donde estaban las otras
				listaFichas.insert(primero,listaFichas.pop());

				ajustarFichas();
			
			}
		}
		block.destroy();
	}
	
	public function intercambiar(indice1 : Int, indice2 : Int){
		var aux :Sprite=listaFichas[indice1];

        listaFichas[indice1]=listaFichas[indice2];
        listaFichas[indice2]=aux;
        listaFichas[indice1].get('sensor').quitarSeleccion();
        listaFichas[indice2].get('sensor').quitarSeleccion();

        ajustarFichas();
        
	}

	private function ajustarFichas(){ //ordena las fichas graficamente

		acum=0;
        //reposicionando
        for(a in 0...listaFichas.length){ //--se puede optimizar no partiendo de 0
          var extra= listaFichas[a].size.x;
          listaFichas[a].pos.x=acum+extra/2+(Luxe.screen.w-Config.longitudPista)/2;
          acum=acum+extra+1;
        }

	}
}



