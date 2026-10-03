// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {SuiteBase, AssetFlow} from "./SuiteBase.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title Threshold native treasury
/// @notice Immutable-owner multisig treasury with transaction approvals, revocation, delay and exactly-once execution.
/// @dev Reference implementation; independent audit required before production.

contract ThresholdTreasury is ReentrancyGuard {
    mapping(address => bool) public isSigner;
    address[] public signers;
    uint256 public immutable threshold;
    uint64 public immutable delay;
    struct Transaction {
        address target;
        uint256 value;
        bytes data;
        uint64 submitted;
        uint256 approvals;
        bool executed;
    }
    Transaction[] private transactions;
    mapping(uint256 => mapping(address => bool)) public approved;
    event Submitted(
        uint256 indexed id,
        address indexed proposer,
        address target,
        uint256 value
    );
    event Approved(uint256 indexed id, address indexed signer);
    event Revoked(uint256 indexed id, address indexed signer);
    event Executed(uint256 indexed id, bytes result);
    event Deposited(address indexed sender, uint256 amount);
    modifier onlySigner() {
        require(isSigner[msg.sender], "signer");
        _;
    }
    constructor(address[] memory owners, uint256 required, uint64 wait) {
        require(
            owners.length > 0 &&
                owners.length <= 50 &&
                required > 0 &&
                required <= owners.length,
            "config"
        );
        for (uint256 i; i < owners.length; i++) {
            require(owners[i] != address(0) && !isSigner[owners[i]], "owner");
            isSigner[owners[i]] = true;
            signers.push(owners[i]);
        }
        threshold = required;
        delay = wait;
    }
    receive() external payable {
        emit Deposited(msg.sender, msg.value);
    }
    function submit(
        address target,
        uint256 value,
        bytes calldata data
    ) external onlySigner returns (uint256 id) {
        require(target != address(0), "target");
        id = transactions.length;
        transactions.push(
            Transaction(target, value, data, uint64(block.timestamp), 0, false)
        );
        emit Submitted(id, msg.sender, target, value);
    }
    function approve(uint256 id) external onlySigner {
        Transaction storage t = transactions[id];
        require(!t.executed && !approved[id][msg.sender], "approval");
        approved[id][msg.sender] = true;
        t.approvals++;
        emit Approved(id, msg.sender);
    }
    function revoke(uint256 id) external onlySigner {
        Transaction storage t = transactions[id];
        require(!t.executed && approved[id][msg.sender], "approval");
        approved[id][msg.sender] = false;
        t.approvals--;
        emit Revoked(id, msg.sender);
    }
    function execute(uint256 id) external nonReentrant {
        Transaction storage t = transactions[id];
        require(
            !t.executed &&
                t.approvals >= threshold &&
                block.timestamp >= t.submitted + delay,
            "execution"
        );
        t.executed = true;
        (bool ok, bytes memory result) = t.target.call{value: t.value}(t.data);
        require(ok, "target reverted");
        emit Executed(id, result);
    }
    function transaction(
        uint256 id
    ) external view returns (Transaction memory) {
        return transactions[id];
    }
    function transactionCount() external view returns (uint256) {
        return transactions.length;
    }
}
