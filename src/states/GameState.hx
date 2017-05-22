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
        ancho : 63,
        color : 0xff0000
      },{
        ancho : 95,
        color : 0xf94b04
      },{
        ancho : 127,
        color : 0xff00d9
      },{
        ancho : 31,
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
  var spawn : Sprite;
  var posicionMouse : luxe.Vector;
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
    trace("--en chequearReemplazoRecursivo ver si es lengh o lengh-1 en los if");

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
        spawn.destroy();
        indicadorTurno.destroy();
        pista1.listaFichas=[];
        pista2.listaFichas=[];
        turno=false;
        Main.machine.set("game_state");
      }
    });

    spawn = new Sprite({
        name: 'spawn',
        pos: new phoenix.Vector(500,100,0,0),
        color: new Color().rgb(0xff00d9),
        size: new Vector(128, 128), 
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

  }

  override public function onmousedown(event:MouseEvent):Void{
      trace(event.pos.x+'-'+event.pos.y);
      if(spawn.point_inside(event.pos)){   
          block = new Sprite({
            name: 'bloque',
            pos: new phoenix.Vector(spawn.pos.x,spawn.pos.y,0,0),
            color: new Color().rgb(0xff00d9),
            size: new Vector(128, 128), 

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
  //para probar cosas
  function test(){
    for(a in 0...pista1.listaFichas.length){
        //pista1.listaFichas[a].destroy();
      }

  }
  //sustituye el sprite por las fichas, si corresponde
  function identificarReemplazo(ancho : Float, col : Color){
    var acum : Float=0;
    var primero : Int = -1;
    var ultimo : Int = -1;
    var pista : Int = -1;
    for(a in 0...pista1.listaFichas.length){
      if(block.point_inside(pista1.listaFichas[a].pos)) {
        if(pista1.listaFichas[a].size.x+1<ancho){
          pista=1;
          acum=acum+pista1.listaFichas[a].size.x+1;
          if(primero==-1){
            primero=a;
          }else ultimo=a;
        }
      }
    }
    for(a in 0...pista2.listaFichas.length){
      if(block.point_inside(pista2.listaFichas[a].pos)) {
        if(pista2.listaFichas[a].size.x+1<ancho){
          pista=2;
          acum=acum+pista2.listaFichas[a].size.x+1;   
          if(primero==-1){
            primero=a;
          }else ultimo=a;     
        }
      }  
    }
    if(acum==ancho){
      trace('primero.'+primero+' ultimo.'+ultimo+' pista.'+pista); 

      acum=0;

      if(primero!=-1 && ultimo != -1){
        trace('dentro de primer if');
        if(pista==1){          
          
          
          for(a in primero...ultimo+1){
            acum1=acum1-pista1.listaFichas[a].size.x-1;
            pista1.listaFichas[a].destroy();            
          } 

          pista1.listaFichas.splice(primero,ultimo-primero+1);          

          

          pista1.listaFichas.push(
            new Sprite({
            pos: new phoenix.Vector(acum1+(ancho-1)/2+75,475,0,0),
            color: col,
            size: new Vector(ancho-1, 128), 
          }));
          acum1=acum1+ancho;
          var componenteColor= new componentes.SensorClick({ name:'sensor' });
          componenteColor.colorInicial(col);
          pista1.listaFichas[pista1.listaFichas.length-1].add(componenteColor);

          pista1.listaFichas.insert(primero,pista1.listaFichas.pop());

          for(a in 0...pista1.listaFichas.length){
            trace(a);
            var extra= pista1.listaFichas[a].size.x;
            pista1.listaFichas[a].pos.x=acum+extra/2+75;
            acum=acum+extra+1;
          }           

          trace('pasó');
        }else if(pista==2){

          
          
          for(a in primero...ultimo+1){
              acum2=acum2-pista2.listaFichas[a].size.x-1;
              pista2.listaFichas[a].destroy();          
          } 
          
          pista2.listaFichas.splice(primero,ultimo-primero+1);
          
          pista2.listaFichas.push(
            new Sprite({
            pos: new phoenix.Vector(acum2+(ancho-1)/2+75,300,0,0),
            color: col,
            size: new Vector(ancho-1, 128), 
          }));
          acum2=acum2+ancho;
          var componenteColor= new componentes.SensorClick({ name:'sensor' });
          componenteColor.colorInicial(col);
          pista2.listaFichas[pista2.listaFichas.length-1].add(componenteColor);

          pista2.listaFichas.insert(primero,pista2.listaFichas.pop());

          for(a in 0...pista2.listaFichas.length){
            trace(a);
            var extra= pista2.listaFichas[a].size.x;
            pista2.listaFichas[a].pos.x=acum+extra/2+75;
            acum=acum+extra+1;
          }

        }
      }
      
    }
    block.destroy(); 
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

    var indice1: Int=-1;
    var indice2: Int=-1;

    if(Luxe.input.mousereleased(luxe.MouseButton.left)){
      if(block!=null){
        if(!block.destroyed){
          identificarReemplazo(block.size.x,block.color);
                   
        }
      }
      
    }

    //iontercambio
    if(turno){//intercambio de fichas pista 1
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
        for(a in 0...pista1.listaFichas.length){ //--se puede optimizar no partiendo de 0
          var extra= pista1.listaFichas[a].size.x;
          pista1.listaFichas[a].pos.x=acum+extra/2+75;
          acum=acum+extra+1;
        }
      }

    }else{ //intercambio de fichas pista2
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
