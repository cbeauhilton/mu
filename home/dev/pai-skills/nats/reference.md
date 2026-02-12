# NATS Deep Reference

## Jepsen Findings (NATS 2.12.1, December 2025)

Jepsen tested NATS 2.12.1's JetStream and found real durability issues. A seasoned operator knows these cold.

### The fsync Problem (#7564)

NATS acknowledges publishes immediately but fsyncs to disk only every 2 minutes (default `sync_interval`). This means:

- Coordinated power failure lost 131,418 of 930,005 messages (14.1%)
- A single OS crash + network delay can cause persistent split-brain
- Different nodes permanently lose different windows of writes

**Mitigation:** Set `sync_interval: always` for critical data. Accept the throughput trade-off. Or accept the risk and design for idempotency + replay.

**The operator's take:** For event-sourced systems where the stream IS the source of truth, `sync_interval: always` is worth considering for production clusters. For embedded single-node (development, small deployments), the default is fine — there's no replication to diverge.

### File Corruption (#7549, #7556)

- `.blk` file corruption on a minority of nodes caused loss of up to 679K of 1.4M writes
- Snapshot corruption caused nodes to declare streams "orphaned" and delete all data
- Corrupted nodes could become leaders and propagate the corruption

**Status:** Improved in 2.12.3 (peer removal fixes). Corruption handling still under investigation.

### Total Stream Loss (#6888, Fixed in 2.10.23)

Process crashes in 2.10.20-2.10.22 could cause entire streams to vanish. Fixed in 2.10.23.

### Operator Recommendations

1. Run 2.12.3+ (latest fixes for peer removal)
2. For critical data: `sync_interval: always`
3. Regular backups (`nats account backup` / `mcp__nats__account_backup`)
4. Monitor stream state — check message counts and sequence numbers
5. Design for replay — consumers should be idempotent

---

## NATS 2.12 Features (December 2025)

### Atomic Batch Publishing

All-or-nothing publish of multiple messages. Server guarantees the entire batch is stored or none of it is.

**Headers:**
- `NATS-Batch-ID` — unique batch identifier (on first message)
- `NATS-Batch-Sequence` — 1-indexed position within batch
- `NATS-Batch-Commit` — present on last message, triggers atomic commit

```go
// Using orbit.go jetstreamext
import "github.com/synadia-io/orbit.go/jetstreamext"

batcher := jetstreamext.NewBatchPublisher(js)
batcher.Add("events.order.created", orderPayload)
batcher.Add("events.order.audit", auditPayload)
err := batcher.Commit(ctx)  // atomic — all or nothing
```

**Requirements:**
- Stream must opt in: `--allow-batch` or `AllowBatch: true`
- Stream must NOT use async persist mode
- Batches cannot span multiple streams

**Default limits (all configurable):**
- 1,000 messages per batch
- 50 concurrent batches per stream
- 1,000 total batches per server
- 10-second inactivity timeout before batch abandonment

**Use cases:** Multi-entity transactions, saga steps, event + audit pairs, cross-aggregate consistency.

### Expected Sequence Headers (Optimistic Concurrency)

Server-side compare-and-swap for publish operations. Three types:

| Header | Checks Against |
|--------|---------------|
| `Nats-Expected-Last-Sequence` | Global stream sequence |
| `Nats-Expected-Last-Subject-Sequence` | Per-subject sequence |
| `Nats-Expected-Last-Msg-Id` | Previous message ID |

```go
msg := &nats.Msg{
    Subject: "orders.123",
    Data:    payload,
    Header:  nats.Header{},
}
msg.Header.Set("Nats-Expected-Last-Subject-Sequence", "5")
ack, err := js.PublishMsg(ctx, msg)
// err if current sequence for orders.123 != 5
```

**Gotcha:** Expected values are actual stream-global sequence numbers, NOT independent per-subject counters starting from zero. Applications must capture and propagate the sequence number returned in publish acks.

**Use case:** Prevent concurrent writes to the same entity. CAS without external locks.

### Distributed Counters

Server-side atomic counters via `AllowMsgCounter` stream config.

