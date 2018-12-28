function processResponse(args) {
    args = args || {};
    const { res, status, json } = args;

    if (!res) {
        throw new Error('res required');
    }

    let shouldContinue = true;

    if (status) {
        res.status(status);
        shouldContinue = false;
    }

    if (json) {
        res.json(json);
        shouldContinue = false;
    }

    if (shouldContinue) {
        return args;
    } else {
        return false;
    }
}

module.exports.processResponse = processResponse;
