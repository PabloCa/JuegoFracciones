package states;
import luxe.States;
import luxe.Text;
import luxe.Input;
import luxe.Input.GamepadEvent;

import luxe.Sprite;
import luxe.Draw;
import mint.render.luxe.LuxeMintRender;
import phoenix.geometry.Geometry;
import luxe.Color;
import lib.AutoCanvas;
import luxe.Vector;

import componentes.Arrastrador;
/**
 * Example game state. Shows controller input.
 */
class GameState extends State {
  var state_machine : States;

  var fondo:Geometry;
  var canvas: mint.Canvas;
  var focus: ControllerFocus; 
  var delta_time_text : Text;
  var text1: mint.TextEdit;
  var block : Sprite;
  var meta : Sprite;
  var arrastrador: Arrastrador;
  var restante : Float;

  public function new(name:String) {
    super({name:name});

    state_machine = new States({ name:'statemachine' });
    state_machine.add(new PauseState('pause', resume));
  }

  override function onenter<T> (_:T) {
    trace("Arreglar el onleave");

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

    var boton_bajar = new mint.Button({
      parent: window,
      name: 'boton2',
      x: 130, y: 60, w: 110, h: 22,
      text: 'reiniciar',
      text_size: 12,
      options: { },
      onclick: function(_, _) {
        Main.machine.set("game_state");
      }
    });

    //sprites

    meta = new Sprite({
        name: 'meta',
        pos: new phoenix.Vector(450,475,0,0),
        color: new Color(0,0,255,1.0),            
        size: new Vector(750, 168)
    });
    restante=meta.size.x;
    text1.text=restante+'';

    block = new Sprite({
        name: 'a sprite',
        pos: new phoenix.Vector(500,100,0,0),
        color: new Color().rgb(0xf94b04),
        size: new Vector(128, 128), 

    });
    arrastrador = new Arrastrador({ name:'arrastrador' });
    block.add(arrastrador);
    arrastrador.setMeta(meta);

    /*Luxe.draw.ngon({
      r:200,
      sides : 3,
      solid : true,
      color: new Color(1,1,1,0.1),
      x:Luxe.screen.mid.x, y:Luxe.screen.mid.y
    });*/

  }
  function colocar(){


    switch Luxe.utils.random.int(1,5) {
      case 1:{
        Luxe.draw.box({

            x : 75+meta.size.x-restante, y : 412,
            w : 64,
            h : 128,      
            color : new Color().rgb(0xff0000)
        });
        restante=restante-65;
      };
      case 2: {
        Luxe.draw.box({
            x : 75+meta.size.x-restante, y : 412,
            w : 96,
            h : 128,      
            color : new Color().rgb(0xf94b04)
        });
        restante=restante-97;
      };
      case 3: {
        Luxe.draw.box({
            x : 75+meta.size.x-restante, y : 412,
            w : 128,
            h : 128,      
            color : new Color().rgb(0xffff00)
        });
        restante=restante-129;
      };
      case 4: {
        Luxe.draw.box({
            x : 75+meta.size.x-restante, y : 412,
            w : 32,
            h : 128,      
            color : new Color().rgb(0x00ff00)
        });
        restante=restante-33;
      };
      default: {text1.text='error';};
    }
    
    text1.text=restante+'';
    if(restante<=0)text1.text=text1.text+'-partida terminada';
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

    if (state_machine.current_state != null &&
        state_machine.current_state.name == "pause") {
          // We don't do anything while paused
          return;
    }
  }
}
