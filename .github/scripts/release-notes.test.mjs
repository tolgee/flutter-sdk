import { test } from 'node:test';
import assert from 'node:assert/strict';
import { collectNotes, formatChangelog, formatRelease } from './release-notes.mjs';

const prBody = `## Release notes
<!-- Written for SDK users. -->
### Fixed
- Plurals crashed the widget
### Changed
- Numbers use the current language's format

## Details
Internal stuff that must not leak.\r
`;

test('takes hand-written notes and merges headings across commits', () => {
  const notes = collectNotes([
    { subject: 'fix: plurals (#9)', body: prBody },
    { subject: 'feat: Enabled customBoxDecoration (#7)', body: '' },
    { subject: 'fix: language flags', body: '## Release notes\n### Fixed\n- Flags were garbled\n\nCo-authored-by: A <a@b.c>' },
    { subject: 'chore: bump deps', body: '' },
    { subject: 'release: v1.2.1', body: '' },
  ]);
  assert.deepEqual([...notes], [
    ['Fixed', ['- Plurals crashed the widget', '- Flags were garbled']],
    ['Changed', ["- Numbers use the current language's format"]],
    ['New', ['- Enabled customBoxDecoration (#7)']],
  ]);
});

test('falls back to the PR title when the notes section is empty or missing headings', () => {
  const notes = collectNotes([
    { subject: 'fix(ui): handle missing localeName', body: '## Release notes\n<!-- todo -->\n' },
    { subject: 'feat: CDN support', body: '## Release notes\n- Load translations from the CDN\n' },
  ]);
  assert.deepEqual([...notes], [
    ['Fixed', ['- Handle missing localeName']],
    ['New', ['- Load translations from the CDN']],
  ]);
});

test('uses the title of reverts and breaking changes, skips titles semantic-release does not parse', () => {
  const notes = collectNotes([
    { subject: 'Revert "fix: plurals (#9)" (#10)', body: 'This reverts commit abc.' },
    { subject: 'feat(api)!: drop old API (#11)', body: '' },
    { subject: 'fix:', body: '' },
    { subject: 'fix:no space', body: '' },
  ]);
  assert.deepEqual([...notes], [
    ['Changed', ['- Revert "fix: plurals (#9)" (#10)']],
    ['New', ['- Drop old API (#11)']],
  ]);
});

test('formats the changelog entry and the GitHub release', () => {
  const notes = new Map([['Fixed', ['- A']], ['New', ['- B']]]);
  assert.equal(formatChangelog('1.3.0', '2026-10-27', notes), '## 1.3.0 (2026-10-27)\n### Fixed\n- A\n### New\n- B\n');
  assert.equal(
    formatRelease('v1.2.1', '1.3.0', '2026-10-27', notes),
    '# [1.3.0](https://github.com/tolgee/flutter-sdk/compare/v1.2.1...v1.3.0) (2026-10-27)\n\n' +
      'Available on pub.dev: [tolgee](https://pub.dev/packages/tolgee/versions/1.3.0), ' +
      '[tolgee_in_context](https://pub.dev/packages/tolgee_in_context/versions/1.3.0)\n\n' +
      '## Fixed\n- A\n## New\n- B\n',
  );
});
