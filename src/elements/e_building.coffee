###
#
# Building Element Class.
# 
# Written by Bryce Summers on 12 - 19 - 2016.
#
# Purpose: This class specifies the gameplay and aesthetic properties of building objects.
###

class TSAG.E_Building extends TSAG.E_Super

    constructor: (position, scale, rotation_z) ->

        super()

        view = @getVisual()

        _position = position
        _rz = rotation_z

        # Allocate a new square mesh, reusing the same unit square geometry.
        mesh = @_newHouse({color: TSAG.style.c_building_fill})

        mesh.position.copy(position.clone())
        mesh.scale.copy(scale.clone())

        # Enough rotation to cover all distinct orientations of the house under symmetry.
        mesh.rotation.z = rotation_z

        @_mesh = mesh
        view.add(mesh)

    # Construct a house object from a square and a triangle.
    _newHouse: (params) ->

        mesh_factory = TSAG.style.unit_meshes
        square   = mesh_factory.newSquare(params)
        triangle = mesh_factory.newTriangle(params)
        triangle.position.x = .5
        triangle.scale.x = .5

        node = new THREE.Object3D();

        node.add(square);
        node.add(triangle);

        return node;

    rotateBuilding: (dr) ->
        mesh.rotation.z += dr

