const readline = require('readline-sync');
const moment = require('moment');
const fs = require('fs');
const jobs = require('./src/jobs');
const topics = require('./src/topics');
const keywords = require('./src/keywords');
const benefits = require('./src/benefits');
const solutions = require('./src/solutions');
const positive_outcomes = require('./src/positiveOutcomes');
const aspects = require('./src/aspects');
const overall_goals = require('./src/overallGoals');
const strategies = require('./src/strategies');
const problems = require('./src/problems');
const questions = require('./src/questions');
const answers = require('./src/answers');
const issues = require('./src/issues');
const { replacePlaceholders, displayHeader, delay } = require('./src/utils');

(async () => {
  try {
    displayHeader();
    console.log('Please wait...');

    await delay(10000);

    const numberOfEntries = readline.questionInt(
      'How many data entries would you like to generate? '
    );

    let dataset = [];

    for (let i = 0; i < numberOfEntries; i++) {
      const job_title = jobs[Math.floor(Math.random() * jobs.length)];
      const topic = topics[Math.floor(Math.random() * topics.length)];
      const keyword1 = keywords[Math.floor(Math.random() * keywords.length)];
      const keyword2 = keywords[Math.floor(Math.random() * keywords.length)];
      const benefit = benefits[Math.floor(Math.random() * benefits.length)];
      const issue = issues[Math.floor(Math.random() * issues.length)];
      const solution = solutions[Math.floor(Math.random() * solutions.length)];
      const positive_outcome =
        positive_outcomes[Math.floor(Math.random() * positive_outcomes.length)];
      const aspect = aspects[Math.floor(Math.random() * aspects.length)];
      const overall_goal =
        overall_goals[Math.floor(Math.random() * overall_goals.length)];
      const strategy =
        strategies[Math.floor(Math.random() * strategies.length)];
      const problem = problems[Math.floor(Math.random() * problems.length)];

      const question = replacePlaceholders(
        questions[Math.floor(Math.random() * questions.length)],
        {
          job_title,
          topic,
          keyword1,
          keyword2,
        }
      );

      const answer = replacePlaceholders(
        answers[Math.floor(Math.random() * answers.length)],
        {
          job_title,
          topic,
          keyword1,
          keyword2,
          benefit,
          issue,
          solution,
          positive_outcome,
          aspect,
          overall_goal,
          strategy,
          problem,
        }
      );

      const content = {
        content: `Question: ${question} Answer: ${answer}`,
        meta: {
          time: moment().format('YYYY-MM-DD HH:mm:ss'),
        },
      };

      dataset.push(content);
    }

    fs.writeFileSync('datasets.json', JSON.stringify(dataset, null, 2));

    console.log(
      'datasets.json file has been created with your specified entries.'
    );
    console.log('Subscribe: https://t.me/HappyCuanAirdrop');
  } catch (error) {
    console.log(`Error in IIFE: ${error}`);
  }
})();
