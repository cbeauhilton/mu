# Datastar Patterns

Idiomatic patterns for real-world applications.

---

## The Fundamental Pattern: CQRS + SSE

Every Datastar app follows this pattern:

```html
<!-- 1. Open stream for reads -->
<div id="resource" data-init="@get('/resource/stream')">
    <!-- Server pushes updates here -->

    <!-- 2. Commands mutate state -->
    <button data-on:click="@post('/resource/action')">
        Do Something
    </button>
</div>
```

```go
// Server: Stream handler
func streamResource(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "text/event-stream")

    // Send current state
    sendHTML(w, renderResource())

    // Subscribe to changes
    for update := range subscribe("resource") {
        sendHTML(w, renderResource())
    }
}

// Server: Command handler
func handleAction(w http.ResponseWriter, r *http.Request) {
    // Mutate state
    doSomething()

    // Publish change (subscribers will get it via stream)
    publish("resource", "updated")

    // Optionally send immediate response
    w.Header().Set("Content-Type", "text/event-stream")
    sendHTML(w, renderResource())
}
```

---

## Pattern: Todo List (Classic Example)

```html
<div id="app" data-signals:newTodo="''">
    <form data-on:submit__prevent="@post('/todos'); $newTodo = ''">
        <input data-bind:newTodo placeholder="What needs doing?">
        <button>Add</button>
    </form>

    <div id="todos" data-init="@get('/todos/stream')">
        <!-- Server renders todos here -->
    </div>
</div>
```

```go
// Backend renders HTML directly
func renderTodos(todos []Todo) string {
    var b strings.Builder
    b.WriteString(`<ul id="todos">`)
    for _, t := range todos {
        b.WriteString(fmt.Sprintf(`
            <li id="todo-%s">
                <span>%s</span>
                <button data-on:click="@delete('/todos/%s')">×</button>
            </li>
        `, t.ID, t.Text, t.ID))
    }
    b.WriteString(`</ul>`)
    return b.String()
}
```

---

## Pattern: Form with Validation

```html
<form id="signup"
      data-signals="{email: '', password: '', errors: {}}"
      data-on:submit__prevent="@post('/signup')">

    <div>
        <input data-bind:email type="email" placeholder="Email">
        <span data-show="$errors.email" data-text="$errors.email" class="error"></span>
    </div>

    <div>
        <input data-bind:password type="password" placeholder="Password">
        <span data-show="$errors.password" data-text="$errors.password" class="error"></span>
    </div>

    <button data-indicator:submitting data-attr:disabled="$submitting">
        <span data-show="!$submitting">Sign Up</span>
        <span data-show="$submitting">Creating account...</span>
    </button>
</form>
```

```go
func handleSignup(w http.ResponseWriter, r *http.Request) {
    email := r.FormValue("email")
    password := r.FormValue("password")

    errors := validate(email, password)
    if len(errors) > 0 {
        // Send validation errors as signals
        w.Header().Set("Content-Type", "text/event-stream")
        fmt.Fprintf(w, "event: datastar-patch-signals\n")
        fmt.Fprintf(w, "data: signals %s\n\n", toJSON(map[string]any{"errors": errors}))
        return
    }

    // Success - redirect or update UI
    createUser(email, password)
    w.Header().Set("Content-Type", "text/event-stream")
    fmt.Fprintf(w, "event: datastar-patch-elements\n")
    fmt.Fprintf(w, "data: selector #signup\n")
    fmt.Fprintf(w, "data: elements <div id=\"signup\">Account created!</div>\n\n")
}
```

---

## Pattern: Infinite Scroll

```html
<div id="feed" data-init="@get('/feed/stream')">
    <!-- Items rendered by server -->
</div>

<div data-on-intersect__once="@get('/feed/more')"
     data-indicator:loadingMore>
    <span data-show="$loadingMore">Loading more...</span>
</div>
```

```go
func handleFeedMore(w http.ResponseWriter, r *http.Request) {
    offset := getOffset(r)
    items := getMoreItems(offset)

    w.Header().Set("Content-Type", "text/event-stream")

    // Append new items
    fmt.Fprintf(w, "event: datastar-patch-elements\n")
    fmt.Fprintf(w, "data: selector #feed\n")
    fmt.Fprintf(w, "data: mode append\n")
    fmt.Fprintf(w, "data: elements %s\n\n", renderItems(items))
}
```

