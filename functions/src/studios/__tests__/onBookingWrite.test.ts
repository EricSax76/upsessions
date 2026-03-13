import { buildInvoiceId, isVatValid } from '../onBookingWrite';

function assert(condition: boolean, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

void (async () => {
  const invoiceId = buildInvoiceId(2026, 42);
  assert(
    invoiceId === 'INV-2026-000042',
    `Expected invoiceId INV-2026-000042, got ${invoiceId}`,
  );

  assert(
    isVatValid(100, 21),
    'Expected VAT to be valid for totalPrice=100 and vatAmount=21',
  );

  assert(
    !isVatValid(100, 19),
    'Expected VAT to be rejected for totalPrice=100 and vatAmount=19',
  );
})();
