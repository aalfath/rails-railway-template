# Rails + Postgres starter for Railway

A small, production-ready Rails app you can deploy on [Railway](https://railway.com) in one click and then make your own.

- **Rails 8.1.4.1** on **Ruby 4.0.9** (pinned in `.ruby-version` and `Gemfile.lock`)
- **PostgreSQL** for everything: your tables, plus Solid Queue (background jobs), Solid Cache (`Rails.cache`) and Solid Cable (Action Cable) in the same database
- Hotwire (Turbo + Stimulus), Propshaft and importmap: no Node.js build step
- One example resource, `Post` (a standard scaffold), and one example background job, `PostCreatedJob`, that runs after each new post
- Built by Railway's default builder (Railpack). There's no Dockerfile.

## Deploy

Use the Rails + Postgres template on Railway. It creates two services:

| Service | What it does |
|---|---|
| `web` | This repo. Puma serves the app, and Solid Queue runs the jobs inside the same process (`SOLID_QUEUE_IN_PUMA`) |
| `Postgres` | Railway's PostgreSQL, with a volume for the data |

The template sets these variables on `web`:

| Variable | Value | Why |
|---|---|---|
| `DATABASE_URL` | `${{Postgres.DATABASE_URL}}` | Connects to the database over Railway's private network |
| `SECRET_KEY_BASE` | `${{secret(128, "abcdef0123456789")}}` | Signs and encrypts cookies. Generated once per deploy |

On every deploy Railway runs `bin/rails db:prepare` before starting the new version (the pre-deploy command in `railway.json`). It creates the database on the first deploy and runs pending migrations after that. The health check is Rails' built-in `/up`.

`RAILS_ENV=production`, `SOLID_QUEUE_IN_PUMA=true` and `BUNDLE_WITHOUT=development:test` are set in `railpack.json`, so they come with the code. You can override any of them with a service variable.

## Make it yours

After deploying, open the `web` service in Railway, go to **Settings → Source** and click **Eject**. Railway copies this repo into your own GitHub account and redeploys from it. From then on, every push to your repo's default branch deploys.

Then clone your copy and start editing:

- `app/models`, `app/controllers`, `app/views`: your app. `Post` is only an example, so delete it when you don't need it: `bin/rails destroy scaffold Post`, then add a migration that drops the `posts` table.
- `app/jobs`: background jobs. Call `MyJob.perform_later(...)` and Solid Queue runs it.
- `config/recurring.yml`: scheduled jobs (cron-style).
- `config/routes.rb`: the home page is `posts#index`. Change `root` to your own page.
- `db/migrate`: `bin/rails g migration ...`. Railway runs new migrations on the next deploy.

When you need more job throughput, run Solid Queue as its own service: add a second service from the same repo with the start command `bin/jobs`, and set `SOLID_QUEUE_IN_PUMA=false` on `web`.

## Run it locally

You need Ruby 4.0.9 (for example through [mise](https://mise.jdx.dev) or rbenv) and PostgreSQL.

```sh
# Start Postgres, if you don't already have it running
docker run -d --name pg -p 5432:5432 -e POSTGRES_PASSWORD=postgres postgres:18

bundle install
export DATABASE_URL=postgres://postgres:postgres@localhost:5432
bin/rails db:prepare
bin/dev            # http://localhost:3000
```

Without `DATABASE_URL`, Rails connects to a local Postgres over its Unix socket and uses the `myapp_development` database.

Tests and checks:

```sh
RAILS_ENV=test bin/rails db:test:prepare test
bin/rubocop
bin/brakeman
```

`bin/ci` runs the full set, and the same checks run on GitHub Actions (`.github/workflows/ci.yml`).

## Secrets

There's no `config/master.key` or `config/credentials.yml.enc` in this repo, and production reads `SECRET_KEY_BASE` from the environment. If you want encrypted credentials, run `bin/rails credentials:edit` to create your own, then add the new `config/master.key` value to Railway as `RAILS_MASTER_KEY`. Never commit the key.

## Licence

MIT. See [LICENSE](LICENSE).
