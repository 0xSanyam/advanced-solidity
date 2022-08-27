// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

contract Encoding {
	error Withdraw_Failed();

	// For the cheatsheet, check out the docs: https://docs.soliditylang.org/en/v0.8.16/cheatsheet.html

	function combineStrings() public pure returns (string memory) {
		return string(abi.encodePacked("Hi World! ", "Love you!"));
	}

	function combineStringsConcat() public pure returns (string memory) {
		string memory str = string.concat("Hi World! ", "Love you!");
		return str;
	}

	// When we send a transaction, it is "compiled" down to bytecode and sent in a "data" object of the transaction.
	// That data object now governs how future transactions will interact with it.

	// Now, in order to read and understand these bytes, we need a special reader.
	// This is supposed to be a new contract? How can we tell?
	// Let's compile this contract in hardhat or remix, and we'll see the the "bytecode" output - that's that will be sent when
	// creating a contract.

	// This bytecode represents exactly the low level computer instructions to make our contract happen.
	// These low level instructions are spread out into something called opcodes (like alphabets in a sentence so to speak).

	// An opcode is going to be 2 characters that represents some special instruction, and also optionally has an input

	// We can see a list of these here:
	// https://www.evm.codes/
	// Or here:
	// https://github.com/crytic/evm-opcodes

	// This opcode reader is sometimes abstractly called the EVM - or the ethereum virtual machine.
	// The EVM basically represents all the instructions a computer needs to be able to read.
	// Any language that can compile down to bytecode with these opcodes is considered EVM compatible
	// Which is why so many blockchains are able to do this - you just get them to be able to understand the EVM and hurray! Solidity smart contracts work on those blockchains.

	// Now, just the binary can be hard to read, so why not press the `assembly` button? We'll get the binary translated into
	// the opcodes and inputs for us!

	// How does this relate back to what we are talking about?
	// Well let's look at this encoding stuff

	// In this function, we encode the number one to what it'll look like in binary
	// Or put another way, we ABI encode it.

	function encodeNumber() public pure returns (bytes memory) {
		bytes memory number = abi.encode(7);
		return number;
	}

	function encodeString() public pure returns (bytes memory) {
		bytes memory str = abi.encode("Encoded!");
		return str;
	}

	// Compressed
	// This is great if you want to save space, not good for calling functions.

	function encodeStringPacked() public pure returns (bytes memory) {
		bytes memory str = abi.encodePacked("Encoded!");
		return str;
	}

	// This is just type casting to string
	// It's slightly different, and they have different gas costs

	// =>
	// The packed one is copying the memory, and the bytes one is just casting the pointer type.

	function encodeStringBytes() public pure returns (bytes memory) {
		bytes memory str = bytes("Encoded!");
		return str;
	}

	// Decoding

	function decodeString() public pure returns (string memory) {
		string memory str = abi.decode(encodeString(), (string));
		return str;
	}

	// multi encode decode

	function multiEncode() public pure returns (bytes memory) {
		bytes memory str = abi.encode("Encoded! ", "Now Bigger!");
		return str;
	}

	function multiDecode() public pure returns (string memory, string memory) {
		(string memory str, string memory secondStr) = abi.decode(multiEncode(), (string, string));
		return (str, secondStr);
	}

	function multiEncodePacked() public pure returns (bytes memory) {
		bytes memory str = abi.encodePacked("Encoded! ", "Now Bigger!");
		return str;
	}

	// Decoding will not work on this

	// function multiDecodePacked() public pure returns(string memory, string memory) {
	//     (string memory str, string memory secondStr) = abi.decode(multiEncodePacked(), (string, string));
	//     return (str, secondStr);
	// }

	//  But this will work!

	function multiStringCastPacked() public pure returns (string memory) {
		string memory str = string(multiEncodePacked());
		return str;
	}

	// We always need two things to call a contract:
	// 1. ABI
	// 2. Contract Address?

	// Well... That is true, but we don't need that massive ABI file. All we need to know is how to create the binary to call
	// the functions that we want to call.

	// Solidity has some more "low-level" keywords, namely "staticcall" and "call".

	// call: How we call functions to change the state of the blockchain.
	// staticcall: This is how (at a low level) we do our "view" or "pure" function calls, and potentially don't change the blockchain state.

	// When you call a function, you are secretly calling "call" behind the scenes, with everything compiled down to the binary stuff
	// for you. Flashback to when we withdrew ETH from our lottery:

	/*
	 *** DO NOT DEPLOY THIS ON AN ACTUAL NETWORK, THIS IS MEANT ONLY FOR TESTING!!! ***
	 */
	function withdraw(address winner) public {
		(bool paid, ) = winner.call{value: address(this).balance}("");
		if (!paid) revert Withdraw_Failed();
	}

	// Remember this

	// - In our {} we were able to pass specific fields of a transaction, like value.
	// - In our () we were able to pass data in order to call a specific function - but there was no function we wanted to call!
	// We only sent ETH, so we didn't need to call a function!
	// If we want to call a function, or send any data, we'd do it in these parathesis!
}
