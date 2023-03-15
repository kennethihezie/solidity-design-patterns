// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "hardhat/console.sol";

contract EmergencyStop {
    address public _owner;
    bool private _isContractRuning = true;

    constructor() {
        _owner = msg.sender;
    }

   modifier _restricted(){
    require(msg.sender == _owner);
    _;
   }

   modifier _isRunning() {
    require(_isContractRuning);
    _;
   }

   function stopContract() _restricted public {
     _isContractRuning = false;
   }

   function startContract() _restricted public {
     _isContractRuning = true;
   }

   
   function transferFunds(uint amount) _isRunning public {
     payable(_owner).transfer(amount);
   }
}