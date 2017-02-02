###

Time Input Controller.

Written by Bryce Summmers on 1 - 31 - 2017.

###

class TSAG.I_Time_Main extends TSAG.Input_Controller

    # Input: THREE.js Scene. Used to add GUI elements to the screen and modify the persistent state.
    # THREE.js
    constructor: (@scene, @camera) ->

        super()

        #@add_time_input_controller(new TSAG.I_Time_Rotate_Buildings(@scene, @camera))
        @add_time_input_controller(new TSAG.I_Time_Generate_Cars(@scene, @camera))