// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ClaimToken is Ownable {
    IERC20 public token;
    bytes32 public merkleRoot;
    mapping(address => bool) public claimed;

    event Claimed(address account, uint256 amount);

    constructor(address token_, bytes32 merkleRoot_) Ownable(msg.sender) {
        token = IERC20(token_);
        merkleRoot = merkleRoot_;
    }

    function setMerkleRoot(bytes32 merkleRoot_) external onlyOwner {
        merkleRoot = merkleRoot_;
    }

    function claim(
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external {
        require(claimed[account] = false, "Claimed");
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));

        require(
            MerkleProof.verify(merkleProof, merkleRoot, leaf),
            "Invalid merkle proof"
        );

        claimed[account] = true;
        require(token.transfer(account, amount), "Transfer failed");

        emit Claimed(account, amount);
    }

    // Function to allow owner to withdraw accidentally sent ERC20 tokens
    function withdrawToken(
        address tokenAddress,
        uint256 amount
    ) external onlyOwner {
        IERC20 _token = IERC20(tokenAddress);
        uint256 balance = _token.balanceOf(address(this));
        require(balance >= amount, "Not enough tokens in the contract");
        require(_token.transfer(owner(), amount), "Token transfer failed");
    }
}