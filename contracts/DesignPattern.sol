// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "hardhat/console.sol";

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
}

//State machine contract
// In the code snippet above, the Safe contract 
// uses modifiers to update the state of the 
// contract between various stages. The stages 
// determine when deposits and withdrawals can be made. 
// If the current state of the contract is not AcceptingDeposit, 
// users can not deposit to the contract, and if the current 
// state is not ReleasingDeposit, users can not withdraw 
// from the contract.
contract Safe {
   enum Stages { AcceptingDeposits, FreezingDeposits, ReleasingDeposits }

   Stages public stage = Stages.AcceptingDeposits;
   uint public creationTime = block.timestamp;
   mapping(address => uint) balances;

   modifier atStage(Stages _stage) {
      require(stage == _stage);
      _;
   }

   modifier timedTransitions() {
      if(stage == Stages.AcceptingDeposits && block.timestamp >= creationTime + 1 days){
         nextStage();
      }
      if(stage == Stages.FreezingDeposits && block.timestamp >= creationTime + 4 days){
         nextStage();
      }
      _;
   }

   function nextStage() internal {
      //jumps to the next stage
      stage = Stages(uint(stage) + 1);
   }

   function deposit() public payable timedTransitions atStage(Stages.AcceptingDeposits) {
      balances[msg.sender] += msg.value;
   }

   function withdraw() public timedTransitions atStage(Stages.ReleasingDeposits) {
      uint amount = balances[msg.sender];
      balances[msg.sender] = 0;
      payable(msg.sender).transfer(amount);
   }
}
