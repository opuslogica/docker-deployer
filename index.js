const fs = require('fs');
const express = require('express');
const bodyParser  = require('body-parser');
const morgan = require('morgan');
const { auth } = require('./src/auth');

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
    auth({
        req, req,
        db: db,
        secret: secret
    });
});

const apiRoutes = express.Router();
app.use('/api', apiRoutes);

app.listen(port);
