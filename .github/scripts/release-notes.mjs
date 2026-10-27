import { execFileSync } from 'node:child_process';
import { readFileSync, writeFileSync } from 'node:fs';
import { pathToFileURL } from 'node:url';

const DEFAULT_HEADING = { feat: 'New', fix: 'Fixed', perf: 'Changed' };

function notesSection(body) {
  const lines = body.replace(/<!--[\s\S]*?-->/g, '').split(/\r?\n/);
  const start = lines.findIndex((l) => /^##\s+release notes\s*$/i.test(l.trim()));
  if (start < 0) return [];
  const end = lines.findIndex((l, i) => i > start && /^#{1,2}\s/.test(l));
  return lines
    .slice(start + 1, end < 0 ? undefined : end)
    .map((l) => l.trimEnd())
    .filter((l) => l.trim() && !/^[\w-]+-by: /i.test(l));
}

export function collectNotes(commits) {
  const notes = new Map();
  const add = (heading, line) => notes.set(heading, [...(notes.get(heading) ?? []), line]);
  for (const { subject, body } of commits) {
    const revert = subject.startsWith('Revert "');
    const [, type, breaking, title = subject] = subject.match(/^(\w+)(?:\([^)]*\))?(!)?: (.+)$/) ?? [];
    const defaultHeading = DEFAULT_HEADING[type] ?? 'Changed';
    let heading = defaultHeading;
    let written = false;
    for (const line of notesSection(body)) {
      const subheading = line.match(/^###\s+(.+)/);
      if (subheading) {
        heading = subheading[1].trim();
      } else {
        add(heading, line);
        written = true;
      }
    }
    if (!written && (type in DEFAULT_HEADING || breaking || revert)) {
      add(defaultHeading, `- ${title[0].toUpperCase()}${title.slice(1)}`);
    }
  }
  return notes;
}

const render = (notes, level) =>
  [...notes].map(([heading, lines]) => `${level} ${heading}\n${lines.join('\n')}\n`).join('');

export const formatChangelog = (version, date, notes) => `## ${version} (${date})\n${render(notes, '###')}`;

export const formatRelease = (prevTag, version, date, notes) =>
  `# [${version}](https://github.com/tolgee/flutter-sdk/compare/${prevTag}...v${version}) (${date})\n\n` +
  `Available on [pub.dev](https://pub.dev/packages/tolgee/versions/${version})\n\n` +
  render(notes, '##');

if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  const [prevTag, version] = process.argv.slice(2);
  const log = execFileSync('git', ['log', '--reverse', '--format=%s%x1f%b%x1e', `${prevTag}..HEAD`], { encoding: 'utf8' });
  const commits = log
    .split('\x1e')
    .filter((record) => record.trim())
    .map((record) => {
      const [subject, body = ''] = record.trim().split('\x1f');
      return { subject, body };
    });
  const notes = collectNotes(commits);
  const date = new Date().toISOString().slice(0, 10);
  writeFileSync('CHANGELOG.md', `${formatChangelog(version, date, notes)}\n\n${readFileSync('CHANGELOG.md', 'utf8')}`);
  process.stdout.write(formatRelease(prevTag, version, date, notes));
}
