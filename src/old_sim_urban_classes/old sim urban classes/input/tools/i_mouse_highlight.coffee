#
# Main Mouse Input Controller.
#
# Refactored by Bryce Summers on 12 - 18 - 2016.
#
# This is the top level mouse input controller that receives all input related to mouse input.
#

#
# Mouse Input Manager
#
# Written by Bryce Summers on 11/22/2016
# Abstracted on 12 - 18 - 2016.
#

class TSAG.I_Mouse_Highlight extends TSAG.I_Tool_Controller

    # Input: THREE.js Scene. Used to add GUI elements to the screen and modify the persistent state.
    # THREE.js
    constructor: (@e_scene, @camera) ->

        super(@e_scene, @camera)

        #@state = "idle"
        @network = @e_scene.getNetwork()

        @previous_elements = []

    # The Highlight controller is always idle.
    isIdle: () ->
        return true

    # Completes all actions, such that it is safe to switch controllers.
    finish: () ->
        while @previous_elements.length > 0
            prev_elem = @previous_elements.pop()
            prev_elem.revertFillColor()

    mouse_down: (event) ->

        if @previous_elements.length > 0
            ###
            @network.removeVisual(@previous_element.getVisual())
            @network.removeCollisionPolygon(@previous_element.getCollisionPolygon())
            #@network.removeTopology
            ###

    mouse_up:   (event) ->
    mouse_move: (event) ->

        @finish()

        elems = @network.query_elements_pt(event.x, event.y)

        for elem in elems
            if elem instanceof TSAG.E_Road
                road = elem
                road.setFillColor(TSAG.style.highlight)
                @previous_elements.push(road)