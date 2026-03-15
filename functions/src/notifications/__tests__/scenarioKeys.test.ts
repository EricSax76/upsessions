import * as fs from 'node:fs';
import * as path from 'node:path';

import { ALL_SCENARIO_KEYS } from '../scenarioKeys';

function assert(condition: boolean, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

void (() => {
  assert(
    ALL_SCENARIO_KEYS.length === 11,
    `Expected 11 scenario keys, got ${ALL_SCENARIO_KEYS.length}`,
  );

  const unique = new Set(ALL_SCENARIO_KEYS);
  assert(
    unique.size === ALL_SCENARIO_KEYS.length,
    'Scenario keys must be unique',
  );

  for (const key of ALL_SCENARIO_KEYS) {
    assert(
      /^[a-z0-9_]+$/.test(key),
      `Scenario key must be snake_case: ${key}`,
    );
  }

  const rulesPath = path.resolve(__dirname, '../../../../firestore.rules');
  const rulesText = fs.readFileSync(rulesPath, 'utf8');
  for (const key of ALL_SCENARIO_KEYS) {
    assert(
      rulesText.includes(`'${key}'`),
      `Missing scenario key in firestore.rules: ${key}`,
    );
  }
})();
