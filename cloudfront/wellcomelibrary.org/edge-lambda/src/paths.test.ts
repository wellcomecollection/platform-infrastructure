import { expect, test } from '@jest/globals';
import { getBnumberFromPath, SierraIdentifier } from './paths';

type ExpectedPath = {
  in: string;
  out: SierraIdentifier | Error;
};
const pathTests = (): ExpectedPath[] => {
  return [
    {
      in: '/item/b21293302',
      out: {
        sierraIdentifier: '2129330',
        sierraSystemNumber: 'b21293302',
      },
    },
    {
      in: '/item/B21293302',
      out: {
        sierraIdentifier: '2129330',
        sierraSystemNumber: 'b21293302',
      },
    },
    {
      in: '/item/b2129330x',
      out: {
        sierraIdentifier: '2129330',
        sierraSystemNumber: undefined,
      },
    },
    {
      in: '/item/b2129330',
      out: {
        sierraIdentifier: '2129330',
        sierraSystemNumber: undefined,
      },
    },
    {
      in: '/player/b21293302',
      out: {
        sierraIdentifier: '2129330',
        sierraSystemNumber: 'b21293302',
      },
    },
    {
      in: '/player/B21293302',
      out: {
        sierraIdentifier: '2129330',
        sierraSystemNumber: 'b21293302',
      },
    },
    {
      in: '/player/b2129330x',
      out: {
        sierraIdentifier: '2129330',
        sierraSystemNumber: undefined,
      },
    },
    {
      in: '/player/b2129330',
      out: {
        sierraIdentifier: '2129330',
        sierraSystemNumber: undefined,
      },
    },
    {
      in: '/item/b21293302/nope',
      out: Error(
        'Path /item/b21293302/nope has the wrong number many elements (expected 2)'
      ),
    },
    {
      in: '/item',
      out: Error('Path /item has the wrong number many elements (expected 2)'),
    },
    {
      in: 'badpath/path',
      out: Error('Path badpath/path does not start with /'),
    },
    {
      in: 'badpath/path',
      out: Error('Path badpath/path does not start with /'),
    },
    {
      in: '/notitem/gary',
      out: Error('Path /notitem/gary does not start with /item or /player'),
    },
    {
      in: '/item/i21293302',
      out: Error('b number in /item/i21293302 does not match /^[bB][0-9]{7}/'),
    },
  ];
};

test.each(pathTests())(
  'Request path is rewritten: %o',
  (test: ExpectedPath) => {
    const result = getBnumberFromPath(test.in);
    const expectedResult = test.out;

    expect(result).toStrictEqual(expectedResult);
  }
);
