#
# Sim Urban Road class.
#
# Written by Bryce Summers on 12 - 19 - 2016.
# This class represents Road elements.
#

class TSAG.E_Road extends TSAG.E_Super

    constructor: () ->

        super()

        # The main curve is used to determine the geometric embedding of the middle curve on the road.
        # It is modifiable by a user and is used to compute all other offset curves.
        @_main_curve = new TSAG.S_Curve()

        # Set road elements to the proper depth.
        visual = @getVisual()
        visual.position.z = TSAG.style.dz_road

        @fill_material = TSAG.style.m_default_fill.clone()

        @_road_visual = null
        @_center_polyline = null

        @lanes = []

        @vert_start = null
        @vert_end   = null
        @halfedge   = null

        # Revert indices.
        # {point1:, point2:, index}
        @reverts = []


    ####################################################################################################
    #
    # Topology.
    #
    ####################################################################################################

    # Set the beginning vertex for this road.
    setStartVertex: (vert) ->
        @vert_start = vert

    getStartVertex: () ->
        return @vert_start

    # Topologically speaking, roads consist of paths starting at an arbitrary vertex
    # and continuing on through vertices of degree 2 until we get to the ending vertex.
    # Roads represent paths between Extraordinary / degree != 2 verts.
    # All of the edges in between will point to this road object in their .data objects.
    # All of these topological elements may be easily found if we know of the halfedge along this road
    # originating from the start vertex and headed in the direction of the ending vertex.
    setHalfedge: (halfedge) ->
        @halfedge = halfedge

    # Returns null if the road's halfedge has not yet been defined.
    getHalfedge: () ->
        return @halfedge

    # Set the ending vertex for this road.
    setEndVertex: (vert) ->
        @vert_end = vert

    getEndVertex: () ->
        return @vert_end

    hasEndPoint: (vert) ->
        return @vert_start == vert or @vert_end == vert


    ####################################################################################################
    #
    # Geometry.
    #
    ####################################################################################################

    # Extends this road to include the given point.
    # returns false if the given point produces illegal road geometry.
    # THREE.Vector3
    addPoint: (pt) ->

        @_main_curve.addPoint(pt)

        # FIXME: Check for illegal road geometry.
        return true

    getLastPoint: () ->
        return @_main_curve.getLastPoint()

    getPenultimatePoint: () ->

        len = @_main_curve.numPoints()
        return @_main_curve.getPointAtIndex(len - 2)

    # 0 is end, 1 is penultimate, i is ith index of the reversed array of points.
    getPointAtIndexFromEnd: (index) ->
        len = @_main_curve.numPoints()
        return @_main_curve.getPointAtIndex(len - 1 - index)

    removeLastPoint: () ->
        return @_main_curve.removeLastPoint()

    # pushes the current state of the road onto the revert stack.
    # Note: The user can legally remove the last point from this road.
    setRevert: () ->
        @reverts.push({index:@_main_curve.numPoints(), point2:@getLastPoint(), point1:@getPenultimatePoint()})

    # reverts to the newest revert state.
    revert: () ->

        revert_obj = @revertObj()

        while @_main_curve.numPoints() > revert_obj.index - 2
            @removeLastPoint()

        @addPoint(revert_obj.point1)
        @addPoint(revert_obj.point2)
        #@reverts.pop()

    revertObj: () ->
        return @reverts[@reverts.length - 1]

    # THREE.Vector3
    # Updates the location of the road's last point.
    updateLastPoint: (pt) ->
        @removeLastPoint()
        @addPoint(pt)


    getPosition: (time) ->
        return @_main_curve.position(time)

    updateDiscretization: (max_length) ->
        @updateVisual(max_length)
        @generateBVH()


    # Max length is the maximum length per segment.
    # FIXME: I should instead scale segments with curvature.
    updateVisual: (max_length) ->

        offset_amount = TSAG.style.road_offset_amount
        @_main_curve.updateDiscretization(max_length)

        # -- Compute various lines for the road.
        # We will pack them into a single THREE.js Object.
        visual = @getVisual()
        visual.remove(@_road_visual)
        @_road_visual = new THREE.Object3D()
        visual.add(@_road_visual)

        # For now, we will use simple black strokes.
        # FIXME: We will put these style properties somewhere else in the future.
        material = TSAG.style.m_default_line.clone()
        material.color = TSAG.style.c_road_outline

        middle_material = TSAG.style.m_default_line.clone()
        middle_material.color = TSAG.style.c_road_midline

        middle_line = new THREE.Geometry()
        middle_line.vertices = @_main_curve.getDiscretization()
        @_center_polyline    = @_THREE_vertex_list_to_BDS_Polyline(middle_line.vertices)
        
        times_left  = []
        times_right = []
        verts_left  = []
        verts_right = []

        left_line  = new THREE.Geometry()
        verts_left = @_main_curve.getOffsets(max_length, offset_amount, times_left)
        left_line.vertices = verts_left

        right_line  = new THREE.Geometry()
        verts_right = @_main_curve.getOffsets(max_length, -offset_amount, times_right)
        right_line.vertices = verts_right

        # Compute fill, using time lists to determine indices for the faces.
        fill_geometry = @_get_fill_geometry(verts_left, verts_right, times_left, times_right)
        fill_material = TSAG.style.m_default_fill.clone()
        fill_material.color = TSAG.style.c_road_fill

        @fill_material = fill_material

        fill_mesh = new THREE.Mesh( fill_geometry, fill_material )
        fill_mesh.position.z = -.01 # Draw dill behind.
        @_road_visual.add(fill_mesh)
        @_road_visual.add(new THREE.Line( middle_line, middle_material ))
        @_road_visual.add(new THREE.Line( left_line,   material ))
        @_road_visual.add(new THREE.Line( right_line,  material ))

        # Update the mathematical model for car movement along lanes.
        @updateLaneStructures(max_length, offset_amount, times_left, times_right)

    updateLaneStructures: (max_length, offset_amount, times_left, times_right) ->
        # Update Lane Structures.
        left_lane_vectors  = @_main_curve.getOffsets(max_length,  offset_amount/2, times_left)
        right_lane_vectors = @_main_curve.getOffsets(max_length, -offset_amount/2, times_right)

        left_lane_polyline  = @_main_curve.threeVectorsToBDSPolyline(left_lane_vectors)
        right_lane_polyline = @_main_curve.threeVectorsToBDSPolyline(right_lane_vectors)

        # FIXME: Flips these if we are in Britain.
        # Over here in the U.S. we drive on the right side of the road.
        right_lane = new TSAG.S_Lane(right_lane_polyline, false, @vert_start, @vert_end)
        left_lane  = new TSAG.S_Lane(left_lane_polyline,  true,  @vert_end, @vert_start)        

        @lanes = []
        @lanes.push(right_lane)
        @lanes.push(left_lane)


    # THREE.Color -> sets this material's fill color.
    setFillColor: (c) ->
        @fill_material.color = c

    revertFillColor: () ->
        @fill_material.color = TSAG.style.c_road_fill

    # Creates a fill polygon based on the input times.
    # Due to line curvature, vertices at higher curvature regions will exhibit higher degrees in this polygonalization.
    # Assumes each list of times ends on the same time, the times increase strictly monototically.
    _get_fill_geometry: (left_verts, right_verts, times_left, times_right) ->

        output = new THREE.Geometry()
        output.vertices = left_verts.concat(right_verts)
        faces = output.faces

        l_len = left_verts.length
        r_len = right_verts.length

        l_index = 0
        r_index = 0

        l_time = 0.0
        r_time = 0.0

        while l_index < l_len - 1 or r_index < r_len - 1

            left_time  = times_left[l_index]
            right_time = times_right[r_index]

            big_left  = false
            big_left  = left_time  < right_time

            # Break tie using by comparing the next couple of points.
            if left_time == right_time
                big_left  = times_left[l_index + 1] < times_right[r_index + 1]

            # Use 2 left vertices and 1 right vertex.
            if big_left
                face = new THREE.Face3(l_index, l_index + 1, r_index + l_len)
                # We use a model to allow collision queries to pipe back to this road object with time domain knowledge.
                face.model = new TSAG.M_Road(@t0, @t1, @road)
                faces.push(face)
                l_index += 1
                continue

            # Big right otherwise.
            face = new THREE.Face3(r_index + 1 + l_len, r_index + l_len, l_index)
            face.model = new TSAG.M_Road(@t0, @t1, @road)
            faces.push(face)
            r_index += 1
            continue

        # THREE.Geometry
        return output

    getCenterPolyline : () ->
        return @_center_polyline

    # THREE.Vector3[] -> BDS.Polyline
    _THREE_vertex_list_to_BDS_Polyline: (vectors) ->
        out = new BDS.Polyline()

        for vec in vectors
            out.addPoint(new BDS.Point(vec.x, vec.y))

        return out

    getLanes: () ->
        return @lanes

    getAgents: (out) ->
        for lane in @lanes
            lane.getAgents(out)

    # Adds a car to this road,
    # Starting at the given vertex and travelling towards the non given vertex.
    # FIXME: I will need to abstract this out once we have multiple lanes.
    addCar: (car, vert) ->
        if vert == @vert_start
            @lanes[0].addCar(car)
        else
            @lanes[1].addCar(car)

    # Returns the total width of the road.
    getWidth: () ->
        TSAG.style.road_offset_amount*@lanes.length