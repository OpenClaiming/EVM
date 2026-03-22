// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
*****************
DISCLAIMER
*****************
... (unchanged)
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

	error NotYetValid(uint256 nbf);
	error Expired(uint256 exp);

	error UnauthorizedLineOperator(address account, address caller);
	error LineNotOpen(address account, uint256 line);
	error PaymentLineMismatch(uint256 expected, uint256 actual);
	error PaymentRecipientsHashMismatch();
	error InvalidRecipient(address recipient);
	error ClaimMaxExceeded(uint256 requested, uint256 available);
	error LineMaxExceeded(uint256 requested, uint256 available);
	error InsufficientCapacity(uint256 requested, uint256 available);
	error PayerMismatch(address expected, address actual);
	error NativeCoinDelegationUnsupported();
	error NativeCoinValueMismatch(uint256 expected, uint256 actual);
	error TransferFailed();

	error AuthorizationActorsHashMismatch();
	error AuthorizationRolesHashMismatch();
	error AuthorizationActionsHashMismatch();
	error AuthorizationConstraintsHashMismatch();
	error AuthorizationContextsHashMismatch();
	error AuthorizationAuthorityMismatch(address expected, address actual);

	bytes32 public constant VERSION_HASH = keccak256(bytes("1"));

	bytes32 public constant EIP712_DOMAIN_TYPEHASH =
		keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

	bytes32 public constant PAYMENT_TYPEHASH =
		keccak256(
			"Payment(address payer,address token,bytes32 recipientsHash,uint256 max,uint256 line,uint256 nbf,uint256 exp)"
		);

	bytes32 public constant PAYMENTS_NAME_HASH =
		keccak256(bytes("OpenClaiming.payments"));

	bytes32 public constant AUTHORIZATION_TYPEHASH =
		keccak256(
			"Authorization(address authority,address subject,bytes32 actorsHash,bytes32 rolesHash,bytes32 actionsHash,bytes32 constraintsHash,bytes32 contextsHash,uint256 nbf,uint256 exp)"
		);

	bytes32 public constant AUTHORIZATION_CONSTRAINT_TYPEHASH =
		keccak256("Constraint(string key,string op,string value)");

	bytes32 public constant AUTHORIZATION_CONTEXT_TYPEHASH =
		keccak256("Context(string type,string value)");

	bytes32 public constant AUTHORIZATIONS_NAME_HASH =
		keccak256(bytes("OpenClaiming.authorizations"));

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

	struct Authorization {
		address authority;
		address subject;
		bytes32 actorsHash;
		bytes32 rolesHash;
		bytes32 actionsHash;
		bytes32 constraintsHash;
		bytes32 contextsHash;
		uint256 nbf;
		uint256 exp;
	}

	struct AuthorizationConstraint {
		string key;
		string op;
		string value;
	}

	struct AuthorizationContext {
		string typ;
		string value;
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

	function recoverSigner(bytes32 digest, bytes calldata signature) public pure returns (address) {
		if (signature.length != 65) revert InvalidSignatureLength();

		bytes32 r;
		bytes32 s;
		uint8 v;

		assembly {
			r := calldataload(signature.offset)
			s := calldataload(add(signature.offset, 32))
			v := byte(0, calldataload(add(signature.offset, 64)))
		}

		if (uint256(s) > SECP256K1N_OVER_2) revert InvalidSignatureS();

		if (v == 0 || v == 1) v += 27;
		if (v != 27 && v != 28) revert InvalidSignatureV();

		address signer = ecrecover(digest, v, r, s);
		if (signer == address(0)) revert InvalidSignature();

		return signer;
	}

	function verify(bytes32 digest, bytes calldata signature, address expectedSigner) public pure returns (bool) {
		return recoverSigner(digest, signature) == expectedSigner;
	}

	// ================= PAYMENT =================

	function paymentDomainSeparator() public view returns (bytes32) {
		return keccak256(
			abi.encode(
				EIP712_DOMAIN_TYPEHASH,
				PAYMENTS_NAME_HASH,
				VERSION_HASH,
				block.chainid,
				address(this)
			)
		);
	}
	
	function verifySignatures(
		bytes32 digest,
		address[] calldata signers,
		bytes[] calldata signatures,
		uint256 minValid
	) public pure returns (bool) {

		if (signers.length != signatures.length) return false;

		uint256 valid = 0;

		// naive dedup (O(n^2), fine for small N)
		for (uint256 i = 0; i < signers.length; i++) {

			address signer = signers[i];
			bytes calldata sig = signatures[i];

			if (signer == address(0)) continue;
			if (sig.length == 0) continue;

			// dedupe check
			bool duplicate = false;
			for (uint256 j = 0; j < i; j++) {
				if (signers[j] == signer) {
					duplicate = true;
					break;
				}
			}
			if (duplicate) continue;

			address recovered = recoverSigner(digest, sig);

			if (recovered == signer) {
				valid++;
				if (valid >= minValid) return true;
			}
		}

		if (minValid == 0) {
			return false;
		}
		return valid >= minValid;
	}

	function paymentHashRecipients(address[] calldata recipients) public pure returns (bytes32) {
		return keccak256(abi.encode(recipients));
	}

	function paymentHash(Payment calldata p) public pure returns (bytes32) {
		return keccak256(
			abi.encode(
				PAYMENT_TYPEHASH,
				p.payer,
				p.token,
				p.recipientsHash,
				p.max,
				p.line,
				p.nbf,
				p.exp
			)
		);
	}

	function paymentDigest(Payment calldata p) public view returns (bytes32) {
		return keccak256(abi.encodePacked("\x19\x01", paymentDomainSeparator(), paymentHash(p)));
	}

	function paymentRecoverSigner(Payment calldata p, bytes calldata sig) public view returns (address) {
		return recoverSigner(paymentDigest(p), sig);
	}

	function paymentVerify(
		Payment calldata p,
		address[] calldata recipients,
		bytes calldata sig,
		uint256 line,
		address recipient,
		uint256 amount
	) public view returns (bool) {
		_paymentValidate(p, recipients, sig, line, recipient, amount);
		return true;
	}
	
	function paymentVerifySignatures(
		Payment calldata p,
		address[] calldata recipients,
		uint256 line,
		address recipient,
		uint256 amount,
		address[] calldata signers,
		bytes[] calldata signatures,
		uint256 minValid
	) public view returns (bool) {

		_paymentValidateCore(p, recipients, line, recipient, amount);

		if (!verifySignatures(paymentDigest(p), signers, signatures, minValid)) {
			return false;
		}

		return true;
	}

	function paymentExecute(
		Payment calldata p,
		address[] calldata recipients,
		bytes calldata sig,
		uint256 line,
		address recipient,
		uint256 amount
	) public payable returns (bool) {
		_paymentValidate(p, recipients, sig, line, recipient, amount);

		Line storage l = lines[p.payer][line];
		l.spent += amount;

		if (p.token == address(0)) {
			if (msg.sender != p.payer) revert NativeCoinDelegationUnsupported();
			if (msg.value != amount) revert NativeCoinValueMismatch(amount, msg.value);
			(bool ok,) = payable(recipient).call{value: amount}("");
			if (!ok) revert TransferFailed();
		} else {
			if (msg.value != 0) revert NativeCoinValueMismatch(0, msg.value);
			(bool ok, bytes memory data) = p.token.call(
				abi.encodeWithSelector(IERC20.transferFrom.selector, p.payer, recipient, amount)
			);
			if (!ok || (data.length != 0 && !abi.decode(data,(bool)))) revert TransferFailed();
		}

		emit PaymentExecuted(p.payer,p.token,recipient,line,amount,l.spent);
		return true;
	}
	
	function paymentExecuteSignatures(
		Payment calldata p,
		address[] calldata recipients,
		uint256 line,
		address recipient,
		uint256 amount,
		address[] calldata signers,
		bytes[] calldata signatures,
		uint256 minValid
	) public payable returns (bool) {

		require(
			paymentVerifySignatures(p, recipients, line, recipient, amount, signers, signatures, minValid),
			"Invalid signatures"
		);

		Line storage l = lines[p.payer][line];
		l.spent += amount;

		if (p.token == address(0)) {
			if (msg.sender != p.payer) revert NativeCoinDelegationUnsupported();
			if (msg.value != amount) revert NativeCoinValueMismatch(amount, msg.value);

			(bool ok,) = payable(recipient).call{value: amount}("");
			if (!ok) revert TransferFailed();
		} else {
			if (msg.value != 0) revert NativeCoinValueMismatch(0, msg.value);

			(bool ok, bytes memory data) = p.token.call(
				abi.encodeWithSelector(IERC20.transferFrom.selector, p.payer, recipient, amount)
			);

			if (!ok || (data.length != 0 && !abi.decode(data,(bool)))) revert TransferFailed();
		}

		emit PaymentExecuted(p.payer,p.token,recipient,line,amount,l.spent);
		return true;
	}

	// ================= AUTHORIZATION =================

	function authorizationDomainSeparator() public view returns (bytes32) {
		return keccak256(
			abi.encode(
				EIP712_DOMAIN_TYPEHASH,
				AUTHORIZATIONS_NAME_HASH,
				VERSION_HASH,
				block.chainid,
				address(this)
			)
		);
	}

	function authorizationHashActors(address[] calldata actors) public pure returns (bytes32) {
		return keccak256(abi.encode(actors));
	}

	function authorizationHashRoles(string[] calldata roles) public pure returns (bytes32) {
		return _hashStringArray(roles);
	}

	function authorizationHashActions(string[] calldata actions) public pure returns (bytes32) {
		return _hashStringArray(actions);
	}

	function authorizationHashConstraints(
		AuthorizationConstraint[] calldata constraints
	) public pure returns (bytes32) {
		bytes32[] memory hashes = new bytes32[](constraints.length);

		for (uint256 i = 0; i < constraints.length; i++) {
			hashes[i] = keccak256(
				abi.encode(
					AUTHORIZATION_CONSTRAINT_TYPEHASH,
					keccak256(bytes(constraints[i].key)),
					keccak256(bytes(constraints[i].op)),
					keccak256(bytes(constraints[i].value))
				)
			);
		}

		return keccak256(abi.encode(hashes));
	}

	function authorizationHashContexts(
		AuthorizationContext[] calldata contexts
	) public pure returns (bytes32) {
		bytes32[] memory hashes = new bytes32[](contexts.length);

		for (uint256 i = 0; i < contexts.length; i++) {
			hashes[i] = keccak256(
				abi.encode(
					AUTHORIZATION_CONTEXT_TYPEHASH,
					keccak256(bytes(contexts[i].typ)),
					keccak256(bytes(contexts[i].value))
				)
			);
		}

		return keccak256(abi.encode(hashes));
	}

	function authorizationHash(Authorization calldata a) public pure returns (bytes32) {
		return keccak256(
			abi.encode(
				AUTHORIZATION_TYPEHASH,
				a.authority,
				a.subject,
				a.actorsHash,
				a.rolesHash,
				a.actionsHash,
				a.constraintsHash,
				a.contextsHash,
				a.nbf,
				a.exp
			)
		);
	}

	function authorizationDigest(Authorization calldata a) public view returns (bytes32) {
		return keccak256(
			abi.encodePacked("\x19\x01", authorizationDomainSeparator(), authorizationHash(a))
		);
	}

	function authorizationRecoverSigner(Authorization calldata a, bytes calldata sig) public view returns (address) {
		return recoverSigner(authorizationDigest(a), sig);
	}

	function authorizationVerify(Authorization calldata a, bytes calldata sig) public view returns (bool) {
		_authorizationValidate(a, sig);
		return true;
	}

	function authorizationVerifyWithData(
		Authorization calldata a,
		bytes calldata sig,
		address[] calldata actors,
		string[] calldata roles,
		string[] calldata actions,
		AuthorizationConstraint[] calldata constraints,
		AuthorizationContext[] calldata contexts
	) public view returns (bool) {

		if (authorizationHashActors(actors) != a.actorsHash) revert AuthorizationActorsHashMismatch();
		if (authorizationHashRoles(roles) != a.rolesHash) revert AuthorizationRolesHashMismatch();
		if (authorizationHashActions(actions) != a.actionsHash) revert AuthorizationActionsHashMismatch();
		if (authorizationHashConstraints(constraints) != a.constraintsHash) revert AuthorizationConstraintsHashMismatch();
		if (authorizationHashContexts(contexts) != a.contextsHash) revert AuthorizationContextsHashMismatch();

		_authorizationValidate(a, sig);
		return true;
	}
	
	function authorizationVerifySignatures(
		Authorization calldata a,
		address[] calldata signers,
		bytes[] calldata signatures,
		uint256 minValid
	) public view returns (bool) {

		if (a.nbf != 0 && block.timestamp < a.nbf) revert NotYetValid(a.nbf);
		if (a.exp != 0 && block.timestamp > a.exp) revert Expired(a.exp);

		if (!verifySignatures(authorizationDigest(a), signers, signatures, minValid)) {
			return false;
		}

		return true;
	}

	// ================= INTERNAL =================

	function _paymentValidate(
		Payment calldata p,
		address[] calldata recipients,
		bytes calldata sig,
		uint256 line,
		address recipient,
		uint256 amount
	) internal view {

		_paymentValidateCore(p, recipients, line, recipient, amount);

		address signer = paymentRecoverSigner(p, sig);
		if (signer != p.payer) revert PayerMismatch(p.payer, signer);
	}
	
	function _paymentValidateCore(
		Payment calldata p,
		address[] calldata recipients,
		uint256 line,
		address recipient,
		uint256 amount
	) internal view {

		if (line != p.line) revert PaymentLineMismatch(p.line, line);
		if (p.nbf != 0 && block.timestamp < p.nbf) revert NotYetValid(p.nbf);
		if (p.exp != 0 && block.timestamp > p.exp) revert Expired(p.exp);

		if (paymentHashRecipients(recipients) != p.recipientsHash) {
			revert PaymentRecipientsHashMismatch();
		}

		bool allowed = false;
		for (uint256 i = 0; i < recipients.length; i++) {
			if (recipients[i] == recipient) {
				allowed = true;
				break;
			}
		}
		if (!allowed) revert InvalidRecipient(recipient);

		Line storage l = lines[p.payer][line];
		if (!l.open) revert LineNotOpen(p.payer, line);

		uint256 claimRemaining = p.max == 0
			? type(uint256).max
			: (l.spent >= p.max ? 0 : p.max - l.spent);

		uint256 lineRemaining = l.max == 0
			? type(uint256).max
			: (l.spent >= l.max ? 0 : l.max - l.spent);
			
		uint256 available = claimRemaining < lineRemaining ? claimRemaining : lineRemaining;
		if (available < amount) revert InsufficientCapacity(amount, available);

		if (claimRemaining < amount) revert ClaimMaxExceeded(amount, claimRemaining);
		if (lineRemaining < amount) revert LineMaxExceeded(amount, lineRemaining);
	}

	function _authorizationValidate(Authorization calldata a, bytes calldata sig) internal view {
		if (a.nbf != 0 && block.timestamp < a.nbf) revert NotYetValid(a.nbf);
		if (a.exp != 0 && block.timestamp > a.exp) revert Expired(a.exp);

		address signer = authorizationRecoverSigner(a, sig);
		if (signer != a.authority) revert AuthorizationAuthorityMismatch(a.authority, signer);
	}

	function _hashStringArray(string[] calldata values) internal pure returns (bytes32) {
		bytes32[] memory hashes = new bytes32[](values.length);

		for (uint256 i = 0; i < values.length; i++) {
			hashes[i] = keccak256(bytes(values[i]));
		}

		return keccak256(abi.encode(hashes));
	}

	function _requireLineOperator(address account, address caller) internal view {
		if (caller == account) return;

		try IOwnable(account).owner() returns (address o) {
			if (o == caller) return;
		} catch {}

		revert UnauthorizedLineOperator(account, caller);
	}
}