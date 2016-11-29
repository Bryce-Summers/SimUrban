/*
 * Entry Point to my Transportation Simulation Game.
 * Sets up THREE.js on the DOM and sets up input from the browser.
 * Written by Bryce Summers on 11/22/2016
 */

var renderer;
var root_scene;
var root_camera;
var mouse_input;

function init()
{
    // Scene Graph.
    root_scene = new TSAG.Random_Scene(window.innerWidth, window.innerHeight);

    // Camera.
    var dim = {x:0, y:0, w:window.innerWidth, h:innerHeight, padding:10};
    root_camera = new THREE.OrthographicCamera( dim.x - dim.w/2, dim.x + dim.w/2, dim.y - dim.h/2, dim.y + dim.h/2, 1, 1000 );
    root_camera.position.z = 2;

    var x = dim.x + dim.w/2;
    var y = dim.y + dim.h/2;
    root_camera.position.x = x;
    root_camera.position.y = y;

    root_camera.lookAt(new THREE.Vector3(x, y, 0))


    // Renderer.
    var params = {
        antialias: true,
    };
    
    init_renderer(params);

    // Clear to white Background.
    // FIXME: Use a Style Class.
    renderer.setClearColor( 0xD8C49E );

    init_input();
}

function init_renderer(params)
{
    var container = document.getElementById( 'container' );
    renderer = new THREE.WebGLRenderer(params);
    renderer.setPixelRatio( window.devicePixelRatio );
    container.appendChild( renderer.domElement );
    // Set the render based on the size of the window.
    onWindowResize();
}

function init_input()
{
    mouse_input = new TSAG.Mouse_Input_Controller(root_scene, root_camera);

    window.addEventListener( 'resize', onWindowResize, false);

    //window.addEventListener("keypress", onKeyPress);
    window.addEventListener("keydown", onKeyPress);

    window.addEventListener("mousemove", onMouseMove);
    window.addEventListener("mousedown", onMouseDown);
    window.addEventListener("mouseup",   onMouseUp);
}


// Events.
function onWindowResize( event )
{
    renderer.setSize( window.innerWidth, window.innerHeight );
}

// FIXME: ReWire these input events.
function onKeyPress( event )
{
    // Key codes for event.which.
    var LEFT  = 37
    var RIGHT = 39
    
    
}

function onMouseMove( event )
{
    mouse_input.mouse_move(event);
}

function onMouseDown( e )//event
{
    //http://stackoverflow.com/questions/2405771/is-right-click-a-javascript-event
    var isRightMB;
    e = e || window.event;

    if ("which" in e)  // Gecko (Firefox), WebKit (Safari/Chrome) & Opera
        isRightMB = e.which == 3; 
    else if ("button" in e)  // IE, Opera 
        isRightMB = e.button == 2; 

    mouse_input.mouse_down(e, isRightMB);
}

function onMouseUp( event )
{
    mouse_input.mouse_up(event);
}

function animate() {

    requestAnimationFrame( animate );
    render();

}

function render() {

    renderer.render(root_scene, root_camera);
}

init();
animate();