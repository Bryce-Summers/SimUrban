###
 * Testing Routines.
 *
 * Written by Bryce Summers on 12 - 16 - 2016.
###


###
 * Testing Axis Aligned Bounding Box.
###

class EX.Testing

    constructor: () ->

        #@test_AABB()


    test_AABB: () ->

        scene = new THREE.Scene()

        geometry = new THREE.Geometry()

        y = 0
        for x in [0 .. 10]
            mesh = @test_mesh(new THREE.Vector3(x*3 +  0, y*3 + 1, 0 ),
                              new THREE.Vector3(x*3 + -1, y*3 - 1, 0 ),
                              new THREE.Vector3(x*3 +  1, y*3 - 1, 0 ))
            scene.add( mesh )

        AABB = new TSAG.AABB(scene, {val: 'x', dim:2})

        origin    = new THREE.Vector3(0, 0, -10)
        direction = new THREE.Vector3(0, 0, 1)
        ray = new THREE.Ray(origin, direction)

        [mesh, inter] = AABB.collision_query(ray)

        console.log(mesh)
        console.log(inter)

    # Returns a test triangle mesh.
    test_mesh: (a, b, c) ->
    
        geometry = new THREE.Geometry()
        geometry.vertices.push(a, b, c)

        geometry.faces.push( new THREE.Face3( 0, 1, 2 ) )

        material = new THREE.MeshBasicMaterial( { color: 0xffff00 } )
        mesh = new THREE.Mesh( geometry, material )