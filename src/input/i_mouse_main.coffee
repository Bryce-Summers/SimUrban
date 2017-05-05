#
# Main Mouse Input Controller.
#
# Written by Bryce Summers on 12 - 18 - 2016.
#
# This is the top level mouse input controller that receives all input related to mouse input.
# It then pipes the input to the user's currently selected tool, such as a road building controller.
# FIXME: Abstract all of this functionality into TSAG.Input_Controller.

class TSAG.I_Mouse_Main extends BDS.Interface_Controller_All

    # Input: THREE.js Scene. Used to add GUI elements to the screen and modify the persistent state.
    # THREE.js
    constructor: (@scene, @camera) ->

        super()

        @_create_cursor()

        @road_build_controller = new TSAG.I_Mouse_Build_Road(@scene, @camera)
        @highlight_controller  = new TSAG.I_Mouse_Highlight(@scene, @camera)
        @stats_controller = new TSAG.I_Mouse_Stats_Overlays(@scene, @camera)
        # Represents all of the buttons.
        @ui_controller = new TSAG.UI_Controller(@scene, @camera)

        #@_current_mouse_input_controller = @highlight_controller
        @_current_mouse_input_controller = @stats_controller

        @state = "idle"
        @_min_dist = 10

    getRoadBuild: () ->
        return @road_build_controller

    getRoadDestroy: () ->
        # FIXME: Doesn't yet exist.
        return @road_destroy_controller

    getHighlight: () ->
        return @highlight_controller

    getStats: () ->
        return @stats_controller

    # deactivates all tools controllers.
    deactivateTools: () ->
        @road_build_controller.setActive(false)
        @highlight_controller.setActive(false)
        @stats_controller.setActive(false)


    ###------------------------------------
      Internal Helper Functions.
    #--------------------------------------
    ###


    _create_cursor: () ->

        # We create a red circular overlay to show us where the mouse currently is, especially for debugging purposes.

        mesh_factory = new TSAG.Unit_Meshes() #TSAG.style.unit_meshes
        params = {color: TSAG.style.cursor_circle_color}

        # THREE.js Mesh
        mesh = mesh_factory.newCircle(params)

        scale = TSAG.style.cursor_circle_radius
        mesh.position.z = TSAG.style.cursor_circle_z

        w = scale
        h = scale

        scale = mesh.scale
        scale.x = w
        scale.y = h

        overlays = @scene.getOverlays()
        overlays.addPermanentVisual(mesh)
        @pointer = mesh

    # Here are the input commands, they get piped to the current input controller.
    mouse_down: (event) ->

        # Switch to Road build.
        if @_current_mouse_input_controller != @road_build_controller and
           @_current_mouse_input_controller.isIdle()
                @switchController(@road_build_controller)

        @_current_mouse_input_controller.mouse_down(event)

    mouse_up:   (event) ->
        @_current_mouse_input_controller.mouse_up(event)

    mouse_move: (event) ->


        if @_current_mouse_input_controller != @highlight_controller and
           @_current_mouse_input_controller.isIdle()
                #@switchController(@highlight_controller)
                @switchController(@stats_controller)

        # Update the red pointer overlay on screen.
        pos = @pointer.position;
        pos.x = event.x
        pos.y = event.y

        @_current_mouse_input_controller.mouse_move(event)

    # Switches to a new input controller.
    switchController: (controller) ->

        @_current_mouse_input_controller.finish()
        @_current_mouse_input_controller = controller