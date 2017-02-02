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

        @network = @e_scene.getNetwork()

        @intersections_perm = []
        @intersections_temp = []

    isIdle: () ->
        return @state == "idle"

    mouse_down: (event) ->

        if @state == "idle"

            @road = new TSAG.E_Road()
            @network.addVisual(@road.getVisual())

            # Create an intersection at the start.
            intersection = new TSAG.E_Intersection(new BDS.Point(event.x, event.y))
            @network.addVisual(intersection.getVisual())
            @intersections_perm.push(intersection)


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

                @finish()

    mouse_up:   (event) ->

        # Finalize the road, add it to the Network's embedding.

    mouse_move: (event) ->

        if @state == "building"

            # We use random numbers to ensure a lack of degeneracy.
            @next_point.x = event.x + .01
            @next_point.y = event.y + .01

            # FIXME: Perhaps this should be dependant on the current view bounds...
            max_length    = TSAG.style.discretization_length
            @road.updateDiscretization(max_length)

            # Update the found intersections.
            @updateTempIntersections()

    finish: () ->

        # We only have work to finish when we are in building mode.
        if @state != "building"
            return

        # Indicate to the user that they can click now to end the interaction.

        # Round last point.
        @road.removeLastPoint()

        @state = "idle"

        max_length = TSAG.style.discretization_length
        @road.updateDiscretization(max_length)

        # Create an intersection at the end and finalize all of these intersections.
        intersection = new TSAG.E_Intersection(new BDS.Point(@_mousePrevious.x, @_mousePrevious.y))
        @network.addVisual(intersection.getVisual())
        @intersections_perm.push(intersection)

        # Add the road's collision polygons to the network BVH.
        # FIXME: Add a bounding polygon instead.
        @network.addCollisionPolygons(@road.to_collision_polygons())

        # Make all intersections collidable.
        for isect in @intersections_perm
            @network.addCollisionPolygon(isect.getCollisionPolygon())

        # FIXME: Make a better way of managing roads.
        @network.roads.push(@road)

        # Preserve the road object.
        @road = null

        @intersections_temp = []
        @intersections_perm = []

    updateTempIntersections: () ->
        @destroyTempIntersections()
        @createTempIntersections()

    createTempIntersections: () ->
        polyline = @road.getCenterPolyline()

        # Get a bounding box for the currently in construction region.
        collision_polygon = @road.generateCollisionPolygon()
        query_box = collision_polygon.generateBoundingBox()

        # The box is used to look up all existing elements within that region.
        elements = @network.query_elements_box(query_box)

        for elem in elements

            # If the element is a road, then we need to create an intersection at that location.
            if elem instanceof TSAG.E_Road
                e_polyline = elem.getCenterPolyline()

                isect_pts = polyline.report_intersections_with_polyline(e_polyline)

                # Create an intersection for every one of these points.
                for pt in isect_pts
                    isect = new TSAG.E_Intersection(pt)
                    @intersections_temp.push(isect)

                    # Add the intersection visually and spatially to the network.
                    @network.addVisual(isect.getVisual())
                    @network.addCollisionPolygon(isect.getCollisionPolygon())
                    
        return


        ###
        # Add intersections every time the mouse cursor intersects an older road.
        road_model = @network.query_road(event.x, event.y)
        if road_model != null
            @network.newIntersection(road_model.getPosition())
        ###

    destroyTempIntersections: () ->

        for isect in @intersections_temp
            @network.removeVisual(isect.getVisual())

            collision_polygon = isect.getCollisionPolygon()
            @network.removeCollisionPolygon(collision_polygon)