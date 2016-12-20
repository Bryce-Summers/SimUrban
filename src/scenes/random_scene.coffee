###
    Random Scene.
    Written by Bryce on 11/22/2016
###

class TSAG.Random_Scene extends THREE.Scene

    constructor: (scene_width, scene_height) ->

        super()

        @_scale = 40
        @_padding = 30;

        @_Mesh_Factory = new TSAG.Unit_Meshes()
        @_AABB = null

        # Create a plane that is perpendicular facing to the z axis.
        for i in [0...3000]

            # Allocate a new square mesh, reusing the same unit square geometry.
            #mesh = @_Mesh_Factory.newSquare({color:0xaaaaaa})
            mesh = @_newHouse({color:0xaaaaaa})

            x = @_padding + Math.random() * (scene_width  - @_padding * 2)
            y = @_padding + Math.random() * (scene_height - @_padding * 2)
            w = @_scale
            h = @_scale

            pos = mesh.position
            pos.x = x
            pos.y = y

            scale = mesh.scale
            scale.x = w
            scale.y = h

            # Enough rotation to cover all distinct orientations of the house under symmetry.
            rotation = mesh.rotation
            rotation.z = Math.random() * Math.PI*2

            @add(mesh)

        return

    # Construct a house object from a square and a triangle.
    _newHouse: (params) ->
        square   = @_Mesh_Factory.newSquare(params)
        triangle = @_Mesh_Factory.newTriangle(params)
        triangle.position.x = .5
        triangle.scale.x = .5

        node = new THREE.Object3D();

        node.add(square);
        node.add(triangle);
        return node;


    getMeshFactory: () ->
        return @_Mesh_Factory

    # Returns the mesh and the intersection point at the given cursor location or null if their is nothing there.
    queryPoint: (x, y) ->
        if @_AABB == null
            @_AABB = new TSAG.AABB(this, {val: 'x', dim:2})

            # Visualize the hierarchy
            line_material = new THREE.LineBasicMaterial({color: 0x0000ff});
            aabb_line_meshes = @_AABB.get_AABB_line_meshes(line_material)
            for mesh in aabb_line_meshes
                @add(mesh)

            

        origin    = new THREE.Vector3(x, y, -10)
        direction = new THREE.Vector3(0, 0,   1)
        ray = new THREE.Ray(origin, direction)

        results = @_AABB.collision_query(ray)

        #[mesh, intersection_point]
        return results