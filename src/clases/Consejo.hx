package clases;

import luxe.Text;
import luxe.Color;

import states.GameState;
class Consejo extends Text
{
	private var visibilidad : Float;
	public function cambiarTexto(texto:String){
		if(this.text!=texto){
			this.text=texto;
			visibilidad=0;
		}
	}

	public function eliminar(){
		this.text='';
		this.destroy();
	}


	override function update( dt:Float ) {
		
		if(visibilidad<1){
			visibilidad=visibilidad+0.01;
			this.color=new Color(0,0,0,visibilidad);
		}
		
  	}

	
}



