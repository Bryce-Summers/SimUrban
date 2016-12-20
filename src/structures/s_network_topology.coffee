#
# Network Topology.
#
# Written by Bryce Summers on 12 - 18 - 2016.
#
# Purpose: This class handles:
#
# - The locations (vertices, endpoints, intersections)
# - edges, represented by curve embeddings that are discretized.
# - Network topology, how the edges are connected at the vertices.
# - The efficient construction of new edges.

class TSAG.S_Vertex

    constructor: () ->

        # The set of edges connected to this location.
        @_edges = []

        # Associated data element.
        @_element = null

    # TSAG.S_Edge
    addEdge: (edge) ->
        @_edges.push(edge)

    setElement: (element) ->
        @_element = element

    getElement: () ->
        return @_element

class TSAG.S_Edge

    constructor: () ->

        # TSAG.Vertex
        @_v0 = null

        # TSAG.Vertex
        @_v1 = null

        # Associated data element.
        @element = null

    getStartVert: () ->
        return @_v0

    getEndVert: () ->
        return @_v1

    setStartVert: (v0) ->
        @_v0 = v0

    setEndVert: (v1) ->
        @_v1 = v1

    setVerts: (v0, v1) ->
        @_v0 = v0
        @_v1 = v1

    setElement: (element) ->
        @_element = element

    getElement: () ->
        return @_element

class TSAG.S_Network_Topology

    constructor: () ->

        # Flag for updating the Bounding volume hierarchy.
        @_bvh_needs_update = true;
        @_bvh = null

        # Vertices, TSAG.Location[]
        @_vertices = []

        # Edges, TSAG.Edge[]
        @_edges = []

    newVertex: () ->
        vert = new TSAG.S_Vertex()
        @_vertices.push(vert)
        return vert

    newEdge: () ->
        edge = new TSAG.S_Edge()
        @_edges.push(edge)
        return edge


