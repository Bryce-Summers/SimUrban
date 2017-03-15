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
        @time_step = 2000.0

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


                # Generate cars for lanes that start at dead ends.
                if @gen_cars and lane.deadStart()
                    x = TSAG.style.road_offset_amount
                    y = TSAG.style.road_offset_amount
                    car = new TSAG.E_Car(new THREE.Vector3(x, y, 1))
                    network.addVisual(car.getVisual())
                    lane.addCar(car)

                # Only process lanes that have cars.
                if lane.isEmpty()
                    continue


                outputs = lane.moveCars()

                # We are done if the lane did not emit any cars.
                if outputs.length == 0
                    continue


                # If the lane has a dead end, then we destroy the cars.
                if lane.deadEnd()
                    for car in outputs
                        network.removeVisual(car.getVisual())

                # Instead of destroying these cars, I would like to move them on to the next lane.
                # To do this
                # 1. link lane indices, perhaps go to the intersection and search for the road that contains the original lane vert.
                # Then randomly choose another road, and deposit it in the proper lane radius. If the lane orientations are reverse, then we invert the indice. 
                # It might not even matter which way it is going, then lane indices will match up.
                # More thinking about what happens when roads of different lane counts line up, also think about routing agents of the same travel class.

                # Move the cars through the intersection to the right lane.
                i_vert   = lane.getEndVert()
                src_vert = lane.getStartVert()

                intersection = i_vert.data.element
                incoming_halfedge = intersection.getIncomingHalfedgeFrom(src_vert)

                # Turn right 1 or 2 times. (right or straight.)
                times = Math.floor(Math.random()*2) + 1

                for i in [0...times]
                    outgoing_halfedge = incoming_halfedge.twin.prev.twin

                # Turn Left.
                #outgoing_halfedge = incoming_halfedge.next

                # Note: Roads are associated to full edges.
                road = outgoing_halfedge.edge.data.element

                for car in outputs
                    road.addCar(car, i_vert)

                    # We need to inform the car that it should consider itself at the beginning of a new lane.
                    car.resetLaneInfo()

        return

