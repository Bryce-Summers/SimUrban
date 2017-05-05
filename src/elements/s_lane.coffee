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
    # BDS.Polyline, bool, SCRIB.Vertex, SCRIB.Vertex
    constructor: (polyline, reverse, @_start_vert, @_end_vert) ->

        @cars = new BDS.SingleLinkedList()

        if reverse
            polyline.reverse()

        # float[] entry i cooresponds to the length from the start to that pt.
        @cumulative_lengths = polyline.computeCumulativeLengths()
        @angles             = polyline.computeTangentAngles()
        @tangents           = polyline.computeUnitTangents()
        @points             = polyline.toPoints()

    getStartVert: () ->
        return @_start_vert

    getEndVert: () ->
        return @_end_vert

    # Adds a car to the beginning of this lane.
    addCar: (car) ->

        @cars.enqueue(car)

    # Transports cars along this lane.
    # Lanes move cars, cars perform navigation that will determine their behavior at intersections.
    moveCars: (dt) ->

        destroyed_cars = []

        iter = @cars.iterator()

        while iter.hasNext()
            car = iter.next()

            # For now, we just want to show cars moving.
            # If they move to the end of the lane, then we simply destroy them.
            if not @_moveCar(car, 1)# fixme, use dt
                iter.remove()
                destroyed_cars.push(car)
            else
                car.addTime(dt)

        return destroyed_cars

    # Accelerate the car based on the cars or end of lane ahead.
    # We can use traffic models here.
    _accelerateCar: (car) ->


    # Moves the care forwards by the given signed distance.
    _moveCar: (car, change_in_distance) ->

        index = car.segment_index
        car.distance += change_in_distance
        car.addDistance(Math.abs(change_in_distance))

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

        # Funky Interpolation.
        #car_position.x = old_position.x * .7 + car_position.x*.3
        #car_position.y = old_position.y * .7 + car_position.y*.3

        old_angle = car.getRotation()
        new_angle = @angles[index]

        if new_angle - old_angle > Math.PI
            new_angle -= Math.PI*2

        if old_angle - new_angle > Math.PI
            new_angle += Math.PI*2

        new_angle = old_angle * .7 + new_angle*.3

        # Update the car's position, rotation, and segment_index.
        car.setPosition(car_position)
        car.segment_index = index
        car.setRotation(new_angle)

        return true

    getAgents: (out) ->

        iter = @cars.iterator()

        while iter.hasNext()
            car = iter.next()
            out.push(car)

        return

    isEmpty: () ->
        return @cars.isEmpty()

    # Returns true iff the lane begins at a vertex of degree 1.
    deadStart: () ->
        return @_start_vert.degree() == 1

    deadEnd: () ->
        return @_end_vert.degree() == 1
