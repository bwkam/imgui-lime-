package;

import lime.graphics.Canvas2DRenderContext;
import lime.app.Application;
import lime.graphics.RenderContext;
import imgui.ImGui;
import imgui.Helpers.*;

class Main extends Application {
	var init:Bool = false;
	var ready:Bool = false;

	static var ImGui_Impl(get, never):Dynamic;
	static var framePending:Bool = false;

	inline static function get_ImGui_Impl():Dynamic
		return untyped window.ImGui_Impl;

	static var io:ImGuiIO = null;

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
				Reflect.field(untyped window.ImGui, 'default')().then(function() {
					initImGui(done, canvas);
				}, function() {
					trace('Failed to load ImGui bindings');
				});
			});
		});
	}

	static function initImGui(done:() -> Void, canvas:Canvas2DRenderContext) {
		ImGui.createContext();
		ImGui.styleColorsDark();
		ImGui_Impl.Init(canvas);

		io = ImGui.getIO();

		done();
	}

	public static function newFrame():Void {
		ImGui_Impl.NewFrame(haxe.Timer.stamp() * 1000);
		ImGui.newFrame();

		framePending = true;
	}

	public static function endFrame():Void {
		if (!framePending)
			return;
		framePending = false;

		ImGui.endFrame();
		ImGui.render();

		ImGui_Impl.RenderDrawData(ImGui.getDrawData());

		// clay.Clay.app.runtime.skipKeyboardEvents = io.wantCaptureKeyboard;
		// clay.Clay.app.runtime.skipMouseEvents = io.wantCaptureMouse;
	}

	public override function render(context:RenderContext):Void {
		switch (context.type) {
			case CANVAS:
				var ctx = context.canvas2D;
				var someFloat = 0.2;

				if (!init) {
					initialize(() -> ready = true, ctx);
				}

				// initGui(() -> {})

				ctx.fillStyle = "#BFFF00";

				ctx.fillRect(0, 0, window.width, window.height);

				if (ready) {
					trace("yo");
					newFrame();

					ImGui.begin('Hello');

					ImGui.sliderFloat('Some slider', fromFloat(someFloat), 0.0, 1.0);

					if (someFloat == 1.0) {
						ImGui.text('Float value is at MAX (1.0)');
					}

					ImGui.end();

					endFrame();
				}

			default:
		}
	}
}
