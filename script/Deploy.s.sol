// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Script, console2 } from "forge-std/Script.sol";
import { Module } from "../src/Module.sol";
import { HatsModuleFactory } from "hats-module/HatsModuleFactory.sol";

abstract contract Deployer is Script {
  bool internal _verbose = true;

  /// @dev Set up the deployer via their private key from the environment
  function deployer() public returns (address) {
    uint256 privKey = vm.envUint("PRIVATE_KEY");
    return vm.rememberKey(privKey);
  }

  function _log(string memory prefix, address deployed) internal view {
    if (_verbose) {
      console2.log(string.concat(prefix, "Module:"), deployed);
    }
  }
}

contract DeployImplementation is Deployer {
  bytes32 public SALT = bytes32(abi.encode("change this to the value of your choice"));
  Module public implementation;

  // default values

  string internal _version = "0.1.0"; // increment this with each new deployment

  /// @dev Override default values, if desired
  function prepare(bool verbose, string memory version) public {
    _verbose = verbose;
    _version = version;
  }

  /// @dev Deploy the contract to a deterministic address via forge's create2 deployer factory.
  function run() public virtual {
    vm.startBroadcast(deployer());

    /**
     * @dev Deploy the contract to a deterministic address via forge's create2 deployer factory, which is at this
     * address on all chains: `0x4e59b44847b379578588920cA78FbF26c0B4956C`.
     * The resulting deployment address is determined by only two factors:
     *    1. The bytecode hash of the contract to deploy. Setting `bytecode_hash` to "none" in foundry.toml ensures that
     *       never differs regardless of where its being compiled
     *    2. The provided salt, `SALT`
     */
    implementation = new Module{ salt: SALT}(_version /* insert constructor args here */);

    vm.stopBroadcast();

    _log("", address(implementation));
  }

  /* FORGE CLI COMMANDS

  ## A. Simulate the implementation deployment locally
  forge script script/Deploy.s.sol:DeployImplementation -f mainnet

  ## B. Deploy implementation to real network and verify on etherscan
  forge script script/Deploy.s.sol:DeployImplementation -f mainnet --broadcast --verify

  ## C. Fix verification issues (replace values in curly braces with the actual values)
  forge verify-contract --chain-id 1 --num-of-optimizations 1000000 --watch --constructor-args $(cast abi-encode \
  "constructor({args})" "{arg1}" "{arg2}" "{argN}" ) \ 
  --compiler-version v0.8.19 {deploymentAddress} \
  src/{Counter}.sol:{Counter} --etherscan-api-key $ETHERSCAN_KEY

  */
}

/// @dev Deploy pre-compiled ir-optimized bytecode to a non-deterministic address
contract DeployImplementationPrecompiled is DeployImplementation {
  /// @dev Update SALT and default values in DeployImplementation contract

  function run() public override {
    vm.startBroadcast(deployer());

    bytes memory args = abi.encode( /* insert constructor args here */ );

    /// @dev Load and deploy pre-compiled ir-optimized bytecode.
    implementation = Module(deployCode("optimized-out/Module.sol/Module.json", args));

    vm.stopBroadcast();

    _log("Precompiled ", address(implementation));
  }
}

/* FORGE CLI COMMANDS

## D. To verify ir-optimized contracts on etherscan...
  1. Run (C) with the following additional flag: `--show-standard-json-input > etherscan.json`
  2. Patch `etherscan.json`: `"optimizer":{"enabled":true,"runs":100}` =>
`"optimizer":{"enabled":true,"runs":100},"viaIR":true`
  3. Upload the patched `etherscan.json` to etherscan manually

  See this github issue for more: https://github.com/foundry-rs/foundry/issues/3507#issuecomment-1465382107

*/

/// @dev Deploy an instance of the implementation
contract DeployInstance is Deployer {
  HatsModuleFactory public factory = HatsModuleFactory(0xfE661c01891172046feE16D3a57c3Cf456729efA);
  bytes32 public SALT = bytes32(abi.encode("change this to the value of your choice"));
  address public implementation;
  address public instance;
  uint256 public hatId;

  // default immutable args

  // default init args

  /// @dev Override default values, if desired
  function prepare(bool verbose, address _implementation, uint256 _hatId) public virtual {
    _verbose = verbose;
    implementation = _implementation;
    hatId = _hatId;
  }

  /// @dev Deploy the contract to a deterministic address via forge's create2 deployer factory.
  function run() public virtual returns (address) {
    vm.startBroadcast(deployer());

    instance = factory.createHatsModule(
      implementation,
      hatId,
      abi.encodePacked( /* insert other immutable args here */ ),
      abi.encode( /* insert init args here */ )
    );

    vm.stopBroadcast();

    _log("", instance);

    return instance;
  }

  /* FORGE CLI COMMANDS

  ## E. Simulate the instance deployment locally
  forge script script/Deploy.s.sol:DeployImplementation -f mainnet

  ## F. Deploy instance to real network and verify on etherscan
  forge script script/Deploy.s.sol:DeployImplementation -f mainnet --broadcast --verify

  */
}
