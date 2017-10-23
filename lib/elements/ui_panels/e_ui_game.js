// Generated by CoffeeScript 1.11.1

/*
    SimUrban Game User Interface.
    Written by Bryce on 4.30.2017
    
    Purpose: This class represents the particular state for the game's ui in its main gameplay state,
        - includes side buttons on the left of the screen.
        - Statistical displays on the bottom of the screen.
        - Messages.

        This class also handles the text based display of information to the users.
 */

(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  TSAG.E_UI_Game = (function(superClass) {
    extend(E_UI_Game, superClass);

    function E_UI_Game(scene) {
      this.scene = scene;
      E_UI_Game.__super__.constructor.call(this, this.scene);
      this.happy_trips = 0;
      this.total_trips = 0;
      this.cost = 0;
      this.createButtons();
      this.createStaticObjects();
      this.changeMessageText("Default Message");
    }

    E_UI_Game.prototype.createButtons = function() {
      var dim_highlight_button, dim_road_button, dim_stats_button, func_build_road, func_highlight, func_stats, pline_highlight_button, pline_road_button, pline_stats_button, view;
      this.mouse_controller = this.scene.get_io_mouse();
      this.controller_build_road = this.mouse_controller.getRoadBuild();
      this.controller_build_road.setActive(true);

      /*
      @controller_demolish_road = mouse_controller.getRoadDestroy()
      @controller_demolish_road.setActive(false)
       */
      this.controller_highlight = this.mouse_controller.getHighlight();
      this.controller_highlight.setActive(true);
      this.controller_stats = this.mouse_controller.getStats();
      this.controller_stats.setActive(false);
      view = this.getVisual();
      dim_road_button = {
        x: 16,
        y: 32,
        w: 64,
        h: 64
      };
      this.img_road_button = TSAG.style.newSprite("images/road.png", dim_road_button);
      view.add(this.img_road_button);
      dim_stats_button = {
        x: 16,
        y: 96,
        w: 64,
        h: 64
      };
      this.img_stats_button = TSAG.style.newSprite("images/stats.png", dim_stats_button);
      view.add(this.img_stats_button);
      dim_highlight_button = {
        x: 16,
        y: 160,
        w: 64,
        h: 64
      };
      this.img_highlight_button = TSAG.style.newSprite("images/highlight.png", dim_highlight_button);
      view.add(this.img_highlight_button);
      pline_road_button = BDS.Polyline.newRectangle(dim_road_button);
      pline_stats_button = BDS.Polyline.newRectangle(dim_stats_button);
      pline_highlight_button = BDS.Polyline.newRectangle(dim_highlight_button);

      /*
       * Future road type selection
      func_build_road_local     = () ->
          mode = TSAG.I_Mouse_Build_Road.mode_local
          @controller_build_road.setMode(mode)
      
      func_build_road_collector = () ->
          mode = TSAG.I_Mouse_Build_Road.mode_collector
          @controller_build_road.setMode(mode)
      
      func_build_road_artery    = () ->
          mode = TSAG.I_Mouse_Build_Road.mode_artery
          @controller_build_road.setMode(mode)
       */
      func_build_road = function(self) {
        return function() {
          self.mouse_controller.deactivateTools();
          self.controller_build_road.setActive(true);
          self.controller_highlight.setActive(true);
        };
      };
      func_stats = function(self) {
        return function() {
          self.mouse_controller.deactivateTools();
          self.controller_stats.setActive(true);
        };
      };
      func_highlight = function(self) {
        return function() {
          self.mouse_controller.deactivateTools();
          self.controller_highlight.setActive(true);
        };
      };
      this.createButton(pline_road_button, this.img_road_button.children[0].material, func_build_road(this));
      this.createButton(pline_stats_button, this.img_stats_button.children[0].material, func_stats(this));
      return this.createButton(pline_highlight_button, this.img_highlight_button.children[0].material, func_highlight(this));
    };

    E_UI_Game.prototype.createStaticObjects = function() {
      var bottom_border, cost_display, dim_cost, dim_happy, img_happy_label, left_border, view;
      view = this.getVisual();
      left_border = this._createRectangle({
        fill: 0x808080,
        x: 0,
        y: 0,
        w: 96,
        h: 800,
        depth: -7
      });
      view.add(left_border);
      dim_happy = {
        x: 0,
        y: 704,
        w: 96,
        h: 96
      };
      img_happy_label = TSAG.style.newSprite("images/happy_face.png", dim_happy);
      view.add(img_happy_label);
      this.hapiness_width = 256;
      this.hapiness_display = this._createRectangle({
        fill: 0xb0efcd,
        x: 64,
        y: 800 - 16 - 50,
        w: 5,
        h: 50,
        depth: -5
      });
      view.add(this.hapiness_display);
      this.sadness_display = this._createRectangle({
        fill: 0xeec3c3,
        x: 64 + 5,
        y: 800 - 66,
        w: this.hapiness_width - 5,
        h: 50,
        depth: -5
      });
      view.add(this.sadness_display);
      this.happiness_text = new THREE.Object3D();
      this.happiness_text.position.x = 64;
      this.happiness_text.position.y = 800 - 66;
      view.add(this.happiness_text);
      bottom_border = this._createRectangle({
        fill: 0x808080,
        x: 0,
        y: 800 - 16,
        w: 1200,
        h: 16,
        depth: -6
      });
      view.add(bottom_border);
      this.info_message_display = this._createRectangle({
        fill: 0x0000ff,
        x: 64 + 256,
        y: 800 - 66,
        w: 520,
        h: 66,
        depth: -5
      });
      view.add(this.info_message_display);
      this.info_message_text = new THREE.Object3D();
      this.info_message_text.position.x = 335;
      this.info_message_text.position.y = 800 - 60;
      view.add(this.info_message_text);
      dim_cost = {
        x: 830,
        y: 800 - 96,
        w: 96,
        h: 96
      };
      this.img_cost_label = TSAG.style.newSprite("images/cost.png", dim_cost);
      view.add(this.img_cost_label);
      cost_display = this._createRectangle({
        fill: 0xffffff,
        x: 900,
        y: 800 - 66,
        w: 1200 - 900,
        h: 50,
        depth: -5
      });
      view.add(cost_display);
      this.cost_text = new THREE.Object3D();
      this.cost_text.position.x = 930;
      this.cost_text.position.y = 800 - 66 + 10;
      view.add(this.cost_text);
      return this.displayCost();

      /*
      img_sad_label = TSAG.style.newSprite("images/sad_face.png", {x: 1200 - 96, y:800 - 96, w:96, h:96})
      view.add(img_sad_label)
       */
    };


    /*
    
    Interface Routines. - What can the ui do?
     */

    E_UI_Game.prototype.message = function(str, params) {
      if (params.type === 'info') {
        this.info_message_display.revertFillColor();
        if (params.element) {
          params.element.revertFillColor();
        }
      }
      if (params.type === 'action') {
        this.info_message_display.setFillColor(TSAG.style.action);
        if (params.element) {
          params.element.setFillColor(TSAG.style.action);
        }
      } else if (params.type === 'error') {
        this.info_message_display.setFillColor(TSAG.style.error);
        if (params.element) {
          params.element.setFillColor(TSAG.style.error);
        }
      }
      return this.changeMessageText(str);
    };

    E_UI_Game.prototype.changeMessageText = function(str) {
      return this.changeText(this.info_message_text, str);
    };

    E_UI_Game.prototype.addCost = function(amount) {
      this.cost += amount;
      return this.displayCost();
    };

    E_UI_Game.prototype.displayCost = function() {
      return this.changeText(this.cost_text, "$" + Math.floor(this.cost / 100) + " million");
    };

    E_UI_Game.prototype.addTrip = function(car) {
      console.log("Time, distance");
      console.log(car.getTimeTravelled());
      console.log(car.getDistanceTravelled());
      this.total_trips = 1;
      this.happy_trips = .9 * this.happy_trips + .1 * 1;
      return this.displayHapiness(this.happy_trips / this.total_trips);
    };

    E_UI_Game.prototype.displayHapiness = function(percentage) {
      var w1, w2;
      this.hapiness_width = 256;
      w1 = this.hapiness_width * percentage;
      w2 = this.hapiness_width - w1;
      this.hapiness_display.scale.x = w1;
      this.hapiness_display.position.x = 64 + w1 / 2;
      this.sadness_display.position.x = 64 + w1 + w2 / 2;
      return this.sadness_display.scale.x = w2;
    };

    E_UI_Game.prototype.changeText = function(text_obj, str) {
      text_obj.children = [];
      return TSAG.style.newText({
        font: TSAG.style.font,
        height: 16,
        fill_color: 0xff000000,
        message: str,
        out: text_obj
      });
    };

    E_UI_Game.prototype.flash = function() {
      return this.info_message_display.setFillColor(TSAG.style.highlight);
    };

    return E_UI_Game;

  })(TSAG.E_UI);

}).call(this);