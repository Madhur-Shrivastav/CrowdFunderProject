//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract DonateFunds {
    receive() external payable {}

    address payable public receiver;
    address public manager;
    uint256 public NoOfDonors;

    constructor() {
        receiver = payable(address(this));
    }

    function setmanager(address account) external returns (address) {
        manager = account;
        return manager;
    }

    ////////////////////////////-----Donors Section-------///////////////////////////////////////////////////////
    mapping(uint256 => address) public donors;

    function hasdonated(address account) public view returns (bool) {
        for (uint256 i = 0; i < NoOfDonors; i++) {
            if (donors[i] == account) {
                return true;
            }
        }
        return false;
    }

    function donate() external payable {
        address donor = msg.sender;
        uint256 amount = msg.value;
        require(donor != receiver, "The smart contract cannot donate.");
        require(donor != manager, "The manager cannot donate.");
        require(
            amount >= 1000000 wei,
            "The minimum amount of donation should be atleast 1 ether."
        );
        if (hasdonated(donor) == false) {
            donors[NoOfDonors] = donor;
            NoOfDonors++;
        }
    }

    function getdonors() external view returns (address[] memory) {
        address[] memory Donors = new address[](NoOfDonors);
        for (uint256 i = 0; i < NoOfDonors; i++) {
            Donors[i] = donors[i];
        }
        return Donors;
    }

    ////////////////////////////-----Request Section-------//////////////////////////////////////////////////////
    //"Medical",2000000,0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
    //"Social",1000000,0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
    //"Startup",65000000,0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
    //"Environment",1000000,0x617F2E2fD72FD9D5503197092aC168c91465E7f2
    //"Loan",1500000,0x17F6AD8Ef982297579C203069C1DbfFE4348c372

    mapping(uint256 => string) public purposes;
    mapping(uint256 => uint256) public payments;
    mapping(uint256 => address) public clients;
    mapping(uint256 => bool) public fullfilled;
    mapping(uint256=>string) public status;
    mapping(uint256 => uint256) public votes;

    uint256 public NoOfRequests = 0;
    uint256 public mappingindex;

    function hasrequested(address account) public view returns (bool) {
        for (uint256 i = 0; i < mappingindex; i++) {
            if (clients[i] == account) {
                return true;
            }
        }
        return false;
    }

    function request(
        string memory _purpose,
        uint256 _payment,
        address payable _client
    ) external {
        require(msg.sender != manager, "The manager cannot request!");
        require(
            hasdonated(_client) == false,
            "You are a donor,so you cannot request for any funds!"
        );
        require(hasrequested(_client) == false, "You have already requested!");

        NoOfRequests++;
        purposes[mappingindex] = _purpose;
        payments[mappingindex] = _payment;
        clients[mappingindex] = _client;
        fullfilled[mappingindex] = false;
        status[mappingindex]="Unfullfilled.";
        votes[mappingindex] = 0;
        mappingindex++;
    }

    function getPurposes() external view returns (string[] memory) {
        string[] memory Purposes = new string[](mappingindex);
        for (uint256 i = 0; i < mappingindex; i++) {
            Purposes[i] = purposes[i];
        }
        return Purposes;
    }

    function getPayments() external view returns (uint256[] memory) {
        uint256[] memory Payments = new uint256[](mappingindex);
        for (uint256 i = 0; i < mappingindex; i++) {
            Payments[i] = payments[i];
        }
        return Payments;
    }

    function getClients() external view returns (address[] memory) {
        address[] memory Clients = new address[](mappingindex);
        for (uint256 i = 0; i < mappingindex; i++) {
            Clients[i] = clients[i];
        }
        return Clients;
    }

    function getFullfilled() external view returns (bool[] memory) {
        bool[] memory Fullfilled = new bool[](mappingindex);
        for (uint256 i = 0; i < mappingindex; i++) {
            Fullfilled[i] = fullfilled[i];
        }
        return Fullfilled;
    }

    function getStatus() external view returns (string[] memory) {
        string[] memory Status = new string[](mappingindex);
        for (uint256 i = 0; i < mappingindex; i++) {
            Status[i] = status[i];
        }
        return Status;
    }

    function getVotes() external view returns (uint256[] memory) {
        uint256[] memory Votes = new uint256[](mappingindex);
        for (uint256 i = 0; i < mappingindex; i++) {
            Votes[i] = votes[i];
        }
        return Votes;
    }

    ////////////////////////////-----Voters Section-------///////////////////////////////////////////////////////
    mapping(uint256 => address) public voters;
    uint256 public VotersLength = 0;
    uint256 public NoOfVoters;

    function hasMaxVotes(uint256 requestnumber) public view returns (bool) {
        uint256 max = 0;
        for (uint256 i = 0; i < mappingindex; i++) {
            if (votes[i] > max) {
                max = votes[i];
            }
        }
        if (votes[requestnumber - 1] == max && votes[requestnumber - 1] != 0) {
            return true;
        } else if (votes[requestnumber - 1] == 0) {
            return false;
        } else {
            return false;
        }
    }

    function getVoters() external view returns (address[] memory) {
        address[] memory Voters = new address[](VotersLength);
        for (uint256 i = 0; i < VotersLength; i++) {
            Voters[i] = voters[i];
        }
        return Voters;
    }

    function hasvoted(address account) public view returns (bool) {
        for (uint256 i = 0; i < VotersLength; i++) {
            if (voters[i] == account) {
                return true;
            }
        }
        return false;
    }

    function vote(uint256 requestnumber) external {
        address voter = msg.sender;
        require(voter != manager, "Manager is not allowed to vote!");
        require(
            hasdonated(voter) == true,
            "You need to donate some ammount in order to vote!"
        );
        require(
            fullfilled[requestnumber - 1] == false,
            "This request has been fullfilled already."
        );
        require(
            hasvoted(voter) == false,
            "You have already voted for a request!"
        );
        voters[VotersLength] = voter;
        VotersLength++;
        votes[requestnumber - 1]++;
        NoOfVoters++;
    }

    ////////////////////////////-----Payment Section-------//////////////////////////////////////////////////////

    function getClientToBePayed(uint256 requestnumber)
        external
        view
        returns (address)
    {
        return clients[requestnumber - 1];
    }

    function pay(uint256 requestnumber) external {
        uint256 payedamount = payments[requestnumber - 1];
        address payable tobepayedclient = payable(clients[requestnumber - 1]);
        require(msg.sender == manager, "Only the manager can pay!");
        require(
            payedamount <= address(this).balance,
            "Insufficient balance in the contract!"
        );
        require(
            fullfilled[requestnumber - 1] == false,
            "This request has been fullfilled already."
        );
        require(
            hasMaxVotes(requestnumber) == true,
            "The request is not supported by the majority of the donors."
        );
        tobepayedclient.transfer(payedamount);
        fullfilled[requestnumber - 1] = true;
        status[requestnumber-1]="Fullfilled.";
        NoOfVoters = NoOfVoters - votes[requestnumber - 1];
        votes[requestnumber - 1] = 0;
        NoOfRequests--;
    }
}
