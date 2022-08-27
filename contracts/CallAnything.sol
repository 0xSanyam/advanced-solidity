// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

// In order to call a function using only the data field of call, we need to encode:
// The function name
// The parameters we want to add
// Down to the binary level

// Now each contract assigns each function it has a function ID. This is known as the "function selector".

// The "function selector" is the first 4 bytes of the function signature.
// The "function signature" is a string that defines the function name & parameters.
// Let's look at this

contract CallAnything {
	address public s_address;
	uint256 public s_amount;

	function transfer(address anAddress, uint256 amount) public {
		s_address = anAddress;
		s_amount = amount;
	}

	// We can get a function selector as easy as this.

	// "transfer(address,uint256)" is our function signature
	// and our resulting function selector of "transfer(address,uint256)" is output from this function

	function getSelectorOne() public pure returns (bytes4 selector) {
		selector = bytes4(keccak256(bytes("transfer(address,uint256)")));
	}

	function getDataToCallTransfer(address anAddress, uint256 amount) public pure returns (bytes memory) {
		return abi.encodeWithSelector(getSelectorOne(), anAddress, amount);
	}

	// So... How can we use the selector to call our transfer function now then?

	function callTransferFunctionWithBinary(address anAddress, uint256 amount) public returns (bytes4, bool) {
		(bool success, bytes memory returnData) = address(this).call(
			// getDataToCallTransfer(anAddress, amount)
			abi.encodeWithSelector(getSelectorOne(), anAddress, amount)
		);

		return (bytes4(returnData), success);
	}

	function callTransferFunctionWithSignature(address anAddress, uint256 amount) public returns (bytes4, bool) {
		(bool success, bytes memory returnData) = address(this).call(abi.encodeWithSignature("transfer(address,uint256)", anAddress, amount));
		return (bytes4(returnData), success);
	}

	// We can also get a function selector from data sent into the call
	function getSelectorTwo() public view returns (bytes4 selector) {
		bytes memory functionCallData = abi.encodeWithSignature("transfer(address,uint256)", address(this), 777);
		selector = bytes4(bytes.concat(functionCallData[0], functionCallData[1], functionCallData[2], functionCallData[3]));
	}

	// Another way to get this data is the hard coded way

	function getCallData() public view returns (bytes memory) {
		return (abi.encodeWithSignature("transfer(address,uint256)", address(this), 777));
	}

	// Pass this:
	// 0xa9059cbb000000000000000000000000e2899bddfd890e320e643044c6b95b9b0b84157a0000000000000000000000000000000000000000000000000000000000000309
	// This is output of `getCallData()`

	// This is another low level way to get function selector using assembly
	// You can actually write code that resembles the opcodes using the assembly keyword!

	// This in-line assembly is called "Yul"
	// It's a best practice to use it as little as possible - only when you need to do something very VERY specific

	function getSelectorThree(bytes calldata functionCallData) public pure returns (bytes4 selector) {
		// offset is a special attribute of calldata
		assembly {
			selector := calldataload(functionCallData.offset)
		}
	}

	// Another way to get your selector with the "this" keyword

	function getSelectorFour() public pure returns (bytes4 selector) {
		return this.transfer.selector;
	}

	// Just a function that gets the signature
	function getSignature() public pure returns (string memory) {
		return "transfer(address,uint256)";
	}
}

contract callFunctionWithoutContract {
	address public s_selectorAndSignatureAddr;

	// Do needs the previous contract's address as a parameter while deploying
	constructor(address selectorAndSignatureAddr) {
		s_selectorAndSignatureAddr = selectorAndSignatureAddr;
	}

	// Pass in 0xa9059cbb000000000000000000000000e2899bddfd890e320e643044c6b95b9b0b84157a0000000000000000000000000000000000000000000000000000000000000309
	// you could use this to change state

	function callSelectorThreeDirectly(bytes calldata callData) public returns (bytes4, bool) {
		(bool done, bytes memory returnData) = s_selectorAndSignatureAddr.call(abi.encodeWithSignature("getSelectorThree(bytes)", callData));

		return (bytes4(returnData), done);
	}

	// with a staticcall, we can have this be a view function!

	function staticCallSelectorFourDirectly() public view returns (bytes4, bool) {
		(bool done, bytes memory returnData) = s_selectorAndSignatureAddr.staticcall(abi.encodeWithSignature("getSelectorFour()"));

		return (bytes4(returnData), done);
	}

	function callTransferFunctionDirectly(address anAddress, uint256 anAmount) public returns (bytes4, bool) {
		(bool success, bytes memory returnData) = s_selectorAndSignatureAddr.call(
			abi.encodeWithSignature("transfer(address,uint256)", anAddress, anAmount)
		);

		return (bytes4(returnData), success);
	}
}
