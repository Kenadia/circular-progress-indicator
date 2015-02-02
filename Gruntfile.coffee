module.exports = (grunt) ->

  grunt.initConfig(
      pkg: grunt.file.readJSON("package.json"),
      autoprefixer: {
        build: {
          expand: true,
          flatten: true,
          src: "src/css/*.css",
          dest: "app/css/"
        }
      },
      coffeelint: {
        app: ["src/coffeescript/*.coffee"],
        tests: ["tests/*.coffee"]
      },
      coffee: {
        glob_to_multiple: {
          expand: true,
          flatten: true,
          cwd: "src/coffeescript",
          src: ["*.coffee"],
          dest: "build/js/",
          ext: ".js"
        }
      }
      uglify: {
        options: {
          banner: "/*! <%= pkg.name %> <%= grunt.template.today(\"yyyy-mm-dd\") %> */\n"
        },
        build: {
          src: "build/js/*.js",
          dest: "app/js/build.min.js"
        }
      }
    )

  grunt.loadNpmTasks("grunt-autoprefixer")
  grunt.loadNpmTasks("grunt-coffeelint")
  grunt.loadNpmTasks("grunt-contrib-coffee")
  grunt.loadNpmTasks("grunt-contrib-uglify")

  grunt.registerTask("default", ["autoprefixer", "coffeelint", "coffee", "uglify"])
