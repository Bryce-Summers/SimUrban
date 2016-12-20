#
# Transportation Network.
#
# Written by Bryce Summers on 12 - 18 - 2016.
#
# Purpose:
# This class represents a connected transportation network and provides gameplay functionality and rendering capabilities.
# Its functions are named according to gameplay uses, rather than mathematical imperatives.

class TSAG.E_Network extends TSAG.E_Super

    constructor: () ->
    
        super()

        # Flag for updating the Bounding volume hierarchy.
        @_bvh_needs_update = true;
        @_bvh = null

        @_network_topology = new TSAG.S_Network_Topology()

        @_intersections = []
        @_roads         = []

    # Returns a new road element containing a topological link to the a location in this Network and an initial position at that location.
    # The location will be new if the position is not yet occupied.
    # The location will be one previously in the network if the position is occupied by an intersection.
    # the location will be a new intersection location if the location is occupied by a road.
    # returns false otherwise.  # FIXME: Implement Error Displays for the user.
    # new locations will be constructed with the default element, old locations will have their elements unchanged.
    newRoad: (x, y) ->

        # FIXME: Implement the real specification.
        # FIXME: Optimize This.
        @_BVH = new TSAG.S_AABVH(@getVisual(), {val: 'x', dim: 2})

        intersection = @newIntersection(x, y)
        vertex = intersection.getVertex()

        # Next Construct the road + topology.
        edge = @_network_topology.newEdge()
        edge.setStartVert(vertex)
        road = new TSAG.E_Road(edge)
        edge.setElement(road)
        @_roads.push(road)

        visual = @getVisual()
        visual.add(road.getVisual())

        return road

    newIntersection: (x, y) ->

        # FIXME: Optimize This.
        @_BVH = new TSAG.S_AABVH(@getVisual(), {val: 'x', dim: 2})

        # First construct a starting intersection + topology.
        vertex = @_network_topology.newVertex()
        position = new THREE.Vector3(x, y, 0)
        intersection = new TSAG.E_Intersection(vertex, position)
        vertex.setElement(intersection)
        @_intersections.push(intersection)

        visual = @getVisual()
        visual.add(intersection.getVisual())

        return intersection

    # Returns a non-intersection patch of road model if found.
    query_road: (x, y) ->

        triangle = @_BVH.query_point(x, y)

        return null if triangle == null

        triangle.mesh.material.color = new THREE.Color(Math.random(), Math.random(), Math.random())

        model   = triangle.model
        element = triangle.mesh.element

        # This needs to come first.
        if element instanceof TSAG.E_Intersection
            return null
            #return element

        if model instanceof TSAG.M_Road
            return model

        return null

    # FIXME: Think this through, and make reasonabble global rediscretization functions.