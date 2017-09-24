package clases;

import ingameConfig.Config;

import luxe.Sprite;
import luxe.Color;
import luxe.Vector;

import luxe.Text;

class Recursos {
	public var spawn:Array<Array<Sprite>>= [for (x in 0...2) [for (y in 0...4) null]];
	public var restantes:Array<Array<Text>>= [for (x in 0...2) [for (y in 0...4) null]];
	public var quedan:Array<Array<Text>>= [for (x in 0...2) [for (y in 0...4) null]];

	var pista1:Pista;
	var pista2:Pista;
	public function new(){
		var margenBorde=110;
	    for(i in 0...2){

			spawn[i][0]=new Sprite({
				pos: new phoenix.Vector(margenBorde,163,0,0),
				texture: Config.imagenes.orientacion[i].alto[0].imagen,
				size: new Vector(Config.anchoFichas, Config.fichas.tipos[0].alto), 
			});
	      	
		    quedan[i][0]= new luxe.Text({
		        color : new Color(0,0,0,1).rgb(0x000000),
		        pos : new Vector(Luxe.screen.w/2-(Luxe.screen.w/2-margenBorde)*1.178-33,129),
		        font : Luxe.renderer.font,
		        point_size : 14,
		        text : "Quedan"
		    });

		    restantes[i][0]= new luxe.Text({
		        color : new Color(0,0,0,1).rgb(0x000000),
		        pos : new Vector(quedan[i][0].pos.x+50,quedan[i][0].pos.y),
		        font : Luxe.renderer.font,
		        point_size : 14,
		        text : "4"
		    });


		    spawn[i][1]=new Sprite({
				pos: new phoenix.Vector(margenBorde,235,0,0),
				texture: Config.imagenes.orientacion[i].alto[1].imagen,
				size: new Vector(Config.anchoFichas, Config.fichas.tipos[1].alto), 
			});

		    quedan[i][1]= new luxe.Text({
		        color : new Color(0,0,0,1).rgb(0x000000),
		        pos : new Vector(Luxe.screen.w/2-(Luxe.screen.w/2-margenBorde)*1.178-33,187),
		        font : Luxe.renderer.font,
		        point_size : 14,
		        text : "Quedan"
		    });

		    restantes[i][1]= new luxe.Text({
		        color : new Color(0,0,0,1).rgb(0x000000),
		        pos : new Vector(quedan[i][1].pos.x+50,quedan[i][1].pos.y),
		        font : Luxe.renderer.font,
		        point_size : 14,
		        text : "3"
		    });

	      	spawn[i][2]=new Sprite({
				pos: new phoenix.Vector(margenBorde,345,0,0),
				texture: Config.imagenes.orientacion[i].alto[2].imagen,
				size: new Vector(Config.anchoFichas, Config.fichas.tipos[2].alto), 
			});
	      	quedan[i][2]= new luxe.Text({
		        color : new Color(0,0,0,1).rgb(0x000000),
		        pos : new Vector(Luxe.screen.w/2-(Luxe.screen.w/2-margenBorde)*1.178-33,272),
		        font : Luxe.renderer.font,
		        point_size : 14,
		        text : "Quedan"
		    });

		    restantes[i][2]= new luxe.Text({
		        color : new Color(0,0,0,1).rgb(0x000000),
		        pos : new Vector(quedan[i][2].pos.x+50,quedan[i][2].pos.y),
		        font : Luxe.renderer.font,
		        point_size : 14,
		        text : "2"
		    });

		    spawn[i][3]=new Sprite({
				pos: new phoenix.Vector(margenBorde,529,0,0),
				texture: Config.imagenes.orientacion[i].alto[3].imagen,
				size: new Vector(Config.anchoFichas, Config.fichas.tipos[3].alto), 
			});
		    quedan[i][3]= new luxe.Text({
		        color : new Color(0,0,0,1).rgb(0x000000),
		        pos : new Vector(Luxe.screen.w/2-(Luxe.screen.w/2-margenBorde)*1.178-33,406),
		        font : Luxe.renderer.font,
		        point_size : 14,
		        text : "Quedan"
		    });

		    restantes[i][3]= new luxe.Text({
		        color : new Color(0,0,0,1).rgb(0x000000),
		        pos : new Vector(quedan[i][3].pos.x+50,quedan[i][3].pos.y),
		        font : Luxe.renderer.font,
		        point_size : 14,
		        text : "2"
		    });


		    margenBorde=Luxe.screen.w-margenBorde;

	    }
	}

	public function clickSpawn(pos:Vector,turno:Int,fichasRestantesTurno:Int):Int{	
		
		var i:Int;
		if(turno==2){
			i=1;
		}else{
			if(turno==1)i=0;
			else return -1;
		}
		
		for(j in 0...4){
			if(spawn[i][j].point_inside(pos)){
				var tipo:Int=identificarTipoAlto(spawn[i][j].size.y);
				var fichasRestantesSpawn:Int = Std.parseInt(restantes[i][j].text);  //estaba haciendo que no puedan haber numeros negativos en el spawn

				if((tipo==0 && fichasRestantesTurno<=0)||fichasRestantesSpawn<=0){
					return -1;
				}else{
					restantes[i][j].text=""+(fichasRestantesSpawn-1);
					if(fichasRestantesSpawn-1==0)spawn[i][j].visible=false;
					return tipo;
				}
			}

		}
		
		return -1;
	}

	public function restituir(id:Int,turno:Int){
		var i: Int; 
		if(turno==2){
			i=1;
		}else{
			if(turno==1)i=0;
			else return;
		}
		if(spawn[i][id].visible==false)spawn[i][id].visible=true;
		restantes[i][id].text=""+(Std.parseInt(restantes[i][id].text)+1);
	}

	public function identificarTipoAlto(alto:Float):Int{
		for(i in 0...4) if(alto==Config.fichas.tipos[i].alto) return i;		
		return -1;
	}

	public function eliminarTodo(){
		for(i in 0...2){
			for(j in 0...4){
				spawn[i][j].destroy();
			    quedan[i][j].destroy();
			    restantes[i][j].destroy();
			}
		}
	}
}