package states;
import luxe.States;
import Sys;
import lib.AutoCanvas;
import mint.layout.margins.Margins;
import luxe.Color;

import mint.render.luxe.LuxeMintRender;

/**
 * Pause State.
 */
class PauseState extends State {

  var canvas: mint.Canvas;
  var focus: ControllerFocus;
  var resume: Void -> Void;
  var fondo: mint.Image;

  public function new(name:String, resume:Void->Void) {
    super({ name:name });
    this.resume = resume;
  }

  override function onenter<T> (_:T) {
    trace("Enter pause state");

    var a_canvas = new AutoCanvas(Luxe.camera.view, {
      name:'canvas',
      rendering: new LuxeMintRender(),
      options: { },
      x: 0, y:0, w: Luxe.screen.w, h: Luxe.screen.h
    });
    a_canvas.auto_listen();

    canvas = a_canvas;
    focus = new ControllerFocus(canvas);

    var panel = new mint.Panel({
      parent: canvas,
      name: 'panel',
      x: 0, y: 0, w: Luxe.screen.w, h: Luxe.screen.h
    });
    fondo = new mint.Image({
            parent: panel,
            name: 'fondo',
            x: 0, y: 0, w: Luxe.screen.w, h: Luxe.screen.h,
            options: { },
            path: 'assets/instrucciones.png'
        });

    var title = new mint.Label({
        parent: panel,
        name: 'title',
        x:700, y:500, w:300, h:64,
        text: '',
        align:center,
        text_size: 36,
        options: { color: new Color().rgb(0x000000)},
        
    });

    var resume_button = new mint.Button({
      parent: panel,
      name: 'resume_button',
      x: 600, y: 50, w: 320, h: 64,
      text: 'Ir al juego',
      text_size: 28,
      options: { 
        color: new Color().rgb(0x175d5f),
        color_hover:new Color().rgb(0x328284),
        color_down: new Color().rgb(0x328284),
      },
      onclick: function(_, _) {
        resume();
      }
    });

    
  }

  override function onleave<T> (_:T) {
    trace("Leave pause state");
    canvas.destroy();
  }

  override function update(elapsed:Float) {
    focus.update(elapsed);
  }
}
