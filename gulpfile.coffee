gulp   = require 'gulp'
coffee = require 'gulp-coffee'

gulp.task 'compile-coffee', () ->
    gulp.src ['./bin/*.coffee', './routes/*.coffee', './app.coffee'], { base: './' }
        .pipe coffee()
				.pipe gulp.dest('./')
