// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract TicketSale {
    address public manager;
    uint public ticketPrice;
    uint public totalTickets;
    mapping(address => uint) public ticketOwners;
    mapping(uint => address) public ticketIdToOwner;
    mapping(address => address) public swapOffers;

    event TicketBought(address buyer, uint ticketId);
    event SwapOffered(address sender, address partner);
    event SwapAccepted(address buyer, address partner);
    event TicketReturned(address owner, uint ticketId);

    constructor(uint numTickets, uint price) {
        manager = msg.sender;
        totalTickets = numTickets;
        ticketPrice = price;
    }

    function buyTicket(uint ticketId) public payable {
        require(msg.sender != manager, "Manager cannot buy tickets");
        require(ticketId > 0 && ticketId <= totalTickets, "Invalid ticket ID");
        require(ticketOwners[msg.sender] == 0, "You already have a ticket");
        require(msg.value == ticketPrice, "Incorrect amount sent");

        ticketOwners[msg.sender] = ticketId;
        ticketIdToOwner[ticketId] = msg.sender;

        emit TicketBought(msg.sender, ticketId);
    }

    function getTicketOf(address person) public view returns (uint) {
        return ticketOwners[person];
    }

    function offerSwap(address partner) public {
        require(ticketOwners[msg.sender] > 0, "You don't have a ticket to swap");
        require(ticketOwners[partner] > 0, "Partner doesn't have a ticket");
        require(msg.sender != partner, "Cannot swap with yourself");

        swapOffers[msg.sender] = partner;
        emit SwapOffered(msg.sender, partner);
    }

    function acceptSwap(address partner) public {
        require(ticketOwners[msg.sender] > 0, "You don't have a ticket to swap");
        require(ticketOwners[partner] > 0, "Partner doesn't have a ticket");
        require(msg.sender == swapOffers[partner], "No swap offer from partner");

        (ticketOwners[msg.sender], ticketOwners[partner]) = (ticketOwners[partner], ticketOwners[msg.sender]);
        swapOffers[partner] = address(0);

        emit SwapAccepted(msg.sender, partner);
    }

    function returnTicket(uint ticketId) public {
        require(ticketOwners[msg.sender] == ticketId, "You don't own this ticket");
        
        uint refundAmount = (ticketPrice * 9) / 10;
        payable(manager).transfer(refundAmount);
        ticketOwners[msg.sender] = 0;

        emit TicketReturned(msg.sender, ticketId);
    }
}
