package states;
import luxe.States;
import luxe.Text;
import luxe.Input;
import luxe.Input.GamepadEvent;

import luxe.Sprite;
import mint.render.luxe.LuxeMintRender;
import phoenix.geometry.Geometry;
import luxe.Color;
import lib.AutoCanvas;
import luxe.Vector;

import entidades.*;
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
  var spawn1 : Sprite;
  var spawn2 : Sprite;
  var spawn3 : Sprite;
  var spawn0 : Sprite;
  var posicionMouse : luxe.Vector;

  var pista1 : Pista;
  var pista2 : Pista;
  var arrastrador: componentes.Arrastrador;
  var acum1 : Float=0;   //se pueden poner en la funcion colocar, localmente
  var acum2 : Float=0;
  var turno : Bool = false;  //false arriba true abajo
  var altoFichas : Float = Config.altoFichas;

  public function new(name:String) {
    super({name:name});

    state_machine = new States({ name:'statemachine' });
    state_machine.add(new PauseState('pause', resume));
  }

  override function onenter<T> (_:T) {
    trace("Gamestate");   


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
      x: Luxe.screen.w-300, y:10, w: 300, h: 150
    });
    autoCanvas.auto_listen();
    canvas=autoCanvas;
    focus = new ControllerFocus(canvas);

    var window = new mint.Window({
        parent: canvas,name: 'window', title: 'window',
        visible: true, closable: false, collapsible: true,
        x:0, y:0, w:256, h: 131,
        h_max: 131, h_min: 131, w_min: 131,
    });
    text1 = new mint.TextEdit({
            parent: window, name: 'textedit1', text: '>:D', renderable: true,
            x: 10, y:32, w: 256-10-10, h: 22
        });

    var boton_subir = new mint.Button({
          parent: window,
          name: 'boton1',
          x: 10, y: 60, w: 110, h: 22,
          text: 'ejec',
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
        acum1=acum2=0;

        for(a in 0...pista1.listaFichas.length){
          pista1.listaFichas[a].destroy();
        }
        for(a in 0...pista2.listaFichas.length){
          pista2.listaFichas[a].destroy();
        }
        pista1.destroy();
        pista2.destroy();
        spawn1.destroy();
        spawn2.destroy();
        spawn3.destroy();
        indicadorTurno.destroy();
        pista1.listaFichas=[];
        pista2.listaFichas=[];
        turno=false;
        Main.machine.set("game_state");
      }
    });

    //sprites

    pista1 = new Pista({
        name: 'pista1',
        pos: new phoenix.Vector(Luxe.screen.w/2,475,0,0),
        color: new Color(0,0,255,1.0),            
        size: new Vector(Config.longitudPista, altoFichas*1.3)
    });

    pista2 = new Pista({
        name: 'pista2',
        pos: new phoenix.Vector(Luxe.screen.w/2,300,0,0),
        color: new Color(0,0,255,1.0),            
        size: new Vector(Config.longitudPista, altoFichas*1.3)
    });

    
    spawn0 = new Sprite({
        name: 'spawn',
        pos: new phoenix.Vector(50,100,0,0),
        color: new Color().rgb(Config.fichas.tipos[0].color),
        size: new Vector(Config.fichas.tipos[0].ancho, altoFichas), 
    });
    spawn1 = new Sprite({
        name: 'spawn',
        pos: new phoenix.Vector(100,100,0,0),
        color: new Color().rgb(Config.fichas.tipos[1].color),
        size: new Vector(Config.fichas.tipos[1].ancho, altoFichas), 
    });
    spawn2 = new Sprite({
        name: 'spawn',
        pos: new phoenix.Vector(200,100,0,0),
        color: new Color().rgb(Config.fichas.tipos[2].color),
        size: new Vector(Config.fichas.tipos[2].ancho, altoFichas), 
    });
    spawn3 = new Sprite({
        name: 'spawn',
        pos: new phoenix.Vector(400,100,0,0),
        color: new Color().rgb(Config.fichas.tipos[3].color),
        size: new Vector(Config.fichas.tipos[3].ancho, altoFichas), 
    });

    indicadorTurno = new Sprite({
        name: 'indicador',
        pos: new phoenix.Vector(30,300,0,0),
        color: new Color().rgb(0x000000),
        size: new Vector(30, 30), 
        geometry: Luxe.draw.circle({
          r : 20,
        })

    });  

    //delta_time_text.text = 'con ejec se ponen fichitas \n se pueden cambiar las fichas seleccionandolas con click \n solo se pueden cambiar si el circulo apunta a la pista de las fichas \n el cuadrado de al lado se puede arastrar ---> \n si se arrastra a un grupo de fichas que sumadas tengan el mismo ancho \n que el cuadrado, estas fichitas se reemplazaran por una ficha rosa';

  }

  override public function onmousedown(event:MouseEvent):Void{

      if(spawn1.point_inside(event.pos)){   
        block = new Sprite({
          name: 'bloque',
          pos: new phoenix.Vector(spawn1.pos.x,spawn1.pos.y,0,0),
          color: new Color().rgb(Config.fichas.tipos[1].color),
          size: new Vector(Config.fichas.tipos[1].ancho, altoFichas), 

        });
        arrastrador = new componentes.Arrastrador({ name:'arrastrador' });
        block.add(arrastrador);    
      }else if(spawn2.point_inside(event.pos)){
        block = new Sprite({
          name: 'bloque',
          pos: new phoenix.Vector(spawn2.pos.x,spawn2.pos.y,0,0),
          color: new Color().rgb(Config.fichas.tipos[2].color),
          size: new Vector(Config.fichas.tipos[2].ancho, altoFichas), 

        });
        arrastrador = new componentes.Arrastrador({ name:'arrastrador' });
        block.add(arrastrador); 
      }else if(spawn3.point_inside(event.pos)){  
        block = new Sprite({
          name: 'bloque',
          pos: new phoenix.Vector(spawn3.pos.x,spawn3.pos.y,0,0),
          color: new Color().rgb(Config.fichas.tipos[3].color),
          size: new Vector(Config.fichas.tipos[3].ancho, altoFichas), 

        });
        arrastrador = new componentes.Arrastrador({ name:'arrastrador' });
        block.add(arrastrador); 
      }else if(spawn0.point_inside(event.pos)){  
        block = new Sprite({
          name: 'bloque',
          pos: new phoenix.Vector(spawn0.pos.x,spawn0.pos.y,0,0),
          color: new Color().rgb(Config.fichas.tipos[0].color),
          size: new Vector(Config.fichas.tipos[0].ancho, altoFichas), 

        });
        arrastrador = new componentes.Arrastrador({ name:'arrastrador' });
        block.add(arrastrador); 
      }
  }
  

  override function onmousemove( event:MouseEvent ) {     
    posicionMouse=event.pos;
  }

  //coloca las fichitas
  function colocar(){

    //var random: Int = Luxe.utils.random.int(0,4);
    var random: Int = Luxe.utils.random.int(0,3);
    text1.text='';

    if(turno){  //poniendo fichas

      //if(!pista1.colocar(Config.fichas.tipos[random].ancho,new Color().rgb(Config.fichas.tipos[random].color)))text1.text='gana el de abajo';
      
      for(i in 0...random){
        if(!pista1.colocar(Config.fichas.tipos[0].ancho,new Color().rgb(Config.fichas.tipos[0].color)))text1.text='gana el de abajo';
      }
      

    }else{
      //if(!pista2.colocar(Config.fichas.tipos[random].ancho,new Color().rgb(Config.fichas.tipos[random].color)))text1.text='gana el de arriba';
      
      for(i in 0...random){
        if(!pista2.colocar(Config.fichas.tipos[0].ancho,new Color().rgb(Config.fichas.tipos[0].color)))text1.text='gana el de arriba';
      }
      
    }
    
    turno=!turno;


    if(turno){    //indicador de turno(la pelotita)
      indicadorTurno.pos.y=475;
    }else{
      indicadorTurno.pos.y=300;
    }
  }

  //para probar cosas
  function test(){
    for(a in 0...pista1.listaFichas.length){
        //pista1.listaFichas[a].destroy();
      }

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

  override function update( dt:Float ) {

    focus.update(dt);
    //delta_time_text.text = 'dt : ' + dt + '\n average : ' + Luxe.debug.dt_average+'\n fps : ' + 1/Luxe.debug.dt_average;


    if(Luxe.input.mousereleased(luxe.MouseButton.left)){ // si se suelta el bloque que se estaba arrastrando
      if(block!=null){
        if(!block.destroyed){
          if(turno){
            pista1.identificarReemplazo(block);
          }else pista2.identificarReemplazo(block);     
                   
        }
      }      
    }

    var indice1: Int=-1;
    var indice2: Int=-1;


    //iontercambio
    if(turno){
      for(a in 0...pista1.listaFichas.length){ //identificando los indices
        if(pista1.listaFichas[a].get('sensor').estaSeleccionado()){
          if(indice1<0)indice1=a;
          else indice2=a;
        }
      }
      if(indice2>-1){
        pista1.intercambiar(indice1, indice2);
      }

    }else{ //intercambio de fichas pista2

      for(a in 0...pista2.listaFichas.length){
        if(pista2.listaFichas[a].get('sensor').estaSeleccionado()){
          if(indice1<0)indice1=a;
          else indice2=a;
        }
      }

      if(indice2>-1){
        pista2.intercambiar(indice1, indice2);
      }
    }

    

    if (state_machine.current_state != null &&
        state_machine.current_state.name == "pause") {
          // We don't do anything while paused
          return;
    }
  }

}
