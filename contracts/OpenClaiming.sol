// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
*********************************************
OFFICIAL OPENCLAIMING PROTOCOL IMPLEMENTATION
*********************************************

Although this code is available for viewing on GitHub and here, the general public is NOT given a license to freely deploy smart contracts based on this code, on any blockchains.
To prevent confusion and increase trust in the audited code bases of smart contracts we produce, we intend for there to be only ONE official Factory address on the blockchain producing the corresponding smart contracts, and we are going to point a blockchain domain name at it.
Copyright (c) Intercoin Inc. All rights reserved.

ALLOWED USAGE.
Provided they agree to all the conditions of this Agreement listed below, anyone is welcome to interact with the official Factory Contract at the this address to produce smart contract instances, or to interact with instances produced in this manner by others.
Any user of software powered by this code MUST agree to the following, in order to use it. If you do not agree, refrain from using the software:

DISCLAIMERS AND DISCLOSURES.
Customer expressly recognizes that nearly any software may contain unforeseen bugs or other defects, due to the nature of software development. Moreover, because of the immutable nature of smart contracts, any such defects will persist in the software once it is deployed onto the blockchain. Customer therefore expressly acknowledges that any responsibility to obtain outside audits and analysis of any software produced by Developer rests solely with Customer.
Customer understands and acknowledges that the Software is being delivered as-is, and may contain potential defects. While Developer and its staff and partners have exercised care and best efforts in an attempt to produce solid, working software products, Developer EXPRESSLY DISCLAIMS MAKING ANY GUARANTEES, REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED, ABOUT THE FITNESS OF THE SOFTWARE, INCLUDING LACK OF DEFECTS, MERCHANTABILITY OR SUITABILITY FOR A PARTICULAR PURPOSE.
Customer agrees that neither Developer nor any other party has made any representations or warranties, nor has the Customer relied on any representations or warranties, express or implied, including any implied warranty of merchantability or fitness for any particular purpose with respect to the Software. Customer acknowledges that no affirmation of fact or statement (whether written or oral) made by Developer, its representatives, or any other party outside of this Agreement with respect to the Software shall be deemed to create any express or implied warranty on the part of Developer or its representatives.