---

## Pattern: Modal Dialog

```html
<div data-signals:modalOpen="false">
    <button data-on:click="$modalOpen = true">Open Modal</button>

    <div data-show="$modalOpen" class="modal-backdrop"
         data-on:click__outside="$modalOpen = false">
        <div class="modal" data-on:keydown.escape__window="$modalOpen = false">
            <h2>Modal Title</h2>
            <p>Content here</p>
            <button data-on:click="$modalOpen = false">Close</button>
        </div>
    </div>
</div>
```

---

## Pattern: Tabs

```html
<div data-signals:activeTab="'overview'">
    <nav>
        <button data-on:click="$activeTab = 'overview'"
                data-class:active="$activeTab === 'overview'">Overview</button>
        <button data-on:click="$activeTab = 'details'"
                data-class:active="$activeTab === 'details'">Details</button>
        <button data-on:click="$activeTab = 'settings'"
                data-class:active="$activeTab === 'settings'">Settings</button>
    </nav>

    <div data-show="$activeTab === 'overview'">Overview content</div>
    <div data-show="$activeTab === 'details'">Details content</div>
    <div data-show="$activeTab === 'settings'">Settings content</div>
</div>
```

**Or load content from server:**
```html
<div data-signals:activeTab="'overview'">
    <nav>
        <button data-on:click="$activeTab = 'overview'; @get('/tabs/overview')">Overview</button>
        <button data-on:click="$activeTab = 'details'; @get('/tabs/details')">Details</button>
    </nav>

    <div id="tab-content" data-init="@get('/tabs/overview')">
        <!-- Server renders tab content here -->
    </div>
</div>
```

---

## Pattern: Search with Debounce

```html
<div data-signals:query="''">
    <input data-bind:query
           data-on:input__debounce.300ms="@get('/search?q=' + encodeURIComponent($query))"
           placeholder="Search...">

    <div id="results" data-indicator:searching>
        <span data-show="$searching">Searching...</span>
        <!-- Server renders results here -->
    </div>
</div>
```

---

## Pattern: Optimistic UI (Use Sparingly!)

The Tao says "don't deceive users with optimistic UI that might fail." But for low-risk actions:

```html
<button data-on:click="$liked = true; @post('/like')"
        data-class:liked="$liked">
    <span data-show="!$liked">♡</span>
    <span data-show="$liked">♥</span>
</button>
```

The server should send back the true state to correct any failed operations.

---

## Pattern: Real-time Collaboration (NATS + Datastar)

```go
// Server with embedded NATS
func main() {
    // Start embedded NATS with KV
    nc, _ := nats.Connect(nats.DefaultURL)
    js, _ := nc.JetStream()
    kv, _ := js.CreateKeyValue(&nats.KeyValueConfig{Bucket: "app"})

    http.HandleFunc("/doc/stream", func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "text/event-stream")

        // Watch KV for changes
        watcher, _ := kv.Watch("doc.*")
        for update := range watcher.Updates() {
            sendHTML(w, renderDoc(update.Value()))
        }
    })

    http.HandleFunc("/doc/edit", func(w http.ResponseWriter, r *http.Request) {
        // Update KV - watchers will see it
        kv.Put("doc.content", []byte(r.FormValue("content")))
    })
}
```

---

## Pattern: File Upload

```html
<form data-signals:file="null"
      data-on:submit__prevent="@post('/upload', {contentType: 'form'})">
    <input type="file" data-bind:file>
    <button data-indicator:uploading data-attr:disabled="$uploading">
        <span data-show="!$uploading">Upload</span>
        <span data-show="$uploading">Uploading...</span>
    </button>
</form>
```

Note: `data-bind` on file inputs sends base64-encoded content.

---

## Morph Initialization Boundary

