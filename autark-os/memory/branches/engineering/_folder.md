# Engineering branch

Repos, reviews, releases. The rule that matters most here: this layer is additive. Nothing under
`apps/` is edited, so `git pull upstream main` stays clean and the app's own boundary rules
(runtime never imports electron; UI only speaks RPC; shared stays pure) are untouched.
