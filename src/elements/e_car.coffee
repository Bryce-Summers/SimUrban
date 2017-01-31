###
#
# Car Element Class.
# 
# Written by Bryce Summers on 1 - 31 - 2017.
#
# Purpose: This class specifies the gameplay and aesthetic properties of building objects.
###

class TSAG.E_Car extends TSAG.E_Super

    constructor: (position, scale, rotation_z) ->

        super()

        view = @getVisual()

        _position = position
        _rz = rotation_z

        # Allocate a new square mesh, reusing the same unit square geometry.
        mesh = @_newCar({color: TSAG.style.c_car_fill})

        mesh.position.copy(position.clone())
        mesh.scale.copy(scale.clone())

        # Enough rotation to cover all distinct orientations of the house under symmetry.
        mesh.rotation.z = rotation_z

        view.add(mesh)

    # Construct a house object from a square and a triangle.
    _newCar: (params) ->

        mesh_factory = TSAG.style.unit_meshes
        square   = mesh_factory.newSquare(params)
        #square.position.x = .5
        square.scale.x = 2

        return square
