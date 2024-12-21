// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingReward {

    // Owner of the contract (can create proposals)
    address public owner;

    // Reward points for each vote
    uint256 public rewardPerVote = 10;

    // Struct to represent a proposal
    struct Proposal {
        uint256 id;
        string title;
        string description;
        uint256 voteCount;
        bool isActive;
    }

    // Struct to represent a voter
    struct Voter {
        bool hasVoted;
        uint256 rewardPoints;
    }

    // Mapping to track all proposals
    mapping(uint256 => Proposal) public proposals;
    
    // Mapping to track whether a user has voted
    mapping(address => Voter) public voters;

    // Proposal counter (unique ID for each proposal)
    uint256 public proposalCounter;

    // Event to notify when a new proposal is created
    event ProposalCreated(uint256 id, string title, string description);
    
    // Event to notify when a vote has been cast
    event Voted(address indexed voter, uint256 proposalId, uint256 reward);

    // Modifier to restrict access to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Constructor
    constructor() {
        owner = msg.sender;
    }

    // Function to create a new proposal
    function createProposal(string memory _title, string memory _description) public onlyOwner {
        proposalCounter++;
        proposals[proposalCounter] = Proposal(proposalCounter, _title, _description, 0, true);
        emit ProposalCreated(proposalCounter, _title, _description);
    }

    // Function to vote on a proposal
    function vote(uint256 _proposalId) public {
        require(proposals[_proposalId].isActive, "This proposal is not active");
        require(!voters[msg.sender].hasVoted, "You have already voted");

        // Mark the voter as having voted
        voters[msg.sender].hasVoted = true;

        // Increase the vote count for the proposal
        proposals[_proposalId].voteCount++;

        // Reward the voter
        voters[msg.sender].rewardPoints += rewardPerVote;

        // Emit the Voted event
        emit Voted(msg.sender, _proposalId, rewardPerVote);
    }

    // Function to get the proposal details by ID
    function getProposal(uint256 _proposalId) public view returns (string memory, string memory, uint256, bool) {
        Proposal memory p = proposals[_proposalId];
        return (p.title, p.description, p.voteCount, p.isActive);
    }

    // Function to get voter reward points
    function getVoterReward(address _voter) public view returns (uint256) {
        return voters[_voter].rewardPoints;
    }

    // Function to deactivate a proposal (e.g., after it has been funded or finished)
    function deactivateProposal(uint256 _proposalId) public onlyOwner {
        proposals[_proposalId].isActive = false;
    }
}
