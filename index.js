const fs = require('fs');
const express = require('express');
const bodyParser  = require('body-parser');
const morgan = require('morgan');

const { auth } = require('./src/auth');
const { verifyToken } = require('./src/verify-token');
const { processResponse } = require('./src/process-response');

const port = 8080;
const dbFile = "./db.json";
const secret = 'SECRET'; // TODO

let db;

if (fs.existsSync(dbFile)) {
    db = require(dbFile);
} else {
    db = {};
}

if (!db) {
    throw new Error("could not create db!");
}

db.users = db.users || {};

const app = express();

app.use(bodyParser.json());
app.use(morgan('combined'));

app.post('/auth', (req, res) => {
    const response = auth({
        req, req,
        db: db,
        secret: secret
    });

    processResponse(Object.assign({}, response, {res: res}));
});

const apiRoutes = express.Router();

// If the jwt is correctly provided, every
// api route will have access to req.user
apiRoutes.use((req, res, next) => {
    const response = verifyToken({
        req: req,
        secret: secret,
        db: db
    });

    if (processResponse(Object.assign({}, response, {res: res}))) {
        const { user } = response;
        if (!user) {
            throw new Error("user not given in response!");
        }

        req.user = user;

        next();
    }
});

app.use('/api', apiRoutes);

app.listen(port);
