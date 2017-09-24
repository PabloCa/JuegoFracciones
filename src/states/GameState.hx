package states;
import luxe.States;
import luxe.Text;
import luxe.Input;
import luxe.Input.GamepadEvent;

import luxe.Sprite;
import luxe.Color;
import luxe.Vector;
import mint.render.luxe.LuxeMintRender;
import lib.AutoCanvas;

import mint.render.luxe.Label;


import clases.*;
import ingameConfig.Config;

class GameState extends State {

  
  var state_machine : States;
   
  var canvas: mint.Canvas;
  var focus: ControllerFocus; 

  var block : Sprite;
  var fondo:Sprite;
  var victoria:Sprite;

  public var etFichasRestantes : Text;
  public var consejo : Text;
  public var textoReserva1 : Text;
  public var textoReserva2 : Text;

  var cambioTurno:mint.Button;
  var instrucciones:mint.Button;

  var posicionMouse : luxe.Vector;

  var pista1 : Pista;
  var pista2 : Pista;
  var recursos:Recursos;
  var ruleta:Ruleta;
  public var premios:Premios;

  var arrastrador: componentes.Arrastrador;
  public var turno : Int = 0;  //1 <, 2 >, 0 aun no empieza
  var anchoFichas : Float = Config.anchoFichas;
  public var fichasRestantes : Int =0;
  var tipoDeFichaArrastrada:Int=-1;  //0 para ficha de recursos, 1 para ficha de reserva
  var juegoTerminado:Bool=false;

  public function new(name:String) {
    super({name:name});

    state_machine = new States({ name:'statemachine' });
    state_machine.add(new PauseState('pause', resume));
  }

  override function onenter<T> (_:T) {
    trace("Gamestate--");   

    //cargando sprites de las fichas
    
    Config.imagenes  = {
      orientacion: [{
          alto : [{
              imagen:Luxe.resources.texture('assets/l0.png')
          },{
              imagen:Luxe.resources.texture('assets/l1.png')
          },{
              imagen:Luxe.resources.texture('assets/l2.png')
          },{
              imagen:Luxe.resources.texture('assets/l3.png')
          }]
        },{
          alto : [{
              imagen:Luxe.resources.texture('assets/r0.png')
          },{
              imagen:Luxe.resources.texture('assets/r1.png')
          },{
              imagen:Luxe.resources.texture('assets/r2.png')
          },{
              imagen:Luxe.resources.texture('assets/r3.png')
          }
      ]}
    ]};
    
    //var image = Luxe.resources.texture('assets/fondo.png');
    
    fondo = new Sprite({
       name: 'fondo',
       texture: Luxe.resources.texture('assets/a1.png'),
       pos: new Vector(Luxe.screen.mid.x, Luxe.screen.mid.y),
       size: new Vector(Luxe.screen.w,  Luxe.screen.h)
    });


    //ventanita
    var autoCanvas = new AutoCanvas(Luxe.camera.view, {
      name:'canvas',
      rendering: new LuxeMintRender(),
      options: {},
      //x: Luxe.screen.w-300, y:10, w: 300, h: 150
      x: 0 ,y: 0, w: Luxe.screen.w, h: Luxe.screen.h
    });
    autoCanvas.auto_listen();
    canvas=autoCanvas;
    focus = new ControllerFocus(canvas);

    //sprites

    ruleta=new Ruleta({
          name: 'ruleta',
          texture: Luxe.resources.texture('assets/r.png'),
          pos: new phoenix.Vector(Luxe.screen.w/2,57,0,0)

      });
    ruleta.setGamestate(this);

    recursos=new Recursos();

    pista1 = new Pista({
        name: 'pista1',
        pos: new phoenix.Vector(Luxe.screen.w/2-Config.anchoFichas*0.8,Luxe.screen.h/2+117,0,0),
        color: new Color(0,0,255,1.0),            
        size: new Vector(Config.anchoFichas, Config.longitudPista)
    });
    pista1.setTurno(1);
    pista1.setReserva(new Vector(pista1.pos.x-210,pista1.pos.y-372));
    pista1.setRecursos(recursos);
    textoReserva1 = new luxe.Text({
        color : new Color(0,0,0,1).rgb(0x000000),
        pos : new Vector(220,13),
        font : Luxe.renderer.font,
        point_size : 20,
        text: 'Reservas'
    });


    pista2 = new Pista({
        name: 'pista2',
        pos: new phoenix.Vector(Luxe.screen.w/2+Config.anchoFichas*0.8,Luxe.screen.h/2+117,0,0),
        color: new Color(0,255,255,1.0),            
        size: new Vector(Config.anchoFichas, Config.longitudPista)
    });
    pista2.setTurno(2);
    pista2.setReserva(new Vector(pista2.pos.x+210,pista2.pos.y-372));
    pista2.setRecursos(recursos);
    textoReserva2 = new luxe.Text({
        color : new Color(0,0,0,1).rgb(0x000000),
        pos : new Vector(662,13),
        font : Luxe.renderer.font,
        point_size : 20,
        text: 'Reservas'
    });


    //
    instrucciones = new mint.Button({
        parent: canvas,        
        name: 'instrucciones',
        x: Luxe.screen.w/2-45, y: 5, w: 90, h:22,        
        text:'Instrucciones',
        text_size: 14,
        options: {},
        onclick: function(e,c) {        
          pause();
        }
    });

    cambioTurno = new mint.Button({
        parent: canvas,        
        name: 'cambioTurno',
        x: Luxe.screen.w/2+36, y: 42, w: 40, h: 32,        
        text:'Iniciar!',
        text_size: 14,
        options: { 
          color: new Color().rgb(0x503200),
          color_hover: new Color().rgb(0xA9700D),
          label: { color:new Color().rgb(0xffffff)} 
        },

        onclick: function(e,c) {siguienteTurno();}
    });


    etFichasRestantes = new luxe.Text({
      color : new Color().rgb(0x000000),
      pos : new Vector(Luxe.screen.w/2-80,78),
      font : Luxe.renderer.font,
      point_size : 14
    });

    consejo = new luxe.Text({
      text: 'Consejo: \nclick en iniciar ¡buena suerte!',
      color : new Color().rgb(0x000000),
      pos : new Vector(Luxe.screen.w/2-125,110),
      font : Luxe.renderer.font,
      point_size : 14
    });
    
  }

