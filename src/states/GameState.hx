package states;
import luxe.States;
import luxe.Text;
import luxe.Input;
import luxe.Input.GamepadEvent;

import luxe.Sprite;
import luxe.Color;
import luxe.Vector;
import mint.render.luxe.LuxeMintRender;
import phoenix.geometry.Geometry;
import lib.AutoCanvas;


import clases.*;
import ingameConfig.Config;

class GameState extends State {

  
  var state_machine : States;
  
  var fondo:Geometry;
  var canvas: mint.Canvas;
  var focus: ControllerFocus; 
  var delta_time_text : Text;

  var text1: mint.TextEdit;

  var block : Sprite;
  var indicadorTurno : Sprite;

  var posicionMouse : luxe.Vector;

  var pista1 : Pista;
  var pista2 : Pista;
  var recursos:Recursos;

  var arrastrador: componentes.Arrastrador;
  var turno : Bool = false;  //false arriba true abajo
  var altoFichas : Float = Config.altoFichas;
  var fichasRestantes : Int =0;

  public function new(name:String) {
    super({name:name});

    state_machine = new States({ name:'statemachine' });
    state_machine.add(new PauseState('pause', resume));
  }

  override function onenter<T> (_:T) {
    trace("Gamestate--actializar el reiniciar---en anadirFicha en pista, hacer que no se pueda pasar");   

    fondo = Luxe.draw.box({
        x : 0, y : 0,
        w : Luxe.screen.w,
        h : Luxe.screen.h,
        color : new Color().rgb(0x4286f4)
    });

    //deltat
    delta_time_text = new luxe.Text({
        color : new Color(0,0,0,1).rgb(0xf6007b),
        pos : new Vector(0,20),
        font : Luxe.renderer.font,
        point_size : 14
    });

    //ventanita
    var autoCanvas = new AutoCanvas(Luxe.camera.view, {
      name:'canvas',
      rendering: new LuxeMintRender(),
      options: { color:new Color().rgb(0x4286f4) },
      //x: Luxe.screen.w-300, y:10, w: 300, h: 150
      x: 0 ,y: 0, w: Luxe.screen.w, h: Luxe.screen.h
    });
    autoCanvas.auto_listen();
    canvas=autoCanvas;
    focus = new ControllerFocus(canvas);

    var window = new mint.Window({
        parent: canvas,name: 'window', title: 'window',
        visible: true, closable: false, collapsible: true,
        x:700, y:1, w:256, h: 131,
        h_max: 131, h_min: 131, w_min: 131,
    });
    text1 = new mint.TextEdit({
            parent: window, name: 'textedit1', text: 'presionar siguiente turno', renderable: true,
            x: 10, y:32, w: 256-10-10, h: 22
        });

    var boton_subir = new mint.Button({
          parent: window,
          name: 'boton1',
          x: 10, y: 60, w: 110, h: 22,
          text: 'siguiente turno',
          text_size: 12,
          options: { },
          onclick: function(_, _) {
            colocar();                            
          }
    });

    

    var boton_test = new mint.Button({
          parent: window,
          name: 'boton3',
          x: 10, y: 90, w: 110, h: 22,
          text: 'test',
          text_size: 12,
          options: { },
          onclick: function(_, _) {
            test();                           
          }
    });

    var boton_bajar = new mint.Button({
      parent: window,
      name: 'boton2',
      x: 130, y: 60, w: 110, h: 22,
      text: 'reiniciar',
      text_size: 12,
      options: { },
      onclick: function(_, _) {
        trace('reiniciando..');

        for(a in 0...pista1.listaFichas.length){
          pista1.listaFichas[a].destroy();
        }
        for(a in 0...pista2.listaFichas.length){
          pista2.listaFichas[a].destroy();
        }
        pista1.destroy();
        pista2.destroy();
        indicadorTurno.destroy();
        pista1.listaFichas=[];
        pista2.listaFichas=[];
        turno=false;
        Main.machine.set("game_state");
      }
    });

    //sprites

    recursos=new Recursos();

    pista1 = new Pista({
        name: 'pista1',
        pos: new phoenix.Vector(Luxe.screen.w/2,550,0,0),
        color: new Color(0,0,255,1.0),            
        size: new Vector(Config.longitudPista, altoFichas*1.3)
    });
    pista1.setRecursos(recursos);

    pista2 = new Pista({
        name: 'pista2',
        pos: new phoenix.Vector(Luxe.screen.w/2,425,0,0),
        color: new Color(0,0,255,1.0),            
        size: new Vector(Config.longitudPista, altoFichas*1.3)
    });
    pista2.setRecursos(recursos);


    


    indicadorTurno = new Sprite({
        name: 'indicador',
        pos: new phoenix.Vector(25,pista2.pos.y,0,0),
        color: new Color().rgb(0x000000),
        size: new Vector(30, 30), 
        geometry: Luxe.draw.circle({
          r : 20,
        })

    });  
    

    //delta_time_text.text = 'con ejec se ponen fichitas \n se pueden cambiar las fichas seleccionandolas con click \n solo se pueden cambiar si el circulo apunta a la pista de las fichas \n el cuadrado de al lado se puede arastrar ---> \n si se arrastra a un grupo de fichas que sumadas tengan el mismo ancho \n que el cuadrado, estas fichitas se reemplazaran por una ficha rosa';

  }

