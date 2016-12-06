#
# Axis Aliged Bounding Box Hiearchy.
# Written by Bryce Summers on 12/6/2016.
#
# Purpose: This set partitioning structure may be used to speed up
#          certain geometric queries, such as collisions between polygonal
#          objects and point scene intersection queries.
#          If may also be used to rapidly detect non-collisions.

class TSAG.AABB

    # Cosntructed from the tree rooted at the given THREE.Object3D node.
    # xyz = 'x', 'y', or 'z'
    constructor: (obj, xyz) ->
        
        mesh_list       = @extract_mesh_list(obj)
        mesh_list       = @sort_mesh_list(mesh_list, xyz)
        [@left, @right] = @partition_by_SA(mesh_list)


    # Converts a THREE.Object3D into a list of Mesh objects.
    extract_mesh_list: (obj) ->
        
        output = []

        obj.transverse((o) ->
                if o.geometry
                    output.push(o)
            )

        return output

    # Sorts the given mesh list by cetroid x position.
    sort_mesh_list: (mesh_list, xyz) ->
        


    # Returns [left_AABB, right_AABB],
    # where the split is detemined by minimizing the surface area heuristic.
    partition_by_SA : (mesh_list) ->


    # Computes the axis aligned bounding box minnimally bounding the given
    # list of meshes.
    # Output will be represented by {min: THREE.Vector3, max: THREE.Vector3}
    compute_AABB: (mesh_list) ->


    # Returns the surface area for the given bounding box.
    compute_SA: (AABB) ->