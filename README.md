# Sim Urban
Sim City for Detail Oriented Transportation Engineering, Urban Planning, etc People.

#Play the Game!
[Current Version](https://bryce-summers.github.io/SimUrban/)

#Past Versions
i[x] are development iterations and d[x] are design iterations.
[i1](https://bryce-summers.github.io/SimUrban/builds/build_i1.html), 
[i2](https://bryce-summers.github.io/SimUrban/builds/build_i2.html), 
[d1](https://bryce-summers.github.io/SimUrbanAxurePrototype/), 
[i3_aabvh](https://bryce-summers.github.io/SimUrban/builds/build_i3_aabvh.html), 
[i3](https://bryce-summers.github.io/SimUrban/builds/build_i3.html)

#Documentation
[Documentation of iterative design and development proccess](https://bryce-summers.github.io/Design_Portfolio/pages/SimUrban/page.html)

#Usage
Use you mouse and click to start a road. Click to continue building the road. In i1, press the right mouse button to end a road, in all others double click to end the road.
The design iterations are more like websites, just click around and experience suggestive designs.

Link 

# People
Leader: Bryce Summers, NYU IDM Graduate Student.
Advisor: Jack Bringardner, NYU Professor: General Engineering and Civil Engineering.

# Status
In Early Progress. I am working on this as a research project at New York Universiy in Collaboration with Transportation Engineers as well as people who care about public policy concerning transit.

# Pull Requests
I don't think I will accept any pull requests until I finish designing and implementing the foundational structure of the game. I plan to develop a standardized way that people can contribute new features and use cases.

By all means, if you have an interest in this project and feel compelled to contribute, submit an issue or a pull request. Thank You!



FIXME: Go through and clarify all of this stuff.

# Dependancies

- 6/18/2016: Three.JS (revision 77) for client side rendering.

# Development Dependancies
- Coffeescript, better object oriented programming syntax.
- Grunt, handles html file inclusion and building.
- npm, manages dependancies.

# Installation

Download grunt to inject the all of the files automatically.

You can probably just use:
npm install

// Initialize npm repository.
npm init

<!-- include: "type": "css", "files": "**/*.css" -->
<!-- /include -->
<!-- include: "type": "js", "files": "**/*.js" -->
<!-- /include -->

npm install
npm install grunt --save-dev
npm install grunt-contrib-uglify --save-dev
npm install grunt-contrib-watch --save-dev
npm install grunt-contrib-concat --save-dev
npm install grunt-include-source --save-dev


npm update

# Building
1. Open up two terminals.
2. Navigate each of them to the folder containing this README.
   It should also contain the index.html file and the Gruntfile.js
   For easy navigation, try shift+click on this fold in windows then choose open command promt here.
   On Linux it is not too difficult. On a map, try dragging the file into the terminal or something of that nature.

3. Automatically compile the coffeescript code to javascript in one terminal:
 coffee -o lib/ -cw src/
4. In the other you can automatically inject all of the source code links into the html file:
 npm install
 grunt
 
 
 It may be useful to install python 3 and run python -m http.server in a command prompt to run a local server.
