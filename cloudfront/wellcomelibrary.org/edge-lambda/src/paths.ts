export type SierraIdentifier = {
  sierraIdentifier: string;
  sierraSystemNumber: string;
};

export type GetBNumberResult = SierraIdentifier | Error;

// Copied from https://github.com/SydneyUniLibrary/sierra-record-check-digit/blob/master/index.js#L21
function calcCheckDigit(recordNumber: number) {
  let m = 2;
  let x = 0;
  let i = Number(recordNumber);
  while (i > 0) {
    const a = i % 10;
    i = Math.floor(i / 10);
    x += a * m;
    m += 1;
  }
  const r = x % 11;
  return r === 10 ? 'x' : String(r);
}

export function getBnumberFromPath(path: string): GetBNumberResult {
  const splitPath = path.split('/');

  // Match on paths like b1234567x / b12345678
  const sierraIdRegexp = /^[bB][0-9]{7}/;

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
  const sierraSystemNumber = `b${sierraIdentifier}${calcCheckDigit(
    parseInt(sierraIdentifier)
  )}`;

  return {
    sierraIdentifier: sierraIdentifier,
    sierraSystemNumber: sierraSystemNumber,
  };
}
