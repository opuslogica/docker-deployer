const { processResponse } = require('../src/process-response');

describe('processResponse', () => {
    test('throw an error when res is not supplied', () => {
        expect(() => {
            processResponse();
        }).toThrow();
    });

    test('process status properly', () => {
        let processedStatus;

        const result = processResponse({
            res: {
                status: (status) => {
                    processedStatus = status;
                }
            },
            status: 400
        });

        expect(result).toBeFalsy();
        expect(processedStatus).toEqual(400);
    });

    test('process json properly', () => {
        let processedJson;
        const json = {foo: 'bar'};

        const result = processResponse({
            res: {
                json: (givenJson) => {
                    processedJson = givenJson;
                }
            },
            json: json
        });

        expect(result).toBeFalsy();
        expect(processedJson).toEqual(json);
    });

    test('process continued result properly', () => {
        const args = {
            res: {},
            foo: 'bar',
            baz: 1
        };

        expect(processResponse(args)).toEqual(args);
    });
});
