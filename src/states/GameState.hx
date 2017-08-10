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

  public var text1: mint.TextEdit;

  var block : Sprite;
  var indicadorTurno : Sprite;

  var posicionMouse : luxe.Vector;

  var pista1 : Pista;
  var pista2 : Pista;
  var recursos:Recursos;
  var ruleta:Ruleta;
  var premios:Premios;

  var arrastrador: componentes.Arrastrador;
  var turno : Int = 2;  //false arriba true abajo
  var altoFichas : Float = Config.altoFichas;
  var anchoFichas : Float = Config.anchoFichas;
  public var fichasRestantes : Int =0;
  var tipoDeFichaArrastrada:Int=-1;  //0 para ficha de recursos, 1 para ficha de reserva

  public function new(name:String) {
    super({name:name});

    state_machine = new States({ name:'statemachine' });
    state_machine.add(new PauseState('pause', resume));
  }

  override function onenter<T> (_:T) {
    trace("Gamestate--actializar el reiniciar---en anadirFicha en pista, hacer que no se pueda pasar, la reserva de arriva no funciona");   

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
        x:Luxe.screen.w/2-128, y:400, w:256, h: 131,
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
            siguienteTurno();                            
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
        turno=2;
        Main.machine.set("game_state");
      }
    });

    //sprites

    ruleta=new Ruleta({
          pos: new phoenix.Vector(Luxe.screen.w/2,50,0,0),
          color: new Color(0,0,0,1.0),            
          size: new Vector(160, 50)
      });
    ruleta.setGamestate(this);

    recursos=new Recursos();

    pista1 = new Pista({
        name: 'pista1',
        pos: new phoenix.Vector(Luxe.screen.w/2-Config.anchoFichas*1.3,Luxe.screen.h/2,0,0),
        color: new Color(0,0,255,1.0),            
        size: new Vector(Config.anchoFichas*1.3, Config.longitudPista)
    });
    pista1.setReserva(new Vector(pista1.pos.x-150,pista1.pos.y-200));
    pista1.setRecursos(recursos);

    pista2 = new Pista({
        name: 'pista2',
        pos: new phoenix.Vector(Luxe.screen.w/2+Config.anchoFichas*1.3,Luxe.screen.h/2,0,0),
        color: new Color(0,255,255,1.0),            
        size: new Vector(Config.anchoFichas*1.3, Config.longitudPista)
    });
    pista2.setReserva(new Vector(pista2.pos.x+150,pista2.pos.y-200));
    pista2.setRecursos(recursos);

    premios = new Premios(); 
    indicadorTurno = new Sprite({
        name: 'indicador',
        pos: new phoenix.Vector(pista2.pos.x,100,0,0),
        color: new Color().rgb(0x000000),
        size: new Vector(30, 30), 
        geometry: Luxe.draw.circle({
          r : 20,
        })

    });  
    

  }

  override public function onmousedown(event:MouseEvent):Void{
      trace(event.pos);
      var tipo=recursos.clickSpawn(event.pos,turno,fichasRestantes);
      if(tipo!=-1){              //si toma de los recursos
        tipoDeFichaArrastrada=0;
        block = new Sprite({
          name: 'bloque',
          pos: new phoenix.Vector(event.pos.x,event.pos.y,0,0),
          color: new Color().rgb(Config.fichas.tipos[tipo].color),
          size: new Vector(anchoFichas, Config.fichas.tipos[tipo].alto), 

        });
        arrastrador = new componentes.Arrastrador({ name:'arrastrador' });
        block.add(arrastrador);  
      }else{                    
        var pista:Pista=obtenerPista();
        if(pista!=null){
          tipoDeFichaArrastrada=1;
          if(pista.reserva.quitarReserva(event.pos)){              //si toma de las reservas
            block = new Sprite({
              name: 'bloque',
              pos: new phoenix.Vector(event.pos.x,event.pos.y,0,0),
              color: new Color().rgb(Config.fichas.tipos[0].color),
              size: new Vector(anchoFichas, Config.fichas.tipos[0].alto), 

            });
            arrastrador = new componentes.Arrastrador({ name:'arrastrador' });
            block.add(arrastrador);  
          }
        }
        
        
      } 
  }
  

  override function onmousemove( event:MouseEvent ) {     
    posicionMouse=event.pos;
  }

  function obtenerPista():Pista{
    if(turno==1)return pista1;
    else{
      if (turno==2) return pista2;
      else return null;
      } 
  }

  function cambiarTurno(){
    //trace('pista1:'+pista1.acum+' -pista2:'+pista2.acum);
    var pista=obtenerPista();
    if(premios.preguntarPremio(pista.obtenerFichasAcumuladas()))return;
    if (turno==1)turno=2;
    else if (turno==2)turno=1;
  }

  function siguienteTurno(){
    cambiarTurno();
    if(turno==1){    //indicador de turno(la pelotita)
      indicadorTurno.pos.x=pista1.pos.x;
    }else{
      if(turno==2)indicadorTurno.pos.x=pista2.pos.x;
    }
    ruleta.encender();
    text1.text='tirando ruleta..';

  }
  //para probar cosas
  function test(){
    pause();
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
        var j:Int=recursos.identificarTipoAlto(block.size.y);
        var pista:Pista;

        if(turno==1){
          i=0;
          pista=pista1;
          
        }else{
          if(turno==2){
            i=1;
            pista=pista2; 
          }else return;
          
        }

        if(j==0){    //si se esta poniendo un bloque nuevo
          if(pista.anadirFicha(j, event.pos)){ //si lo suelta dentro 
            if(tipoDeFichaArrastrada==0)fichasRestantes--;
            tipoDeFichaArrastrada=-1;
            text1.text='fichas restantes: '+fichasRestantes;
          }else{ //si lo suelta fuera
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

    var pista:Pista=null;

    if(turno==1){
      pista=pista1;
    }else{ 
      if(turno==2)pista=pista2;
      else return;
    }

    var indice1: Int=-1;
    var indice2: Int=-1;

    if(pista!=null){
      for(a in 0...pista.listaFichas.length){ //identificando los indices
      if(pista.listaFichas[a].get('sensor').estaSeleccionado()){
        if(indice1<0)indice1=a;
        else indice2=a;
        }
      }
      if(indice2>-1){
        pista.intercambiar(indice1, indice2);
      }   
    }
     

    if (state_machine.current_state != null &&
        state_machine.current_state.name == "pause") {
          // We don't do anything while paused
          return;
    }
  }

}
