#
# Axis Aliged Bounding Box Hiearchy.
# Written by Bryce Summers on 12/6/2016.
#
# Purpose: This set partitioning structure may be used to speed up
#          certain geometric queries, such as collisions between polygonal
#          objects and point scene intersection queries.
#          If may also be used to rapidly detect non-collisions.
#
# FIXME: Instead of using Mesh lists, I think that I should use triangle lists.

class TSAG.AABB

    # Contructed from the tree rooted at the given THREE.Object3D node.
    # Obj can alternatively be a list of Triangles with pointers to their mesh objects.
    # xyz = {val: 'x', 'y', or 'z', dim = 2 or 3}
    constructor: (obj, xyz) ->
        
        # Array of THREE.mesh objects.
        @_leafs = []

        if obj instanceof THREE.Object3D
            triangle_list       = @_extract_triangle_list(obj)
        else
            triangle_list = obj

        if triangle_list.length < 4
            for i in [0...triangle_list.length]
                @leafs.push(triangle_list[i])

        @_AABB = _compute_AABB(triangle_list)

        if xyx.dim == 2
            @_AABB.min.z = -1
            @_AABB.max.z = +1

        triangle_list       = @_sort_triangle_list(triangle_list, xyz)
        [left_partition, right_partition] = @_partition_by_SA(triangle_list)

        xyz.value = @_nextXYZ(xyz)
        @_left  = new TSAG.AABB(left_partition,  xyz)
        @_right = new TSAG.AABB(right_partition, xyz)

    # Takes in a THREE.ray.
    # returns [A THREE.Mesh, intersection] if it intersects its geometry.
    # returns null otherwise.
    # FIXME: This doesn't currenlty use early exit strategies for 3D collision.
    # It will only work in 2D for now.
    collision_query: (ray) ->
        if ray.intersectsBox(@_AABB) == null
            return null

        if @_leafs.length > 0
            for i in [0...@_leafs.length]
                triangle = @_leafs[i]
                a = triangle.a
                b = triangle.b
                c = triangle.c

                # No backface culling.
                intersection = ray.intersectTriangle ( a, b, c, false)
                if intersection != null
                    return [triangle.mesh, intersection]

        else
            output = @_left.collision_query(ray)
            if output != null then return output

            output = @_right.collision_query(ray)
            if output != null then return output

        # No Intersection.
        return null

    ###
     - Private Construction Methods. -----------------------
    ###

    # converts a THREE.Object3D into a list of Triangle objects with pointers to their mesh objects.
    _extract_triangle_list: (obj) ->
        mesh_list = @_extract_mesh_list(obj)
        triangle_list = []

        for mesh in mesh_list
            geometry = mesh.geometry
            vertices = geometry.vertices
            faces    = geometry.faces

            for face in faces
                a = vertices[face.a]
                b = vertices[face.b]
                c = vertices[face.c]
                triangle = new THREE.Triangle(a, b, c)

                # Set a pointer to this triangle's mesh.
                triangle.mesh = mesh

                triangle_list.push(triangle)


    # Converts a THREE.Object3D into a list of Mesh objects.
    _extract_mesh_list: (obj) ->
        
        output = []

        add_output =
            (o) -> if o.geometry then output.push(o)

        add_output.output = output

        obj.transverse(add_output)

        return output

    # Sorts the given mesh list by cetroid x position.
    _sort_triangle_list: (triangle_list, xyz) ->
        centroid_index_list = @_centroid_index_list(triangle_list)

        sort_function = 
            (a, b) ->
                switch this.val
                    when 'x' then return a.centroid.x - b.centroid.x
                    when 'y' then return a.centroid.y - b.centroid.y
                    when 'z' then return a.centroid.z - b.centroid.z
                debugger
                console.log("xyz is malformed.")
        sort_function.val = xyz.val

        centroid_index_list.sort(sort_function)

        output = []
        len = triangle_list.length
        for i in [0..len]
            output[i] = centroid_index_list[i].index

        return output

    _nextXYZ: (xyz) ->

        if xyz.dim == 2
            switch xyz.val
                when 'x' then return 'y'
                when 'y' then return 'x'
                when 'z' then console.log("xyz is malformed.")
            debugger
            console.log("xyz is malformed.")

        else if xyz.dim == 3
            switch xyz
                when 'x' then return 'y'
                when 'y' then return 'z'
                when 'z' then return 'x'

        debugger
        console.log("Case not handled.")


    # Converts a mesh list into a mesh list.
    _centroid_index_list: (triangle_list) ->
        output = []
        len = triangle_list.length
        for i in [0...len]
            centroid_index_node = {}
            centroid_index_node.index = i
            centroid_index_node.centroid = @_computeCentroid(triangle_list[i])
            output.push(centroid_index_node)

        return output

    # Computes the centroid of the the vertices in the given THREE.js geometry.
    _computeCentroid: (triangle) ->
        centroid = new Vector3(0, 0, 0)

        centroid.add(triangl.a)
        centroid.add(triangl.b)
        centroid.add(triangl.c)

        centroid.divideScalar(3)

        return centroid


    # Returns [left_AABB, right_AABB],
    # where the split is detemined by minimizing the surface area heuristic.
    # ASSUMPTION: mesh_list.length >= 1
    _partition_by_SA: (triangle_list) ->
        @_ensure_bounding_boxes(triangle_list)

        # Declare minnimization values.
        min_sah   = Number.MAX_VALUE
        min_index = -1

        # Left starts out including the 1st item.
        left = triangle_list[0]
        
        # We populate the right partition in backwards order,
        # so that we can sequentially pop/push items to the left.
        # This saves us array movement time.
        right = []
        i0 = triangle_list.length - 1
        for i in [i0..1] #2 dots imply inclusive of 0.
            right.push(triangle_list[i])

        for i in [1..i0] # [1, len-1] All possible partitions.
            left_AABB = @_compute_AABB(left)
            sah_left  = @_compute_SA(left_AABB)

            right_AABB = @_compute_AABB(right)
            sah_right  = @_compute_SA(right_AABB)

            sah = sah_left + sah_right

            if sah < min_sah
                min_sah   = sah
                min_index = min_index

            # Iterate partition choice.
            left.push(right.pop())

        # Now we will populate to the minnimum partition.
        # ASSUMPTION: min_index >= 1
        left  = []
        right = []

        for i in [0...min_index] # [0,min_index)
            left.push(triangle_list[i])
        for i in [min_index..i0] # [min_index, len]
            right.push(triangle_list[i])

        return [left, right]

    # Ensures that all meshes have valid computed bounding boxes.
    _ensure_bounding_boxes: (triangle_list) ->
        
        len = triangle_list.length
        for i in [0...len]
            triangle = triangle_list[i]
            if not triangle.boundingBox
                @_computeBoundingBox(triangle)

    _computeBoundingBox: (triangle) ->
        AABB = new THREE.Box()

        AABB.expandByPoint(triangle.a)
        AABB.expandByPoint(triangle.b)
        AABB.expandByPoint(triangle.c)

        triangle.boundingBox = AABB

    # Computes the axis aligned bounding box minnimally bounding the given
    # list of meshes.
    # Output will be represented by {min: THREE.Vector3, max: THREE.Vector3}
    _compute_AABB: (triangle_list) ->

        # THREE.Box3
        output = new THREE.Box3()

        for i in [0...triangle_list.length]
            triangle     = triangle_list[i]
            AABB = triangle.boundingBox
            output.union(AABB)

        return AABB

    # Returns the surface area for the given bounding box.
    _compute_SA: (AABB) ->
        min = AABB.min
        max = AABB.max

        dx = max.x - min.x
        dy = max.y - min.y
        dz = max.z - min.z

        sxy = dx*dy
        sxz = dx*dz
        syz = dy*dz

        return sxy + sxz + syz
