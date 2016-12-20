#
# Main Mouse Input Controller.
#
# Written by Bryce Summers on 12 - 18 - 2016.
#
# This is the top level mouse input controller that receives all input related to mouse input.
# It then pipes the input to the user's currently selected tool, such as a road building controller.

class TSAG.I_Mouse_Main

    # Input: THREE.js Scene. Used to add GUI elements to the screen and modify the persistent state.
    # THREE.js
    constructor: (@scene, @camera) ->

        @create_cursor()

        @road_build_controller = new TSAG.I_Mouse_Build_Road(@scene, @camera)
        @_current_mouse_input_controller = @road_build_controller

        @state = "idle"
        @_min_dist = 10

    create_cursor: () ->

        # We create a red circular overlay to show us where the mouse currently is, especially for debugging purposes.

        mesh_factory = new TSAG.Unit_Meshes()#TSAG.style.unit_meshes
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

        @scene.addOverlayVisual(mesh)
        @pointer = mesh

    # Here are the input commands, they get piped to the current input controller.
    mouse_down: (event) ->
        @_current_mouse_input_controller.mouse_down(event)

    mouse_up:   (event) ->
        @_current_mouse_input_controller.mouse_up(event)

    mouse_move: (event) ->

        # Update the red pointer overlay on screen.
        pos = @pointer.position;
        pos.x = event.x
        pos.y = event.y

        @_current_mouse_input_controller.mouse_move(event)