export type SierraIdentifier = {
  sierraIdentifier: string;
  sierraSystemNumber?: string;
};

export type GetBNumberResult = SierraIdentifier | Error;

export function getBnumberFromPath(path: string): GetBNumberResult {
  const splitPath = path.split('/');

  // Match on paths like b1234567x / b12345678
  const sierraIdRegexp = /^[bB][0-9]{7}/;
  const sierraSystemNumberRegexp = /^[bB][0-9]{8}/;

  if (splitPath[0] !== '') {
    return Error(`Path ${path} does not start with /`);
  }

  if (splitPath.length !== 3) {
    return Error(
      `Path ${path} has the wrong number many elements (expected 2)`
    );
  }

  if (!(splitPath[1] === 'item' || splitPath[1] === 'player')) {
    return Error(`Path ${path} does not start with /item or /player`);
  }

  if (!sierraIdRegexp.test(splitPath[2])) {
    return Error(`b number in ${path} does not match ${sierraIdRegexp}`);
  }

  const sierraIdentifier = splitPath[2].toLowerCase().substr(1, 7);
  const sierraSystemNumber = sierraSystemNumberRegexp.test(splitPath[2])
    ? splitPath[2].toLowerCase().substr(0, 9)
    : undefined;

  return {
    sierraIdentifier: sierraIdentifier,
    sierraSystemNumber: sierraSystemNumber,
  };
}
