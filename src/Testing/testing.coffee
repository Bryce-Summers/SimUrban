###
 * Testing Routines.
 *
 * Written by Bryce Summers on 12 - 16 - 2016.
###


###
 * Testing Axis Aligned Bounding Box.
###

class TSAG.Testing

    constructor: () ->

    	@test_AABB()


    test_AABB: () ->

    	scene = new THREE.Scene()

    	geometry = new THREE.Geometry()



		material = new THREE.MeshBasicMaterial( { color: 0xffff00 } );
		mesh = new THREE.Mesh( geometry, material );
		scene.add( mesh );

		AABB = new TSAG.AABB(scene, {val: 'x', dim:2})

		origin    = new THREE.Vector3(0, 0, -10)
		direction = new THREE.Vector3(0, 0, 1)
		ray = new THREE.Ray(origin, direction)

		[mesh, inter] = AABB.collision_query(ray)

		console.log(mesh)
		console.log(inter)
