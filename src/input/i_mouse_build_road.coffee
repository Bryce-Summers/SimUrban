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
        # The road only needs to dispaly the curved and straight portions.
        # The road will not add points at intermediate intersection vertices,
        # but those points will be captured in the more detailed @isects array.
        @road  = null
        @legal = false # Stores whether the current road is legal or not.

        # The Vector at the end of the road that the user is currently dragging.
        @next_point = null

        @network   = @e_scene.getNetwork()
        @_generator = @network.getGenerator()
        @_linker    = @network.getLinker()

        # isects stores a path of critical elements and locations during the construction of a road.
        # A List of {isect:, type:'p','t', 'i', 's', road:, vert:, point:}
        # 'p' is permanant and is already inside of the embedding.
        # 's' is a split point and will need to be newly allocated.
        # - if this is a t curve, then road: will contain the road to be split.
        # - 
        # 'i' stands for intermediate point, which are points along curves that don't intersect original curves.
        # 't' stands for tail point.
        # 's' and 'i' i.e. non-permanent points will be deallocated if the curve is cancelled or illegal.
        # vert: will be added later during finish(), when we are linking topology.
        # point: will store the canonical location for this path object.
        @isects = []

        # This stores the intersections contained within the last region of road, which is that modifiable by mouse movement during construction.
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


            pt = new BDS.Point(event.x, event.y)
            # Extract the original points for possible modification.
            isect_obj = @classify_or_construct_intersection(pt)
            @start_or_end_point(isect_obj)
            # The first intersection is the first finalized location.
            @isects.push(isect_obj)

            # the point may have changed.
            pt = isect_obj.point
            x = pt.x
            y = pt.y

            @road.addPoint(new THREE.Vector3(x, y, 0))
            
            # The second point is used as the dummy point during mouse movements.
            @next_point = new THREE.Vector3( x, y + 1, 0)
            @road.addPoint(@next_point)

            # First revert state.
            @road.setRevert()

            # Initialize the road visuals.
            max_length    = TSAG.style.discretization_length
            @road.updateVisual(max_length)

            
            @state = "building"
            @_mousePrevious.x = event.x
            @_mousePrevious.y = event.y

        # Road Building State.
        else if @state == "building"

            
            ###
            if not @legal()
                # Play an error noise, flash the road, etc.
                # Let the user know that this is an erroneous action.
                return
            ###
            

            dist = TSAG.Math.distance(
                        event.x, event.y,
                        @_mousePrevious.x,
                        @_mousePrevious.y)

            # Build more road if the user clicks far enough away.
            if dist > @_min_dist

                # Note: In this case, we will not be using the event positions.

                # Round last point.
                pos = @next_point
                pos.x = Math.floor(pos.x)
                pos.y = Math.floor(pos.y)

                # FIXME: Only use BDS.Points in Game Logic.
                pt = new BDS.Point(pos.x, pos.y)

                # Cosntruct a new isect_obj at the given mouse clicked position.
                isect_obj = @classify_or_construct_intersection(pt)
                # The point may have shifted if there is a collision with an element at this location.
                pos = isect_obj.point

                @road.updateLastPoint(pos)

                # We use offsets to prevent 0 length splines that cause degenerate behavior.
                @next_point = new THREE.Vector3( pos.x + .01, pos.y + .01, 0)
                @road.addPoint(@next_point)

                # FIXME: Maybe I should use the position of the intersection instead.
                @_mousePrevious.x = event.x
                @_mousePrevious.y = event.y

                # Remove a control point form the permenant isects if present.
                if @isects[@isects.length - 1].type == 'i'
                    @isects.pop()

                # Move all of the latest segment intersections over to main intersection array,
                # we will no longer have to worry about updating them.
                for isect in @isects_last_segment
                    @isects.push(isect)

                # Empty the temporary intersection array.
                @isects_last_segment = []

                # Add the end point to the array,
                # if it is not duplicating an the last intersection point on the last segment.
                # This may happen if the user builds a point on a road where the mouse has already crossed the road.
                last_isect = @isects[@isects.length - 1]
                dist = last_isect.point.distanceTo(isect_obj.point)
                if dist > @road.getWidth()
                    @isects.push(isect_obj)
                # Otherwise, we remove its visual if it exists.
                else if isect_obj.isect != undefined
                    @network.removeVisual(isect_obj.isect.getVisual())

                # Every time the user moves their mouse and modifies the last segment, the road will revert
                # back to this state before adding the extra intersection points.
                # All intersections and curves in the next segment will revert to this state.
                # FIXME: Handle the intermediate point that may be used as a curve pivot.
                @road.setRevert()


            # Stop the interaction if the user is sufficiently close to their
            # previous tap.
            else
                @finish()

        return


    # Returns an intersection_obj at the given location,
    # based on whether this location is in an existing intersection, road, or area.
    # Constructs a new object if it is in an area.
    # The obj will contain a possibly shifted .point value which aligns the point with the existing infrastructure.
    classify_or_construct_intersection: (pt) ->

        # Categorize the starting point as a 'p', 's', 't', or 'i' point.
        # based on whether the original point is in an isect, a road, or empty space/area,
        # Intermediate points will be constructed at curve locations.
        element = @_getIsectOrRoadAtPt(pt)

        out = null

        # 'p' starting point is inside of an intersection.
        # We handle this by shifting the starting point to the intersection's point.
        # and creating a 'p' isect.
        if element instanceof TSAG.E_Intersection
            isect_pt = element.getPoint()
            out = {isect:start_element, type:'p', point:isect_pt}
        # 's' Split point intersection.
        else if element instanceof TSAG.E_Road

            road = element
            
            [pt, edge] = road.getClosePointOnCenterLine(pt)

            if pt == null

                err = new Error("Pt was not actually inside of the road proper. Check you collision detection and bounds.")
                console.log(err.stack)
                debugger
                throw err

            intersection = new TSAG.E_Intersection(pt)

            out = {isect:intersection, type:'s', road_edge:edge, point:intersection.getPoint()}           
            @network.addVisual(out.isect.getVisual())
        # Intermediate point. Callers will need to modify this into a tail point if necessary.
        else
            #intersection = new TSAG.E_Intersection(pt)
            #@network.addVisual(intersection.getVisual())
            out = {type:'i', point:pt}

        return out

    # Takes an intersection and converts it to special starting or ending point processing.
    # For instance, it takes an intermediate isect_obj and instantiates an intersection for the end point.
    # Converts the type from 'i' to 't'
    start_or_end_point: (isect_obj) ->

        if isect_obj.type == 'i'

            pt = isect_obj.point
            intersection = new TSAG.E_Intersection(pt)
            @network.addVisual(intersection.getVisual())
            isect_obj.isect = intersection
            isect_obj.type = 't'

    mouse_up:   (event) ->

        # Finalize the road, add it to the Network's embedding.

    mouse_move: (event) ->

        if @state == "building"

            @e_scene.ui_message("Building Road.", {type:'info', element:@road})


            # If the user is close to the previous point, then we indicate that they made finish the road.
            dist = TSAG.Math.distance(
                event.x, event.y,
                @_mousePrevious.x,
                @_mousePrevious.y)

            if dist <= @_min_dist

                if @isects.length <= 2 # 1 is dummy.
                    @e_scene.ui_message("Click to cancel road.", {type:'info', element:@road})
                else
                    @e_scene.ui_message("Click to complete road.", {type:'info', element:@road})
                return


            # We use random numbers to ensure a lack of degeneracy.
            @next_point.x = event.x + .01
            @next_point.y = event.y + .01

            # Ensure the straightness of roads through non-intermediate 
            # intersections by projecting point onto ray.
            len = @isects.length # First road can go any way.
            if len > 1
                i1 = @isects[len - 1]
                if i1.type != 'i'
                    i2 = @isects[len - 2]

                    p1 = i1.point
                    p2 = i2.point
                    dir = p2.sub(p1)
                    ray = new BDS.Ray(p1, dir)

                    pt = @vec_to_pt(@next_point)

                    # Projection ensures straightness.
                    pt = ray.projectPoint(pt)
                    @next_point = @pt_to_vec(pt)

            # Update the found intersections.
            @updateTemporaryRoad()
            

    # This may be called from anyone who knows about this controller.
    # For instance it may be called when the user transitions into another controller state.
    # This function will cancel the road if necessary.
    finish: () ->

        # We only have work to finish when we are in building mode.
        if @state != "building"
            return

        # One way or another, we are transitioning back to the idle state.
        @state = "idle"

        @e_scene.ui_message("", {type:"info"})

        # Roads must span at least 2 vertices.
        if @isects.length < 2
            @_cancel()
            return

        # Indicate to the user that they can click now to end the interaction.

        # Remove the dummy modification point at the end.
        @road.removeLastPoint()

        # FIXME: This should be changed to a function that updates the intermediate points for curves.
        max_length = TSAG.style.discretization_length
        @road.updateDiscretization(max_length)

        end_pt = @road.getLastPoint()
        x = end_pt.x
        y = end_pt.y

        # Note: We don't need to worry about the last segment intersections,
        # because that is only a dummy segment at this point.

        # We process the last isect location as an end point.
        last_isect = @isects[@isects.length - 1]
        @start_or_end_point(last_isect)


        # 1. Delete the Temporary Road visual.
        @network.removeVisual(@road.getVisual())
        @road = null # We no longer need the temporary road.

        # 2. Delete the non-permanant Intersection visuals.
        # FIXME: Is this really necessary? I think that we will be using these visuals.
        ###
        for isect_obj in @isects
            if isect_obj.type != 'p'
                @network.removeVisual(isect_obj.isect.getVisual())
        ###

        # 2. Add collision geometry for all non-permanant intersections.
        for isect_obj in @isects
            type = isect_obj.type
            if type != 'p' and type != 'i'
                isect = isect_obj.isect
                collision_polygon = isect.getCollisionPolygon()
                @network.addCollisionPolygon(collision_polygon)

        # 3. Remove the visuals and collidability from roads at split points.
        #    Split their topology.
        #    Then reconstruct the roads and override their topology with new road elements.
        for isect_obj in @isects

            # Ignore non-split points.
            if isect_obj.type != 's'
                continue

            # isect_objs store the edge that they intersected.
            road_edge = isect_obj.road_edge
            road = road_edge.data.element

            @network.removeVisual(road.getVisual())
            @network.removeCollisionPolygon(road.getCollisionPolygon())
            @network.removeRoad(road)

            # Split the original road topology.
            split_vert = @_generator.newVertex()
            split_isect = isect_obj.isect
            split_vert.data.point = split_isect.getPoint()

            # This isect_obj will be converted into a permanant vertex, 
            # so that we don't allocate any additional information for it later.
            isect_obj.type = 'p'

            # isect -> vert.
            split_isect.setTopology(split_vert)

            # vert -> isect.
            split_vert.data.element = split_isect

            @_linker.split_edge_with_vert(road_edge, split_vert)

            isects = @_populate_split_path(road, split_vert)

            # Reconstruct the road that has now been destroyed.
            @construct_roads_along_isect_path(isects)
        

        # 4. Prepare a list of verts for linking.
        # Associate every intersection with a SCRIB.Vertex.
        for isect_obj in @isects

            if isect_obj.type == 'p'
                isect_obj.vert = isect_obj.isect.getTopology()
                continue

            vert = @_generator.newVertex()

            # Non-intermediate locations will have intersection elements,
            # which we associate with verts.
            if isect_obj.type != 'i'
                isect = isect_obj.isect
                isect.setTopology(vert)   # Element -> Vert.
                vert.data.element = isect # Vert -> Element.
                vert.data.point   = isect.getPoint()
            # intermediate locations.
            else                
                vert.data.point = isect_obj.point

            # We might as well put the verts right into the isect_objs.
            isect_obj.vert = vert
            continue

        # 5. Link the Topology.
        len = @isects.length
        ###
        for i = 0; i < len - 1; i++
        ###
        for i in [0...len - 1] by 1
            
            obj1 = @isects[i]
            obj2 = @isects[i + 1]

            vert1 = obj1.vert
            vert2 = obj2.vert

            @_linker.link_verts(vert1, vert2)

        # 6. Construct all of the roads along the path.
        @construct_roads_along_isect_path(@isects)


        ###

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
        ###

        @isects = []
        @isects_last_segment = []
        return

    # Cancels the road construction, deletes all allocated elements.
    _cancel: () ->
        if @road
            @network.removeVisual(@road.getVisual())

        for isect_obj in @isects_last_segment
            @isects.push(isect_obj)

        for isect_obj in @isects
            if isect_obj.type != 'i'
                @network.removeVisual(isect_obj.isect.getVisual())

        @road = null

        @isects = []
        @isects_last_segment = []


    # E_Road -> isects[]
    _populate_split_path: (road, split_vert) ->

        vert1 = road.getStartVertex()
        vert2 = split_vert
        vert3 = road.getEndVertex()

        isects = []
        halfedge = vert1.get_outgoing_halfedge_to(split_vert)

        # If the starting vert doesn't connect directly to the split vert,
        # then the original road's canonical halfedge is still valid and we
        # will use it.
        if halfedge == null
            halfedge = road.getHalfedge()

        # Starting Isect.
        isect_obj = {isect:vert1.data.element, type:'p', point: vert1.data.point, vert: vert1}
        isects.push(isect_obj)
        
        halfedge = @_append_intermediate_isects_until_vert(halfedge.next, vert2, isects)
        
        # Add the split point.
        isect_obj = {isect:vert2.data.element, type:'s', point: vert2.data.point, vert: vert2}
        isects.push(isect_obj)

        halfedge = @_append_intermediate_isects_until_vert(halfedge.next, vert3, isects)
        
        isect_obj = {isect:vert3.data.element, type:'p', point: vert3.data.point, vert: vert3}
        isects.push(isect_obj)

        return isects

    # Appends intermediate intersection objects to the output list
    # following next pointers after the given halfedge until it
    # reaches a halfedge originating from the indicated vert.
    # this should be used to fill in the intermediate verts along a path.
    _append_intermediate_isects_until_vert: (halfedge, stop_vert, output) ->

        loop
            # 'Current'
            c_vert = halfedge.vertex

            # Stop if we have come to the split intersection point.
            break unless c_vert != stop_vert

            c_isect = c_vert.data.element
            c_point = c_vert.data.point

            # Add intermediate intersections along the way.
            isect_obj = {isect:c_isect, type:'i', point: c_point, vert: c_vert}
            output.push(isect_obj)

            halfedge = halfedge.next

        return halfedge



    # Given a list of intersection objects,
    # This function creates roads along it that are split at split at non-intermediate points.
    # It adds them visually, collidable, and topologically to the network.
    construct_roads_along_isect_path: (isects) ->



        # FIXME: Next step, globalize debugging functions for half edge graphs, make a vertex star print debug function and find out
        # why the verts are not being linked properly.



        # We will be building a road the whole way through.

        # Start the first road.
        _road = new TSAG.E_Road()
        @network.addVisual(_road.getVisual())

        _road.addPoint(isects[0].point)
        _road.setStartVertex(isects[0].vert)

        for i in [1...isects.length]
            isect_obj      = isects[i]
            prev_isect_obj = isects[i - 1]

            vert_prev = prev_isect_obj.vert
            vert      = isect_obj.vert

            # The Halfedge by which we are extending the last road.
            halfedge = vert_prev.get_outgoing_halfedge_to(vert)

            # We associate edges with the roads we are building.
            # NOTE: We don't associate halfedges with roads, since we will be associating them with building fronts.
            edge = halfedge.edge
            edge.data.element = _road



            # Extend the road and give it a canonical halfedge if this is its first span.
            _road.addPoint(isect_obj.point)
            if _road.getHalfedge() == null
                _road.setHalfedge(halfedge)

            # FIXME: use a switch statement or not. Handle all cases for extending this road.
            # Don't forget to call this function to rebuild the roads that we've demolished while splitting and
            # to call the linker's split point function.

            # Intermediate Vert.
            if isect_obj.type == 'i'
                # Intermediate verts are associated with Roads, rather than intersections.
                vert.data.element = _road
                continue

            # Otherwise, if we have come to a non-intermediate point.
            # We've hit the end of the current road at a degree != juncture or dead end.
            
            _road.setEndVertex(vert)
            _road.updateDiscretization(TSAG.style.discretization_length)
            @network.addCollisionPolygon(_road.getCollisionPolygon())
            @network.addRoad(_road)
            _road = null
            
            # We don't need to associate these verts with intersections,
            # because they should have been associated already when the verts were created.
            #vert.data.element = isect_obj.isect
            
            # If we have come to a tail point, then our path is over.
            if isect_obj.type == 't'
                break

            # Else, we begin a new road.

            _road = new TSAG.E_Road()
            @network.addVisual(_road.getVisual())

            _road.addPoint(isect_obj.point)
            _road.setStartVertex(vert)
            continue

        return


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

        # Set the last point on the renderable road to be the user indicated next point.
        # Update the position of the last point in the road.
        @road.updateLastPoint(@next_point)

        # FIXME: Perhaps this should be dependant on the current view bounds...
        # We discretize here because we need to check for legality.
        max_length    = TSAG.style.discretization_length
        @road.updateDiscretization(max_length)

        # 2. Check legality of the current segment. Stop and color the road red if it is not legal.
        if not @checkLegality()
            @road.setFillColor(TSAG.style.error)

            @legal = false
            return

        # The road is Legal!
        @road.revertFillColor()
        @legal = true

        # Interpolate curves.
        # 2. Create new temporary intersections, that would be created 
        # 2. Find the intersections with the global embedding's line bvh.
        # 3. Check to see if endpoints
        @createTempIntersections()

        # We have to rediscretize, because we may have added some curved segments.
        @road.updateDiscretization(max_length)


    destroyLastSegmentIsects: () ->

        # Revert the road to contain the control point and nothing more.
        @road.revert()

        for isect_obj in @isects_last_segment

            # Ignore Permanant intersection objects.
            if isect_obj.type != 's'
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
                # Adds intersections to @isect_last_segment
                @_intersectPolygons(e_polyline, temp_polyline, elem)


        # -- Step 2. Add the end point if it is on an established road...
        last_point     = temp_polyline.getLastPoint()

        # But only if it is sufficiently far away from the last intersection found.
        far_enough = true
        if @isects_last_segment.length > 0
            last_intersection_point = @isects_last_segment[@isects_last_segment.length - 1].point
            far_enough = last_intersection_point.distanceTo(last_point) > @road.getWidth() # @_min_dist?
       
        e_road = @_getRoadAtPt(last_point)
        
        # ASSUMPTION: We will not be intersecting an intersection,
        # because that would be caught by the legality checker...
        if e_road != null and far_enough

            isect_obj = @classify_or_construct_intersection(last_point)
            @network.addVisual(isect_obj.isect.getVisual())
            @isects_last_segment.push(isect_obj)

        # After the intersections have been computed,
        # we add an intermediate curve, where
        # pt1 is the last non - control isect pt.
        # pt2 is the intermediate point at the end of @isects, that is treated as a control point.
        # pt3 is the first intersection computed along this contructed linear segment above in this function.
        if @isects.length >= 2 and @isects[@isects.length - 1].type == 'i'

            len = @isects.length
            pt1 = @isects[len - 2].point
            pt2 = @isects[len - 1].point
            if @isects_last_segment.length > 0
                pt3 = @isects_last_segment[0].point
            else
                pt3 = last_point

            dir1 = pt1.sub(pt2)
            dir2 = pt3.sub(pt2)

            # Curves need at least 90 degrees or my algorithm becomes degenerate.
            if dir1.angleBetween(dir2) < Math.PI/2
                @road.revert()
                @e_scene.ui_message("Error: Curve is too sharp!", {type:"error", element:@road})
                return


            # Remove the current point and the intermediate point from the road.
            # They will be replaced in @_createTempCurve.
            @road.removeLastPoint()
            last_point = @road.removeLastPoint()

            # Adds intersections to @isect_last_segment.
            # Adds the road points to visualize it to the user.
            @_createTempCurve(pt1, pt2, pt3)

            # Add the current user point back, because it controls the linear expanse.
            @road.addPoint(@next_point)

        return

    # Create temporary intersection objects.
    # visual updates only, no topology.
    # THREE.Vector3's FIXME: Use BDS.Points.
    _createTempCurve: (pt0, pt1, pt2) ->

        # Compute the Curve.

        # FIXME: right now we are computing an interpolation.
        # rather than an arc.
        # We will also need to modify the road.

        #prefix = @_quadraticBezier(pt0, pt1, pt2);
        prefix = @_arc(pt0, pt1, pt2, TSAG.style.radius_speed1);

        # Add the curve points as a prefix to the last segment.
        @isects_last_segment = prefix.concat(@isects_last_segment)

        return

    # Computes pts along an arc.
    # The arc will have the given radius and will start on and tangent to the line 01 and end tangent to the line 12.
    # BDS.Point, BDS.Point, BDS.Point -> List of intermediate intersection objects.
    _arc: (pt0, pt1, pt2, radius) ->

        # FIXME: I will need to do some legality checking here, because arc may produce illegal geometry.

        # -- Compute useful mathematical objects.
        dir01 = pt1.sub(pt0)
        dir21 = pt1.sub(pt2)

        ray01 = new BDS.Ray(pt0, dir01)
        ray21 = new BDS.Ray(pt2, dir21)


        # -- Compute Orientation of points and determine normal direction towards curve circle center.

        # -1, 0, or 1
        orientation = ray01.line_side_test(pt2)
        orientation = BDS.Math.sign(orientation)

        # No Curve.
        if orientation == 0
            return []

        # -- Compute The rays ray01 and ray21 offset towards the center from line 01 and line 21.

        perp_dir_pt0 = ray01.getRightPerpendicularDirection().multScalar(orientation)
        perp_dir_pt0 = perp_dir_pt0.normalize()
        offset_pt0   = pt0.add(perp_dir_pt0.multScalar(radius))

        perp_dir_pt2 = ray21.getLeftPerpendicularDirection().multScalar(orientation)
        perp_dir_pt2 = perp_dir_pt2.normalize()
        offset_pt2   = pt2.add(perp_dir_pt2.multScalar(radius))

        offset_ray01 = new BDS.Ray(offset_pt0, dir01)
        offset_ray21 = new BDS.Ray(offset_pt2, dir21)

        # -- The intersection is the center of the arc's circle.
        arc_center_pt = offset_ray01.intersect_ray(offset_ray21)

        # FIXME: This signals invalid geometry.
        if arc_center_pt == null
            return []

        # -- Find the start and ending angles and the cooresponding radial length.
        angle1 = perp_dir_pt0.multScalar(-1).angle()
        angle2 = perp_dir_pt2.multScalar(-1).angle()

        seg_length = TSAG.style.discretization_length

        curve_pts = []

        # If we are in left orientation, then we reverse the angles to minnimum, maximum order.
        # We later reverse the points for ordering them correctly in road path order.
        if orientation < 0
            temp = angle1
            angle1 = angle2
            angle2 = temp

        angle2 += Math.PI*2 if angle2 < angle1
        angle_diff = angle2 - angle1
        arc_length = radius*angle_diff

        len = Math.ceil(arc_length / seg_length)

        for i in [0...len]
            angle = angle1 + i*(angle2 - angle1)/len
            pt = BDS.Point.directionFromAngle(angle)
            curve_pts.push(arc_center_pt.add(pt.multScalar(radius)))

        # Reverse if left orientation.
        if orientation < 0
            curve_pts = curve_pts.reverse()

        isects = []
        for pt in curve_pts
            # Intermediate vertices are very simple to construct.
            isect_obj = {type:'i', point:pt}
            isects.push(isect_obj)
            @road.addPoint(@pt_to_vec(pt))

        return isects

    # BDS.Point, BDS.Point, BDS.Point -> List of intermediate intersection objects.
    _quadraticBezier: (pt0, pt1, pt2) ->

        isects = []

        d1 = pt1.sub(pt0)
        d2 = pt2.sub(pt1)

        # Build road points without duplicating pt0 or pt2.
        # pt1 will be discarded as a control point.
        for t in [1...10]
            time = t/10.0

            # Order 1 Bezier Curves.
            b1 = pt0.add(d1.multScalar(time))
            b2 = pt1.add(d2.multScalar(time))

            # Quadratic Bezier Curve interpolates between positions on the first bezier curves.
            d3 = b2.sub(b1)
            pt = b1.add(d3.multScalar(time))

            # Intermediate vertices are very simple to construct.
            isect_obj = {type:'i', point:pt}
            isects.push(isect_obj)
            @road.addPoint(@pt_to_vec(pt))

        return isects

    vec_to_pt: (vec) ->
        x = vec.x
        y = vec.y
        z = vec.z
        return new BDS.Point(x, y, z)

    pt_to_vec: (pt) ->
        x = pt.x
        y = pt.y
        z = pt.z
        return new THREE.Vector3(x, y, z)


    # Creates e_intersections for every point of intersection between the following 2 polygons.
    # uses the edge from the permanant polyline for later splitting.
    # BDS.Polyline, BDS.Polyline, TSAG.E_Road
    _intersectPolygons: (perm_poly, new_poly, road_in_embedding) ->

        isect_datas = perm_poly.report_intersections_with_polyline(new_poly)

        # FIXME: What happens if the intersections are out of order with regards to
        # the road that we are constructing.

        # Create an intersection for every one of these points.
        for data in isect_datas

            pt = data.point
            edge_index = data.index

            # Find the intersected edge.
            # We assumed that roads are associated with paths,
            # where the canonical halfedge points along the road from the road's first index.
            halfedge = road_in_embedding.getHalfedge()
            for i in [0...edge_index]
                halfedge = halfedge.next
            edge = halfedge.edge

            intersection = new TSAG.E_Intersection(pt)
            isect_obj = {isect:intersection, type:'s', road_edge:edge, point:intersection.getPoint()}

            @isects_last_segment.push(isect_obj)

            # Add the intersection visually and spatially to the network.
            @network.addVisual(intersection.getVisual())
            #@network.addCollisionPolygon(intersection.getCollisionPolygon())

        return #out

        ###
        # Add intersections every time the mouse cursor intersects an older road.
        road_model = @network.query_road(event.x, event.y)
        if road_model != null
            @network.newIntersection(road_model.getPosition())
        ###

    # Returns a road or intersections at the given point.
    # Preference is given to returning an intersection.
    _getIsectOrRoadAtPt: (pt) ->

        # FIXME: Convert this call to function on a point.
        elems = @network.query_elements_pt(pt.x, pt.y)

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
    _getRoadAtPt: (pt) ->
        elems = @network.query_elements_pt(pt.x, pt.y)

        for elem in elems
            if elem instanceof TSAG.E_Road
                return elem

        return null