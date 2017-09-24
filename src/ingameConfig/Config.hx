package ingameConfig;
class Config 
{
	
	public static var longitudPista : Float=400;
	public static var anchoFichas : Float=200;
	public static var imagenes;
	public static var fichas = {
	    tipos: [{
	        alto : longitudPista/16-1,
	        color : 0xff0000
	      },{
	        alto : longitudPista/8-1,
	        color : 0xf94b04
	      },{
	        alto : longitudPista/4-1,
	        color : 0xff00d9
	      },{
	        alto : longitudPista/2-1,
	        color : 0x00ff00
	      }
	]};
	


}