Datastar only initializes `data-*` attributes on elements present at initial
page load. Elements delivered via SSE morph (`datastar-patch-elements`) get
their DOM updated but Datastar does **not** re-run plugin initialization on
new nodes. This means `data-signals`, `data-bind`, `data-on:*` placed on
morphed-in elements are inert — they exist as HTML attributes but never fire.

Morph diffs and patches *changed attributes on existing elements*. It does
not call the initialization pipeline on elements that didn't exist before.

### Delegation pattern

Put all Datastar attributes on a **stable ancestor** — an element that exists
in the initial HTML shell, not one delivered by SSE:

```html
<!-- main exists at page load — Datastar initializes it -->
<main id="app"
      data-signals:displayName="''"
      data-on:focusout="
        if (evt.target.matches('.editable-input')) {
          $displayName = evt.target.value;
          @post(evt.target.dataset.postUrl);
        }
      "
      data-on:click="
        let btn = evt.target.closest('.action-btn');
        if (btn) { @post(btn.dataset.actionUrl); }
      ">

  <!-- This entire subtree can be morphed freely.
       The inputs below have NO data-* attributes — they're
       plain HTML. The delegation handler on <main> reads
       their values from evt.target. -->
  <div id="content" data-init="@get('/stream')">
    <input class="editable-input"
           data-post-url="/item/123/rename"
           value="current name"/>
    <button class="action-btn"
            data-action-url="/item/123/delete">Delete</button>
  </div>
</main>
```

### Key rules

- **`focusout` bubbles, `blur` doesn't.** Use `focusout` for delegation on
  inputs. Same for `focusin` vs `focus`.
- **Read DOM values directly** — `data-bind` on a morphed input is dead, so
  read `evt.target.value` in the handler and push to the signal manually.
- **Server drives canonical state** — the next morph overwrites the input's
  `value` attribute with whatever the server rendered. The signal is just a
  transient vehicle for the POST, not the source of truth.
- **`data-*` on morphed elements for data, not behavior** — plain HTML
  attributes like `data-post-url` or `data-action-url` survive morphing fine.
  Only *Datastar-processed* attributes (`data-on:*`, `data-bind`, etc.) are
  affected by the initialization boundary.

---

## Northstar Architecture (Canonical)

```
┌─────────────────────────────────────────────────┐
│                   Browser                        │
│  ┌─────────────────────────────────────────┐    │
│  │  data-init="@get('/stream')"            │    │
│  │  data-on:click="@post('/action')"       │    │
│  └─────────────────────────────────────────┘    │
└───────────────────────┬─────────────────────────┘
                        │ SSE
                        ▼
┌─────────────────────────────────────────────────┐
│                 Go Server                        │
│  ┌─────────────┐    ┌─────────────────────┐     │
│  │   Handlers  │───▶│  Templ Templates    │     │
│  └──────┬──────┘    └─────────────────────┘     │
│         │                                        │
│         ▼                                        │
│  ┌─────────────────────────────────────────┐    │
│  │           Embedded NATS                  │    │
│  │  ┌─────────────────────────────────┐    │    │
│  │  │         KV Store (state)        │    │    │
│  │  └─────────────────────────────────┘    │    │
│  └─────────────────────────────────────────┘    │
└─────────────────────────────────────────────────┘
```

Key points:
- No REST API layer
- Server directly manipulates NATS KV
- KV changes trigger SSE pushes to all connected clients
- Templ renders HTML on server
- Frontend is a dumb terminal

---

## Session State (Not URL State)

```go
// Session middleware
func withSession(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        cookie, _ := r.Cookie("session_id")
        if cookie == nil {
            // Create new session
            sessionID := uuid.New().String()
            http.SetCookie(w, &http.Cookie{Name: "session_id", Value: sessionID})
        }
        // Load session state from DB/KV
        session := loadSession(cookie.Value)
        ctx := context.WithValue(r.Context(), "session", session)
        next.ServeHTTP(w, r.WithContext(ctx))
    })
}

// Handler uses session for state, not URL params
func handleProducts(w http.ResponseWriter, r *http.Request) {
    session := r.Context().Value("session").(*Session)

    // Filters come from session, not URL
    products := getProducts(session.Filters)

    // Render based on session state
    renderProducts(w, products, session.SortOrder)
}
```
