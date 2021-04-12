export type GetBNumberResult = string | Error;

export function getBnumberFromPath(path: string): GetBNumberResult {
  const splitPath = path.split('/');

  // Match on paths like b1234567x / b12345678
  const bNumberRegexp = /^[bB][0-9]{7}/;

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

  if (!bNumberRegexp.test(splitPath[2])) {
    return Error(`b number in ${path} does not match ${bNumberRegexp}`);
  }

  return splitPath[2].toLowerCase().substr(1, 7);
}
