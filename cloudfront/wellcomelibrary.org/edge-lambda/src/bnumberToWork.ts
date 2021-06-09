import { findWorkWithIdentifierValue, GetWorkResult } from './catalogueApi';
import { SierraIdentifier } from './paths';

export async function getWork(
  sierraIdentifier: SierraIdentifier
): Promise<GetWorkResult> {
  const sierraIdWork = await findWorkWithIdentifierValue(
    sierraIdentifier.sierraIdentifier,
    'sierra-identifier'
  );
  if (sierraIdWork) {
    return sierraIdWork;
  }

  if (sierraIdentifier.sierraSystemNumber) {
    const sierraSysNumWork = await findWorkWithIdentifierValue(
      sierraIdentifier.sierraSystemNumber,
      'sierra-system-number'
    );
    if (sierraSysNumWork) {
      return sierraSysNumWork;
    }
  }

  return Error('No matching Catalogue API results found');
}
