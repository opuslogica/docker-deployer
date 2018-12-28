const jwt = require('jsonwebtoken');

function auth(args) {
    const { req, db, secret } = args;

    if (!req || !db || !secret) {
        throw new Error('incorrect arguments');
    }

    if (!req.body || !req.body.user || !req.body.password) {
        return {
            status: 400,
            json: {
                error: 'not valid request'
            }
        };
    }

    const { user, password } = req.body;

    if (!db.users[user]) {
        return {
            status: 404,
            json: {
                error: 'the given user does not exist'
            }
        };
    }

    const users = db.users || {};

    // TODO hash + salt
    if (users[user].password !== password) {
        return {
            status: 403,
            json: {
                error: 'incorrect password'
            }
        };
    }

    const payload = {
        user: user
    };

    const token = jwt.sign(payload, secret, {
        expiresIn: "1d"
    });

    return {
        json: {
            token: token
        }
    };
}

module.exports.auth = auth;