```go
// Enable on stream
jetstream.StreamConfig{
    // ...
    AllowMsgCounter: true,
}

// Increment via header
msg.Header.Set("Nats-Expected-Last-Subject-Sequence", "0")  // create-if-not-exists
// Counter value returned in publish ack
```

---

## NATS 2.11 Features (January 2026)

### Message Tracing

End-to-end visibility into message routing. Critical for debugging subject mapping, authorization, and multi-tenant flows.

**Trace headers:**
- `Nats-Trace-Dest` — subject where trace events are published
- `Nats-Trace-Only` — trace without delivering the message (dry run, default in CLI)
- `Nats-Trace-Hop` — hierarchical hop tree (1, 1.1, 1.2) showing fan-out

**Trace event types:** `IN` (ingress), `EG` (egress), `JS` (JetStream storage), `SE`/`SI` (account export/import boundary), `SM` (subject mapping transform)

**CLI:**
```bash
nats trace "orders.created.123"              # trace routing for subject
nats trace "orders.>" --trace-only           # dry run, no delivery
```

**Cross-account:** Requires explicit opt-in via `allow_trace` in account config. Traces stay within the initiating account unless explicitly allowed.

### Consumer Pausing

Temporarily pause a consumer without destroying it. State (ack floor, pending) is preserved.

```go
consumer, _ := js.Consumer(ctx, "STREAM", "my-consumer")
consumer.Pause(ctx, time.Now().Add(30*time.Minute))  // pause for 30 min
consumer.Resume(ctx)                                   // resume early
```

```bash
nats consumer pause STREAM my-consumer --until "2026-01-15T12:00:00Z"
nats consumer resume STREAM my-consumer
```

**Use cases:** Maintenance windows, backpressure relief, consumer upgrades without message loss.

### Priority Groups (pcgroups)

Kafka-style consumer group semantics. Available via orbit.go.

```go
import "github.com/synadia-io/orbit.go/pcgroups"
```

---

## Orbit.go (Client Extensions)

`github.com/synadia-io/orbit.go` — Synadia's official client-side extension library. Not in core nats.go; separate import.

| Module | Purpose |
|--------|---------|
| `natsext` | `RequestMany` — fan-out request/reply |
| `jetstreamext` | Atomic batch publishing, batch get |
| `pcgroups` | Priority consumer groups (Kafka-style) |
| `kvcodec` | Typed KV with marshal/unmarshal |
| `counters` | Distributed counter helpers |
| `natscontext` | Context file management |
| `natssysclient` | System account client helpers |

---

## JetStream Storage Tiers

### Stream (Source of Truth)
- Immutable, append-only event log
- `DenyDelete: true`, `DenyPurge: true` for event sourcing
- Subjects encode domain hierarchy
- Single stream + wildcard consumers > many narrow streams
- `S2Compression` for storage savings

### KV (Materialized Views)
- Built by consumers reading the stream
- `kv.Watch()` drives reactive SSE loops
- One bucket per view/projection
- `Compression: true` — always worth it
- Use granular keys for targeted watchers
- Rebuildable from stream replay

### Object Store (Large Data)
- Chunks data across messages transparently
- For large blobs: clinical data, datasets, binary assets, TRON documents
- Not for the reactive SSE loop (too large for per-update pushes)

**The Rule:** Stream is truth. KV is derived. Object Store is for big things.

---

## JetStream Anti-Patterns & Performance (from Synadia blog, Jan/Aug 2025)

### Consumer Scaling Limits

| Metric | Threshold | Why |
|--------|-----------|-----|
| Consumers per stream | <100K | Metadata overhead grows linearly |
| Disjoint filter subjects per consumer | <300 | Server evaluates all filters per message |
| Consumer info calls | Minimize | Use `CreateOrUpdateConsumer` (idempotent) instead of check-then-create |

### Memory Usage Drivers

1. **Dedup tables** — Each stream tracks `MaxMsgId` entries. Tune `Duplicates` window (default 2min)
2. **File store cache** — Recently accessed blocks cached in memory. Configurable per stream
3. **Metadata tracking** — Per-subject tracking for `DeliverLastPerSubject`. More subjects = more memory
4. **Meta leader overhead** — The meta leader holds all stream/consumer configs in memory

