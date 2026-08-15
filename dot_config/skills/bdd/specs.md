# Spec Structure and Naming

## File naming

Spec files are named after the **feature** they verify, not the class they test:

- `authorization_specs` — not `function_tests`
- `gitlab_account_status_specs` — not `account_controller_tests`
- `unblock_eligibility_specs` — not `license_service_tests`

Use the file naming convention of the project's language (e.g. `AuthorizationSpecs.cs` in C#, `authorization_specs.rb` in Ruby, `authorization.spec.ts` in TypeScript).

## Context naming (classes / describe blocks)

Contexts use **snake_case** (or the language's equivalent readable format) to read as natural-language scenarios. Each context represents the state of the world when the behaviour is observed:

```
# C# — classes with snake_case
Authorizing_a_request_with_a_valid_token
Unblocking_an_account_when_license_limit_reached

# Ruby/RSpec — describe/context strings
describe "authorizing a request with a valid token"
context "when the license limit is reached"

# TypeScript/Jest — describe strings
describe("authorizing a request with a valid token", ...)
describe("unblocking an account when license limit reached", ...)
```

## Behaviour naming (methods / it blocks)

Name the expected **outcome**, prefixed with `Should_` (or `should`/`it` in the language's idiom):

```
# C#
Should_allow_the_request
Should_forward_the_gitlab_username_claim
Should_deny_the_request

# Ruby/RSpec
it "allows the request"
it "forwards the gitlab username claim"

# TypeScript/Jest
it("should allow the request", ...)
it("should forward the gitlab username claim", ...)
```

## Context structure

Each context sets up the scenario (the "given/when") in setup, then each behaviour asserts one outcome (the "then"):

```
Context: Authorizing a request with a valid token
  Setup: generate a valid token, call the authorizer
  Behaviour: should allow the request
  Behaviour: should forward the gitlab username claim
  Behaviour: should not forward the exp claim
```

One setup per context. Multiple assertions (one per method/it block) against the shared result.

## Helper classes / modules

Helper code (factories, builders, fakes) follows the **standard naming convention of the language** — only spec contexts use snake_case:

- `TokenFactory` (C#), `token_factory.rb` (Ruby), `tokenFactory.ts` (TypeScript)

## Constants in factories

Factories expose **constants** for any values used in both creation and assertion. Specs reference the constant — never duplicate the value:

```
# The factory defines the value once
TokenFactory.GitlabUsername = "joebloggs"

# The spec asserts against the constant
response.context["gitlab_username"].should == TokenFactory.GitlabUsername
```

Changing a test value requires editing one place only.

## Organising specs

```
tests/
├── helpers/
│   ├── TokenFactory         (generates test JWTs, HTTP responses, etc.)
│   └── FakeGitLabServer     (in-memory substitute for external API)
├── AuthorizationSpecs       (feature: JWT authorizer behaviour)
├── AccountStatusSpecs       (feature: fetching GitLab account state)
└── UnblockEligibilitySpecs  (feature: license check and unblock logic)
```

Group by feature. One spec file can contain multiple contexts for the same feature.
