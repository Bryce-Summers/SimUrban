#
# Main Mouse Input Controller.
#
# Written by Bryce Summers on 12 - 18 - 2016.
#
# This is the top level mouse input controller that receives all input related to mouse input.
# It then pipes the input to the user's currently selected tool, such as a road building controller.
# FIXME: Abstract all of this functionality into TSAG.Input_Controller.

class TSAG.I_Mouse_Main extends BDS.Controller_Group

    # Input: THREE.js Scene. Used to add GUI elements to the screen and modify the persistent state.
    # THREE.js
    constructor: (@scene, @camera) ->

        super()

        @_create_cursor()

        @road_build_controller = new TSAG.I_Mouse_Build_Road(@scene, @camera)
        @add_mouse_input_controller(@road_build_controller)

        @highlight_controller  = new TSAG.I_Mouse_Highlight(@scene, @camera)
        @add_mouse_input_controller(@highlight_controller)

        @stats_controller = new TSAG.I_Mouse_Stats_Overlays(@scene, @camera)
        @add_mouse_input_controller(@stats_controller)

        # Represents all of the buttons.
        @ui_controller = new TSAG.UI_Controller(@scene, @camera)
        @add_mouse_input_controller(@ui_controller)

        @state = "idle"

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
        @road_build_controller.cancel()
        @road_build_controller.finish()

        @highlight_controller.setActive(false)
        @highlight_controller.finish()

        @stats_controller.setActive(false)
        @stats_controller.finish()


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

    mouse_move: (event) ->

        super(event)

        pos = @pointer.position;
        pos.x = event.x
        pos.y = event.y