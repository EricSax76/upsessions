import { admin } from '../firebase';
import { region } from '../region';

const VAT_RATE = 0.21;
const VAT_TOLERANCE = 0.01;

function numberOrNull(value: unknown): number | null {
  if (typeof value !== 'number' || !Number.isFinite(value)) return null;
  return value;
}

export function isVatValid(totalPrice: number, vatAmount: number): boolean {
  const expected = totalPrice * VAT_RATE;
  return Math.abs(vatAmount - expected) <= VAT_TOLERANCE;
}

export function buildInvoiceId(year: number, sequence: number): string {
  return `INV-${year}-${sequence.toString().padStart(6, '0')}`;
}

async function markValidationFailure(
  ref: admin.firestore.DocumentReference,
  message: string,
): Promise<void> {
  await ref.set(
    {
      paymentStatus: 'failed',
      _validationError: message,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
}

export const onBookingCreated = region.firestore
  .document('bookings/{bookingId}')
  .onCreate(async (snapshot) => {
    const data = snapshot.data() as Record<string, unknown> | undefined;
    if (!data) return;

    const totalPrice = numberOrNull(data.totalPrice);
    const vatAmount = numberOrNull(data.vatAmount);

    if (
      totalPrice == null
      || vatAmount == null
      || !isVatValid(totalPrice, vatAmount)
    ) {
      await markValidationFailure(
        snapshot.ref,
        'Invalid vatAmount. Expected totalPrice * 0.21 (+/- 0.01).',
      );
      return;
    }

    const db = admin.firestore();
    const counterRef = db.collection('counters').doc('invoices');

    await db.runTransaction(async (transaction) => {
      const counterSnap = await transaction.get(counterRef);
      const currentRaw = counterSnap.get('value');
      const currentValue = typeof currentRaw === 'number' && Number.isFinite(currentRaw)
        ? Math.max(0, Math.floor(currentRaw))
        : 0;
      const nextValue = currentValue + 1;

      const year = new Date().getUTCFullYear();
      const invoiceId = buildInvoiceId(year, nextValue);

      transaction.set(
        counterRef,
        {
          value: admin.firestore.FieldValue.increment(1),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      transaction.set(
        snapshot.ref,
        {
          invoiceId,
          _validationError: admin.firestore.FieldValue.delete(),
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    });
  });
