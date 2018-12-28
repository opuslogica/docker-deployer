const fs = require('fs');
const { exec } = require('child_process');

function run(args) {
    args = args || {};
    const { url, dockerComposeFile, branch, commitHash } = args;

    if (!url || !dockerComposeFile || !branch || !commitHash) {
        return {
            status: 400,
            json: {
                error: 'must supply url, dockerComposeFile, branch, and commitHash'
            }
        };
    }

    const path = ['tmp', url, branch, commitHash, dockerComposeFile].join('/');

    fs.mkdir(path, {recursive: true}, (err) => {
        if (err) throw err;

        // TODO this is very dangerous! sanitize these strings!
        // TODO this should probably be streaming output back to the request
        // through a websocket or something
        exec(`git clone ${url} ${path}`, (err, stdout, stderr) => {
            if (err) throw err;
            console.log(stdout);
            console.log(stderr);

            exec(`docker-compose -f ${dockerComposeFile} build`, {cwd: path}, (err, stdout, stderr) => {
                if (err) throw err;
                console.log(stdout);
                console.log(stderr);

                exec(`docker-compose -f ${dockerComposeFile} up -d`, {cwd: path}, (err, stdout, stderr) => {
                    if (err) throw err;
                    console.log(stdout);
                    console.log(stderr);

                });
            });
        });
    });
}

module.exports.run = run;
