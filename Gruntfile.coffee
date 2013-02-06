prompt = require "prompt"
exec = require("child_process").exec

module.exports = (grunt) ->

  #
  # Configuration
  #
  
  grunt.initConfig
    # Package information
    pkg: grunt.file.readJSON "package.json"

    # JSHint (see http://www.jshint.com/docs/)
    jshint:
      options:
        # Predefined globals
        browser: true

        # The Good Parts
        eqeqeq: true
        eqnull: true
        curly: true
        latedef: true
        undef: true
        forin: true

        # Style preferences
        indent: 2
        camelcase: true
        trailing: true
        quotmark: "double"
        newcap: true

      dist:
        files:
          src: ["src/**/*.js", "test/**/*.js"]

    # File concatenation, copying and templating
    concat:
      options:
        process: true
      dist:
        src: ["src/bugsnag.js"]
        dest: "dist/bugsnag.js"

    # Minification
    uglify:
      dist:
        files:
          "dist/bugsnag.min.js": ["dist/bugsnag.js"]

    # Upload to s3
    s3:
      bucket: "bugsnagcdn"
      access: "public-read"

      upload: [
        src: "src/bugsnag.js",
        dest: "bugsnag-<%= process.env.RELEASE_VERSION %>.js"
      ,
        src: "dist/bugsnag.min.js",
        dest: "bugsnag-<%= process.env.RELEASE_VERSION %>.min.js"
      ]

    # Version bumping
    bump:
      options: part: "patch"
      files: ["package.json", "component.json"]


  #
  # Tasks
  #

  # Task to tag a version in git
  grunt.registerTask "git-tag", "Tags a release in git", (version) ->
    done = this.async()
    releaseVersion = process.env.RELEASE_VERSION || version

    done(false) unless releaseVersion

    child = exec "git tag v#{releaseVersion}" (error, stdout, stderr) ->
      if error?
        console.log("Error running git tag: " + error);
        done(false)
      else
        done()

  # Load tasks from plugins
  grunt.loadNpmTasks "grunt-contrib-jshint"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-bumpx"
  grunt.loadNpmTasks "grunt-s3"

  # Release meta-task
  # lint, update version, minify, tag in git, copy to s3
  # grunt.registerTask "release", ["jshint", "update-version", "uglify", "git-tag"]

  # Default meta-task
  grunt.registerTask "default", ["jshint", "uglify"]