package ingameConfig;
class Config 
{
	
	public static var longitudPista : Float=400;
	public static var altoFichas : Float=80;///-------eliminar
	public static var anchoFichas : Float=80;
	public static var fichas = {
	    tipos: [{
	        ancho : longitudPista/16-1,
	        alto : longitudPista/16-1,
	        color : 0xff0000
	      },{
	        ancho : longitudPista/8-1,
	        alto : longitudPista/8-1,
	        color : 0xf94b04
	      },{
	        ancho : longitudPista/4-1,
	        alto : longitudPista/4-1,
	        color : 0xff00d9
	      },{
	        ancho : longitudPista/2-1,
	        alto : longitudPista/2-1,
	        color : 0x00ff00
	      }
	]};
	


}
