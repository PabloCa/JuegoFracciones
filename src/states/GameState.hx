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

class GameState extends State {

  
  var state_machine : States;

  var fichas = {
    tipos: [{
        ancho : 64,
        color : 0xff0000
      },{
        ancho : 96,
        color : 0xf94b04
      },{
        ancho : 128,
        color : 0xff00d9
      },{
        ancho : 32,
        color : 0x00ff00
      }
    ]
  };
  
  var fondo:Geometry;
  var canvas: mint.Canvas;
  var focus: ControllerFocus; 
  var delta_time_text : Text;
  var text1: mint.TextEdit;
  var block : Sprite;
  var indicadorTurno : Sprite;
  var pista1 ={
    sprite : null,
    listaFichas : []
  };
  var pista2 ={
    sprite : null,
    listaFichas : []
  };
  var arrastrador: componentes.Arrastrador;
  var acum1 : Float=0;   //se pueden poner en la funcion colocar, localmente
  var acum2 : Float=0;
  var longitudPista : Float=750;
  var turno : Bool = false;  //false arriba true abajo

  public function new(name:String) {
    super({name:name});

    state_machine = new States({ name:'statemachine' });
    state_machine.add(new PauseState('pause', resume));
  }

  override function onenter<T> (_:T) {
    trace("Game state");

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
        point_size : 20
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
            parent: window, name: 'textedit1', text: 'hola', renderable: true,
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

    //sprites

    pista1.sprite = new Sprite({
        name: 'pista1',
        pos: new phoenix.Vector(450,475,0,0),
        color: new Color(0,0,255,1.0),            
        size: new Vector(longitudPista, 168)
    });

    pista2.sprite = new Sprite({
        name: 'pista2',
        pos: new phoenix.Vector(450,300,0,0),
        color: new Color(0,0,255,1.0),            
        size: new Vector(longitudPista, 168)
    });

    var boton_bajar = new mint.Button({
      parent: window,
      name: 'boton2',
      x: 130, y: 60, w: 110, h: 22,
      text: 'reiniciar',
      text_size: 12,
      options: { },
      onclick: function(_, _) {
        trace('reiniciando');
        acum1=acum2=0;
        acum1=acum2=0;

        for(a in 0...pista1.listaFichas.length){
          pista1.listaFichas[a].destroy();
        }
        for(a in 0...pista2.listaFichas.length){
          pista2.listaFichas[a].destroy();
        }
        pista1.sprite.destroy();
        pista2.sprite.destroy();
        block.destroy();
        indicadorTurno.destroy();
        pista1.listaFichas=[];
        pista2.listaFichas=[];
        turno=false;
        Main.machine.set("game_state");
      }
    });

    block = new Sprite({
        name: 'a sprite',
        pos: new phoenix.Vector(500,100,0,0),
        color: new Color().rgb(0xf94b04),
        size: new Vector(128, 128), 

    });
    arrastrador = new componentes.Arrastrador({ name:'arrastrador' });
    block.add(arrastrador);
    arrastrador.setMeta(pista1.sprite);

    indicadorTurno = new Sprite({
        name: 'indicador',
        pos: new phoenix.Vector(30,300,0,0),
        color: new Color().rgb(0x000000),
        size: new Vector(30, 30), 
        geometry: Luxe.draw.circle({
          r : 20,
        })

    });
    
    

  }
  function colocar(){
    var extra : Float=0;
    var color: Int=0;
    var random: Int = Luxe.utils.random.int(0,4);
    extra=fichas.tipos[random].ancho;
    color=fichas.tipos[random].color;

    if(turno){  //poniendo fichas

      pista1.listaFichas.push(
        new Sprite({
        pos: new phoenix.Vector(acum1+extra/2+75,475,0,0),
        color: new Color().rgb(color),
        size: new Vector(extra, 128), 
      }));
      acum1=acum1+extra+1;
      var componenteColor= new componentes.SensorClick({ name:'sensor' });
      componenteColor.colorInicial(new Color().rgb(color));
      pista1.listaFichas[pista1.listaFichas.length-1].add(componenteColor);

    }else{

      pista2.listaFichas.push(
        new Sprite({
        pos: new phoenix.Vector(acum2+extra/2+75,300,0,0),
        color: new Color().rgb(color),
        size: new Vector(extra, 128), 
      }));
      acum2=acum2+extra+1;
      var componenteColor= new componentes.SensorClick({ name:'sensor' });
      componenteColor.colorInicial(new Color().rgb(color));
      pista2.listaFichas[pista2.listaFichas.length-1].add(componenteColor);

    }
    text1.text='';
    if(longitudPista<acum1)text1.text=text1.text+'-partida terminada1';
    else if(longitudPista<acum2)text1.text=text1.text+'-partida terminada2';

    
    turno=!turno;
    if(turno){    //indicador de turno
      indicadorTurno.pos =new phoenix.Vector(30,475,0,0);
    }else{
      indicadorTurno.pos =new phoenix.Vector(30,300,0,0);
    }

  }

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

  override function update( dt:Float ) {

    focus.update(dt);
    delta_time_text.text = 'dt : ' + dt + '\n average : ' + Luxe.debug.dt_average+'\n fps : ' + 1/Luxe.debug.dt_average;

    var indice1: Int=-1;
    var indice2: Int=-1;
    if(turno){
      for(a in 0...pista1.listaFichas.length){
        if(pista1.listaFichas[a].get('sensor').estaSeleccionado()){
          if(indice1<0)indice1=a;
          else indice2=a;
        }
      }
      if(indice2>-1){
        
        var aux :Sprite=pista1.listaFichas[indice1];
        var acum : Float =0;
        //cambiando la posicion en el array
        pista1.listaFichas[indice1]=pista1.listaFichas[indice2];
        pista1.listaFichas[indice2]=aux;
        pista1.listaFichas[indice1].get('sensor').quitarSeleccion();
        pista1.listaFichas[indice2].get('sensor').quitarSeleccion();
        //reposicionando
        for(a in 0...pista1.listaFichas.length){
          var extra= pista1.listaFichas[a].size.x;
          pista1.listaFichas[a].pos.x=acum+extra/2+75;
          acum=acum+extra+1;
        }
      }

    }else{
      for(a in 0...pista2.listaFichas.length){
        if(pista2.listaFichas[a].get('sensor').estaSeleccionado()){
          if(indice1<0)indice1=a;
          else indice2=a;
        }
      }
      if(indice2>-1){
        
        var aux :Sprite=pista2.listaFichas[indice1];
        var acum : Float =0;
        //cambiando la posicion en el array
        pista2.listaFichas[indice1]=pista2.listaFichas[indice2];
        pista2.listaFichas[indice2]=aux;
        pista2.listaFichas[indice1].get('sensor').quitarSeleccion();
        pista2.listaFichas[indice2].get('sensor').quitarSeleccion();
        //reposicionando
        for(a in 0...pista2.listaFichas.length){
          var extra= pista2.listaFichas[a].size.x;
          pista2.listaFichas[a].pos.x=acum+extra/2+75;
          acum=acum+extra+1;
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
