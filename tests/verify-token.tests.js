const jwt = require('jsonwebtoken');
const { verifyToken } = require('../src/verify-token');

const secret = 'SECRET';

describe('verifyToken', () => {
    test('throw an error when not all arguments are supplied', () => {
        expect(() => {
            verifyToken();
        }).toThrow();
    });

    test('403 on no token', () => {
        const response = verifyToken({
            secret: secret,
            db: {},
            req: {}
        });

        expect(response.status).toEqual(403);
    });

    test('user to be returned on proper token', () => {
        const user = {
            bar: 'baz'
        };

        const response = verifyToken({
            secret: secret,
            db: {
                foo: user
            },
            req: {
                body: {
                    token: jwt.sign({user: 'foo'}, secret)
                }
            }
        });

        expect(response).toEqual(user);
    });
});
