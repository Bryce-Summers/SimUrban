// Generated by CoffeeScript 1.11.1

/*
    Sim Urban Overlays
    Written by Bryce on May.4.2017
    
    Purpose: This class provides functions for mapping visual data displays across the screen.
        It also provides functions for producing custom sized geometries.
        - produce overlays.
        - Reset the screen to the normal aesthetic.
 */

(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  TSAG.E_Overlays = (function(superClass) {
    extend(E_Overlays, superClass);

    function E_Overlays() {
      var view;
      E_Overlays.__super__.constructor.call(this);
      view = this.getVisual();
    }

    E_Overlays.prototype.createRectangle = function(params) {
      var rect;
      rect = TSAG.style.unit_meshes.newSquare({
        color: new THREE.Color(params.fill)
      });
      rect.scale.x = params.w;
      rect.scale.y = params.h;
      rect.position.x = params.x + params.w / 2;
      rect.position.y = params.y + params.h / 2;
      rect.position.z = params.depth;
      return rect;
    };

    E_Overlays.prototype.addPermanentVisual = function(mesh) {
      var view;
      view = this.getVisual();
      return view.add(mesh);
    };

    return E_Overlays;

  })(TSAG.E_Super);

}).call(this);