### Performance Alternatives

| Instead of... | Consider... |
|---------------|-------------|
| Many consumers reading same data | `Republish` to fan out |
| Consumer for simple key lookup | `Direct Get API` for point reads |
| Consumer info polling | Idempotent `CreateOrUpdateConsumer` |
| Many narrow streams | One broad stream + filtered consumers |

---

## Subject Mapping & Transforms

### Basic Mapping
```
"foo.bar" : "baz.quux"
```

### Wildcard Reordering
```
"bar.*.*" : "baz.{{wildcard(2)}}.{{wildcard(1)}}"
```

### Token Functions
- `{{wildcard(n)}}` — reference wildcard by position
- `{{split(separator)}}` — split on character
- `{{splitfromleft(index, offset)}}` / `{{splitfromright(index, offset)}}`
- `{{slicefromleft(index, chars)}}` / `{{slicefromright(index, chars)}}`
- `{{partition(num_partitions, token_positions...)}}` — deterministic partitioning

### Weighted Mappings (Canary/A-B Testing)
```
myservice.requests: [
  { destination: myservice.requests.v1, weight: 98% },
  { destination: myservice.requests.v2, weight: 2% }
]
```

### Cluster-Scoped Mappings
```
mappings = {
  "foo": [
    {destination: "foo.west", weight: 100%, cluster: "west"},
    {destination: "foo.central", weight: 100%, cluster: "central"}
  ]
}
```

### Deterministic Partitioning
```
"neworders.*" : "neworders.{{wildcard(1)}}.{{partition(3,1)}}"
```
Creates 3 partitions. Same key always maps to same partition. Enables parallel processing with per-key ordering.

### Transform Scopes
Transforms apply at: root config, account level, import subjects, stream ingress, sources/mirrors, republish. They fire before routing/subscription matching. Non-recursive within a single scope.

### Testing
```bash
nats server mapping "source.subject" "dest.pattern"  # test rules
nats trace subject.name                                # trace routing (2.11+)
```

---

## Consumer Patterns

### Durable Pull Consumer (Standard)
```go
cons, _ := js.CreateOrUpdateConsumer(ctx, "STREAM", jetstream.ConsumerConfig{
    Name:          "my-processor",
    Durable:       "my-processor",
    FilterSubject: "events.orders.>",
    DeliverPolicy: jetstream.DeliverAllPolicy,
    AckPolicy:     jetstream.AckExplicitPolicy,
})

// Fetch messages
msgs, _ := cons.Fetch(10)
for msg := range msgs.Messages() {
    // process
    msg.Ack()
}
```

### Push Consumer (Niche Use)
Pull consumers are preferred for most workloads — they give the client flow control. Push consumers still have a place for low-volume discrete events needing immediate action (e.g., workflow pause/cancel signals). Production-validated pattern from Vitrifi: pull for high-volume state changes, push for urgent control events.

### Ephemeral Consumers
No `Durable` name. Useful for one-off queries or temporary subscriptions. Automatically cleaned up.

### Replay Strategies
- `DeliverAllPolicy` — replay from the very beginning (rebuilding projections)
- `DeliverLastPolicy` — latest message only
- `DeliverLastPerSubjectPolicy` — latest per subject (KV-like semantics)
- `DeliverNewPolicy` — only new messages from now
- `DeliverByStartSequencePolicy` — from a specific sequence
- `DeliverByStartTimePolicy` — from a specific time

### Dead Letter Queue via Advisories

Subscribe to advisory subjects to capture messages that exceed `MaxDeliver`:

```go
// Subscribe to DLQ advisories
nc.Subscribe("$JS.EVENT.ADVISORY.CONSUMER.MAX_DELIVERIES.STREAM.*", func(msg *nats.Msg) {
    // Parse advisory JSON to get stream_seq
    // Retrieve original message via stream.GetMsg(ctx, seq)
    // Inspect, log, or reprocess
})
```

Set `MaxDeliver: 2` with `BackOff: [5*time.Second]` for fail-fast-to-DLQ rather than retry storms.

