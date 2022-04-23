// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// import "contracts/Operator.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "hardhat/console.sol";


interface IOperator {
    function addWallet(string memory _phoneNumber, string memory _password) external;
    function getWalletPhoneNumber(address _walletAddress) external view returns (string memory);
    function getWalletAddress(string calldata _phoneNumber) external view returns (address);
    function getWalletBalance(string calldata _phoneNumber) external view returns (uint256);
}

contract Wallet {

    address public operatorAddress;
    event Received(address, uint); // see https://docs.soliditylang.org/en/latest/contracts.html#receive-ether-function

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function setOperatorAddress(address _operatorAddress) external {
        operatorAddress = _operatorAddress;
    }

    function transferETH(address _to, uint256 _amount) public payable {
        payable(_to).transfer(_amount);
    }

    function transferToPhoneNumber(string memory _toPhoneNumber, uint256 _amount) public payable {
        uint256 balance = address(this).balance;
        require(balance >= _amount, "Not enough ETH to transfer");
        IOperator operator = IOperator(operatorAddress);
        address to = operator.getWalletAddress(_toPhoneNumber);
        transferETH(to, _amount);
    }

}