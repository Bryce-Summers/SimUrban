###

Lane Elements

Written by Bryce Summers on 2 - 1 - 2017.

Purpose: This class contains handles the movement of cars along a lane.

queues cars through lane.
Parameterizes car movement:
 - t space [0:start, 1:end]      # Percentage space, needed for coorespondence with alternate lanes.
 - s space [0:start, length:end] # Distance space,   needed for realistic movement of vehicles.

###
class TSAG.S_Lane

    # Input is a BDS.Polyline that represents the geometry of this lane.
    # ? Lane coorespondences.
    constructor: (polyline, reverse) ->

        @cars = new BDS.SingleLinkedList()

        if reverse
            polyline.reverse()

        # float[] entry i cooresponds to the length from the start to that pt.
        @cumulative_lengths = polyline.computeCumulativeLengths()
        @angles             = polyline.computeTangentAngles()
        @tangents           = polyline.computeUnitTangents()
        @points             = polyline.toPoints()

    # Adds a car to the beginning of this lane.
    addCar: (car) ->

        @cars.enqueue(car)

    # Transports cars along this lane.
    # Lanes move cars, cars perform navigation that will determine their behavior at intersections.
    moveCars: () ->

        destroyed_cars = []

        iter = @cars.iterator()

        while iter.hasNext()
            car = iter.next()

            # For now, we just want to show cars moving.
            # If they move to the end of the lane, then we simply destroy them.
            if not @_moveCar(car, 1)
                iter.remove()
                destroyed_cars.push(car)

        return destroyed_cars

    # Accelerate the car based on the cars or end of lane ahead.
    # We can use traffic models here.
    _accelerateCar: (car) ->


    # Moves the care forwards by the given signed distance.
    _moveCar: (car, change_in_distance) ->

        index = car.segment_index
        car.distance += change_in_distance

        # Search forward for the appropriate segment.
        loop

            next_length = @cumulative_lengths[index + 1]

            # While our car's new distance exceeds the next cumulative distance,
            # we increase the car's segment index.
            break unless car.distance >= next_length
            index += 1

            # The car has reached the end of the lane.
            return false if index == @cumulative_lengths.length
        
        return false if index >= @points.length - 1

        local_distance = car.distance - @cumulative_lengths[index]
        local_point    = @points[index]
        local_tangent  = @tangents[index]

        if not local_tangent
            debugger

        car_position = local_point.add(local_tangent.multScalar(local_distance))

        # Update the car's position, rotation, and segment_index.
        car.setPosition(car_position)
        car.segment_index = index
        car.setRotation(@angles[index])

        return true