### Consumer Best Practices
1. Always `AckExplicit` — never `AckNone` for important data
2. Use `FilterSubject` — let the server filter, not the client
3. Name consumers meaningfully — they're visible in monitoring
4. Set `MaxDeliver` for poison message protection
5. Use `AckWait` wisely — too short = redelivery storms
6. Use idempotent `CreateOrUpdateConsumer` — don't check-then-create
7. Keep disjoint filter subjects under 300 per consumer
8. **Never churn durable consumers** — creating/destroying thousands in bursts causes Raft instability

---

## Leaf Nodes & Edge Patterns

### Hub-and-Spoke (Canonical Edge Pattern)
Leaf nodes connect to a hub cluster. Each leaf sees only its own traffic + explicitly imported subjects.

**Key optimization:** Use identical cluster names on leaf nodes to prevent subscription propagation across leaves. Without this, every subscription on one leaf propagates to all others via the hub.

### Multi-Cluster Consistency Models

Four models, each with distinct trade-offs:

| Model | Consistency | Write Latency | Failure Tolerance |
|-------|-------------|---------------|-------------------|
| Single cluster (R3/R5) | Immediate (RAFT majority) | Local | AZ failures |
| Super-cluster (mirrors/sources) | Eventual | Local | Region failures (reads only) |
| Stretch cluster (cross-region RAFT) | Immediate | Inter-region RTT | Region failures (R5 = 2 regions) |
| Virtual streams (2.10+) | Eventual | Local | Region isolation (publish continues) |

**Virtual streams** (most complex, best latency): Each region has a write stream (region-specific subjects) + read stream (sources from all write streams). Cluster-scoped subject mappings route transparently.

**Virtual stream limitations:**
- No `WorkQueue` or `Interest` retention
- KV CAS impossible (sequence numbers discontinuous across regions)
- Named durable consumers are per-region, not global
- Ordering not guaranteed across regions after split-brain reconnect

### Leaf Node Daisy-Chaining

Leaf nodes can chain: edge device -> plant gateway -> regional hub -> cloud. Each hop has its own store-and-forward buffer. Built-in MQTT support means IoT devices bridge directly into JetStream without a separate broker.

### Cross-Domain Mirroring (Edge Replication)

Edge leaf nodes run local JetStream with their own domain. Mirror chains replicate to cloud:

```
STATIONTX-LOCAL (edge, 2-day retention)
  --> mirror --> STATIONTX-HISTORY (cloud, long retention)
    --> mirror --> STATIONTX-PROCESS (cloud, work queue)
```

Configure external domain access: `$JS.<domain>.API`. Combine with `Nats-Msg-Id` dedup headers for exactly-once semantics across the mirror chain.

---

## Reliable Delivery Pattern

Request-based publishing (not fire-and-forget) for critical messages:

```go
// Publish with dedup ID and wait for JetStream ack
msg := &nats.Msg{
    Subject: "orders.created",
    Data:    payload,
    Header:  nats.Header{},
}
msg.Header.Set(nats.MsgIdHdr, txnID)  // dedup within window
ack, err := js.PublishMsg(ctx, msg)     // request-reply to JetStream
if err != nil {
    // client-side retry — dedup prevents duplicates
}
```

The dedup window is configurable per stream (default 2 minutes). Set it to match your retry timeout.

---

## Audit & Compliance ($SYS Subjects)

Stream `$SYS` subjects to JetStream for tamper-resistant audit trails:

| Subject | Event |
|---------|-------|
| `$SYS.ACCOUNT.*.CONNECT` | Client connections |
| `$SYS.ACCOUNT.*.DISCONNECT` | Client disconnections |
| `$SYS.SERVER.*.CLIENT.AUTH.ERR` | Authentication failures |
| `$SYS.ACCOUNT.*.LEAFNODE.CONNECT` | Leaf node connections |
| `$SYS.ACCOUNT.*.LEAFNODE.DISCONNECT` | Leaf node disconnections |

JetStream CRUD operations emit advisories with user identity. Streams are tamper-proof (exception: GDPR message erasure). **Caveat:** Events may not be generated during hardware failure or unexpected server shutdown.

---

## Connectors (Wombat/Benthos)

