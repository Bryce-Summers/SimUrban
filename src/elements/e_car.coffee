###
#
# Car Element Class.
# 
# Written by Bryce Summers on 1 - 31 - 2017.
#
# Purpose: This class specifies the gameplay and aesthetic properties of building objects.
#
###

class TSAG.E_Car extends TSAG.E_Super

    constructor: (scale) ->

        super()
        @createVisual(scale)

        # Lane navigation variables.
        @distance = 0.0    # The Distance this car has travelled along this lane.
        @segment_index = 0 # The index of the segement that this car is on.
        @next_car = null

    createVisual: (scale) ->

        view = @getVisual()

        # Allocate a new square mesh, reusing the same unit square geometry.
        mesh = @_newCar({color: TSAG.style.c_car_fill})
        view.add(mesh)

        view.position.z = TSAG.style.dz_cars

        @setScale(scale)

    # Construct a house object from a square and a triangle.
    _newCar: (params) ->

        mesh_factory = TSAG.style.unit_meshes
        square   = mesh_factory.newSquare(params)
        #square.position.x = .5
        square.scale.x = 2

        return square