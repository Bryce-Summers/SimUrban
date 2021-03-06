// Generated by CoffeeScript 1.11.1

/*

Building Rotation Time Controller.

Written by Bryce Summmers on 1 - 31 - 2017.

 - A Test time controller that takes every building in the scene and rotates it by a steady rate.
 */

(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  TSAG.I_Time_Rotate_Buildings = (function(superClass) {
    extend(I_Time_Rotate_Buildings, superClass);

    function I_Time_Rotate_Buildings(scene, camera) {
      this.scene = scene;
      this.camera = camera;
      I_Time_Rotate_Buildings.__super__.constructor.call(this);
    }

    I_Time_Rotate_Buildings.prototype.time = function(dt) {
      var buildings, element, i, len, results;
      buildings = this.scene.getBuildings();
      results = [];
      for (i = 0, len = buildings.length; i < len; i++) {
        element = buildings[i];
        results.push(element.rotateBuilding(.01));
      }
      return results;
    };

    return I_Time_Rotate_Buildings;

  })(BDS.Interface_Controller_All);

}).call(this);