  override public function onmousedown(event:MouseEvent):Void{
      trace(event.pos);
      var tipo=recursos.clickSpawn(event.pos,turno,fichasRestantes);
      if(tipo!=-1){              //si toma de los recursos
        tipoDeFichaArrastrada=0;
        block = new Sprite({
          name: 'arrastrable',
          texture: Config.imagenes.orientacion[turno-1].alto[tipo].imagen,
          pos: new phoenix.Vector(event.pos.x,event.pos.y,0,0),
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
              texture: Config.imagenes.orientacion[turno-1].alto[0].imagen,
              pos: new phoenix.Vector(event.pos.x,event.pos.y,0,0),
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
    if(premios.preguntarPremio(pista.obtenerFichasAcumuladas(),turno))return;
    if (turno==1)turno=2;
    else if (turno==2)turno=1;
  }

  function primerTurno(){
     
    premios = new Premios(); 
    fondo.texture=Luxe.resources.texture('assets/a2.png');
    turno=1;
  }

  function siguienteTurno(){
    if(!juegoTerminado){
      if(turno==0)primerTurno();
      else cambiarTurno();
      premios.premioMerecido=false;      
      ruleta.encender();
      cambioTurno.label.text='FIN \n turno';
      etFichasRestantes.text= 'Fichas restantes: -';
      if(Std.parseInt(recursos.restantes[turno-1][0].text)>0){
        consejo.text='Consejo: \narrastra fichas de 1/8 en la construcción';
      }else{
        consejo.text='Consejo: \nhaz un reemplazo para recuperar fichas';
      }
    }else reiniciar();
  }
  //para probar cosas
  function test(){
    pause();
  }

  function reiniciar(){
    if(!fondo.destroyed){
      fondo.destroy();
    } 
    if(!victoria.destroyed){
      victoria.destroy();
    } 
    if(!etFichasRestantes.destroyed){
      etFichasRestantes.destroy();
    } 
    if(!consejo.destroyed){
      consejo.destroy();
    }
    if(!cambioTurno.destroyed){
      cambioTurno.destroy();
    } 
    if(!instrucciones.destroyed){
      instrucciones.destroy();
    }
    if(!ruleta.destroyed){
     ruleta.destroy();
    }

    recursos.eliminarTodo();
    recursos=null;
    pista1.eliminarTodo();
    pista1=null;
    pista2.eliminarTodo();
    pista2=null;
    premios.eliminarTodo();
    premios=null;

    juegoTerminado=false;
    fichasRestantes=0;
    turno=0;

    machine.set('game_state');
  }

  override function onleave<T> (_:T) {
    trace("Leave game state");
    canvas.destroy();
  }

  function pause() {
    state_machine.set('pause');
    cambioTurno.visible=false;
    instrucciones.visible=false;
  }

  function resume() {
    instrucciones.visible=true;
    cambioTurno.visible=true;
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
          var exitoAnadir=pista.anadirFicha(j, event.pos);
          if(exitoAnadir!=0){ //si lo suelta dentro 
            if(tipoDeFichaArrastrada==0)fichasRestantes--;
            tipoDeFichaArrastrada=-1;
            etFichasRestantes.text='Fichas restantes: '+fichasRestantes;

            //eleccion de consejos
            if(pista.estaLlena()){
              consejo.text='Consejo: \n¡ya casi ganas!, completa el edificio \ncon fichas de un entero';
            }else{
              if(exitoAnadir==1){
                if(premios.cambiarMartillo(pista.obtenerFichasAcumuladas(),turno))
                  consejo.text='Consejo: \nestás en una zona premiada, si haces un \nreemplazo tendrás un turno extra';//--2
                else{
                  if(fichasRestantes>0){
                    if(Std.parseInt(recursos.restantes[i][j].text)>0){
                      consejo.text='Consejo:\narrastra fichas de 1/8 en la construcción';
                      cambioTurno.label.text='FIN \n turno';
                    }else{
                      consejo.text='Consejo: \nhaz un reemplazo para recuperar fichas';
                    }
                  }else consejo.text='Consejo: \nya ocupaste todas las fichas de este \nturno, puedes terminar tu turno';
                }
              }              
            }

            
          }else{ //si lo suelta fuera
            recursos.restantes[i][j].text=""+(Std.parseInt(recursos.restantes[i][j].text)+1);
            recursos.spawn[i][j].visible=true;
          }
        }else{      //si se esta reemplazando
          if(pista.identificarReemplazo(block,turno)){  //cambiando el coton del siguiente turno
            if(premios.merecePremio(pista.obtenerFichasAcumuladas(),turno)){
              cambioTurno.label.text='turno \nextra';
              consejo.text='Consejo: \n¡tienes un turno extra! recuerda dejar las\nfichas que sobren en la reserva';
            }
            if(Std.parseInt(recursos.restantes[i][3].text)==0){
              juegoTerminado=true;
              cambioTurno.label.text=' re-\niniciar';
              if(i==0){
                consejo.text='¡Genial! \n¡el jugador de la izquierda ha ganado!';
                victoria = new Sprite({
                   name: 'victoria',
                   texture: Luxe.resources.texture('assets/z.png'),
                   pos: new Vector(309,416,0,0),                  
                   size: new Vector(Config.anchoFichas-13, Config.longitudPista+43,0,0)
                });

              }
              if(i==1){
                consejo.text='¡Genial! \n¡el jugador de la derecha ha ganado!';
                victoria = new Sprite({
                   name: 'victoria',
                   texture: Luxe.resources.texture('assets/z.png'),
                   pos: new Vector(657,416,0,0),                   
                   size: new Vector(Config.anchoFichas-13, Config.longitudPista+43,0,0)
                });
              }
            }
          }else recursos.restantes[i][j].text=""+(Std.parseInt(recursos.restantes[i][j].text)+1);
        }  

        block.destroy();
        block=null;    
        
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
    if(recursos!=null){
      for(i in 0...2){
        for(j in 0...4){
          if(Std.parseInt(recursos.restantes[i][j].text)>0)recursos.spawn[i][j].visible=true;        
        }
      }
    }
    

    if (state_machine.current_state != null &&
        state_machine.current_state.name == "pause") {
          // We don't do anything while paused
          return;
    }
  }

}
