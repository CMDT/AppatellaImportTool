const { spawn } = require('child_process');

const DB_BUILD_TIME_MS = 2000;



function create(destination, username, password, schemaPath) {
    return new Promise(
        function (resolve, reject) {

            process.env["PGPASSWORD"] = password;

            var cArgs = [];
            cArgs.push(`-U`); //username of owner (us)
            cArgs.push(`${username}`)
            cArgs.push(`-w`); //no password - it's in env variable
            cArgs.push(`${destination}`); // db to create
            

            const create = spawn('createdb', cArgs, { env: process.env });

            create.stdout.on('data', (data) => {
                console.log(`create: stdout:\n${data}`);
            });

            create.stderr.on('data', (data) => {
                console.error(`create: stderr:\n${data}`);
            });

            create.on('exit', function (code, signal) {
                console.log('create process exited with ' +
                    `code ${code} and signal ${signal}`);
                if (code != 0) {
                    reject(new Error("Errors trying to create the DB. It may not have been dropped properly"));
                } else {

                    var pArgs = [];
                    pArgs.push(`-U`); // username of owner (us)
                    pArgs.push(`${username}`); // username of owner (us)
                    pArgs.push('-d');
                    pArgs.push(`${destination}`); // name of db

                    const cat = spawn('cat', [`${schemaPath}`], {env: process.env});
                    const imp = spawn('psql', pArgs, { env: process.env });
                    cat.stdout.pipe(imp.stdin);
        
                    cat.stderr.on('data', (data) => {
                        console.error(`cat: stderr:\n${data}`);
                    });

                    cat.on('exit', function (code, signal) {
                        console.log('cat process exited with ' +
                            `code ${code} and signal ${signal}`);
                        if (code != 0) {
                            reject(new Error("errors trying to submit to files to DB"));
                        } else {
                            setTimeout(resolve, DB_BUILD_TIME_MS); // wait for DB to settle before continuing.
                        }
                    });
                }
            });
        });
}


function drop(name, username, password) {
    return new Promise(
        function (resolve, reject) {
            var args = [];
            args.push(`--if-exists`);
            args.push(`-U`);
            args.push(`${username}`);
            args.push(name);
            process.env["PGPASSWORD"] = password;

            const drop = spawn('dropdb', args, { env: process.env });
            drop.stdout.on('data', (data) => {
                console.log(`drop: stdout:\n${data}`);
            });

            drop.stderr.on('data', (data) => {
                console.error(`drop: stderr:\n${data}`);
            });
            drop.on('exit', function (code, signal) {
                console.log('drop process exited with ' +
                    `code ${code} and signal ${signal}`);
                if (code != 0) {
                    reject(new Error("couldn't drop the old database. Are you connected using another app?"));
                } else {
                    resolve();
                }
            });
        });
}



module.exports = {
    create: create,
    drop: drop
};