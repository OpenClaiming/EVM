// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IOpenClaiming {

	struct Payment {
		address payer;
		address token;
		bytes32 recipientsHash;
		uint256 max;
		uint256 line;
		uint256 nbf;
		uint256 exp;
	}

	function lineOpen(address account, uint256 line, uint256 max) external;

	function lineClose(address account, uint256 line) external;

	function lineAvailable(address account, uint256 line) external view returns (uint256);

	function executePayment(
		Payment calldata payment,
		address[] calldata recipients,
		bytes calldata signature,
		uint256 line,
		address recipient,
		uint256 amount
	) external payable returns (bool);

	function verifyPayment(
		Payment calldata payment,
		bytes calldata signature
	) external view returns (bool);
}