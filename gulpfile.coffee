gulp   = require 'gulp'
coffee = require 'gulp-coffee'

gulp.task 'compile-coffee', () ->
  gulp.src ['./{bin,routes,models}/*.coffee', './{app,utils}.coffee'], { base: './' }
    .pipe coffee()
    .pipe gulp.dest('./')

gulp.task 'watch', () ->
  gulp.watch './**/*.coffee', ['compile-coffee']
