// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Test, console2 } from "forge-std/Test.sol";
import { Module } from "../src/Module.sol";
import { DeployImplementation, DeployImplementationPrecompiled, DeployInstance } from "../script/Deploy.s.sol";
// import {
//   HatsModuleFactory, IHats, deployModuleInstance, deployModuleFactory
// } from "hats-module/utils/DeployFunctions.sol";
import { IHats } from "hats-protocol/Interfaces/IHats.sol";

contract ModuleTest is DeployImplementation, Test {
  /// @dev Inherit from DeployPrecompiled instead of Deploy if working with pre-compiled contracts

  /// @dev variables inhereted from DeployImplementation script
  // Module public implementation;
  // bytes32 public SALT;

  uint256 public fork;
  uint256 public BLOCK_NUMBER = 18_265_600; // after HatsModuleFactory deployment block
  IHats public HATS = IHats(0x3bc1A0Ad72417f2d411118085256fC53CBdDd137); // v1.hatsprotocol.eth
  DeployInstance public deployInstance;
  Module public instance;
  uint256 public hatId;

  string public MODULE_VERSION;

  function setUp() public virtual {
    // create and activate a fork, at BLOCK_NUMBER
    fork = vm.createSelectFork(vm.rpcUrl("mainnet"), BLOCK_NUMBER);

    // deploy implementation via the script
    prepare(false, MODULE_VERSION);
    run();
  }
}

contract WithInstanceTest is ModuleTest {
  function setUp() public virtual override {
    super.setUp();

    // set up the hats

    // set up the other immutable args (if necessary)

    // set up the init args (if necessary)

    // deploy the DeployInstance script
    deployInstance = new DeployInstance();

    // prepare the script with the necessary args
    deployInstance.prepare(false, address(implementation), hatId);

    // run the script to deploy an instance of the module
    instance = Module(deployInstance.run());
  }
}

contract Deployment is WithInstanceTest {
  /// @dev ensure that both the implementation and instance are properly initialized
  function test_initialization() public {
    // implementation
    vm.expectRevert("Initializable: contract is already initialized");
    implementation.setUp("setUp attempt");
    // instance
    vm.expectRevert("Initializable: contract is already initialized");
    instance.setUp("setUp attempt");
  }

  function test_version() public {
    assertEq(instance.version(), MODULE_VERSION);
  }

  function test_implementation() public {
    assertEq(address(instance.IMPLEMENTATION()), address(implementation));
  }

  function test_hats() public {
    assertEq(address(instance.HATS()), address(HATS));
  }

  function test_hatId() public {
    assertEq(instance.hatId(), hatId);
  }

  // test other initial values
}

contract UnitTests is WithInstanceTest { }
