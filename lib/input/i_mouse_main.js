// Generated by CoffeeScript 1.11.1
(function() {
  TSAG.I_Mouse_Main = (function() {
    function I_Mouse_Main(scene, camera) {
      this.scene = scene;
      this.camera = camera;
      this.create_cursor();
      this.road_build_controller = new TSAG.I_Mouse_Build_Road(this.scene, this.camera);
      this._current_mouse_input_controller = this.road_build_controller;
      this.state = "idle";
      this._min_dist = 10;
    }

    I_Mouse_Main.prototype.create_cursor = function() {
      var h, mesh, mesh_factory, params, scale, w;
      mesh_factory = new TSAG.Unit_Meshes();
      params = {
        color: TSAG.style.cursor_circle_color
      };
      mesh = mesh_factory.newCircle(params);
      scale = TSAG.style.cursor_circle_radius;
      mesh.position.z = TSAG.style.cursor_circle_z;
      w = scale;
      h = scale;
      scale = mesh.scale;
      scale.x = w;
      scale.y = h;
      this.scene.addOverlayVisual(mesh);
      return this.pointer = mesh;
    };

    I_Mouse_Main.prototype.mouse_down = function(event) {
      return this._current_mouse_input_controller.mouse_down(event);
    };

    I_Mouse_Main.prototype.mouse_up = function(event) {
      return this._current_mouse_input_controller.mouse_up(event);
    };

    I_Mouse_Main.prototype.mouse_move = function(event) {
      var pos;
      pos = this.pointer.position;
      pos.x = event.x;
      pos.y = event.y;
      return this._current_mouse_input_controller.mouse_move(event);
    };

    return I_Mouse_Main;

  })();

}).call(this);