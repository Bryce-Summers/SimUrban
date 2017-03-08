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

        @_road_visual = null
        @_center_polyline = null

        @lanes = []


    # Extends this road to include the given point.
    # returns false if the given point produces illegal road geometry.
    # THREE.Vector3
    addPoint: (pt) ->

        @_main_curve.addPoint(pt)

        # FIXME: Check for illegal road geometry.
        return true

    getLastPoint: () ->
        return @_main_curve.getLastPoint()

    removeLastPoint: () ->
        return @_main_curve.removeLastPoint()

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

        # FIXME: Flips these if we are in Brittain.
        # Over here in the U.S. we drive on the right side of the road.
        left_lane  = new TSAG.S_Lane(left_lane_polyline,  true)
        right_lane = new TSAG.S_Lane(right_lane_polyline, false)

        @lanes = []
        @lanes.push(left_lane)
        @lanes.push(right_lane)


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

    # Returns the total width of the road.
    getWidth: () ->
        TSAG.style.road_offset_amount*@lanes.length