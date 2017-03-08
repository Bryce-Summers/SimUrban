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
        @road  = null
        @legal = false # Stores whether the current road is legal or not.

        # The Vector at the end of the road that the user is currently dragging.
        @next_point = null

        @network   = @e_scene.getNetwork()
        @generator = @network.getGenerator()
        @linker    = @network.getLinker()

        # A List of {isect:, type:'p','t', 'i', road:}
        # 'p' is permanant and is already inside of the embedding.
        # 's' is a split point and will need to be newly allocated.
        # - if this is a t curve, then road: will contain the road to be split.
        # - 
        # 'i' stands for intermediate point, which are points along curves that don't intersect original curves.
        # 's' and 'i' i.e. non-permanent points will be deallocated if the curve is cancelled or illegal.
        @isects = []
        @isects_last_segment = []

    isIdle: () ->
        return @state == "idle"

    mouse_down: (event) ->

        if @state == "idle"

            # We are building a brand new temporary road, for display to the user.
            # It will also be used to asertertain the geometry validty of this road's placement.
            # We will deallocate this road during finish(), in favor of chopped up portions.
            @road = new TSAG.E_Road()
            @network.addVisual(@road.getVisual())

            # Extract the original points for possible modification.
            x = event.x
            y = event.y

            # Categorize the starting point as a 'p', 't', or 'i' point.
            # based on whether the original point is in an isect, a road, or empty space/area,
            start_element = @_getIsectOrRoadAtPt(x, y)

            # 'p' starting point is inside of an intersection.
            # We handle this by shifting the starting point to the intersection's point.
            # and creating a 'p' isect.
            if start_element instanceof TSAG.E_Intersection
                isect_pt = start_element.getPoint()
                x = isect_pt.x
                y = isect_pt.y
                @isects.push({isect:start_element, type:'p'})
            # 's' Split point intersection.
            else if start_element instanceof TSAG.E_Road
                intersection = new TSAG.E_Intersection(new BDS.Point(x, y))
                @network.addVisual(intersection.getVisual())
                @isects.push({isect:intersection, type:'s', road:start_element})
            # 'i' intermediate point, an intersection point in space.
            else
                intersection = new TSAG.E_Intersection(new BDS.Point(x, y))
                @network.addVisual(intersection.getVisual())
                @isects.push({isect:intersection, type:'i'})


            @road.addPoint(new THREE.Vector3(x, y, 0))
            
            # The second point is used as the dummy point during mouse movements.
            @next_point = new THREE.Vector3( x, y+1, 0)
            @road.addPoint(@next_point)
            
            @state = "building"
            @_mousePrevious.x = event.x
            @_mousePrevious.y = event.y

        # Road Building State.
        else if @state == "building"

            if not @legal
                # Play an error noise, flash the road, etc.
                # Let the user know that this is an erroneous action.
                return
            

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
                @road.updateLastPoint(pos)

                # We use offsets to prevent 0 length splines that cause degenerate behavior.
                @next_point = new THREE.Vector3( event.x + .01, event.y + .01, 0)
                @road.addPoint(@next_point)


                @_mousePrevious.x = event.x
                @_mousePrevious.y = event.y

                # Move all of the latest segment intersections over to main intersection array, 
                # we will no longer have to worry about updating them.
                for isect in @isects_last_segment
                    @isects.push(isect)

                # Empty the temporary intersection array.
                @isects_last_segment = []

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
            # Set the last point on the renderable road to be the user indicated next point.
            @road.updateLastPoint(@next_point)

            # FIXME: Perhaps this should be dependant on the current view bounds...
            max_length    = TSAG.style.discretization_length
            @road.updateDiscretization(max_length)

            # Update the found intersections.
            @updateTemporaryRoad()

    # This may be called from anyone who knows about this controller.
    # For instance it may be called when the user transitions into another controller state.
    finish: () ->

        # We only have work to finish when we are in building mode.
        if @state != "building"
            return


        # FIXME: This is where I do the embedding.


        # Indicate to the user that they can click now to end the interaction.

        # Remove the dummy modification point at the end.
        @road.removeLastPoint()

        @state = "idle"

        max_length = TSAG.style.discretization_length
        @road.updateDiscretization(max_length)


        end_pt = @road.getLastPoint()
        x = end_pt.x
        y = end_pt.y

        # Categorize the ending point as a 'p', 't', or 'i' point.
        # based on whether the last point is in an isect, a road, or empty space/area,
        end_element = @_getIsectOrRoadAtPt(end_pt.x, end_pt.y)

        # 'p' starting point is inside of an intersection.
        # We handle this by shifting the starting point to the intersection's point.
        # and creating a 'p' isect.
        if end_element instanceof TSAG.E_Intersection
            isect_pt = end_element.getPoint()
            x = isect_pt.x
            y = isect_pt.y
            @isects.push({isect:end_element, type:'p'})
        # 's' Split point intersection.
        else if end_element instanceof TSAG.E_Road
            intersection = new TSAG.E_Intersection(new BDS.Point(x, y))
            #@network.addVisual(intersection.getVisual())
            @isects.push({isect:intersection, type:'s', road:end_element})
        # 'i' intermediate point, an intersection point in space.
        else
            intersection = new TSAG.E_Intersection(new BDS.Point(x, y))
            #@network.addVisual(intersection.getVisual())
            @isects.push({isect:intersection, type:'i'})



        # 1. Delete the Temporary Road visual.
        @network.removeVisual(@road.getVisual())
        #@road = null # We no longer need the road.

        # 2. Delete the non-permanant Intersection visuals.
        for isect_obj in @isects
            if isect_obj.type != 'p'
                @network.removeVisual(isect_obj.isect.getVisual())


        # Associate every intersection (Except for the intermediate ones) with a SCRIB.Vertex.

        # 2. Use the linker to link this graph.

        # 3. Create Roads and associate intersections.
        #    Associate every road with a path.
        #    The roads need to have arc curve, instead of the temporary solution that we have right now.
        #    This can come later.


        # Add the road's collision polygons to the network BVH.
        # FIXME: Add a bounding polygon instead.
        @network.addCollisionPolygons(@road.to_collision_polygons())

        # Make all intersections collidable.
        for isect_obj in @isects
            isect = isect_obj.isect
            @network.addCollisionPolygon(isect.getCollisionPolygon())

        # Embed the road topology between the list of intersections.
        # This will enable vehicles to move on the new road,
        # it will also update the areas.
        #@embedRoadTopology()

        # FIXME: Make a better way of managing roads.
        @network.addRoad(@road)

        # Preserve the road object.
        @road = null

        @isects = []
        @isects_last_segment = []


    #############################################################################################
    # Temporary Road Updates.
    #
    # - Displays information about the road being built over time.
    # - Populates the intermediate data, such as intersection locations,
    #   that will be used in the final Topological update where we embed the road.
    #############################################################################################


    # In this function, we update the appearance of the road that is in cosntruction.
    # - We indicate whether the road is legal.
    # - We indicate where intersections will be created.
    updateTemporaryRoad: () ->

        # 1. Destroy the non-permanant intersections from the last segment.
        @destroyLastSegmentIsects()

        # 2. Check legality of the current segment. Stop and color the road red if it is not legal.
        if not @checkLegality()
            @road.setFillColor(TSAG.style.error)

            @legal = false
            return

        # The road is Legal!
        @road.revertFillColor()
        @legal = true

        # 2. Create new temporary intersections, that would be created 
        # 2. Find the intersections with the global embedding's line bvh.
        # 3. Check to see if endpoints
        @createTempIntersections()


    destroyLastSegmentIsects: () ->

        for isect_obj in @isects_last_segment

            # Ignore Permanant intersection objects.
            if isect_obj.type == 'p'
                continue

            isect = isect_obj.isect
            @network.removeVisual(isect.getVisual())

            # FIXME: Why would an isect have a collision polygon in the network?
            collision_polygon = isect.getCollisionPolygon()
            @network.removeCollisionPolygon(collision_polygon)

        @isects_last_segment = []

    # Returns true iff the last segment is legal.
    checkLegality: () ->

        # Check curvature.

        # Collision with an existing intersection.

        # Collision with important buildings.

        collision_polygon = @road.generateCollisionPolygon()
        query_box = collision_polygon.generateBoundingBox()
        # FIXME.


    createTempIntersections: () ->

        # -- Step 1. Check for all intermediate intersections with the Graph embedding.

        # The polyline representing the center of the temporary road.
        polyline = @road.getCenterPolyline()

        temp_polyline = polyline.getLastSegment()

        # Get a bounding box for the currently in construction region.
        query_box = temp_polyline.generateBoundingBox()

        # The box is used to look up all existing elements within that region.
        elements = @network.query_elements_box(query_box)

        for elem in elements

            # If the element is a road, then we need to create an intersection at that location.
            if elem instanceof TSAG.E_Road
                e_polyline = elem.getCenterPolyline()
                @_intersectPolygons(temp_polyline, e_polyline)


        # -- Step 2. Check if the latest endpoint is within the original road embedding.

        # first_point = temp_polyline.getFirstPoint()
        last_point     = temp_polyline.getLastPoint()
        last_direction = temp_polyline.getLastDirection()

        e_road = @_getRoadAtPt(last_point.x, last_point.y)
        
        # ASSUMPTION: We will not be intersecting an intersection,
        # because that would be caught by the legality checker...
        if e_road != null

            # FIXME: Instead, I should use the network
            e_polyline = e_road.getCenterPolyline()
            
            width = e_road.getWidth()

            # Create an intersection polyline of at least enough width
            # to get to the midpoint of the existing center line.
            p1 = last_point
            p2 = last_point.add(last_direction.multScalar(width))
            query_polyline = new BDS.Polyline(false, [p1, p2])

            @_intersectPolygons(query_polyline, e_polyline, e_road)

        return

    # Creates e_intersections for every point of intersection between the following 2 polygons.
    # BDS.Polyline, BDS.Polyline, TSAG.E_Road
    _intersectPolygons: (poly1, poly2, road_in_embedding) ->

        isect_pts = poly1.report_intersections_with_polyline(poly2)

        # FIXME: What happens if the intersections are out of order with regards to
        # the road that we are constructing?

        # Create an intersection for every one of these points.
        for pt in isect_pts
            intersection = new TSAG.E_Intersection(pt)
            @isects_last_segment.push(isect:intersection, type:'s', road:road_in_embedding)

            # Add the intersection visually and spatially to the network.
            @network.addVisual(intersection.getVisual())
            @network.addCollisionPolygon(intersection.getCollisionPolygon())

        ###
        # Add intersections every time the mouse cursor intersects an older road.
        road_model = @network.query_road(event.x, event.y)
        if road_model != null
            @network.newIntersection(road_model.getPosition())
        ###

    # Returns a road or intersections at the given point.
    # Preference is given to returning an intersection.
    _getIsectOrRoadAtPt: (x, y) ->
        elems = @network.query_elements_pt(x, y)

        # Look for an intersection first,
        # since they may be on top of roads.
        for elem in elems
            if elem instanceof TSAG.E_Intersection
                return elem

        # Look for roads second.
        for elem in elems
            if elem instanceof TSAG.E_Road
                return elem

        return null

    # Returns the TSAG.E_Road at the given point in the network embedding.
    # Returns null if not found.
    _getRoadAtPt: (x, y) ->
        elems = @network.query_elements_pt(x, y)

        for elem in elems
            if elem instanceof TSAG.E_Road
                return elem

        return null