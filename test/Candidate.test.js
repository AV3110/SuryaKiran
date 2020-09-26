const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');

const provider = ganache.provider();
const web3 = new Web3(provider);

const compiledCreateCandidate = require('../ethereum/build/CreateCandidate.json');
const compiledCandidate = require('../ethereum/build/Candidate.json');

let accounts;
let createCandidate;
let candidateAddress;
let candidate;

beforeEach(async () => {
  accounts = await web3.eth.getAccounts();
  console.log(accounts);
  createCandidate = await new web3.eth.Contract(JSON.parse(compiledCreateCandidate.interface))
    .deploy({ data: compiledCreateCandidate.bytecode })
    .send({ from: accounts[0], gas: '1000000' });
    await createCandidate.methods.addCandidate().send({
      from: accounts[0],
      gas: '1000000'
    });

    [candidateAddress] = await createCandidate.methods.getCandidatePool().call();
    candidate = await new web3.eth.Contract(
      JSON.parse(compiledCandidate.interface),
      candidateAddress
    );
});

//tests
describe('Candidates', () => {
  it('deploys createCandidate and a Candidate', () => {
    console.log(assert.ok(createCandidate.options.address));
    console.log(assert.ok(candidate.options.address));
  });

  it('marks caller as the candidate manager', async () => {
    const manager = await candidate.methods.manager().call();
    assert.equal(accounts[0], manager);
  });

  it('allows people to contribute money and marks them as eligibleVoters', async () => {
    await candidate.methods.makeContrubution().send({
      value: '200',
      from: accounts[1]
    });
    const isContributor = await candidate.methods.eligibleVoters(accounts[1]).call();
    assert(isContributor);
  });
});
