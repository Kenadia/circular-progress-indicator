module.exports = (grunt) ->

  grunt.initConfig(
      pkg: grunt.file.readJSON("package.json"),
      coffeelint: {
        app: ["app/js/*.coffee"],
        tests: ["tests/*.coffee"]
      },
      coffee: {
        glob_to_multiple: {
          expand: true,
          flatten: true,
          cwd: "app/js",
          src: ["*.coffee"],
          dest: "app/js/",
          ext: ".js"
        }
      }
      uglify: {
        options: {
          banner: "/*! <%= pkg.name %> <%= grunt.template.today(\"yyyy-mm-dd\") %> */\n"
        },
        build: {
          src: "app/js/*.js",
          dest: "app/js/build.min.js"
        }
      }
    )

  grunt.loadNpmTasks("grunt-coffeelint")
  grunt.loadNpmTasks("grunt-contrib-coffee")
  grunt.loadNpmTasks("grunt-contrib-uglify")

  grunt.registerTask("default", ["coffeelint", "coffee", "uglify"])