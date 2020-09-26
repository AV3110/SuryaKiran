const path = require('path');
const solc = require('solc');
const fs = require('fs-extra')

//to delete the build folder for successive compilations
const buildPath = path.resolve(__dirname, 'build');
fs.removeSync(buildPath);

const candidatePath = path.resolve(__dirname, 'contracts', 'Candidate.sol');
const source = fs.readFileSync(candidatePath, 'utf8');
const output = solc.compile(source, 1).contracts;

console.log(output);

fs.ensureDirSync(buildPath);

//to iterate over both the contracts
for(let contract in output) {
  fs.outputJsonSync (
    path.resolve(buildPath, contract.replace(':', '') + '.json'),
    output[contract]
  );
}
