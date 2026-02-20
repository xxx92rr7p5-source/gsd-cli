import { Command } from 'commander';
import chalk from 'chalk';

const program = new Command();

program
  .name('gsd')
  .description('Autonomous AI development pipeline CLI')
  .version('0.1.0');

program
  .command('status')
  .description('Pipeline dashboard')
  .option('-v, --verbose', 'Detailed output')
  .option('--json', 'JSON output')
  .action(async (opts) => {
    console.log(chalk.bold('GSD Pipeline — coming soon'));
  });

program.parse();
