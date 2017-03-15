###
#
# Global Style objects, including materials for roads, lines, etc.
#
# Written by Bryce Summers on 12 - 19 - 2016.
#
###

TSAG.init_style = () ->
    TSAG.style = 
    {

        radius_speed1: 50,

        discretization_length: 10,
        road_offset_amount: 10,

        # Thee length a user needs to drag their mouse between inputs for curve construction.
        user_input_min_move: 10,

        # Materials.
        m_default_fill: new THREE.MeshBasicMaterial( {color: 0xffffff, side: THREE.DoubleSide} ),
        m_default_line: new THREE.LineBasicMaterial( {color: 0x000000, linewidth:5}),

        # Colors.
        c_building_fill:      new THREE.Color(0xaaaaaa),
        c_building_outline:   new THREE.Color(0x000000),

        c_car_fill:           new THREE.Color(0x00aaaa),

        c_road_fill:          new THREE.Color(0x888888),
        c_road_midline:       new THREE.Color(0x514802),
        c_road_outline:       new THREE.Color(0x000000),
        #road_lane_line  = 

        AABB_testing_material: new THREE.LineBasicMaterial({color: 0x0000ff}),
        cursor_circle_radius: 10,
        cursor_circle_z: 1,
        cursor_circle_color: new THREE.Color(0xff0000),

        # Depth Order.
        dz_intersection: 0.01,
        dz_road: 0,

        dz_cars: .02,

        highlight: new THREE.Color(0x0000ff),

        error: new THREE.Color(0xff0000),
    }

    # Unit Geometries for rendering.
    # This needs to be below the style specifications, because it looks them up in its constructor.
    TSAG.style.unit_meshes = new TSAG.Unit_Meshes();