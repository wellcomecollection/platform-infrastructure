import { apiQuery, GetWorkResult, Identifier, Work } from './catalogueApi';
import { SierraIdentifier } from './paths';

async function findMatchingWork(
  identifierType: string,
  identifierValue: string
): Promise<Work | undefined> {
  const resultList = apiQuery(identifierValue);

  for await (const result of resultList) {
    if (result.identifiers) {
      const identifiers: Identifier[] = result.identifiers;
      const hasMatchingId = identifiers.some(
        (thing) =>
          thing.identifierType.id === identifierType &&
          thing.value === identifierValue
      );

      if (hasMatchingId) {
        return result;
      }
    }
  }
}

export async function getWork(
  sierraIdentifier: SierraIdentifier
): Promise<GetWorkResult> {
  const sierraIdWork = await findMatchingWork(
    'sierra-identifier',
    sierraIdentifier.sierraIdentifier
  );
  if (sierraIdWork) {
    return sierraIdWork;
  }

  if (sierraIdentifier.sierraSystemNumber) {
    const sierraSysNumWork = await findMatchingWork(
      'sierra-system-number',
      sierraIdentifier.sierraSystemNumber
    );
    if (sierraSysNumWork) {
      return sierraSysNumWork;
    }
  }

  return Error('No matching Catalogue API results found');
}
