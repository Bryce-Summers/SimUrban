###

Car Element Class.
 
Written by Bryce Summers on 1 - 31 - 2017.

Purpose: This class specifies the gameplay properties of car objects.

###

class TSAG.E_Car extends TSAG.E_Super

    constructor: (scale) ->

        super()

        @total_distance = 0.0
        @total_time = 0.0

        @createVisual(scale)
        @resetLaneInfo()

    # Sets this car's internal info to place it at the start of a new lane.
    resetLaneInfo: () ->
        # Lane navigation variables.
        # These are used to maintain a car's position in its lane.
        @distance = 0.0    # The Distance this car has traveled along this lane.
        @segment_index = 0 # The index of the segement that this car is on.
        @next_car = null

    addDistance: (dist) ->
        @total_distance += dist

    addTime: (dt) ->
        @total_time += dt

    getDistanceTravelled: () ->
        return @total_distance

    getTimeTravelled: () ->
        return @total_time

    createVisual: (scale) ->

        view = @getVisual()

        # Allocate a new square mesh, reusing the same unit square geometry.
        mesh = @_newCar({color: TSAG.style.c_car_fill})
        view.add(mesh)

        view.position.z = TSAG.style.dz_cars

        @setScale(scale)

    # Construct a car THREE.JS object.
    _newCar: (params) ->

        mesh_factory = TSAG.style.unit_meshes
        square   = mesh_factory.newSquare(params)
        #square.position.x = .5
        square.scale.x = 2

        return square