# NATS Security Architecture

## Authentication Paradigms

### Operator Paradigm (Production, Multi-Tenant)

Hierarchical key signing: Operator signs Account, Account signs User/Module. Credentials resolve dynamically — no static config files to distribute at scale.

```
Operator (root of trust)
  └─ Account (tenant boundary, signed by operator)
     ├─ User (ephemeral credentials, signed by account)
     └─ Module/Service (automation keys, signed by account)
```

Use when: cloud deployments, IoT with device churn, multi-region, multi-tenant.

### Configuration-Based (Dev, Small Deployments)

Static file-based account/user definitions in `nats.conf`. Operators generate NKeys, distribute via config management.

Use when: development, single-tenant, config-as-code deployments.

Hybrid is fine — operator-generated keys referenced in static config files.

---

## JWT Resolvers

The resolver determines how the server fetches account JWTs at connection time.

| Resolver | Mechanism | Use Case |
|----------|-----------|----------|
| **Memory** | Loaded at startup, held in RAM | Development, testing |
| **File** | Read from local filesystem | Static deployments, config-as-code |
| **URL** | Fetched from HTTP endpoint | Dynamic credential management, webhook-based auth |
| **Full/Mesh** | Cluster nodes replicate internally | Production clusters, peer-to-peer credential sharing |

---

## Auth Callout (Legacy Integration)

Delegates authentication to external systems: LDAP, OAuth, OIDC, custom identity providers.

**Flow:**
1. Client connects with credentials
2. Server invokes auth callout service (a NATS service on a designated subject)
3. Callout returns signed user JWT or rejection
4. Server allows/denies connection

**Lifecycle:** Credential rotation requires disconnect + reconnect. The callout is invoked per connection, not per message.

**Constraint:** An individual account cannot mix Auth Callout + JWT resolver. Pick one per account.

---

## Account-Based Authorization

Accounts are security boundaries. Cross-account data sharing uses explicit exports/imports:

- **Stream exports** (pub/sub): Account A exports a subject; Account B imports it as a subscription. Read-only data flow.
- **Service exports** (request/reply): Account A exports an RPC endpoint; Account B imports it and can send requests. Bidirectional.

This enables precise cross-team/cross-tenant data sharing without opening the full subject space.

---

## Mixed Authentication Modes

A single cluster can run different auth mechanisms on different accounts simultaneously:

- Account A: static (file-based)
- Account B: JWT resolver (dynamic)
- Account C: auth callout (delegated to LDAP)

Each account picks one mechanism. The cluster handles routing transparently.

---

## Anti-Patterns

| Don't | Do Instead |
|-------|------------|
| File-based config for large/dynamic deployments | Operator paradigm + JWT resolvers |
| Mix auth callout + JWT on same account | One mechanism per account; use separate accounts |
| Static credentials in high-churn environments | Operator paradigm with key expiry/rotation |
| Credential rotation without planning for disconnects | Auth callout rotation drops connections; design clients for reconnect |

---

## Tools

- `nsc` — Operator/account/user management, JWT generation
- `nkeys` — NKey generation (ed25519 keypairs)
- `nats server check connection` — Verify auth setup
