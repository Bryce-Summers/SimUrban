###

Building Rotation Time Controller.

Written by Bryce Summmers on 1 - 31 - 2017.

 - A Test time controller that takes every building in the scene and rotates it by a steady rate.

###

class TSAG.I_Time_Generate_Cars

    # Input: THREE.js Scene. Used to add GUI elements to the screen and modify the persistent state.
    # THREE.js
    constructor: (@scene, @camera) ->
        @time_count = 0.0
        @time_step = 1000.0

    time: (dt) ->

        @time_count += dt
        @gen_cars = false

        if @time_count > @time_step
            @time_count = (@time_count % @time_step) - @time_step
            @gen_cars = true

        # TSAG.E_Building[]
        network = @scene.getNetwork()
        roads   = network.getRoads()

        # Randomly Generate Cars and have them run along each lane.
        for road in roads
            lanes = road.getLanes()
            for lane in lanes
                if @gen_cars
                    x = TSAG.style.road_offset_amount
                    y = TSAG.style.road_offset_amount
                    car = new TSAG.E_Car(new THREE.Vector3(x, y, 1))
                    @scene.addVisual(car.getVisual())
                    lane.addCar(car)


                destroyed = lane.moveCars()

                for car in destroyed
                    @scene.removeVisual(car.getVisual())

        return

