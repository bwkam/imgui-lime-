package;

import lime.graphics.Canvas2DRenderContext;
import lime.app.Application;
import lime.graphics.RenderContext;
import imgui.ImGui;
import imgui.Helpers.*;

class Main extends Application {
	var init:Bool = false;

	public function new() {
		super();
		init = false;
	}

	public function initialize(done:() -> Void, canvas:Canvas2DRenderContext):Void {
		if (preloader.complete) {
			loadImGui(done, canvas);
			init = true;
		}
	}

	static function loadScript(src:String, done:Bool->Void) {
		var didCallDone = false;

		var script = js.Browser.document.createScriptElement();
		script.setAttribute('type', 'text/javascript');
		script.addEventListener('load', function() {
			if (didCallDone)
				return;
			didCallDone = true;
			done(true);
		});
		script.addEventListener('error', function() {
			if (didCallDone)
				return;
			didCallDone = true;
			done(false);
		});
		script.setAttribute('src', src);

		js.Browser.document.head.appendChild(script);
	}

	static function loadImGui(done:() -> Void, canvas:Canvas2DRenderContext) {
		loadScript('assets/imgui.umd.js', function(_) {
			loadScript('assets/imgui_impl.umd.js', function(_) {
				trace("finished loading scripts");
			});
		});
	}

	public override function render(context:RenderContext):Void {
		switch (context.type) {
			case CANVAS:
				var ctx = context.canvas2D;
				var someFloat = 0.2;

				if (!init) {
					initialize(() -> {
						ImGui.begin('Hello');

						ImGui.sliderFloat('Some slider', fromFloat(someFloat), 0.0, 1.0);

						if (someFloat == 1.0) {
							ImGui.text('Float value is at MAX (1.0)');
						}

						ImGui.end();
					}, ctx);
				}

				ctx.fillStyle = "#BFFF00";

				ctx.fillRect(0, 0, window.width, window.height);

			default:
		}
	}
}
