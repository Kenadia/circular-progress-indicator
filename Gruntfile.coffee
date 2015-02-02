module.exports = (grunt) ->

  grunt.initConfig(
      pkg: grunt.file.readJSON("package.json"),
      clean: {
        build: {
          src: ["build", "app/css", "app/js"]
        },
        stylesheets: {
          src: ["build/css/*.css"]
        },
        scripts: {
          src: ["build/js/*.js"]
        }
      }
      autoprefixer: {
        build: {
          expand: true,
          flatten: true,
          src: "src/css/*.css",
          dest: "build/css/"
        }
      },
      cssmin: {
        build: {
          src: "build/css/*.css",
          dest: "app/css/build.min.css"
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
      },
      watch: {
        stylesheets: {
          files: "src/css/*.css",
          tasks: ["stylesheets"],
          options: {
            livereload: true
          }
        },
        scripts: {
          files: "src/coffeescript/*.coffee",
          tasks: ["scripts"],
          options: {
            livereload: true
          }
        }
      }
    )

  grunt.loadNpmTasks("grunt-contrib-clean")
  grunt.loadNpmTasks("grunt-autoprefixer")
  grunt.loadNpmTasks("grunt-contrib-cssmin")
  grunt.loadNpmTasks("grunt-coffeelint")
  grunt.loadNpmTasks("grunt-contrib-coffee")
  grunt.loadNpmTasks("grunt-contrib-uglify")
  grunt.loadNpmTasks("grunt-contrib-watch")

  grunt.registerTask("stylesheets", "Compiles the stylesheets.",
                     ["autoprefixer", "cssmin"])

  grunt.registerTask("scripts", "Compiles the CoffeeScript files.",
                     ["coffeelint", "coffee", "uglify"])

  grunt.registerTask("build", "Compiles all assets.",
                     ["clean:build", "stylesheets", "scripts"])

  grunt.registerTask("default", ["build", "watch"])
