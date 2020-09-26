pragma solidity ^0.4.17;

contract CreateCandidate {
  address[] public candidatePool;

  function addCandidate() public {
    address newCandidate = new Candidate(msg.sender);
    candidatePool.push(newCandidate);
  }

  function getCandidatePool() public view returns (address[]) {
      return candidatePool;
  }
}

contract Candidate {

  struct CandidateRequest {
    string name;
    string description;
    uint contrubutionValue;
    address recepientAddress;
    bool isForwarded;
    uint voteCount;
    mapping(address => bool) voters;
  }

  //Global Values
  CandidateRequest[] public requests;
  address public manager;
  //value in ether
  uint public minimumContribution = 1;
  mapping(address => bool) public eligibleVoters;
  uint public eligibleVotersCount;

  //Constructor
  function Candidate () public {
    manager = msg.sender;
  }

  function makeContrubution() public payable {
      require(msg.value >= minimumContribution);

      //add all contrubutors to eligibleVoters
      eligibleVoters[msg.sender] = true;
      eligibleVotersCount++;
  }

  function addNewCandidateRequest(string name, string description, uint contrubutionValue, address recepientAddress) public {

    //only manager can add the new candidate after preliminary interview
    require(msg.sender == manager);

    CandidateRequest memory newCandidateRequest = CandidateRequest({
      name: name,
      description: description,
      contrubutionValue: contrubutionValue,
      recepientAddress: recepientAddress,
      isForwarded: false,
      voteCount: 0
    });
    requests.push(newCandidateRequest);
  }

  function castVote(uint index) public {
    CandidateRequest storage request = requests[index];

    //only contriubutors can vote
    require(eligibleVoters[msg.sender]);
    //only one vote per contributor
    require(!request.voters[msg.sender]);

    request.voters[msg.sender] = true;
    request.voteCount++;
  }

  function forwardRequest(uint index) public {
    require(msg.sender == manager);

    CandidateRequest storage request = requests[index];

    //codition to check majority vote
    require(request.voteCount > (eligibleVotersCount / 2));
    //check if request is not already isForwarded
    require(!request.isForwarded);

    request.recepientAddress.transfer(request.contrubutionValue);
    request.isForwarded = true;
  }

  function getSummary() public view returns (
    uint, uint, uint, uint, address
    ) {
      return (
        minimumContribution,
        this.balance,
        requests.length,
        eligibleVotersCount,
        manager
      );
  }

  function getRequestsCount() public view returns (uint) {
      return requests.length;
  }
}
