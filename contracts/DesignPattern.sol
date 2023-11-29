// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "hardhat/console.sol";

// public - all can access

// external - Cannot be accessed internally, only externally

// internal - only this contract and contracts deriving from it can access

// private - can be accessed only from this contract

// As for best practices, you should use external if you expect
// that the function will only ever be called externally, and use
// public if you need to call the function internally. Reason because
// public function consume more gas than external functions

contract DesignPattern {
   // Function to receive Ether. msg.data must be empty
   receive() external payable {
      console.log('Receive Hook called %s', gasleft());
   }

    //Fallback function is called when msg.data is not empty
   fallback() external payable {
      console.log('Fallback Hook called %s', gasleft());
   }
    /*
    When transferring Ether in Solidity, 
    we use the Send, Transfer, or Call methods. 
    These three methods have the same singular goal: 
    to send Ether out of a smart contract.
    Let’s have a look at how to use the 
    Transfer and Call methods for this purpose. 
    The following code samples demonstrate different implementations.
    */
   function transfer(address payable _to) public payable {
      //First is the Transfer method. When using this approach, 
      //all receiving smart contracts must define a fallback 
      //function, or the transfer transaction will fail. 
      //There is a gas limit of 2300 gas available, 
      //which is enough to complete the transfer transaction 
      //and aids in the prevention of reentry assaults:
     _to.transfer(msg.value);
   }

   function send(address payable _to) public payable {
      //The send returns a boolean value.
      bool sent = _to.send(msg.value);
      require(sent, "Failed to send ether");
   }

   function call(address payable _to) public payable {
      //Next is the Call method. Other functions in 
      //the contract can be triggered using this method, 
      //and optionally set a gas fee to use when the function executes:
      //Call returns a boolean value indicating success or failure.
      //This is the current recommended method to use.
      (bool sent, bytes memory data) = _to.call{value: msg.value, gas: 1000}("");
      require(sent, "Ether not sent");
   }

   /*
   Behavioral patterns
   
   Guard check: The function below shows how to implement the 
   guard check pattern using all three techniques.
   */
   function contribute(address payable _from) payable public {
      require(msg.value != 0, "Not enough ether");
      require(_from != address(0), "Invalid address");
      uint prevBalance = address(this).balance;
      uint amount;

      if(_from.balance == 0){
         amount = msg.value;
      } else if(_from.balance < msg.sender.balance){
         amount = msg.value / 2;
      } else {
         //revert() throws an exception, returns any gas supplied, 
         //and reverts the function call to the contract’s original state 
         //if the requirement for the function fails. 
         //The revert() method does not evaluate or require any conditions.
         revert("Insufficent Balance!!!");
      }

      _from.transfer(amount);
      //assert() evaluates the conditions for a function, 
      //then throws an exception, reverts the contract to the
      //previous state, and consumes the gas supply if the 
      //requirements fail after execution.
      assert(address(this).balance == prevBalance - amount);
   }

   //Randomness
   // This method is predicatable. Use with care!
   // The random() function below generates a random and unique integer 
   // by hashing the block number (block.number, which is a variable on the blockchain).
   function random() public view returns(uint rand){
      rand = uint(blockhash(block.number - 1));
      console.log("randome number: %s", rand);
      return rand;
   }

   //Events and Emit
   //In Solidity, you'll see that events are defined using the 
   //“event” keyword and are emitted using the “emit” keyword. 
   //Placing the “indexed” keyword in front of a parameter 
   //name will store it as a topic in the log record. 
   //Without the keyword “indexed”, it will be stored as data
   //refer to https://docs.soliditylang.org/en/v0.8.19/contracts.html#events for more info
   event Deposit(address indexed from, string indexed id, uint value);

   function deposit(string memory id) public payable {
      // Events are emitted using `emit`, followed by
      // the name of the event and the arguments
      emit Deposit(msg.sender, id, msg.value);
   }
}

//resume at Emergency stop.
