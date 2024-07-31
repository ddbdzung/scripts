const _ = require("lodash");
const fs = require("fs/promises");

const readFile = require("./read-short-file-txt");

async function main() {
  const tabSpaces = "  ";
  const fileNameWithExt = "golive-file.txt";
  const waitForGoliveStatus = "Chờ golive";

  const file = await readFile(fileNameWithExt);

  const lines = file.split("\n").filter((line) => line !== "");

  const res = lines.map((line) => {
    const [
      projects,
      sprints,
      jiras,
      issues,
      group,
      repository,
      mergeUrls,
      assignee,
      isReported,
      status,
      havePatchScript,
    ] = line.split("\t");
    return {
      projects,
      sprints,
      assignee,
      group,
      repository,
      jiras: jiras.split(",").filter((jira) => jira),
      issues: issues.split(","),
      mergeUrls: mergeUrls.split(","),
      isReported: isReported === "TRUE",
      willGolive: status === waitForGoliveStatus,
      havePatchScript: havePatchScript === "TRUE",
    };
  });
  const allListGolived = res.every((item) => item.willGolive);
  if (allListGolived) {
    console.info("All issues have been golived");

    await fs.writeFile("golive-report.txt", "All issues have been golived");

    return 0;
  }

  let willReport = false;
  let message = "Danh sách các repo sẽ golive:\n\n";
  const groupedByGroup = _(res).groupBy("group").value();
  Object.entries(groupedByGroup).forEach(([group, list]) => {
    const scriptMap = {};
    const filteredWillGoliveList = list.filter((item) => item.willGolive);
    const groupByRepo = _(filteredWillGoliveList).groupBy("repository").value();
    Object.entries(groupByRepo).forEach(([repo, list]) => {
      scriptMap[repo] = list.some((item) => item.havePatchScript);
    });
    const repositories = Array.from(new Set(Object.keys(groupByRepo)));

    if (repositories.length === 0) return;

    message += `${group}:\n`;
    repositories.forEach((repo) => {
      let msg = `${tabSpaces}${repo}`;
      if (scriptMap[repo]) {
        msg += `${tabSpaces}(có script)\n`;
      }

      message += msg;
    });

    if (!willReport) {
      willReport = true;
    }

    message += "\n";
  });

  if (!willReport) {
    console.info("No issue will golive");

    await fs.writeFile("golive-report.txt", "No issue will golive");

    return 0;
  }

  await fs.writeFile("golive-report.txt", message);

  return 0;
}

main().then(console.log).catch(console.error);
