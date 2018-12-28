const fs = require('fs');
const { exec } = require('child_process');

function kill(args) {
    args = args || {};
    const { url, dockerComposeFile, branch, commitHash } = args;

    const path = ['tmp', url, branch, commitHash, dockerComposeFile].join('/');

    fs.mkdir(path, {recursive: true}, (err) => {
        if (err) throw err;

        // TODO this is very dangerous! sanitize these strings!
        // TODO this should probably be streaming output back to the request
        // through a websocket or something
        exec(`docker-compose -f ${dockerComposeFile} down`, {cwd: path}, (err, stdout, stderr) => {
            if (err) throw err;
            console.log(stdout);
            console.log(stderr);
        });
    });
}

module.exports.kill = kill;
