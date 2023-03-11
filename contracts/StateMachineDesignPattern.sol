// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

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