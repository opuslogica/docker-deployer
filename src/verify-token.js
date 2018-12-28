const jwt = require('jsonwebtoken');

function verifyToken(args) {
    args = args || {};

    const { req, secret, db } = args;

    if (!req || !secret || !db) {
        throw new Error('incorrect arguments');
    }

    req.body = req.body || {};
    req.query = req.query || {};
    req.headers = req.headers || {};

    let token = req.body.token || req.query.token || req.headers['x-access-token'];

    if (!token) {
        return {
            status: 403,
            json: {
                error: 'no token provided'
            }
        };
    }

    token = jwt.verify(token, secret);

    if (!token) {
        return {
            status: 403,
            json: {
                error: 'failed to authenticate token'
            }
        };
    }

    let { user } = token;

    if (!user) {
        return {
            status: 400,
            json: {
                error: 'authentication token was valid but incorrectly formatted'
            }
        };
    }

    user = db[user];

    if (!user) {
        return {
            status: 400,
            json: {
                error: 'authentication token was valid but no cooresponding user was found'
            }
        };
    }

    return user;
}

module.exports.verifyToken = verifyToken;
