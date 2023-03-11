// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "hardhat/console.sol";


  //Pull-over-push
   //This design pattern shifts the risk of Ether transfer from 
   //the contract to the users. During the Ether transfer, 
   //several things can go wrong, causing the transaction to fail. 
   //In the pull-over-push pattern, three parties are 
   //involved: the entity initiating the transfer (the contract’s author), 
   //the smart contract, and the receiver. This pattern includes mapping, 
   //which aids in the tracking of users’ outstanding balances. 
   //Instead of delivering Ether from the contract to a recipient, 
   //the user invokes a function to withdraw their allotted Ether. 
   //Any inaccuracy in one of the transfers has no impact on the 
   //other transactions. The following is an example of pull-over-pull:
contract PullOverPush {
   mapping(address => uint) profits;

   function allowPull(address owner, uint amount) private {
     profits[owner] += amount;
   }

   function withdrawProfits() public {
     uint amount = profits[msg.sender];
     require(amount != 0);
     require(address(this).balance >= amount);

     profits[msg.sender] = 0;
     payable(msg.sender).transfer(amount);
   }
}

/*
In the PullOverPush contract above, allows users 
to withdraw the profits mapped to their address if the balance 
of the user is greater than or equal to profits alloted to the user.
*/