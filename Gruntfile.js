module.exports = function (grunt) {
  grunt.initConfig({
    includeSource: {
      options: {
        basePath: './'
      },
      myTarget: {
        files: {
          'index.html': 'index.tpl.html'
        }
      }
    }
  });
  
  grunt.loadNpmTasks('grunt-include-source');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.registerTask('default', function (target) {
    grunt.task.run('includeSource');
  });
};