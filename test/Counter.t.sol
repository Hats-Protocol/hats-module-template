// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import { Test, console2 } from "forge-std/Test.sol";
import { Counter } from "../src/Counter.sol";
import { Deploy, DeployPrecompiled } from "../script/Counter.s.sol";

contract CounterTest is DeployPrecompiled, Test {
  /// @dev Inherit from DeployPrecompiled instead of Deploy if working with pre-compiled contracts

  /// @dev variables inhereted from Deploy script
  // Counter public counter;
  // bytes32 public SALT;

  uint256 public fork;
  uint256 public BLOCK_NUMBER;

  function setUp() public virtual {
    // OPTIONAL: create and activate a fork, at BLOCK_NUMBER
    // fork = vm.createSelectFork(vm.rpcUrl("mainnet"), BLOCK_NUMBER);

    // deploy via the script
    prepare(true);
    run();
  }
}

contract UnitTests is CounterTest {
  function test_empty() public {
    counter.setNumber(2);
  }
}
