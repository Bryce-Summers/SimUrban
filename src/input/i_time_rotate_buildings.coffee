###

Building Rotation Time Controller.

Written by Bryce Summmers on 1 - 31 - 2017.

 - A Test time controller that takes every building in the scene and rotates it by a steady rate.

###

class TSAG.I_Time_Rotate_Buildings extends TSAG.Input_Controller

    # Input: THREE.js Scene. Used to add GUI elements to the screen and modify the persistent state.
    # THREE.js
    constructor: (@scene, @camera) ->
        super()

    time: (dt) ->

        # TSAG.E_Building[]
        buildings = @scene.getBuildings()

        for element in buildings
            element.rotateBuilding(.01)
