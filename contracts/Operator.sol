// SPDX-License-Identifier: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/proxy/Proxy.sol";
import "hardhat/console.sol";


interface IWallet {
    function phoneNumber() external pure returns (string memory);
    function setOperatorAddress(address _operatorAddress) external;
    event Received(address, uint);
    receive() external payable;
    function transferETH(address _to, uint256 _amount) external payable;
    function transferToPhoneNumber(string memory _toPhoneNumber, uint256 _amount) external payable;
    function transferOwnership(address _newOwner) external;
}

// This is the main building block for smart contract.
contract Operator is Proxy {

    mapping(string => address) phoneToAddress;
    mapping(address => string) addressToPhone;
    mapping(string => bytes32) passwords;
    address private walletImplementation;
    event WalletCreation(address);

    constructor(address __implementation) {
        walletImplementation = __implementation;
    }

    function _implementation() internal view override returns (address) {
        return walletImplementation;
    }

    function hash(string memory _password) internal pure returns (bytes32) {
        return keccak256(abi.encode(_password));
    }

    function addWallet(string memory _phoneNumber, string memory _password) public {
        address payable walletAddress = payable(Clones.clone(walletImplementation));
        IWallet wallet = IWallet(walletAddress);
        wallet.setOperatorAddress(address(this));
        phoneToAddress[_phoneNumber] = walletAddress;
        passwords[_phoneNumber] = hash(_password);
        addressToPhone[walletAddress] = _phoneNumber;
        emit WalletCreation(walletAddress);
    }

    function getWalletPhoneNumber(address _walletAddress) view public returns (string memory) {
        return addressToPhone[_walletAddress];
    }

    function getWalletAddress(string memory _phoneNumber) view public returns (address) {
        address addr = phoneToAddress[_phoneNumber];
        require(addr != address(0), "The phone number is not registered yet.");
        return addr;
    }

    function checkWalletPassword(string memory _phoneNumber, string memory _password) view public returns (bool) {
        bytes32 hashedPassword = hash(_password);
        require(passwords[_phoneNumber] == hashedPassword, "The password is not correct.");
        return true;
    }

    function getWalletBalance(string memory _phoneNumber) view public returns (uint256) {
        address walletAddress = getWalletAddress(_phoneNumber);
        return walletAddress.balance;
    }

}