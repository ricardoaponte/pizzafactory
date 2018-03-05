/*

PizzaPlace Contract
Ricardo Aponte-Yunqué 2018
Link Puerto Rico Smart Contracts Workshop

Items to point out:

1. Gas prices
2. Events
3. Modifiers
4. Structs
5. Areas of storage: memory, storage, stack
6. Loops vs Mappings
7. Guard functions: require, assert, revert
8. Function visibility:
    public: Public functions are part of the contract interface and can be either called internally or via messages. For public state variables, an automatic getter function (see below) is generated.
    internal (protected): Those functions and state variables can only be accessed internally (i.e. from within the current contract or contracts deriving from it), without using this.
    private: Private functions and state variables are only visible for the contract they are defined in and not in derived contracts.
    external: External functions are part of the contract interface, which means they can be called from other contracts and via transactions. An external function f cannot be called internally (i.e. f() does not work, but this.f() works). External functions are sometimes more efficient when they receive large arrays of data.
9. Naming conventions

Resources:

OpenZeppelin: https://github.com/OpenZeppelin

Style Guide: http://solidity.readthedocs.io/en/develop/style-guide.html
Security Considerations: http://solidity.readthedocs.io/en/develop/security-considerations.html

*/

pragma solidity ^0.4.19;

import "./ownable.sol";
import "./safemath.sol";

contract PizzaFactory is Ownable {

    uint public totalAmountPaid = 0;
    mapping (address => Participant) public users;
    mapping (uint => address) usersCount;
    address owner;

    event RefundProcessed(address _to, uint _amount);
    event RefundNotProcessed(string _reason);
    event PizzaPaid(address _from, uint _amount);
    event PizzaBeingMade();

    // TODO: Add more info to Participant struct (Tip: Full Name)
    struct Participant {
        uint amountPaid;
    }

    // Define Pizza
    struct PizzaDefinition {
        string name;
        uint price;
    }
    PizzaDefinition public pizza;

    // Constructor
    function PizzaFactory(uint _pizzaPrice, string _pizzaName) public payable {
        require(_pizzaPrice > 0 && bytes(_pizzaName).length > 0);
        pizza.price = _pizzaPrice;
        pizza.name = _pizzaName;

        // Save the Contract creator address
        owner = msg.sender;
    }

    function getBalance() onlyOwner public view returns(uint) {
        return this.balance;
    }

    // Make sure that the sender is not the owner
    modifier isNotOwner() {
        require(msg.sender != owner);
        _;
    }

    // Pay for Pizza
    function payForPizza() isNotOwner public payable {
        // TODO: Go make pizza if it is all paid for.
        // TODO: Check if payment is less or equal to the remaining pizza price before accepting the payment.
        require(totalAmountPaid < pizza.price);
        users[msg.sender].amountPaid += msg.value;
        totalAmountPaid += msg.value;

        //Emit pizzaPayed Event
        PizzaPaid(msg.sender, msg.value);
    }

    // Return amount to user
    function refundPayment() isNotOwner public payable {
        uint amountToRefund = users[msg.sender].amountPaid;
        if (amountToRefund > 0) {
            totalAmountPaid -= amountToRefund;
            users[msg.sender].amountPaid = 0;
            msg.sender.transfer(amountToRefund);
            RefundProcessed(msg.sender, amountToRefund);
        }
        else {
            RefundNotProcessed("There is no amount to be refunded");
        }
    }

    // Return the amount the user paid
    function getAmountPaid() public view returns (uint) {
        return users[msg.sender].amountPaid;
    }

    // Get the total amount remaining
    function getAmountRemaining() external view returns (uint) {
        return pizza.price - totalAmountPaid;
    }

    // Prepare Pizza
    function makePizza() payable public returns(string) {
        if (totalAmountPaid < pizza.price) {
            return "Pizza is not paid for yet";
        }
        else {
            // Pay the Pizza owner and make Pizza!
            owner.transfer(totalAmountPaid);
            totalAmountPaid = 0;

            //Emit PizzaBeingMade event
            PizzaBeingMade();
            return "Your Pizza is being prepared, thank you for your bussiness!";
        }
    }

}