INDEMNIFICATION.
Customer agrees to indemnify, defend and hold Developer and its officers, directors, employees, agents and contractors harmless from any loss, cost, expense (including attorney's fees and expenses), associated with or related to any demand, claim, liability, damages or cause of action of any kind or character (collectively referred to as "claim"), in any manner arising out of or relating to any third party demand, dispute, mediation, arbitration, litigation, or any violation or breach of any provision of this Agreement by Customer.
NO WARRANTY.
THE SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY. DEVELOPER SHALL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, SPECIAL, INCIDENTAL, CONSEQUENTIAL, OR EXEMPLARY DAMAGES FOR BREACH OF THE LIMITED WARRANTY. TO THE MAXIMUM EXTENT PERMITTED BY LAW, DEVELOPER EXPRESSLY DISCLAIMS, AND CUSTOMER EXPRESSLY WAIVES, ALL OTHER WARRANTIES, WHETHER EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT LIMITATION ALL IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE OR USE, OR ANY WARRANTY ARISING OUT OF ANY PROPOSAL, SPECIFICATION, OR SAMPLE, AS WELL AS ANY WARRANTIES THAT THE SOFTWARE (OR ANY ELEMENTS THEREOF) WILL ACHIEVE A PARTICULAR RESULT, OR WILL BE UNINTERRUPTED OR ERROR-FREE. THE TERM OF ANY IMPLIED WARRANTIES THAT CANNOT BE DISCLAIMED UNDER APPLICABLE LAW SHALL BE LIMITED TO THE DURATION OF THE FOREGOING EXPRESS WARRANTY PERIOD. SOME STATES DO NOT ALLOW THE EXCLUSION OF IMPLIED WARRANTIES AND/OR DO NOT ALLOW LIMITATIONS ON THE AMOUNT OF TIME AN IMPLIED WARRANTY LASTS, SO THE ABOVE LIMITATIONS MAY NOT APPLY TO CUSTOMER. THIS LIMITED WARRANTY GIVES CUSTOMER SPECIFIC LEGAL RIGHTS. CUSTOMER MAY HAVE OTHER RIGHTS WHICH VARY FROM STATE TO STATE.

LIMITATION OF LIABILITY.
TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT SHALL DEVELOPER BE LIABLE UNDER ANY THEORY OF LIABILITY FOR ANY CONSEQUENTIAL, INDIRECT, INCIDENTAL, SPECIAL, PUNITIVE OR EXEMPLARY DAMAGES OF ANY KIND, INCLUDING, WITHOUT LIMITATION, DAMAGES ARISING FROM LOSS OF PROFITS, REVENUE, DATA OR USE, OR FROM INTERRUPTED COMMUNICATIONS OR DAMAGED DATA, OR FROM ANY DEFECT OR ERROR OR IN CONNECTION WITH CUSTOMER'S ACQUISITION OF SUBSTITUTE GOODS OR SERVICES OR MALFUNCTION OF THE SOFTWARE, OR ANY SUCH DAMAGES ARISING FROM BREACH OF CONTRACT OR WARRANTY OR FROM NEGLIGENCE OR STRICT LIABILITY, EVEN IF DEVELOPER OR ANY OTHER PERSON HAS BEEN ADVISED OR SHOULD KNOW OF THE POSSIBILITY OF SUCH DAMAGES, AND NOTWITHSTANDING THE FAILURE OF ANY REMEDY TO ACHIEVE ITS INTENDED PURPOSE. WITHOUT LIMITING THE FOREGOING OR ANY OTHER LIMITATION OF LIABILITY HEREIN, REGARDLESS OF THE FORM OF ACTION, WHETHER FOR BREACH OF CONTRACT, WARRANTY, NEGLIGENCE, STRICT LIABILITY IN TORT OR OTHERWISE, CUSTOMER'S EXCLUSIVE REMEDY AND THE TOTAL LIABILITY OF DEVELOPER OR ANY SUPPLIER OF SERVICES TO DEVELOPER FOR ANY CLAIMS ARISING IN ANY WAY IN CONNECTION WITH OR RELATED TO THIS AGREEMENT, THE SOFTWARE, FOR ANY CAUSE WHATSOEVER, SHALL NOT EXCEED 1,000 USD.

TRADEMARKS.
This Agreement does not grant you any right in any trademark or logo of Developer or its affiliates.

LINK REQUIREMENTS.
Operators of any Websites and Apps which make use of smart contracts based on this code must conspicuously include the following phrase in their website, featuring a clickable link that takes users to intercoin.app:
"Visit https://intercoin.app to launch your own NFTs, DAOs and other Web3 solutions."

STAKING OR SPENDING REQUIREMENTS.
In the future, Developer may begin requiring staking or spending of Intercoin tokens in order to take further actions (such as producing series and minting tokens). Any staking or spending requirements will first be announced on Developer's website (intercoin.org) four weeks in advance. Staking requirements will not apply to any actions already taken before they are put in place.

CUSTOM ARRANGEMENTS.
Reach out to us at intercoin.org if you are looking to obtain Intercoin tokens in bulk, remove link requirements forever, remove staking requirements forever, or get custom work done with your Web3 projects.

ENTIRE AGREEMENT
This Agreement contains the entire agreement and understanding among the parties hereto with respect to the subject matter hereof, and supersedes all prior and contemporaneous agreements, understandings, inducements and conditions, express or implied, oral or written, of any nature whatsoever with respect to the subject matter hereof. The express terms hereof control and supersede any course of performance and/or usage of the trade inconsistent with any of the terms hereof. Provisions from previous Agreements executed between Customer and Developer., which are not expressly dealt with in this Agreement, will remain in effect.

SUCCESSORS AND ASSIGNS
This Agreement shall continue to apply to any successors or assigns of either party, or any corporation or other entity acquiring all or substantially all the assets and business of either party whether by operation of law or otherwise.

ARBITRATION
All disputes related to this agreement shall be governed by and interpreted in accordance with the laws of New York, without regard to principles of conflict of laws. The parties to this agreement will submit all disputes arising under this agreement to arbitration in New York City, New York before a single arbitrator of the American Arbitration Association ("AAA"). The arbitrator shall be selected by application of the rules of the AAA, or by mutual agreement of the parties, except that such arbitrator shall be an attorney admitted to practice law New York. No party to this agreement will challenge the jurisdiction or venue provisions as provided in this section. No party to this agreement will challenge the jurisdiction or venue provisions as provided in this section.
**/

/**
 * @title OpenClaiming
 * @author Intercoin Inc.
 * @notice Canonical EIP-712 verifier and execution layer for the OpenClaiming Protocol v1.
 *
 * @dev Deployed at 0x99996a51cc950d9822D68b83fE1Ad97B32Cd9999 on all supported chains.
 *      This contract is not upgradeable. Immutable deployment.
 *
 * ─────────────────────────────────────────────────────────────────────────────
 * OVERVIEW
 * ─────────────────────────────────────────────────────────────────────────────
 *
 * OpenClaiming provides two standard on-chain extensions:
 *
 *   payments  — Authorizes ERC-20 or native coin transfers. The payer signs a
 *               Payment struct off-chain. The contract verifies the signature,
 *               enforces the line cap, and executes the transfer.
 *
 *   actions   — Authorizes ControlContract.invoke() + endorse() flows. Multiple
 *               signers each sign the same Action struct off-chain. The contract
 *               verifies all signatures, then forwards invoke() as the invoker
 *               and endorse() as each valid signer via EIP-2771.
 *
 * ─────────────────────────────────────────────────────────────────────────────
 * DEFAULT LINE (line 0)
 * ─────────────────────────────────────────────────────────────────────────────
 *
 * Line 0 is the implicit default line. It is ALWAYS open and has an unlimited
 * ceiling (max = 0). No call to lineOpen() is required to use line 0.
 *
 * Payment claims that use line 0 draw directly on the payer's ERC-20 balance
 * and the ERC-20 allowance the payer has granted to this contract. The contract
 * imposes no additional cap beyond the per-claim max field.
 *
 * Issuers who need budget isolation can open explicit named lines (line >= 1)
 * via lineOpen() with a specific max. All lines — including line 0 — draw
 * from the same underlying token balance; they are accounting buckets, not
 * separate balances.
 *
 * Off-chain systems (Jets, Drops) independently pre-screen payer balances and
 * ERC-20 allowances before accepting payment tokens, caching results in memory
 * (default TTL: 1 hour). The definitive check is always on-chain at execution.
 *
 * ─────────────────────────────────────────────────────────────────────────────
 * EIP-712 MULTISIGNATURE MODEL
 * ─────────────────────────────────────────────────────────────────────────────
 *
 * All signers sign the SAME EIP-712 digest. The digest is determined entirely
 * by the typed struct — it does not change based on the number of signers.
 * Multisig is layered on top: the contract receives parallel signers[] and
 * signatures[] arrays, verifies each sig[i] against signers[i] over the shared
 * digest, deduplicates by address, and counts unique valid signatures.
 *
 * This is fully EIP-712 compliant. Wallets (MetaMask, etc.) can display the
 * typed data for human review before signing, regardless of how many co-signers
 * are involved.
 *
 * ─────────────────────────────────────────────────────────────────────────────
 * TRUST MODEL — EIP-2771 FORWARDING
 * ─────────────────────────────────────────────────────────────────────────────
 *
 * For actions, this contract calls ControlContract and IncomeContract on behalf
 * of human signers. It does this via EIP-2771: the signer's address is appended
 * as the last 20 bytes of calldata. The target contract's _msgSender() strips
 * those bytes and returns the signer address rather than address(this).
 *
 * REQUIREMENT: OpenClaiming must be registered as TrustedForwarder on any
 * ControlContract or IncomeContract it interacts with. Deployers set this via
 * the `trustedForwarder` parameter in those contracts' initializers.
 *
 * This allows Community role checks in ControlContract and manager checks in
 * IncomeContract to resolve to the actual human signer, preserving the on-chain
 * governance invariants.
 *
 * ─────────────────────────────────────────────────────────────────────────────
 * LINE ACCOUNTING
 * ─────────────────────────────────────────────────────────────────────────────
 *
 * Payment lines are tracked as: lines[payer][lineId] → { max, spent, open }
 *
 * Line 0 is always open with unlimited max (see DEFAULT LINE above).
 * Lines >= 1 must be opened via lineOpen() before use.
 *
 * The claim's `max` field is a per-claim ceiling; the line's `max` is an
 * overall ceiling. Both are enforced independently. Setting either to 0
 * means unlimited at that level.
 *
 * ─────────────────────────────────────────────────────────────────────────────
 * REQUIRED CHANGES IN DEPENDENT CONTRACTS
 * ─────────────────────────────────────────────────────────────────────────────
 *
 * ControlContract:
 *   - init() must accept address trustedForwarder and call _setTrustedForwarder()
 *   - generateInvokeID() must use _msgSender() not msg.sender
 *   - invoke(), endorse(), heartbeat() must use _msgSender() throughout
 *
 * IncomeContract:
 *   - __IncomeContract_init() must accept address trustedForwarder
 *   - pay() already uses _msgSender() via canManage modifier — verify throughout
 *   - Deployer must call addManager(recipient, payerAddress) before payment
 *     claims can execute via the IncomeContract path
 */

// ---------- Minimal interfaces ----------

/// @dev Minimal ERC-20 interface — only transferFrom is needed.
interface IERC20 {
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

/// @dev Used to check whether a caller is the owner of a payer account,
///      allowing the owner to open/close lines on behalf of the account.
interface IOwnable {
    function owner() external view returns (address);
}

/// @dev IncomeContract interface for the managed payment path.
///      pay() is called forwarded as the payer via EIP-2771.
interface IIncomeContract {
    function pay(address recipient, uint256 amount) external;
}

/// @dev ControlContract interface for the actions execution path.
///      Both invoke() and endorse() are called forwarded as human signers
///      via EIP-2771 so Community role checks resolve to the actual signer.
interface IControlContract {
    function invoke(
        address contractAddress,
        string  calldata method,
        string  calldata params,
        uint256 minimum,
        uint256 fraction,
        uint64  delay
    ) external returns (uint256 invokeID, uint40 invokeIDWei);

    function endorse(uint256 invokeID) external;
}

// ---------- Main contract ----------

contract OpenClaiming {

    // ─────────────────────────────────────────────────────────────────────────
    // Errors
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Signature is cryptographically invalid (ecrecover returned zero
    ///         or the recovered address does not match the expected signer).
    error InvalidSignature();

    /// @notice Signature is not exactly 65 bytes (r || s || v).
    error InvalidSignatureLength();

    /// @notice Signature v byte is not 27 or 28 (after normalisation from 0/1).
    error InvalidSignatureV();

    /// @notice Signature s value exceeds secp256k1n/2, violating low-s
    ///         canonicality (EIP-2). Prevents signature malleability.
    error InvalidSignatureS();

    /// @notice block.timestamp is before the claim's nbf (not-before) field.
    /// @param nbf The earliest timestamp at which the claim becomes valid.
    error NotYetValid(uint256 nbf);

    /// @notice block.timestamp is after the claim's exp (expiry) field.
    /// @param exp The timestamp at which the claim expired.
    error Expired(uint256 exp);

    /// @notice Caller is not authorised to open or close lines for this account.
    ///         Only the account itself or its Ownable owner may manage lines.
    /// @param account The account whose line was being managed.
    /// @param caller  The address that attempted the operation.
    error UnauthorizedLineOperator(address account, address caller);

    /// @notice The payment line has not been opened. Call lineOpen() first.
    ///         Note: line 0 (DEFAULT_LINE) is always open and never raises this error.
    /// @param account The payer address.
    /// @param line    The line id.
    error LineNotOpen(address account, uint256 line);

    /// @notice The recipients array passed to execute does not hash to the
    ///         recipientsHash committed in the Payment struct.
    error PaymentRecipientsHashMismatch();

    /// @notice The chosen recipient is not in the authorised recipients set.
    /// @param recipient The address that was rejected.
    error InvalidRecipient(address recipient);

    /// @notice The requested amount exceeds what the claim's max field allows
    ///         given the line's current spent total.
    /// @param requested Amount requested.
    /// @param available Amount available under the claim ceiling.
    error ClaimMaxExceeded(uint256 requested, uint256 available);

    /// @notice The requested amount exceeds what the line's max field allows.
    /// @param requested Amount requested.
    /// @param available Amount available under the line ceiling.
    error LineMaxExceeded(uint256 requested, uint256 available);

    /// @notice The requested amount exceeds the combined available capacity
    ///         (minimum of claim remaining and line remaining).
    /// @param requested Amount requested.
    /// @param available Combined available capacity.
    error InsufficientCapacity(uint256 requested, uint256 available);

    /// @notice The address recovered from the payment signature does not match
    ///         the payer declared in the Payment struct.
    /// @param expected p.payer
    /// @param actual   Recovered signer address.
    error PayerMismatch(address expected, address actual);

    /// @notice Native coin payments cannot be delegated — msg.sender must be
    ///         p.payer when token == address(0).
    error NativeCoinDelegationUnsupported();

    /// @notice msg.value does not match the expected native coin amount.
    /// @param expected Required msg.value.
    /// @param actual   Received msg.value.
    error NativeCoinValueMismatch(uint256 expected, uint256 actual);

    /// @notice An ERC-20 transferFrom or native coin transfer failed.
    error TransferFailed();

    /// @notice The invoker address passed to actionsExecute was not found
    ///         among the verified signers.
    error InvokerNotInSigners();

    /// @notice signers[] and signatures[] have mismatched lengths, or the
    ///         array is empty.
    error InvalidSignerCount();

    /// @notice The keccak256 hash of the params bytes passed to actionsExecute
    ///         does not match the paramsHash committed in the Action struct.
    error ParamsHashMismatch();

    // ─────────────────────────────────────────────────────────────────────────
    // EIP-712 constants
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice keccak256("1") — version component of all domain separators.
    bytes32 public constant VERSION_HASH = keccak256(bytes("1"));

    /// @notice Standard EIP-712 domain type hash used in both domain separators.
    bytes32 public constant EIP712_DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    // payments extension

    /// @notice keccak256("OpenClaiming.payments") — name component of the
    ///         payments domain separator.
    bytes32 public constant PAYMENTS_NAME_HASH =
        keccak256(bytes("OpenClaiming.payments"));

    /// @notice EIP-712 type hash for the Payment struct.
    ///         Must match exactly in off-chain signers (JS/PHP) and on-chain.
    bytes32 public constant PAYMENTS_TYPEHASH =
        keccak256(
            "Payment(address payer,address token,bytes32 recipientsHash,uint256 max,uint256 line,uint256 nbf,uint256 exp)"
        );

    // actions extension

    /// @notice keccak256("OpenClaiming.actions") — name component of the
    ///         actions domain separator.
    bytes32 public constant ACTIONS_NAME_HASH =
        keccak256(bytes("OpenClaiming.actions"));

    /// @notice EIP-712 type hash for the Action struct.
    ///         Must match exactly in off-chain signers (JS/PHP) and on-chain.
    bytes32 public constant ACTIONS_TYPEHASH =
        keccak256(
            "Action(address authority,address subject,address contractAddress,bytes4 method,bytes32 paramsHash,uint256 minimum,uint256 fraction,uint256 delay,uint256 nbf,uint256 exp)"
        );

    // messages extension

    /// @notice keccak256("OpenClaiming.messages") — name component of the
    ///         messages domain separator.
    bytes32 public constant MESSAGES_NAME_HASH =
        keccak256(bytes("OpenClaiming.messages"));

    /// @notice EIP-712 type hash for the MessageAssociation struct.
    ///         Must match exactly in off-chain signers (JS/PHP) and on-chain.
    bytes32 public constant MESSAGES_TYPEHASH =
        keccak256(
            "MessageAssociation(address account,bytes32 endpointType,bytes32 commitment)"
        );

    /// @dev secp256k1 curve order divided by 2. Signatures with s > this value
    ///      are rejected to enforce low-s canonicality and prevent malleability.
    uint256 internal constant SECP256K1N_OVER_2 =
        0x7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a0;

    // ─────────────────────────────────────────────────────────────────────────
    // Default line
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice The default line ID (line 0).
    ///
    /// @dev Line 0 is always open and has an unlimited ceiling (max = 0).
    ///      No call to lineOpen() is required to use it.
    ///
    ///      Payment claims using line 0 draw directly on the payer's:
    ///        - ERC-20 balance
    ///        - ERC-20 allowance granted to this contract
    ///
    ///      The contract imposes no additional cap beyond the per-claim max.
    ///
    ///      Lines >= 1 are optional budget-isolation buckets opened via lineOpen().
    ///      All lines share the same underlying token balance.
    uint256 public constant DEFAULT_LINE = 0;

    // ─────────────────────────────────────────────────────────────────────────
    // Structs
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Tracks spending against an explicit payment line (line >= 1).
    ///
    /// @dev Line 0 is implicit and not stored here; it is always open with
    ///      unlimited max. The spent counter for line 0 IS stored in the
    ///      mapping at lines[payer][0] to enforce per-claim max ceilings —
    ///      only the open flag is ignored for line 0.
    ///
    /// @param max   Overall ceiling for this line. 0 = unlimited.
    /// @param spent Running total of all amounts paid out on this line.
    /// @param open  Whether the line is currently accepting payments.
    ///              Always treated as true for line 0.
    struct Line {
        uint256 max;
        uint256 spent;
        bool    open;
    }

    /// @notice EIP-712 typed struct for a payment authorization.
    ///
    /// @param payer          Address whose tokens will be transferred.
    /// @param token          ERC-20 token address. address(0) = native coin.
    /// @param recipientsHash keccak256(abi.encode(address[])) of the authorised
    ///                       recipient set. Commits the payer to a specific set
    ///                       of addresses without storing them on-chain.
    /// @param max            Claim-level spending ceiling. 0 = unlimited.
    ///                       Combined with the line's own max; the lower wins.
    /// @param line           Trustline bucket id.
    ///                       Use 0 (DEFAULT_LINE) for the always-open default line,
    ///                       which draws on the payer's full token balance with no
    ///                       contract-level cap beyond this claim's max.
    ///                       Use >= 1 for explicitly budget-capped lines opened via
    ///                       lineOpen(). All lines draw from the same token balance.
    /// @param nbf            Unix timestamp before which the claim is invalid.
    ///                       0 = no lower bound.
    /// @param exp            Unix timestamp after which the claim is invalid.
    ///                       0 = no expiry.
    struct Payment {
        address payer;
        address token;
        bytes32 recipientsHash;
        uint256 max;
        uint256 line;
        uint256 nbf;
        uint256 exp;
    }

    /// @notice EIP-712 typed struct for an action authorization.
    ///
    /// @param authority        Semantic authority behind the claim (iss).
    ///                         For governance actions this is typically the
    ///                         community treasury or multisig address.
    /// @param subject          Address of the ControlContract that will
    ///                         receive the invoke() and endorse() calls.
    /// @param contractAddress  Target contract that ControlContract will call
    ///                         once quorum and delay conditions are met.
    /// @param method           4-byte ABI selector of the target method.
    /// @param paramsHash       keccak256 of the ABI-encoded params bytes.
    ///                         Commits signers to exact calldata without
    ///                         storing it on-chain.
    /// @param minimum          Minimum number of endorsements required for
    ///                         ControlContract to consider quorum met,
    ///                         regardless of fraction.
    /// @param fraction         Fractional quorum threshold out of 1e10.
    ///                         E.g. 5000000000 = 50% of eligible endorsers.
    /// @param delay            Seconds that must elapse after quorum before
    ///                         ControlContract allows execution. 0 = immediate.
    /// @param nbf              Unix timestamp before which the claim is invalid.
    /// @param exp              Unix timestamp after which the claim is invalid.
    struct Action {
        address authority;
        address subject;
        address contractAddress;
        bytes4  method;
        bytes32 paramsHash;
        uint256 minimum;
        uint256 fraction;
        uint256 delay;
        uint256 nbf;
        uint256 exp;
    }

    /// @notice EIP-712 typed struct for a messages endpoint association.
    /// @param account      The address associating the endpoint.
    /// @param endpointType keccak256 of the endpoint type string (e.g. keccak256("api")).
    /// @param commitment   keccak256(abi.encodePacked(salt, url)). Salt=0 for public.
    struct MessageAssociation {
        address account;
        bytes32 endpointType;
        bytes32 commitment;
    }

    /// @notice Pre-flight result returned by paymentsPreFlight() and actionsPreFlight().
    ///
    /// @param valid           True if all checked conditions pass.
    /// @param extension       "payments" or "actions".
    /// @param digest          The EIP-712 digest that was verified.
    /// @param validSigCount   Number of unique valid signatures found.
    /// @param notYetValid     True if block.timestamp < nbf.
    /// @param expired         True if block.timestamp > exp.
    /// @param lineOpen        True if the payment line is open (payments only).
    ///                        Always true for line 0.
    /// @param capacityOk      True if the line has sufficient capacity (payments only).
    struct PreflightResult {
        bool    valid;
        string  extension;
        bytes32 digest;
        uint256 validSigCount;
        bool    notYetValid;
        bool    expired;
        bool    lineOpen;
        bool    capacityOk;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // State
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Payment line state. lines[payer][lineId] → Line.
    ///
    /// @dev The open flag is only meaningful for lineId >= 1.
    ///      Line 0 is always treated as open regardless of this mapping.
    ///      The spent counter at lines[payer][0] is used to enforce per-claim
    ///      max ceilings on DEFAULT_LINE payments.
    mapping(address => mapping(uint256 => Line)) public lines;

    /// @notice messages[account][endpointType] → commitment
    mapping(address => mapping(bytes32 => bytes32)) public messages;

    // ─────────────────────────────────────────────────────────────────────────
    // Events
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Emitted when a payment line is opened or its max updated.
    /// @param account The payer address that owns the line.
    /// @param line    The line id.
    /// @param max     The spending ceiling. 0 = unlimited.
    event LineOpened(address indexed account, uint256 indexed line, uint256 max);

    /// @notice Emitted when a payment line is closed.
    /// @param account The payer address.
    /// @param line    The line id.
    event LineClosed(address indexed account, uint256 indexed line);

    /// @notice Emitted after a successful payment execution.
    /// @param payer     The address whose tokens were transferred.
    /// @param token     The token address. address(0) = native coin.
    /// @param recipient The address that received the payment.
    /// @param line      The line id debited.
    /// @param amount    The amount transferred.
    /// @param newSpent  The line's new cumulative spent total after this payment.
    event PaymentsExecuted(
        address indexed payer,
        address indexed token,
        address indexed recipient,
        uint256 line,
        uint256 amount,
        uint256 newSpent
    );

    /// @notice Emitted after a successful actions execution.
    /// @param authority        The authority declared in the Action struct.
    /// @param subject          The ControlContract that was called.
    /// @param contractAddress  The target contract passed to invoke().
    /// @param method           The 4-byte selector passed to invoke().
    /// @param invokeID         The invokeID returned by ControlContract.invoke(),
    ///                         re-derived deterministically for endorsement.
    event ActionsExecuted(
        address indexed authority,
        address indexed subject,
        address indexed contractAddress,
        bytes4  method,
        uint256 invokeID
    );

    /// @notice Emitted after a successful message association.
    /// @param account      The on-chain address being associated.
    /// @param endpointType Can be keccak256("api"), keccak256("form"), keccak256("email"), etc.
    /// @param commitment   The keccak hash of (salt + endpoint url). Salt=0 for public endpoints.
    event MessagesAssociated(
        address indexed account,
        bytes32 indexed endpointType,
        bytes32         commitment
    );

    // ─────────────────────────────────────────────────────────────────────────
    // Line management
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Open a payment line for an account, or update its max.
    ///
    /// @dev Only the account itself or its Ownable owner may call this.
    ///      A line must be open before any payment claim can execute against it.
    ///      Calling lineOpen() on an already-open line updates the max without
    ///      resetting spent.
    ///
    ///      Not needed for line 0 (the default, always-open line).
    ///
    /// @param account  The payer address that will own the line.
    /// @param line     An arbitrary uint256 used as the line id. Use >= 1 for
    ///                 explicit budget-capped lines. Line 0 is the always-open
    ///                 default and calling lineOpen(account, 0, max) sets a
    ///                 spending cap on the default line.
    /// @param max      Spending ceiling in token base units. 0 = unlimited.
    function lineOpen(address account, uint256 line, uint256 max) external {
        _requireLineOperator(account, msg.sender);
        lines[account][line].max  = max;
        lines[account][line].open = true;
        emit LineOpened(account, line, max);
    }

    /// @notice Close a payment line, preventing any further spending.
    ///
    /// @dev spent is preserved — the history is not erased. Re-opening the
    ///      line with lineOpen() resumes from the existing spent total.
    ///
    ///      Cannot close line 0 (DEFAULT_LINE). The default line is always
    ///      open by protocol design.
    ///
    /// @param account The payer address.
    /// @param line    The line id to close. Must be >= 1.
    function lineClose(address account, uint256 line) external {
        require(line != DEFAULT_LINE, "OpenClaiming: cannot close default line");
        _requireLineOperator(account, msg.sender);
        lines[account][line].open = false;
        emit LineClosed(account, line);
    }

    /// @notice Returns true if the given line is currently open for payments.
    ///
    /// @dev Line 0 always returns true regardless of storage state.
    ///      Lines >= 1 return the stored open flag.
    ///
    /// @param account The payer address.
    /// @param line    The line id to check.
    /// @return        True if the line is open.
    function lineIsOpen(address account, uint256 line) external view returns (bool) {
        if (line == DEFAULT_LINE) return true;
        return lines[account][line].open;
    }

    /// @notice Returns the remaining spendable capacity on a line, taking
    ///         both the line-level max and a given claim-level max into account.
    ///
    /// @dev For line 0 (DEFAULT_LINE):
    ///        - No line-level cap applies.
    ///        - Returns claimMax (or type(uint256).max if claimMax == 0).
    ///        - Off-chain callers should also check ERC-20 balance/allowance,
    ///          since line 0 draws directly on the payer's token balance.
    ///
    ///      For lines >= 1:
    ///        - Returns 0 if the line is closed.
    ///        - Enforces both claim max and line max; the lower wins.
    ///
    ///      Use this off-chain before constructing a payment claim to confirm
    ///      the line has sufficient capacity for the intended amount.
    ///
    /// @param account  The payer address.
    /// @param line     The line id.
    /// @param claimMax The max value from the Payment claim. 0 = unlimited.
    /// @return         Available amount in token base units.
    function lineAvailable(
        address account,
        uint256 line,
        uint256 claimMax
    ) external view returns (uint256) {
        if (line == DEFAULT_LINE) {
            // No line-level cap. Only claim max applies.
            return claimMax == 0 ? type(uint256).max : claimMax;
        }
        Line storage l = lines[account][line];
        if (!l.open) return 0;
        uint256 claimRemaining = claimMax == 0
            ? type(uint256).max
            : (l.spent >= claimMax ? 0 : claimMax - l.spent);
        uint256 lineRemaining = l.max == 0
            ? type(uint256).max
            : (l.spent >= l.max ? 0 : l.max - l.spent);
        return claimRemaining < lineRemaining ? claimRemaining : lineRemaining;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Signature primitives
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Recover the signer address from an EIP-712 digest and a
    ///         65-byte signature (r || s || v).
    ///
    /// @dev Enforces low-s (EIP-2) to prevent signature malleability.
    ///      v is normalised from {0,1} to {27,28} if needed.
    ///      Reverts on any malformed input rather than returning address(0).
    ///
    /// @param digest    The EIP-712 digest (32 bytes).
    /// @param signature 65-byte signature: r (32) || s (32) || v (1).
    /// @return signer   The recovered signer address.
    function recoverSigner(
        bytes32 digest,
        bytes calldata signature
    ) public pure returns (address signer) {
        if (signature.length != 65) revert InvalidSignatureLength();

        bytes32 r;
        bytes32 s;
        uint8   v;

        assembly {
            r := calldataload(signature.offset)
            s := calldataload(add(signature.offset, 32))
            v := byte(0, calldataload(add(signature.offset, 64)))
        }

        if (uint256(s) > SECP256K1N_OVER_2) revert InvalidSignatureS();
        if (v == 0 || v == 1) v += 27;
        if (v != 27 && v != 28)             revert InvalidSignatureV();

        signer = ecrecover(digest, v, r, s);
        if (signer == address(0)) revert InvalidSignature();
    }

    /// @notice Verify a single signature against an expected signer address.
    ///
    /// @param digest          The EIP-712 digest.
    /// @param signature       65-byte signature.
    /// @param expectedSigner  The address the signature must recover to.
    /// @return                True if the signature is valid for expectedSigner.
    function verify(
        bytes32 digest,
        bytes calldata signature,
        address expectedSigner
    ) public pure returns (bool) {
        return recoverSigner(digest, signature) == expectedSigner;
    }

    /// @notice Verify multiple signatures over the same EIP-712 digest.
    ///
    /// @dev Each sig[i] is verified against signers[i]. Duplicate signer
    ///      addresses are counted only once. Returns true as soon as minValid
    ///      unique valid signatures are found, without processing the rest.
    ///      Returns false immediately if minValid == 0.
    ///
    ///      This function does NOT revert on individual bad signatures — it
    ///      simply does not count them. This allows partial submission: a
    ///      relayer can submit all collected signatures and the contract
    ///      counts however many are valid.
    ///
    /// @param digest      The EIP-712 digest all signers signed.
    /// @param signers     Addresses expected to have signed. Parallel to signatures.
    /// @param signatures  65-byte signatures. signatures[i] must be from signers[i].
    /// @param minValid    Minimum number of unique valid signatures required.
    /// @return            True if at least minValid unique valid signatures found.
    function verifySignatures(
        bytes32           digest,
        address[] calldata signers,
        bytes[]   calldata signatures,
        uint256            minValid
    ) public pure returns (bool) {
        if (signers.length != signatures.length) return false;
        if (minValid == 0) return false;

        uint256 valid = 0;

        for (uint256 i = 0; i < signers.length; i++) {
            address signer = signers[i];
            if (signer == address(0))      continue;
            if (signatures[i].length == 0) continue;

            // O(n²) dedup — acceptable for the small signer counts typical
            // in governance and payment multisig scenarios
            bool dup = false;
            for (uint256 j = 0; j < i; j++) {
                if (signers[j] == signer) { dup = true; break; }
            }
            if (dup) continue;

            // Catch malformed sigs without reverting the whole batch
            try this.recoverSigner(digest, signatures[i]) returns (address recovered) {
                if (recovered == signer) {
                    valid++;
                    if (valid >= minValid) return true;
                }
            } catch {}
        }

        return valid >= minValid;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Pre-flight view — off-chain claim validation
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Validate a payments claim off-chain before submitting.
    ///
    /// @dev Returns a PreflightResult struct summarising validity without
    ///      reverting. Intended for relayers and UIs to pre-flight claims,
    ///      estimate gas, and surface human-readable error states.
    ///      Does NOT modify state. Safe to call at any time.
    ///
    ///      lineOpen is always true for line 0 (DEFAULT_LINE).
    ///
    /// @param p            The Payment struct to validate.
    /// @param recipients   The plaintext recipient array (must hash to p.recipientsHash).
    /// @param recipient    The intended recipient for this execution.
    /// @param amount       The intended transfer amount.
    /// @param signers      Signer addresses parallel to signatures.
    /// @param signatures   65-byte signatures from the respective signers.
    /// @param minValid     Minimum valid signatures required.
    /// @return result      Populated PreflightResult.
    function paymentsPreFlight(
        Payment        calldata p,
        address[] calldata recipients,
        address            recipient,
        uint256            amount,
        address[] calldata signers,
        bytes[]   calldata signatures,
        uint256            minValid
    ) external view returns (PreflightResult memory result) {
        result.extension   = "payments";
        result.digest      = paymentsDigest(p);
        result.notYetValid = (p.nbf != 0 && block.timestamp < p.nbf);
        result.expired     = (p.exp != 0 && block.timestamp > p.exp);

        // Line 0 is always open
        result.lineOpen = (p.line == DEFAULT_LINE) ? true : lines[p.payer][p.line].open;

        if (result.lineOpen) {
            uint256 available;
            if (p.line == DEFAULT_LINE) {
                // No line cap — only claim max applies
                available = p.max == 0 ? type(uint256).max : p.max;
            } else {
                Line storage l = lines[p.payer][p.line];
                uint256 claimRemaining = p.max == 0
                    ? type(uint256).max
                    : (l.spent >= p.max ? 0 : p.max - l.spent);
                uint256 lineRemaining = l.max == 0
                    ? type(uint256).max
                    : (l.spent >= l.max ? 0 : l.max - l.spent);
                available = claimRemaining < lineRemaining ? claimRemaining : lineRemaining;
            }
            result.capacityOk = (available >= amount);
        }

        // Count valid sigs without reverting on bad ones
        uint256 valid = 0;
        for (uint256 i = 0; i < signers.length; i++) {
            if (signers[i] == address(0) || signatures[i].length == 0) continue;
            bool dup = false;
            for (uint256 j = 0; j < i; j++) {
                if (signers[j] == signers[i]) { dup = true; break; }
            }
            if (dup) continue;
            try this.recoverSigner(result.digest, signatures[i]) returns (address recovered) {
                if (recovered == signers[i]) valid++;
            } catch {}
        }
        result.validSigCount = valid;

        // Check recipient is in set
        bool recipientOk = false;
        if (paymentsHashRecipients(recipients) == p.recipientsHash) {
            for (uint256 i = 0; i < recipients.length; i++) {
                if (recipients[i] == recipient) { recipientOk = true; break; }
            }
        }

        result.valid = (
            !result.notYetValid &&
            !result.expired     &&
            result.lineOpen     &&
            result.capacityOk   &&
            recipientOk         &&
            valid >= minValid
        );
    }

    /// @notice Validate an actions claim off-chain before submitting.
    ///
    /// @dev Returns a PreflightResult struct summarising validity without
    ///      reverting. lineOpen and capacityOk are not applicable for actions
    ///      and will be returned as false.
    ///
    /// @param a          The Action struct to validate.
    /// @param params     The plaintext params bytes (must hash to a.paramsHash).
    /// @param signers    Signer addresses parallel to signatures.
    /// @param signatures 65-byte signatures.
    /// @param minValid   Minimum valid signatures required.
    /// @param invoker    The address that will call invoke(). Must be in signers.
    /// @return result    Populated PreflightResult.
    function actionsPreFlight(
        Action         calldata a,
        bytes          calldata params,
        address[] calldata signers,
        bytes[]   calldata signatures,
        uint256            minValid,
        address            invoker
    ) external view returns (PreflightResult memory result) {
        result.extension   = "actions";
        result.digest      = actionsDigest(a);
        result.notYetValid = (a.nbf != 0 && block.timestamp < a.nbf);
        result.expired     = (a.exp != 0 && block.timestamp > a.exp);

        // lineOpen / capacityOk not applicable for actions
        result.lineOpen   = false;
        result.capacityOk = false;

        bool paramsOk     = (keccak256(params) == a.paramsHash);
        bool invokerFound = false;

        uint256 valid = 0;
        for (uint256 i = 0; i < signers.length; i++) {
            if (signers[i] == address(0) || signatures[i].length == 0) continue;
            bool dup = false;
            for (uint256 j = 0; j < i; j++) {
                if (signers[j] == signers[i]) { dup = true; break; }
            }
            if (dup) continue;
            try this.recoverSigner(result.digest, signatures[i]) returns (address recovered) {
                if (recovered == signers[i]) {
                    valid++;
                    if (signers[i] == invoker) invokerFound = true;
                }
            } catch {}
        }
        result.validSigCount = valid;

        result.valid = (
            !result.notYetValid &&
            !result.expired     &&
            paramsOk            &&
            invokerFound        &&
            valid >= minValid
        );
    }

    // ─────────────────────────────────────────────────────────────────────────
    // payments — EIP-712 hash helpers
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Returns the EIP-712 domain separator for the payments extension.
    function paymentsDomainSeparator() public view returns (bytes32) {
        return keccak256(abi.encode(
            EIP712_DOMAIN_TYPEHASH,
            PAYMENTS_NAME_HASH,
            VERSION_HASH,
            block.chainid,
            address(this)
        ));
    }

    /// @notice Hash a recipient array for use as Payment.recipientsHash.
    ///
    /// @dev Use this helper off-chain (via eth_call) to compute the value to
    ///      place in Payment.recipientsHash before signing. Matches the
    ///      encoding used during verification.
    ///
    /// @param recipients Array of authorised recipient addresses.
    /// @return           keccak256(abi.encode(recipients))
    function paymentsHashRecipients(
        address[] calldata recipients
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(recipients));
    }

    /// @notice Compute the EIP-712 struct hash for a Payment.
    /// @param p The Payment struct.
    /// @return  The struct hash (before domain prefix).
    function paymentsHash(Payment calldata p) public pure returns (bytes32) {
        return keccak256(abi.encode(
            PAYMENTS_TYPEHASH,
            p.payer,
            p.token,
            p.recipientsHash,
            p.max,
            p.line,
            p.nbf,
            p.exp
        ));
    }

    /// @notice Compute the final EIP-712 digest for a Payment.
    ///         This is what signers must sign.
    /// @param p The Payment struct.
    /// @return  The digest: keccak256("\x19\x01" || domainSeparator || structHash)
    function paymentsDigest(Payment calldata p) public view returns (bytes32) {
        return keccak256(abi.encodePacked(
            "\x19\x01",
            paymentsDomainSeparator(),
            paymentsHash(p)
        ));
    }

    /// @notice Recover the signer of a Payment claim.
    /// @param p   The Payment struct.
    /// @param sig 65-byte signature.
    /// @return    The recovered signer address.
    function paymentsRecoverSigner(
        Payment calldata p,
        bytes   calldata sig
    ) public view returns (address) {
        return recoverSigner(paymentsDigest(p), sig);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // payments — verify
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Verify a payment claim signed by the payer alone.
    ///
    /// @dev Checks timing, recipients hash, recipient membership, line state,
    ///      and that the recovered signer is p.payer. Does not modify state.
    ///
    /// @param p          The Payment struct.
    /// @param recipients Plaintext recipient array. Must hash to p.recipientsHash.
    /// @param sig        65-byte signature from p.payer.
    /// @param recipient  The intended recipient for this execution.
    /// @param amount     The intended transfer amount.
    /// @return           True if all checks pass (reverts otherwise).
    function paymentsVerify(
        Payment        calldata p,
        address[] calldata recipients,
        bytes     calldata sig,
        address            recipient,
        uint256            amount
    ) public view returns (bool) {
        _paymentsValidate(p, recipients, sig, recipient, amount);
        return true;
    }

    /// @notice Verify a payment claim signed by multiple signers.
    ///
    /// @dev Checks timing, recipients hash, recipient membership, line state,
    ///      and that at least minValid unique valid signatures are present.
    ///
    /// @param p          The Payment struct.
    /// @param recipients Plaintext recipient array.
    /// @param recipient  The intended recipient.
    /// @param amount     The intended amount.
    /// @param signers    Addresses expected to have signed.
    /// @param signatures Corresponding 65-byte signatures.
    /// @param minValid   Minimum valid unique signatures required.
    /// @return           True if all checks pass (reverts otherwise).
    function paymentsVerifySignatures(
        Payment        calldata p,
        address[] calldata recipients,
        address            recipient,
        uint256            amount,
        address[] calldata signers,
        bytes[]   calldata signatures,
        uint256            minValid
    ) public view returns (bool) {
        _paymentsValidateCore(p, recipients, recipient, amount);
        return verifySignatures(paymentsDigest(p), signers, signatures, minValid);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // payments — execute
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Execute a payment authorized by the payer's single signature.
    ///
    /// @dev Validates the claim, updates the line spent total (CEI), then
    ///      transfers tokens. Two transfer paths are available:
    ///
    ///      Direct ERC-20 (incomeContract == address(0)):
    ///        Calls token.transferFrom(payer, recipient, amount).
    ///        Payer must have approved this contract for at least `amount`.
    ///
    ///      IncomeContract (incomeContract != address(0)):
    ///        Calls incomeContract.pay(recipient, amount) forwarded as payer
    ///        via EIP-2771. Payer must be registered as a manager on the
    ///        IncomeContract. OpenClaiming must be its TrustedForwarder.
    ///
    ///      Native coin (p.token == address(0)):
    ///        msg.sender must be p.payer. msg.value must equal amount.
    ///        Native coin cannot be delegated to a relayer.
    ///
    /// @param p              The Payment struct (must be signed by p.payer).
    /// @param recipients     Plaintext recipient array.
    /// @param sig            65-byte signature from p.payer.
    /// @param recipient      Address to receive the payment (must be in recipients).
    /// @param amount         Amount to transfer in token base units.
    /// @param incomeContract address(0) for direct transferFrom, otherwise the
    ///                       IncomeContract to route through.
    function paymentsExecute(
        Payment        calldata p,
        address[] calldata recipients,
        bytes     calldata sig,
        address            recipient,
        uint256            amount,
        address            incomeContract
    ) public payable returns (bool) {
        _paymentsValidate(p, recipients, sig, recipient, amount);
        _paymentsTransfer(p, recipient, amount, incomeContract);
        return true;
    }

    /// @notice Execute a payment authorized by multiple signers.
    ///
    /// @dev Identical to paymentsExecute but verifies a set of signatures
    ///      instead of a single payer signature. Useful for treasury multisig
    ///      or any scenario where the payer is a group rather than an individual.
    ///
    /// @param p              The Payment struct.
    /// @param recipients     Plaintext recipient array.
    /// @param recipient      Address to receive the payment.
    /// @param amount         Amount to transfer.
    /// @param signers        Addresses that signed the claim.
    /// @param signatures     Corresponding 65-byte signatures.
    /// @param minValid       Minimum valid unique signatures required.
    /// @param incomeContract address(0) for direct transferFrom, otherwise
    ///                       the IncomeContract to route through.
    function paymentsExecuteSignatures(
        Payment        calldata p,
        address[] calldata recipients,
        address            recipient,
        uint256            amount,
        address[] calldata signers,
        bytes[]   calldata signatures,
        uint256            minValid,
        address            incomeContract
    ) public payable returns (bool) {
        _paymentsValidateCore(p, recipients, recipient, amount);
        if (!verifySignatures(paymentsDigest(p), signers, signatures, minValid)) {
            revert InvalidSignature();
        }
        _paymentsTransfer(p, recipient, amount, incomeContract);
        return true;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // actions — EIP-712 hash helpers
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Returns the EIP-712 domain separator for the actions extension.
    function actionsDomainSeparator() public view returns (bytes32) {
        return keccak256(abi.encode(
            EIP712_DOMAIN_TYPEHASH,
            ACTIONS_NAME_HASH,
            VERSION_HASH,
            block.chainid,
            address(this)
        ));
    }

    /// @notice Hash the raw params bytes for use as Action.paramsHash.
    ///
    /// @dev Use this helper off-chain to compute the value for Action.paramsHash
    ///      before signing. params should be ABI-encoded calldata arguments
    ///      (without the method selector).
    ///
    /// @param params ABI-encoded parameter bytes.
    /// @return       keccak256(params)
    function actionsHashParams(bytes calldata params) public pure returns (bytes32) {
        return keccak256(params);
    }

    /// @notice Compute the EIP-712 struct hash for an Action.
    /// @param a The Action struct.
    /// @return  The struct hash (before domain prefix).
    function actionsHash(Action calldata a) public pure returns (bytes32) {
        return keccak256(abi.encode(
            ACTIONS_TYPEHASH,
            a.authority,
            a.subject,
            a.contractAddress,
            a.method,
            a.paramsHash,
            a.minimum,
            a.fraction,
            a.delay,
            a.nbf,
            a.exp
        ));
    }

    /// @notice Compute the final EIP-712 digest for an Action.
    ///         This is what signers must sign.
    /// @param a The Action struct.
    /// @return  The digest.
    function actionsDigest(Action calldata a) public view returns (bytes32) {
        return keccak256(abi.encodePacked(
            "\x19\x01",
            actionsDomainSeparator(),
            actionsHash(a)
        ));
    }

    /// @notice Recover the signer of an Action claim.
    /// @param a   The Action struct.
    /// @param sig 65-byte signature.
    /// @return    The recovered signer address.
    function actionsRecoverSigner(
        Action calldata a,
        bytes  calldata sig
    ) public view returns (address) {
        return recoverSigner(actionsDigest(a), sig);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // actions — verify
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Verify an action claim signed by the authority alone.
    /// @param a   The Action struct.
    /// @param sig 65-byte signature from a.authority.
    /// @return    True if valid (reverts otherwise).
    function actionsVerify(
        Action calldata a,
        bytes  calldata sig
    ) public view returns (bool) {
        _actionsValidateCore(a);
        address signer = actionsRecoverSigner(a, sig);
        if (signer != a.authority) revert InvalidSignature();
        return true;
    }

    /// @notice Verify an action claim signed by multiple signers.
    /// @param a          The Action struct.
    /// @param signers    Addresses that signed.
    /// @param signatures Corresponding 65-byte signatures.
    /// @param minValid   Minimum valid unique signatures required.
    /// @return           True if valid (reverts otherwise).
    function actionsVerifySignatures(
        Action         calldata a,
        address[] calldata signers,
        bytes[]   calldata signatures,
        uint256            minValid
    ) public view returns (bool) {
        _actionsValidateCore(a);
        return verifySignatures(actionsDigest(a), signers, signatures, minValid);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // actions — execute
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Execute an action authorized by multiple signers.
    ///
    /// @dev Full execution flow:
    ///   1. Validate timing (nbf/exp) and params hash.
    ///   2. Verify all signatures over the EIP-712 action digest.
    ///   3. Confirm invoker is among the valid signers.
    ///   4. Call ControlContract.invoke() forwarded as invoker (EIP-2771),
    ///      so _msgSender() inside ControlContract resolves to the invoker
    ///      and Community role checks pass.
    ///   5. Re-derive invokeID deterministically using the same formula as
    ///      ControlContract.generateInvokeID():
    ///        keccak256(block.timestamp, block.prevrandao, invoker)
    ///      This works because ControlContract must use _msgSender() (= invoker)
    ///      not msg.sender (= this contract) in generateInvokeID().
    ///   6. Call ControlContract.endorse(invokeID) forwarded as each valid
    ///      signer. ControlContract checks Community roles per endorser and
    ///      accumulates towards quorum. If quorum is met and delay is 0,
    ///      ControlContract auto-executes the target call.
    ///
    /// @dev REQUIREMENTS:
    ///   - OpenClaiming must be set as TrustedForwarder on the ControlContract.
    ///   - ControlContract.generateInvokeID() must use _msgSender(), not
    ///     msg.sender. This is a required change to the ControlContract.
    ///   - invoker must hold the invoke role in the Community contract
    ///     associated with the ControlContract.
    ///
    /// @param a          The Action struct.
    /// @param params     Raw ABI-encoded params bytes. Must satisfy
    ///                   keccak256(params) == a.paramsHash.
    /// @param signers    Addresses that signed the action claim.
    /// @param signatures Corresponding 65-byte signatures.
    /// @param minValid   Minimum valid unique signatures required before
    ///                   forwarding to ControlContract.
    /// @param invoker    The signer that holds the invoke role. Must appear
    ///                   in signers[] with a valid signature.
    function actionsExecute(
        Action         calldata a,
        bytes          calldata params,
        address[] calldata signers,
        bytes[]   calldata signatures,
        uint256            minValid,
        address            invoker
    ) public returns (bool) {
        _actionsValidateCore(a);

        if (keccak256(params) != a.paramsHash) revert ParamsHashMismatch();
        if (signers.length == 0 || signers.length != signatures.length) {
            revert InvalidSignerCount();
        }

        // Verify all sigs, collect unique valid signers
        bytes32 digest = actionsDigest(a);
        address[] memory validSigners = new address[](signers.length);
        uint256 validCount = 0;

        for (uint256 i = 0; i < signers.length; i++) {
            address signer = signers[i];
            if (signer == address(0))      continue;
            if (signatures[i].length == 0) continue;

            if (recoverSigner(digest, signatures[i]) != signer) revert InvalidSignature();

            bool dup = false;
            for (uint256 j = 0; j < validCount; j++) {
                if (validSigners[j] == signer) { dup = true; break; }
            }
            if (!dup) {
                validSigners[validCount] = signer;
                validCount++;
            }
        }

        if (validCount < minValid) revert InvalidSignature();

        // Confirm invoker is among valid signers
        bool invokerFound = false;
        for (uint256 i = 0; i < validCount; i++) {
            if (validSigners[i] == invoker) { invokerFound = true; break; }
        }
        if (!invokerFound) revert InvokerNotInSigners();

        // invoke() forwarded as invoker
        _forwardCall(
            a.subject,
            abi.encodeWithSelector(
                IControlContract.invoke.selector,
                a.contractAddress,
                _bytes4ToHex(a.method),
                _bytesToHex(params),
                a.minimum,
                a.fraction,
                uint64(a.delay)
            ),
            invoker
        );

        // Re-derive invokeID — deterministic because ControlContract uses
        // _msgSender() (= invoker via EIP-2771) in generateInvokeID()
        uint256 invokeID = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.prevrandao,
            invoker
        )));

        // endorse() forwarded as each valid signer
        bytes memory endorseCall = abi.encodeWithSelector(
            IControlContract.endorse.selector,
            invokeID
        );
        for (uint256 i = 0; i < validCount; i++) {
            _forwardCall(a.subject, endorseCall, validSigners[i]);
        }

        emit ActionsExecuted(
            a.authority,
            a.subject,
            a.contractAddress,
            a.method,
            invokeID
        );

        return true;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Internal — payments validation
    // ─────────────────────────────────────────────────────────────────────────

    function _paymentsValidate(
        Payment        calldata p,
        address[] calldata recipients,
        bytes     calldata sig,
        address            recipient,
        uint256            amount
    ) internal view {
        _paymentsValidateCore(p, recipients, recipient, amount);
        address signer = paymentsRecoverSigner(p, sig);
        if (signer != p.payer) revert PayerMismatch(p.payer, signer);
    }

    function _paymentsValidateCore(
        Payment        calldata p,
        address[] calldata recipients,
        address            recipient,
        uint256            amount
    ) internal view {
        if (p.nbf != 0 && block.timestamp < p.nbf) revert NotYetValid(p.nbf);
        if (p.exp != 0 && block.timestamp > p.exp) revert Expired(p.exp);

        if (paymentsHashRecipients(recipients) != p.recipientsHash) {
            revert PaymentRecipientsHashMismatch();
        }

        bool allowed = false;
        for (uint256 i = 0; i < recipients.length; i++) {
            if (recipients[i] == recipient) { allowed = true; break; }
        }
        if (!allowed) revert InvalidRecipient(recipient);

        // ── Line check ──────────────────────────────────────────────────────
        // Line 0 (DEFAULT_LINE) is always open with unlimited max.
        // All other lines must have been explicitly opened via lineOpen().
        uint256 claimRemaining;
        uint256 lineRemaining;

        if (p.line == DEFAULT_LINE) {
            // No line-level cap. Enforce only the per-claim max.
            // spent is tracked at lines[p.payer][0] even for the default line.
            uint256 spent = lines[p.payer][DEFAULT_LINE].spent;
            claimRemaining = p.max == 0
                ? type(uint256).max
                : (spent >= p.max ? 0 : p.max - spent);
            lineRemaining = type(uint256).max;
        } else {
            Line storage l = lines[p.payer][p.line];
            if (!l.open) revert LineNotOpen(p.payer, p.line);

            claimRemaining = p.max == 0
                ? type(uint256).max
                : (l.spent >= p.max ? 0 : p.max - l.spent);
            lineRemaining = l.max == 0
                ? type(uint256).max
                : (l.spent >= l.max ? 0 : l.max - l.spent);
        }

        uint256 available = claimRemaining < lineRemaining ? claimRemaining : lineRemaining;

        if (amount > available)      revert InsufficientCapacity(amount, available);
        if (amount > claimRemaining) revert ClaimMaxExceeded(amount, claimRemaining);
        if (amount > lineRemaining)  revert LineMaxExceeded(amount, lineRemaining);
    }

    /// @dev CEI: line state updated BEFORE any external token/contract call.
    function _paymentsTransfer(
        Payment calldata p,
        address          recipient,
        uint256          amount,
        address          incomeContract
    ) internal {
        // spent is tracked for both line 0 and named lines
        lines[p.payer][p.line].spent += amount;

        if (p.token == address(0)) {
            if (msg.sender != p.payer) revert NativeCoinDelegationUnsupported();
            if (msg.value != amount)   revert NativeCoinValueMismatch(amount, msg.value);
            (bool ok,) = payable(recipient).call{value: amount}("");
            if (!ok) revert TransferFailed();
        } else {
            if (msg.value != 0) revert NativeCoinValueMismatch(0, msg.value);

            if (incomeContract == address(0)) {
                (bool ok, bytes memory data) = p.token.call(
                    abi.encodeWithSelector(
                        IERC20.transferFrom.selector,
                        p.payer,
                        recipient,
                        amount
                    )
                );
                if (!ok || (data.length != 0 && !abi.decode(data, (bool)))) {
                    revert TransferFailed();
                }
            } else {
                _forwardCall(
                    incomeContract,
                    abi.encodeWithSelector(
                        IIncomeContract.pay.selector,
                        recipient,
                        amount
                    ),
                    p.payer
                );
            }
        }

        emit PaymentsExecuted(
            p.payer,
            p.token,
            recipient,
            p.line,
            amount,
            lines[p.payer][p.line].spent
        );
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Internal — actions validation
    // ─────────────────────────────────────────────────────────────────────────

    function _actionsValidateCore(Action calldata a) internal view {
        if (a.nbf != 0 && block.timestamp < a.nbf) revert NotYetValid(a.nbf);
        if (a.exp != 0 && block.timestamp > a.exp) revert Expired(a.exp);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Internal — EIP-2771 forwarding
    // ─────────────────────────────────────────────────────────────────────────

    /// @dev Append signer as the last 20 bytes of calldata (EIP-2771 standard).
    ///      The target contract's _msgSender() strips those bytes and returns
    ///      the signer address rather than address(this).
    ///      Reverts if the forwarded call reverts.
    function _forwardCall(
        address      target,
        bytes memory data,
        address      signer
    ) internal {
        (bool ok,) = target.call(abi.encodePacked(data, signer));
        require(ok, "OpenClaiming: forwarded call failed");
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Internal — line operator authorisation
    // ─────────────────────────────────────────────────────────────────────────

    /// @dev Allows the account itself or the account's Ownable owner to manage
    ///      lines. Reverts for any other caller.
    function _requireLineOperator(address account, address caller) internal view {
        if (caller == account) return;
        try IOwnable(account).owner() returns (address o) {
            if (o == caller) return;
        } catch {}
        revert UnauthorizedLineOperator(account, caller);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Internal — hex encoding for ControlContract calldata
    // ─────────────────────────────────────────────────────────────────────────

    /// @dev Convert bytes4 to an 8-character lowercase hex string without 0x
    ///      prefix. ControlContract.invoke() expects the method selector in
    ///      this format and uses fromHex() internally to reconstruct bytes.
    function _bytes4ToHex(bytes4 b) internal pure returns (string memory) {
        bytes memory h = new bytes(8);
        bytes memory chars = "0123456789abcdef";
        for (uint256 i = 0; i < 4; i++) {
            h[i * 2]     = chars[uint8(b[i]) >> 4];
            h[i * 2 + 1] = chars[uint8(b[i]) & 0x0f];
        }
        return string(h);
    }

    /// @dev Convert arbitrary bytes to a lowercase hex string without 0x prefix.
    ///      ControlContract.invoke() expects params in this format.
    function _bytesToHex(bytes calldata b) internal pure returns (string memory) {
        bytes memory h = new bytes(b.length * 2);
        bytes memory chars = "0123456789abcdef";
        for (uint256 i = 0; i < b.length; i++) {
            h[i * 2]     = chars[uint8(b[i]) >> 4];
            h[i * 2 + 1] = chars[uint8(b[i]) & 0x0f];
        }
        return string(h);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // messages — EIP-712 hash helpers
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Returns the EIP-712 domain separator for the messages extension.
    function messagesDomainSeparator() public view returns (bytes32) {
        return keccak256(abi.encode(
            EIP712_DOMAIN_TYPEHASH,
            MESSAGES_NAME_HASH,
            VERSION_HASH,
            block.chainid,
            address(this)
        ));
    }

    /// @notice Compute the EIP-712 struct hash for a MessageAssociation.
    /// @param m The MessageAssociation struct.
    /// @return  The struct hash (before domain prefix).
    function messagesHash(MessageAssociation calldata m) public pure returns (bytes32) {
        return keccak256(abi.encode(
            MESSAGES_TYPEHASH,
            m.account,
            m.endpointType,
            m.commitment
        ));
    }

    /// @notice Compute the final EIP-712 digest for a MessageAssociation.
    ///         This is what the account must sign.
    /// @param m The MessageAssociation struct.
    /// @return  The digest: keccak256("\x19\x01" || domainSeparator || structHash)
    function messagesDigest(MessageAssociation calldata m) public view returns (bytes32) {
        return keccak256(abi.encodePacked(
            "\x19\x01",
            messagesDomainSeparator(),
            messagesHash(m)
        ));
    }

    // ─────────────────────────────────────────────────────────────────────────
    // messages — associate
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Direct path — msg.sender associates their own endpoint.
    ///
    /// @dev No signature required; msg.sender is authoritative.
    ///      Use this when the account is calling on-chain directly.
    ///
    /// @param endpointType keccak256 of the endpoint type string (e.g. keccak256("api")).
    /// @param commitment   keccak256(abi.encodePacked(salt, url)). Salt=0 for public endpoints.
    function messagesAssociate(
        bytes32 endpointType,
        bytes32 commitment
    ) external {
        messages[msg.sender][endpointType] = commitment;
        emit MessagesAssociated(msg.sender, endpointType, commitment);
    }

    /// @notice Relayed path — signer pre-signs EIP-712, anyone can submit.
    ///
    /// @dev Verifies the EIP-712 signature over the MessageAssociation struct,
    ///      then stores the commitment on behalf of the signer. Enables
    ///      gasless association flows where the account signs off-chain and
    ///      a relayer submits the transaction.
    ///
    /// @param m   The MessageAssociation struct (account, endpointType, commitment).
    /// @param sig 65-byte EIP-712 signature from m.account.
    function messagesAssociateFor(
        MessageAssociation calldata m,
        bytes              calldata sig
    ) external {
        address signer = recoverSigner(messagesDigest(m), sig);
        if (signer != m.account) revert InvalidSignature();
        messages[m.account][m.endpointType] = m.commitment;
        emit MessagesAssociated(m.account, m.endpointType, m.commitment);
    }
	
	/// @notice Verify that an account has associated a given endpoint url with a given endpoint type.
	///
	/// @dev Recomputes keccak256(abi.encodePacked(salt, url)) and compares it against
	///      the stored commitment. Two usage modes:
	///
	///      Public endpoint (salt = bytes32(0)):
	///        Anyone can verify the url — no secret knowledge required.
	///        commitment = keccak256(abi.encodePacked(bytes32(0), url))
	///
	///      Private endpoint (salt != bytes32(0)):
	///        Only callers who know the salt can verify the url.
	///        The on-chain commitment reveals nothing about the url without the salt.
	///
	///      Returns false (does not revert) if no association exists or if the
	///      url/salt pair does not match the stored commitment.
	///
	/// @param account      The address whose endpoint association is being verified.
	/// @param endpointType keccak256 of the endpoint type string (e.g. keccak256("api")).
	/// @param salt         Blinding factor. bytes32(0) for public endpoints.
	/// @param url          The plaintext endpoint url to verify against the commitment.
	/// @return             True if the stored commitment matches keccak256(abi.encodePacked(salt, url)).
	function messagesVerify(
	    address account,
	    bytes32 endpointType,
	    bytes32 salt,
	    string calldata url
	) external view returns (bool) {
	    bytes32 commitment = keccak256(abi.encodePacked(salt, url));
	    return messages[account][endpointType] == commitment;
	}
}