  override public function onmousedown(event:MouseEvent):Void{

      var tipo=recursos.clickSpawn(event.pos,turno,fichasRestantes);
      if(tipo!=-1){              //si toma de los recursos
        block = new Sprite({
          name: 'bloque',
          pos: new phoenix.Vector(event.pos.x,event.pos.y,0,0),
          color: new Color().rgb(Config.fichas.tipos[tipo].color),
          size: new Vector(Config.fichas.tipos[tipo].ancho, altoFichas), 

        });
        arrastrador = new componentes.Arrastrador({ name:'arrastrador' });
        block.add(arrastrador);  
      }else{                      
        var pista:Pista;
        if(turno){
          pista=pista1;
        }else{
          pista=pista1;
        }

        if(pista.reserva.quitarReserva(event.pos)){              //si toma de las reservas
          block = new Sprite({
            name: 'bloque',
            pos: new phoenix.Vector(event.pos.x,event.pos.y,0,0),
            color: new Color().rgb(Config.fichas.tipos[0].color),
            size: new Vector(Config.fichas.tipos[0].ancho, altoFichas), 

          });
          arrastrador = new componentes.Arrastrador({ name:'arrastrador' });
          block.add(arrastrador);  
        }
      } 
  }
  

  override function onmousemove( event:MouseEvent ) {     
    posicionMouse=event.pos;
  }

  function obtenerPista():Pista{
    if(turno)return pista1;
    else return pista2;
  }

  //coloca las fichitas
  function colocar(){
    trace("pista1 "+ pista1.acum+"_pista2 "+pista2.acum);
    var pista=obtenerPista();
    if(pista.acum%216!=0 || pista.acum==0){
      turno=!turno;
      if(turno){    //indicador de turno(la pelotita)
        indicadorTurno.pos.y=pista1.pos.y;
      }else{
        indicadorTurno.pos.y=pista2.pos.y;
      }
    }      

    //var random: Int = Luxe.utils.random.int(0,3);
    var random: Int = 20;

    fichasRestantes=random;
    text1.text='fichas: '+random;

  }

  //para probar cosas
  function test(){


  }


  override function onleave<T> (_:T) {
    trace("Leave game state");
    canvas.destroy();
    delta_time_text.destroy();
  }

  function pause() {
    state_machine.set('pause');
  }

  function resume() {
    state_machine.unset();
  }


  override public function onmouseup(event:MouseEvent):Void  //dejando las fichas que se arrastran
    {

      if(block!=null){ if(!block.destroyed){

        var i:Int;
        var j:Int=recursos.identificarTipoAncho(block.size.x);
        var pista:Pista;

        if(turno){
          i=1;
          pista=pista1;
          
        }else{
          i=0;
          pista=pista2; 
        }

        if(j==0){    //si se esta poniendo un bloque nuevo
          if(pista.anadirFicha(j, event.pos)){
            fichasRestantes--;
            text1.text='fichas restantes: '+fichasRestantes;
          }else{
            recursos.restantes[i][j].text=""+(Std.parseInt(recursos.restantes[i][j].text)+1);
          }
        }else{      //si se esta reemplazando
          if(pista.identificarReemplazo(block,turno)){
            if(Std.parseInt(recursos.restantes[i][3].text)==0)text1.text='juego terminado';
          }else recursos.restantes[i][j].text=""+(Std.parseInt(recursos.restantes[i][j].text)+1);
        }  

        block.destroy();    
        
      }}
    }

  override function update( dt:Float ) {

    focus.update(dt);

    //intercambio
    var indice1: Int=-1;
    var indice2: Int=-1;
    var pista:Pista;

    if(turno){
      pista=pista1;
    }else{ 
      pista=pista2;
    }

    for(a in 0...pista.listaFichas.length){ //identificando los indices
      if(pista.listaFichas[a].get('sensor').estaSeleccionado()){
        if(indice1<0)indice1=a;
        else indice2=a;
      }
    }
    if(indice2>-1){
      pista.intercambiar(indice1, indice2);
    }    

    if (state_machine.current_state != null &&
        state_machine.current_state.name == "pause") {
          // We don't do anything while paused
          return;
    }
  }

}
