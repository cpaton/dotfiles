# State-Based Testing

## Principle

Verify behaviour by inspecting **state** (the return value, the observable result), not by asserting on **interactions** (was this method called? how many times? with what arguments?). If you need to check a mock was called, the design probably needs a rethink.

## Prefer real implementations

Use the **real** implementation wherever possible. Only substitute at true system boundaries you cannot run in tests:

| Layer | Use real? | Why |
|-------|-----------|-----|
| Your own classes/modules | ✅ Always | You control them; they're fast |
| In-memory data stores | ✅ Yes | Cheap, fast, real behaviour |
| Cryptography (JWT signing, hashing) | ✅ Yes | Generate real keys/tokens in-test |
| SDK-provided test utilities | ✅ Yes | Use constructable versions the SDK provides |
| External HTTP APIs | Substitute | Use fake server or in-memory stub |
| Real databases | Maybe | Use test instance, in-memory, or embedded where possible |
| System clock | Substitute | Inject a clock/time provider |
| Filesystem | Maybe | Use temp directories or in-memory FS |

## How to make things testable without mocks

### Inject configuration, not services

Instead of injecting a mock validator, inject the **configuration** that lets a real validator work in tests:

```
# Production: discovers keys from identity provider
Validator(issuer: "https://idp.example.com", audience: "api")

# Test: uses pre-configured keys, no network
Validator(signing_key: test_key, issuer: "test-issuer", audience: "test-aud")
```

### Generate real test data

Instead of mocking what a token/response "would look like", generate a real one. Most languages have libraries for this:

- **JWTs** — generate with real RSA/HMAC keys and a standard JWT library
- **HTTP responses** — construct the actual response objects your code consumes
- **Database records** — insert real data into an in-memory or test database
- **Events/messages** — construct the actual event POCOs/structs the handler receives

### Use constructable types from SDKs

Many SDKs provide concrete implementations designed for testing:

- AWS: `TestLambdaContext`, constructable event classes (POCOs)
- ASP.NET: `TestServer`, `WebApplicationFactory`
- Express/Koa: `supertest`

Check the SDK documentation for test utilities before reaching for mocks.

## When substitution is acceptable

Substitute (not mock) at boundaries where real calls are:

- **Slow** (network latency)
- **Non-deterministic** (external state changes between runs)
- **Destructive** (writes to production systems)
- **Expensive** (costs money per call)

Even then, prefer **fakes** (lightweight in-memory implementations with real behaviour) over mocks (interaction-recording stubs):

```
# Bad: mock that records interactions
mock_gitlab.expect(:unblock_user).with(user_id).once

# Good: fake that maintains state
fake_gitlab = FakeGitLabServer.new
fake_gitlab.add_user(id: 42, state: "blocked")
# ... exercise the system ...
fake_gitlab.get_user(42).state  # => "active"
```

A fake that stores users in a hash/dictionary is better than a mock that asserts `unblock` was called once.

## The test: does it survive a refactor?

After writing a spec, mentally refactor the production code (rename a class, extract a method, change internal structure). If the spec would break, it's coupled to implementation. If it still passes, it's testing behaviour.
