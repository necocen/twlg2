gulp   = require 'gulp'
coffee = require 'gulp-coffee'
cjsx   = require 'gulp-cjsx'
symlink = require 'gulp-symlink'
less   = require 'gulp-less'

gulp.task 'compile-coffee', () ->
  gulp.src ['./{bin,routes,models}/*.coffee', './{app,utils}.coffee'], { base: './' }
    .pipe coffee()
    .pipe gulp.dest('./')

gulp.task 'compile-cjsx', () ->
  gulp.src ['./cjsx/**/*.cjsx'], { base: './cjsx/' }
    .pipe(cjsx({bare: true}))
		.pipe gulp.dest('./public/javascripts/')

gulp.task 'compile-less', () ->
  gulp.src ['./less/**/*.less'], { base: './less/' }
    .pipe(less())
    .pipe gulp.dest('./public/stylesheets/')

gulp.task 'watch', () ->
  gulp.watch './**/*.coffee', ['compile-coffee']
  gulp.watch './cjsx/**/*.cjsx', ['compile-cjsx']
  gulp.watch './less/**/*.less', ['compile-less']

gulp.task 'deploy', ['compile-coffee', 'compile-cjsx', 'compile-less'], () ->
  gulp.src '../shared/config/default.yml'
    .pipe symlink('./config/default.yml', { force: true })
