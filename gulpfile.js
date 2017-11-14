var gulp = require('gulp');
const {execFile} = require('child_process');


gulp.task('default', ['killall-processing', 'start-processing', 'watch-restart', 'move-processing-window']);

// Utility tasks
// -------------
gulp.task('watch-restart', () => {
    return gulp.watch(['*.pde'], ['killall-processing', 'start-processing', 'move-processing-window']);
});

gulp.task('start-processing', ['killall-processing'], (end) => {
    // Make sure start-processing.sh is executable
    execFile('./scripts/start-processing.sh', (err, stdout) => {
        if (err) {
            console.log(err);
        }
        end();
    });
});

gulp.task('killall-processing', (end) => {
    // Make sure killall-java.sh is executable
    execFile('./scripts/killall-java.sh', (err, stdout) => {
        if (err) {
            console.log(err);
        }
        end();
    });
});

gulp.task('move-processing-window', (end) => {
    setTimeout(() => {
        // Make sure move-processing-window.sh is executable
        execFile('./scripts/move-processing-window.sh', (err, stdout) => {
            if (err) {
                console.log(err);
            }
            end();
        });
    }, 1000);
});
