const { spawn } = require('child_process');

const DB_BUILD_TIME_MS = 2000;


function create(destination, schemaPath) {
    return new Promise(
        function (resolve, reject) {

            const create = spawn('createdb', [destination]);

            create.on('exit', function (code, signal) {
                console.log('create process exited with ' +
                    `code ${code} and signal ${signal}`);
                if(code != 0){
                    reject(new Error("Errors trying to create the DB. It may not have been dropped properly"));
                }else{
                    const cat = spawn('cat', [schemaPath]);
                    const imp = spawn('psql', [destination]);
                    cat.stdout.pipe(imp.stdin);
                    cat.on('exit', function (code, signal) {
                        console.log('cat process exited with ' +
                            `code ${code} and signal ${signal}`);
                            if(code != 0){
                                reject(new Error("errors trying to submit to files to DB"));
                            }else{
                                setTimeout(resolve, DB_BUILD_TIME_MS); // wait for DB to settle before continuing.
                            }
                    });
                }
            });
        });
}


function drop(name) {
    return new Promise(
        function (resolve, reject) {

            const create = spawn('dropdb', [name]);

            create.on('exit', function (code, signal) {
                console.log('drop process exited with ' +
                `code ${code} and signal ${signal}`);
                if(code != 0){
                    reject(new Error("couldn't drop the old database. Are you connected using another app?"));
                }else{
                    resolve();
                }
            });
        });
}



module.exports = {
    create: create,
    drop: drop
};