var gulp = require('gulp');
const {execFile} = require('child_process');

gulp.task('default', ['watch-restart', 'killall-processing', 'start-processing', 'move-processing-window']);

// Utility tasks
// -------------
gulp.task('watch-restart', () => {
    return gulp.watch(['*.pde'], ['killall-processing', 'start-processing', 'move-processing-window']);
});

gulp.task('start-processing', ['killall-processing'], (end) => {
    // Make sure start-processing.sh is executable
    execFile('./scripts/start-processing.sh'), (err, stdout) => {
        if (err) {
            // console.log(err);
        }
    };
    end(); // Finish the task here, not in the callback of execFile, because processing-java keeps running while the Processing application is open. So the task would never finish with end in the callback
});

gulp.task('killall-processing', (end) => {
    // Make sure killall-java.sh is executable
    execFile('./scripts/killall-java.sh', (err, stdout) => {
        if (err) {
            // console.log(err);
        }
        end();
    });
});

gulp.task('move-processing-window', (end) => {
    // Here we use a timeout rather than making the task dependant on previous tasks, as this wouldn't ensure the Processing app has been properly launched
    setTimeout(() => {
        // Make sure move-processing-window.sh is executable
        execFile('./scripts/move-processing-window.sh', (err, stdout) => {
            if (err) {
                // console.log(err);
            }
            end();
        });
    }, 2800); // Make sure to use a time just longer than what it takes to kill and restart the Processing app
});
