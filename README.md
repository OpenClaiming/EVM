# 🔐 OpenClaiming EVM

Canonical EIP-712 payment execution contract for OpenClaiming.

---

# 🚀 Overview

Implements:

- Delegated payments
- Trustline (line-based) accounting
- Deterministic EIP-712 verification (off-chain)
- Multi-line aggregation

OpenClaiming turns signed messages into portable, executable payment permissions.

---

# 🌐 What is OpenClaiming?

OpenClaiming is a protocol for expressing signed claims that can be:

- verified across systems
- executed on-chain or off-chain
- reused as portable authorization primitives

Instead of sending transactions, users sign claims, which can later be executed.

---

# 🧠 Core Model

Each payer has independent trustlines:

payer → line → max → spent → open/closed

Each claim:

- references a line
- defines a max
- defines allowed recipients

Execution enforces:

remaining = min(claim.max, line.max) - line.spent

---

# 📜 Payment Struct (EIP-712)

Payment(
    address payer,
    address token,
    bytes32 recipientsHash,
    uint256 max,
    uint256 line,
    uint256 nbf,
    uint256 exp
)

---

# 🔐 Signature Flow

OpenClaiming supports both **server-signed** and **wallet-signed** claims, but is primarily designed for **server-side signing**.

---

## 🖥️ Off-chain (Typical: Server Signing)

1. Build OpenClaiming JSON
2. Convert to typed EIP-712 struct
3. Compute hashes (e.g. recipientsHash)
4. Sign using a server-controlled private key

In this model:

- Private keys are securely stored on backend systems
- The user does **not** rely on wallet UI to inspect signatures
- The application UI is responsible for transparency

This is the **recommended and primary usage pattern**.

---

## 👛 Off-chain (Optional: Wallet Signing)

1. Build EIP-712 struct
2. Present to user wallet (e.g. MetaMask)
3. User signs via `eth_signTypedData_v4`

Notes:

- Wallet support for complex structures (arrays, nested data) may vary
- Hardware wallets may not display full data correctly
- For better UX, additional fields (like full recipient arrays) may be included alongside hashes

---

## ⛓️ On-chain

1. Recompute struct hash
2. Recover signer using `ecrecover`
3. Validate:
   - signer matches payer / authority
   - time constraints (`nbf`, `exp`)
   - recipients hash matches provided recipients
   - line limits and claim max
4. Execute payment

---

## 🧠 Key Insight

OpenClaiming treats signatures as:

> **portable, machine-verifiable permissions**

Not necessarily as user-facing wallet approvals.

---

## ⚠️ Important

- Most production flows will use **server-side signing**
- Wallet signing is supported but not required
- The trust model is application-driven, not wallet-driven

---

# ⚙️ Usage

## 1. Open a line

openClaiming.lineOpen(account, line, max);

## 2. Sign claim off-chain

## 3. Execute on-chain

openClaiming.executePayment(...)

---

# 🧱 Contract Features

## Line management

- lineOpen(account, line, max)
- lineClose(account, line)
- lineAvailable(account, line)

## Execution

- executePayment(...)
- executePaymentMulti(...)

## Verification

- verifyPayment(...)

---

# 🔓 Delegation Model

## ERC20

Requires:

token.approve(OpenClaiming, amount);

Then:

transferFrom(payer → recipient)

---

## Native coin (ETH)

- token == address(0)
- must use msg.value
- cannot be delegated

---

# 🔄 Multi-Line Payments

Allows combining capacity across multiple claims:

- same payer
- same token
- same recipient

---

# 🧪 Solidity Integration Example

## Consumer Contract

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IOpenClaiming.sol";

contract OpenClaimingConsumer {

    address public constant OPENCLAIMING_ADDRESS = 0x0000000000000000000000000000000000000000;

    IOpenClaiming public constant oc = IOpenClaiming(OPENCLAIMING_ADDRESS);

    uint256 public constant PRICE = 1e18;

    function purchase(
        IOpenClaiming.Payment calldata payment,
        address[] calldata recipients,
        bytes calldata signature
    ) external payable {

        bool ok = oc.verifyPayment(payment, signature);
        require(ok, "invalid signature");

        bool success = oc.executePayment{value: msg.value}(
            payment,
            recipients,
            signature,
            payment.line,
            address(this),
            PRICE
        );

        require(success, "payment failed");

        _handlePurchase(payment.payer);
    }

    function _handlePurchase(address buyer) internal {
        // application logic
    }
}

---

# 🌐 Frontend Example (ethers.js)

import { ethers } from "ethers";

const domain = {
    name: "OpenClaiming.payments",
    version: "1",
    chainId: 1,
};

const types = {
    Payment: [
        { name: "payer", type: "address" },
        { name: "token", type: "address" },
        { name: "recipientsHash", type: "bytes32" },
        { name: "max", type: "uint256" },
        { name: "line", type: "uint256" },
        { name: "nbf", type: "uint256" },
        { name: "exp", type: "uint256" }
    ]
};

const recipients = [
    "0xRecipientAddress..."
];

const recipientsHash = ethers.keccak256(
    ethers.AbiCoder.defaultAbiCoder().encode(["address[]"], [recipients])
);

const value = {
    payer: signer.address,
    token: "0xTokenAddress...",
    recipientsHash,
    max: ethers.parseUnits("100", 18),
    line: 0,
    nbf: 0,
    exp: 0
};

const signature = await signer.signTypedData(domain, types, value);

---

# ⚠️ Important Notes

- Only EOAs sign claims
- No JSON parsing on-chain
- Off-chain must prepare all data correctly
- line 0 is valid
- max = 0 means unlimited
- claim max is enforced relative to line usage

---

# 🚫 What This Contract Does NOT Do

- does not parse JSON
- does not construct EIP-712 payloads
- does not sign messages
- does not store claims

All of that is handled off-chain.

---

# 📈 Summary

OpenClaiming EVM provides:

- portable signed payments
- deterministic EIP-712 verification
- trustline-based accounting
- composable execution layer

It turns signatures into executable economic primitives.
