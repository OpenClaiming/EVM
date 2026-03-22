// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
*****************
DISCLAIMER
*****************

This smart contract is provided for reference and general use. It may be freely deployed,
modified, and used by anyone at their own discretion.

IMPORTANT NOTICE.

Smart contracts are immutable once deployed and may contain bugs, vulnerabilities,
or unintended behaviors. By using, deploying, or interacting with this contract,
you acknowledge and accept all risks associated with its use.

NO WARRANTIES.

THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, AND NON-INFRINGEMENT.

There is no guarantee that this contract is free from defects, secure, or suitable
for any specific use case. Users are solely responsible for reviewing, testing,
auditing, and validating the contract before deployment or use.

SECURITY AND AUDITS.

It is the responsibility of any user or deployer of this contract to conduct
independent security audits and thorough testing. Do not rely on this code
without proper validation in your own environment.

LIMITATION OF LIABILITY.

IN NO EVENT SHALL ANY AUTHORS, CONTRIBUTORS, OR DISTRIBUTORS OF THIS SOFTWARE
BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER IN AN ACTION OF
CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

This includes, without limitation:
- Loss of funds
- Loss of data
- Business interruption
- Incorrect execution of transactions
- Exploits or attacks

USE AT YOUR OWN RISK.

By using this software, you agree that you understand the risks of blockchain-based
systems and accept full responsibility for any outcomes resulting from its use.

*****************
**/

interface IERC20 {
	function transferFrom(address from, address to, uint256 value) external returns (bool);
}

interface IOwnable {
	function owner() external view returns (address);
}

contract OpenClaiming {

	error InvalidSignature();
	error InvalidSignatureLength();
	error InvalidSignatureV();
	error InvalidSignatureS();
	error InvalidArrayLengths();
	error NotYetValid(uint256 nbf);
	error Expired(uint256 exp);
	error UnauthorizedLineOperator(address account, address caller);
	error LineNotOpen(address account, uint256 line);
	error PaymentLineMismatch(uint256 expected, uint256 actual);
	error RecipientsHashMismatch();
	error InvalidRecipient(address recipient);
	error ClaimMaxExceeded(uint256 requested, uint256 available);
	error LineMaxExceeded(uint256 requested, uint256 available);
	error InsufficientCapacity(uint256 requested, uint256 available);
	error TokenMismatch(address expected, address actual);
	error PayerMismatch(address expected, address actual);
	error NativeCoinDelegationUnsupported();
	error NativeCoinValueMismatch(uint256 expected, uint256 actual);
	error TransferFailed();

	bytes32 public constant VERSION_HASH = keccak256(bytes("1"));

	bytes32 public constant EIP712_DOMAIN_TYPEHASH =
		keccak256("EIP712Domain(string name,string version,uint256 chainId)");

	bytes32 public constant PAYMENT_TYPEHASH =
		keccak256(
			"Payment(address payer,address token,bytes32 recipientsHash,uint256 max,uint256 line,uint256 nbf,uint256 exp)"
		);

	bytes32 public constant PAYMENTS_NAME_HASH =
		keccak256(bytes("OpenClaiming.payments"));

	uint256 internal constant SECP256K1N_OVER_2 =
		0x7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a0;

	struct Line {
		uint256 max;
		uint256 spent;
		bool open;
	}

	struct Payment {
		address payer;
		address token;
		bytes32 recipientsHash;
		uint256 max;
		uint256 line;
		uint256 nbf;
		uint256 exp;
	}

	mapping(address => mapping(uint256 => Line)) public lines;

	event LineOpened(address indexed account, uint256 indexed line, uint256 max);
	event LineClosed(address indexed account, uint256 indexed line);
	event PaymentExecuted(address indexed payer,address indexed token,address indexed recipient,uint256 line,uint256 amount,uint256 newSpent);

	function lineOpen(address account, uint256 line, uint256 max) external {
		_requireLineOperator(account, msg.sender);
		lines[account][line].max = max;
		lines[account][line].open = true;
		emit LineOpened(account, line, max);
	}

	function lineClose(address account, uint256 line) external {
		_requireLineOperator(account, msg.sender);
		lines[account][line].open = false;
		emit LineClosed(account, line);
	}

	function executePayment(
		Payment calldata payment,
		address[] calldata recipients,
		bytes calldata signature,
		uint256 line,
		address recipient,
		uint256 amount
	) external payable returns (bool) {

		if (line != payment.line) revert PaymentLineMismatch(payment.line, line);
		if (keccak256(abi.encodePacked(recipients)) != payment.recipientsHash) revert RecipientsHashMismatch();

		bool allowed = false;
		for (uint i=0;i<recipients.length;i++) {
			if (recipients[i]==recipient) allowed = true;
		}
		if (!allowed) revert InvalidRecipient(recipient);

		Line storage l = lines[payment.payer][line];
		if (!l.open) revert LineNotOpen(payment.payer, line);

		uint256 claimRemaining = payment.max == 0 ? type(uint256).max : payment.max - l.spent;
		uint256 lineRemaining = l.max == 0 ? type(uint256).max : l.max - l.spent;
		uint256 available = claimRemaining < lineRemaining ? claimRemaining : lineRemaining;

		if (available < amount) revert ClaimMaxExceeded(amount, available);

		l.spent += amount;

		if (payment.token == address(0)) {
			if (msg.sender != payment.payer) revert NativeCoinDelegationUnsupported();
			if (msg.value != amount) revert NativeCoinValueMismatch(amount, msg.value);
			(bool ok,) = payable(recipient).call{value: amount}("");
			if (!ok) revert TransferFailed();
		} else {
			if (msg.value != 0) revert NativeCoinValueMismatch(0, msg.value);
			(bool ok, bytes memory data) = payment.token.call(
				abi.encodeWithSelector(IERC20.transferFrom.selector, payment.payer, recipient, amount)
			);
			if (!ok || (data.length != 0 && !abi.decode(data,(bool)))) revert TransferFailed();
		}

		emit PaymentExecuted(payment.payer,payment.token,recipient,line,amount,l.spent);
		return true;
	}

	function _requireLineOperator(address account, address caller) internal view {
		if (caller == account) return;
		try IOwnable(account).owner() returns (address o) {
			if (o == caller) return;
		} catch {}
		revert UnauthorizedLineOperator(account, caller);
	}
}