NATS connectors use the Wombat (formerly Benthos) runtime for data integration.

- **Bloblang** scripting language for transforms
- Dynamic subject routing based on message content
- Bidirectional: NATS ↔ Kafka, databases, HTTP, cloud services
- Runs as a standalone process or embedded

---

## NATS RPC (Proto Codegen)

The `toolbelt/natsrpc` package provides proto extensions for generating type-safe NATS clients/servers:

```protobuf
extend google.protobuf.ServiceOptions {
  optional bool is_not_singleton = 12337;
}

extend google.protobuf.MessageOptions {
  optional string kv_bucket = 13337;
  optional bool kv_client_readonly = 13338;
  optional google.protobuf.Duration kv_ttl = 13339;
  optional uint32 kv_history_count = 13340;
}

extend google.protobuf.FieldOptions {
  optional bool kv_id = 14337;
}
```

### RPC Patterns
- Unary: `rpc Method(Request) returns (Response)`
- Client streaming: `rpc Method(stream Request) returns (Response)`
- Server streaming: `rpc Method(Request) returns (stream Response)`
- Bidirectional: `rpc Method(stream Request) returns (stream Response)`

---

## Version History (Key Releases)

| Version | Date | Notable Changes |
|---------|------|----------------|
| 2.10 | 2024 | Subject mapping transforms, weighted mappings, cluster-scoped mappings, S2 stream compression, consumer batch/expires |
| 2.10.23 | 2024 | Fixed total stream loss on crash (#6888) |
| 2.11 | Jan 2026 | Message tracing (`nats trace`), consumer pausing, priority groups, `allow_trace` cross-account |
| 2.12 | Dec 2025 | Atomic batch publishing, expected sequence headers, distributed counters (`AllowMsgCounter`) |
| 2.12.1 | Dec 2025 | Jepsen-tested version — fsync and corruption issues identified |
| 2.12.3 | Dec 2025 | Peer removal fixes from Jepsen findings, used in northstar |

---

## Licensing (Resolved)

**NATS is Apache 2.0.** Synadia announced BSL on Apr 25, 2025. Community backlash was swift. Reversed 18 days later (May 13, 2025). NATS remains Apache 2.0 under CNCF governance. Synadia is building a separate commercial distribution. The open-source project is unaffected.

---

## Go Client Library (nats.go)

### Current Version
`github.com/nats-io/nats.go` v1.48.0 (northstar), v1.47.0 (toolbelt)

### Key Imports
```go
import (
    "github.com/nats-io/nats.go"
    "github.com/nats-io/nats.go/jetstream"
)
```

### Connection
```go
nc, _ := nats.Connect(nats.DefaultURL)           // localhost:4222
nc, _ := nats.Connect("nats://host:4222",
    nats.UserInfo("user", "pass"),
    nats.MaxReconnects(-1),                       // infinite reconnect
    nats.ReconnectWait(time.Second),
)
```

### JetStream
```go
js, _ := jetstream.New(nc)

// Create/update stream
stream, _ := js.CreateOrUpdateStream(ctx, jetstream.StreamConfig{...})

// Create/update consumer
cons, _ := js.CreateOrUpdateConsumer(ctx, "STREAM", jetstream.ConsumerConfig{...})

// Publish
js.Publish(ctx, "subject", payload)
js.PublishMsg(ctx, &nats.Msg{Subject: "subject", Data: payload, Header: nats.Header{...}})
```

---

## NixOS Integration

### Packages (in dev.nix)
- `nats-server` — NATS server binary
- `natscli` — `nats` CLI
- `nats-top` — real-time monitoring
- `nsc` — account/operator management
- `nkeys` — NKey generation

### MCP NATS (in claude-code.nix)
Overlay at `overlays/mcp-nats.nix` builds `mcp-nats` v0.1.3 from `sinadarbouy/mcp-nats`. Configured as MCP server in Claude Code.

### Authentication
The MCP server supports: credentials-based (`NATS_<ACCOUNT>_CREDS`), user/password (`NATS_USER`/`NATS_PASSWORD`), or anonymous (`NATS_NO_AUTHENTICATION`).
