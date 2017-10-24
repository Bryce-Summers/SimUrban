###
#
# Element Interface Class.
# This specifies properties of all element objects.
#
# Written by Bryce Summers on 12 - 19 - 2016.
#
# Some Elements will have pointers to Scribble Elements.
# All elements contain an @_view object that is a renderable THREE.js scene node.
# All elements also contain an BDS.AABVH @_BVH object that stores versions of this element's geometry for collision detection.
###

class TSAG.E_Super

    # Input something like a THREE.Scene object if desired.
    constructor: (@_view) ->

        # The view is a three.js object that stores the visual data used for rendering to the screen.
        if not @_view
            @_view = new THREE.Object3D()

        # The bvh is a BDS.BVH2D object that stores geometry used for collision detection,
        # Which will allow users to query and interact with these elements.
        @_bvh = new BDS.BVH2D()

        # The collision polygon used to represent this element in more macroscopic bvh's
        @_collision_polygon = null

        # The topology is a SCRIB Halfedge Mesh element that represents this element's topological structure.
        if not @_topology
            @_topology = null # This indicates that this is a temporary element, such as those being used in construction onscreen.

    isTemporary: () ->
        return @_topology == null

    # Returns the current visual.
    getVisual: () ->
        return @_view

    # Set the topology after it is no longer tempory.
    setTopology: (@_topology) ->

    getTopology: () ->
        return @_topology

    # THREE.JS scene graph manipulation methods.
    addVisual: (subview) ->
        @_view.add(subview)

    removeVisual: (subview) ->
        @_view.remove(subview)

    addCollisionPolygons: (polygons) ->
        for aPolygon in polygons
            @addCollisionPolygon(aPolygon)

    addCollisionPolygon: (polygon) ->
        @_bvh.add(polygon)

    removeCollisionPolygons: (polygons) ->
        for aPolygon in polygons
            @removeCollisionPolygon(aPolygon)

    removeCollisionPolygon: (polygon) ->
        @_bvh.remove(polygon)

    # Generates this Element's BVH from scratch with all collision data pointing to thie element.
    # This may be useful for leaf node's, but should be avoided for parent nodes.
    generateBVH: () ->
        polylines = @_to_collision_polygons()
        @_bvh = new BDS.BVH2D(polylines)

    generateCollisionPolygon: () ->
        @_collision_polygon = @_bvh.toBoundingBox().toPolyline()
        @_collision_polygon.setAssociatedData(@)
        return @_collision_polygon

    getCollisionPolygon: () ->
        if @_collision_polygon == null
            @generateCollisionPolygon()

        return @_collision_polygon

    # Returns a new visual that is freshly constructed based on the given viewport.
    # some classes, such as road networks will provide a function to reconstruct the visual, optimized for a particular viewport.
    # toVisual: (viewport) ->

    # Methods to convert this element's THREE.JS object directly into Collision detection geometry.
    # Directly copies this element's triangle representation, doesn't do any bounding box optimizations.
    # Each individual element may wish to override this with more efficient or coarse methods.
    # converts a THREE.Object3D into a list of Triangle objects with pointers to their mesh objects.
    # () -> BDS.Polyline()
    # Optional: appends lines to an input list.
    # Note: Polylines are interpreted to be polygons when closed.
    _to_collision_polygons: (output) ->

        obj           = @_view
        mesh_list     = @_to_mesh_list(obj)
        polyline_list = []

        if output != undefined
            polyline_list = output

        for mesh in mesh_list
            geometry = mesh.geometry
            vertices = geometry.vertices
            faces    = geometry.faces

            # Matrix Transform from local mesh position coordinates to world position coordinates.
            localToWorld = mesh.matrixWorld

            for face in faces
                a = vertices[face.a].clone()
                b = vertices[face.b].clone()
                c = vertices[face.c].clone()

                a.applyMatrix4(localToWorld)
                b.applyMatrix4(localToWorld)
                c.applyMatrix4(localToWorld)

                a = @_vector_to_point(a)
                b = @_vector_to_point(b)
                c = @_vector_to_point(c)

                polyline = new BDS.Polyline(true, [a, b, c])

                # Associate this polyline with this Game element.
                polyline.setAssociatedData(@)

                polyline_list.push(polyline)

        return polyline_list

    # Converts a THREE.JS Vector to a BDS.Point.
    _vector_to_point: (vec) ->
        return new BDS.Point(vec.x, vec.y, vec.z);

    # Converts this object's view into a list of three.js objects.
    # THREE.Object3D -> THREE.Mesh[]
    _to_mesh_list: (obj) ->

        output = []

        add_output =
            (o) -> if o.geometry then output.push(o)

        obj.traverse(add_output)

        return output

    setFillColor: (c) ->

        err = new Error("This method should be overriden in a subclass.")
        console.log(err.stack)
        debugger
        throw err

    revertFillColor: () ->

        err = new Error("This method should be overriden in a subclass.")
        console.log(err.stack)
        debugger
        throw err


    # FIXME

    setPosition: (position) ->
        z = @_view.position.z
        @_view.position.copy(position.clone())
        @_view.position.z = z
    
    setRotation: (rotation_z) ->
        @_view.rotation.z = rotation_z

    getRotation: () ->
        return @_view.rotation.z

    setScale: (scale) ->

        @_view.scale.copy(scale.clone())

    getPosition: () ->
        return @_view.position.clone()

    # Returns a list of all agents.
    # This might be used in road demolition to get a list of cars that need to be moved.
    getAgents: (out) ->
        throw new Error("Destroy is unimplemented for this element!!!")


    # Returns true if one of this element's collision geometries contains the given point.
    containsPt: (pt) ->
        return @_bvh.query_point(pt) != null
