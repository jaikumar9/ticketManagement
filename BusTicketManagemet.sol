// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TicketBooking {
    address public owner;
    uint256 public totalSeats = 20;
    uint256 public maxTicketsPerAddress = 4;
    uint256 public seatsAvailable = 20;

    mapping(address => uint256[]) private userBookings;
    mapping(uint256 => address) private seatToPassenger;

    event TicketBooked(address indexed passenger, uint256[] seatNumbers);

    constructor() {
        owner = msg.sender;
    }

    modifier validSeatNumbers(uint256[] memory seatNumbers) {
        require(seatNumbers.length > 0 && seatNumbers.length <= maxTicketsPerAddress, "Invalid number of seats.");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this operation.");
        _;
    }

    function bookSeats(uint256[] memory seatNumbers) public validSeatNumbers(seatNumbers) {
        require(seatsAvailable >= seatNumbers.length, "Not enough seats available.");
        
        for (uint256 i = 0; i < seatNumbers.length; i++) {
            uint256 seatNumber = seatNumbers[i];
            require(seatNumber >= 1 && seatNumber <= totalSeats, "Invalid seat number.");
            require(userBookings[msg.sender].length < maxTicketsPerAddress, "Maximum tickets reached.");
            require(seatToPassenger[seatNumber] == address(0), "Seat is already booked.");
            
            userBookings[msg.sender].push(seatNumber);
            seatToPassenger[seatNumber] = msg.sender;
            seatsAvailable--;
        }
        
        emit TicketBooked(msg.sender, seatNumbers);
    }

    function showAvailableSeats() public view returns (uint256[] memory) {
        uint256[] memory available = new uint256[](seatsAvailable);
        uint256 seatCount = 0;
        
        for (uint256 i = 1; i <= totalSeats; i++) {
            if (seatToPassenger[i] == address(0)) {
                available[seatCount] = i;
                seatCount++;
            }
        }
        
        return available;
    }

    function checkAvailability(uint256 seatNumber) public view returns (bool) {
        require(seatNumber >= 1 && seatNumber <= totalSeats, "Invalid seat number.");
        return seatToPassenger[seatNumber] == address(0);
    }
    
    function myTickets() public view returns (uint256[] memory) {
        return userBookings[msg.sender];
    }

    // Function to allow the owner to check availability for any seat number
    function ownerCheckAvailability(uint256 seatNumber) public view onlyOwner returns (bool) {
        require(seatNumber >= 1 && seatNumber <= totalSeats, "Invalid seat number.");
        return seatToPassenger[seatNumber] == address(0);
    }
}
