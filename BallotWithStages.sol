// SPDX-License-Identifier:  GPL-3.0
pragma solidity ^0.8.4;

contract BallotWithStages {
    
    struct Voter {
        uint weight;
        bool voted;
        uint8 vote;
    }
    
    // modifier
    modifier onlyOwner() {
        require(msg.sender == chairperson);
        _;
    }
    
    struct Proposal {
        uint voteCount; // could add other data about Proposal
    }
    
    enum Stage {Init, Vote, Done}
    Stage public stage = Stage.Init;
    
    address public chairperson;
    mapping(address => Voter) public voters;
    uint[4] public proposals;
    
    // Create a new ballot with 4 different proposals.
    constructor () {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
    }
    
    /// Give chairperson the right to start the registration process.
    function startRegistration() onlyOwner {
        stage = Stage.Reg;
    }
    
    /// Give $(toVoter) the right to vote on this ballot.
    /// May only be called by $(chairperson).
    function register(address toVoter) public onlyOwner {
        if(voters[toVoter].weight !=0 || stage !=Stage.Reg) revert();
        voters[toVoter].weight = 1;
        voters[toVoter].voted = false;
    }
    
    /// Give chairperson the right to start the voting process.
    function startVoting() public {
        stage = Stage.Vote;
    }
    
    /// Give a single vote to proposal $(toProposal).
    function vote(uint8 toProposal) public {
        Voter storage sender = voters[msg.sender];
        if (sender.voted || toProposal >=4 || sender.weight == 0 || stage !=Stage.Vote) revert();
	sender.vote = toProposal;
        proposals[toProposal] += sender.weight;
    }

    function winningProposal() public view returns (uint _winningProposal) {
        if (stage != Stage.Done) revert();
        uint256 winningVoteCount = 0;
        for (uint8 prop = 0; prop < 4; prop++)
            if (proposals[prop] > winningVoteCount) {
                winningVoteCount = proposals[prop];
                _winningProposal = prop;
            }
    }
}