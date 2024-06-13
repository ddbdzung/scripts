const _ = require('lodash');
const fs = require('fs/promises');

const readFile = require('./read-short-file-txt');

async function main() {
  const tabSpaces = '  ';
  // const fileNameWithExt = 'read-short-file-txt.sample.txt';
  const fileNameWithExt = 'read-short-file-txt.txt';
  const file = await readFile(fileNameWithExt);

  const lines = file.split('\n').filter((line) => line !== '');

  const res = lines.map((line) => {
    const [jiras, issues, group, repository, mergeUrls, assignee, isReported] = line.split('\t');
    return {
      assignee,
      group,
      repository,
      jiras: jiras.split(',').filter((jira) => jira),
      issues: issues.split(','),
      mergeUrls: mergeUrls.split(','),
      isReported: isReported === 'TRUE',
    };
  });
  const allReported = res.every((item) => item.isReported);
  if (allReported) {
    console.info('All issues have been reported');

    await fs.writeFile('output.txt', 'All issues have been reported');

    return 0;
  }

  // Group by asignee
  const groupedByAssignee = _(res).groupBy('assignee').value();
  const messages = [];
  for (const assignee in groupedByAssignee) {
    let message = `${assignee} ơi merge giúp em với ạ\n\n`;
    const groupedByGroup = _(groupedByAssignee[assignee]).groupBy('group').value();
    for (const group in groupedByGroup) {
      const dataList = groupedByGroup[group];
      const isAllReported = dataList.every((item) => item.isReported);

      if (isAllReported) {
        continue;
      }

      message += `${group}:\n`;

      // Tạo 1 merge request cho mỗi repository (gộp tất cả issue vào trong 1 MR, nhưng 1 MR có nhiều commit)
      dataList.forEach(({ repository, mergeUrls, issues, jiras, isReported }) => {
        if (isReported) {
          return;
        }

        message += `${tabSpaces}- Repository: ${repository}`;
        if (issues.length) {
          message += `, Issues: ${issues.join(',')}`;
        }

        if (jiras.length) {
          message += `, Jiras: ${jiras.join(',')}`;
        }

        message += '\n';

        mergeUrls.forEach((url) => {
          message += `${tabSpaces}${tabSpaces}+ ${url}\n`;
        });
      });
    }

    message += '\n-------------------------\n';
    messages.push(message);
  }

  await fs.writeFile('output.txt', messages.join('\n'), {
    encoding: 'utf8',
  });

  return 0;
}

main().then(console.log).catch(console.error);
