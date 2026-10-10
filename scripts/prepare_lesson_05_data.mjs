// Author helper: create the approved public teaching subset, never alter the source.
// Run from the repository root with @oai/artifact-tool available to Node.js.
import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import { FileBlob, SpreadsheetFile, Workbook } from '@oai/artifact-tool';

const source = await SpreadsheetFile.importXlsx(await FileBlob.load('data/raw/four_countries_data.xlsx'));
const rows = source.worksheets.getItemAt(0).getRange('A1:BA1087').values;
const allowed = [
  ...Array.from({ length: 6 }, (_, i) => `Q${i + 1}_PROP_1`),
  ...Array.from({ length: 8 }, (_, i) => `Q${i + 1}_ANX_1`),
  'Q1_P_AI_1', 'Q2_P_AI_1', 'Q3_P_AI_1',
  'Q4_ADO_AI_1', 'Q5_ADO_AI_1', 'Q6_ADO_AI_1', 'Country',
];
const indices = allowed.map(name => rows[0].findIndex(value => String(value).toLowerCase() === name.toLowerCase()));
assert(indices.every(i => i >= 0), 'Missing approved source column');
assert.equal(new Set(indices).size, 21);
const selected = rows.map(row => indices.map(i => row[i] ?? null));
assert.equal(selected.length, 1087);
const workbook = Workbook.create();
const sheet = workbook.worksheets.add('Sheet1');
sheet.getRange('A1:U1087').values = selected;
sheet.getRange('A1:U1087').format.font = { name: 'Arial', size: 10 };
sheet.getRange('A1:U1087').format.columnWidth = 44;
sheet.getRange('A1:U3').format.wrapText = true;
sheet.getRange('A1:U1').format.font = { name: 'Arial', size: 10, bold: true };
sheet.getRange('A2:U2').format.rowHeight = 80;
sheet.getRange('A2:U3').format.verticalAlignment = 'top';
sheet.getRange('A3:U3').format.rowHeight = 34;
sheet.getRange('A4:T1087').setNumberFormat('0.00');
sheet.freezePanes.freezeRows(3);
workbook.recalculate();
assert.deepEqual(sheet.getRange('A1:U1087').values, selected);
await fs.mkdir('output/lesson05', { recursive: true });
const preview = await workbook.render({ sheetName: 'Sheet1', range: 'A1:C8', scale: 1.5, format: 'png' });
await fs.writeFile('output/lesson05/four-preview.png', new Uint8Array(await preview.arrayBuffer()));
const exported = await SpreadsheetFile.exportXlsx(workbook);
await exported.save('data/raw/four_countries_teaching.xlsx');
// The exporter may also emit a diagnostic file; it is not a teaching resource.
await fs.rename('data/raw/four_countries_teaching.xlsx.inspect.ndjson', 'output/lesson05/four-inspect.ndjson').catch(error => {
  if (error.code !== 'ENOENT') throw error;
});
console.log('Exported 1084 observations, 20 closed-response items and country; three metadata rows preserved.');
