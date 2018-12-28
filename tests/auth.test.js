const jwt = require('jsonwebtoken');
const { auth } = require('../src/auth');

const secret = 'SECRET';

describe('auth', () => {
    test('throw an error when not all arguments are supplied', () => {
        expect(() => {
            auth();
        }).toThrow();
    });

    test('400 when not all params provided', () => {
        expect(auth({
            req: {
                body: {
                }
            },
            db: {},
            secret: secret
        }).status).toEqual(400);
    });

    test('404 when the user does not exist', () => {
        expect(auth({
            req: {
                body: {
                    user: 'foo',
                    password: 'bar'
                }
            },
            db: {
                users: {
                    baf: {
                        password: 'baz'
                    }
                }
            },
            secret: secret
        }).status).toEqual(404);
    });

    test('403 when an incorrect password is given', () => {
        expect(auth({
            req: {
                body: {
                    user: 'foo',
                    password: 'bar'
                }
            },
            db: {
                users: {
                    foo: {
                        password: 'baz'
                    }
                }
            },
            secret: secret
        }).status).toEqual(403);
    });

    test('a token should be returned when valid credentials are given', () => {
        const { status, json } = auth({
            req: {
                body: {
                    user: 'foo',
                    password: 'bar'
                }
            },
            db: {
                users: {
                    foo: {
                        password: 'bar'
                    }
                }
            },
            secret: secret
        });

        expect(status).toBeFalsy();
        expect(jwt.verify(json.token, secret).user).toEqual('foo');
    });
});
