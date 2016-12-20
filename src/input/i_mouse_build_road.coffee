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

class TSAG.I_Mouse_Build_Road

    # Input: THREE.js Scene. Used to add GUI elements to the screen and modify the persistent state.
    # THREE.js
    constructor: (@e_scene, @camera) ->

        @state = "idle"
        @_mousePrevious = {x:0, y:0}
        @_min_dist = TSAG.style.user_input_min_move

        # Points to the current road being constructed by the user using this input controller.
        @road = null

        # The Vector at the end of the road that the user is currently dragging.
        @next_point = null

    mouse_down: (event) ->

        if @state == "idle"

            @network = @e_scene.getNetwork()

            @road = @network.newRoad(event.x, event.y)
            @road.addPoint(new THREE.Vector3( event.x, event.y, 0))
            
            # The second point is used as the dummy point during mouse movements.
            @next_point = new THREE.Vector3( event.x, event.y+1, 0)
            @road.addPoint(@next_point)
            
            @state = "building"
            @_mousePrevious.x = event.x
            @_mousePrevious.y = event.y

        else

            dist = TSAG.Math.distance(
                        event.x, event.y,
                        @_mousePrevious.x,
                        @_mousePrevious.y)

            # Build more road if the user clicks far enough away.
            if dist > @_min_dist

                # Round last point.
                pos = @next_point
                pos.x = Math.floor(pos.x)
                pos.y = Math.floor(pos.y)

                # We use offsets to prevent 0 length splines that cause degenerate behavior.
                @next_point = new THREE.Vector3( event.x + .01, event.y + .01, 0)
                @road.addPoint(@next_point)

                @_mousePrevious.x = event.x
                @_mousePrevious.y = event.y
            # Stop the interaction if the user is sufficiently close to their
            # previous tap.
            else

                # Indicate to the user that they can click now to end the interaction.

                # Round last point.
                @road.removeLastPoint()

                @state = "idle"

                max_length = TSAG.style.discretization_length;
                @road.updateDiscretization(max_length)

                # Preserve the road object.
                @road = null

    mouse_up:   (event) ->

    mouse_move: (event) ->

        if @state == "building"

            # We use random numbers to ensure a lack of degeneracy.
            @next_point.x = event.x + .01
            @next_point.y = event.y + .01

            # FIXME: Perhaps this should be dependant on the current view bounds...
            max_length    = TSAG.style.discretization_length;
            @road.updateDiscretization(max_length)

            # Add intersections everytime the mouse cursor intersects an older road.
            road_model = @network.query_road(event.x, event.y)
            if road_model != null
                @network.newIntersection(road_model.getPosition())