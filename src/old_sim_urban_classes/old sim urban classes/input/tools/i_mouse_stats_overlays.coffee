#
# Overlayed Statistics Controller.
#
# Written by Bryce Summers on May.4.2017
#

#
# Mouse Input Manager
#
# Written by Bryce Summers on 11/22/2016
# Abstracted on 12 - 18 - 2016.
#

class TSAG.I_Mouse_Stats_Overlays extends TSAG.I_Tool_Controller

    # Input: THREE.js Scene. Used to add GUI elements to the screen and modify the persistent state.
    # THREE.js
    constructor: (@scene, @camera) ->

        super(@scene, @camera)

        # We will need the network to activate stat's overlays.
        @overlays = @scene.getOverlays()
        @view = @overlays.getVisual()
        @network  = @scene.getNetwork()
        @previous_elements = []

    # The Highlight controller is always idle.
    isIdle: () ->
        return true

    # Completes all actions, such that it is safe to switch controllers.
    finish: () ->
        while @previous_elements.length > 0
            prev_elem = @previous_elements.pop()
            prev_elem.hide_stats(@view)

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

        elem = @network.query_area_elements_pt(new BDS.Point(event.x, event.y))

        if elem != null
            elem.display_stats(@view)
            @previous_elements.push(elem)