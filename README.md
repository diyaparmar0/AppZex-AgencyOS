# AppZex AgencyOS — Full Stack Developer Assignment

A production-minded multi-tenant agency project-management SaaS built for the AppZex technical assignment.

## What is included

- **Super Admin portal** — platform dashboard, agency search/filter, status control, support mode, activity log.
- **Agency workspace** — dashboard, clients, projects, tasks, milestones, meetings, feedback, files and team management.
- **Client portal** — isolated client login, project progress, shared updates/meetings/files and change requests.
- **Multi-tenancy** — agency ID is enforced server-side on operational queries; client records are additionally scoped by client ID.
- **Authentication** — HTTP-only signed session cookie and bcrypt password hashes.
- **Derived progress** — project progress is calculated from completed tasks, never manually typed.
- **File security** — file content is stored behind an authenticated download route; clients can only download files explicitly shared with their own projects.
- **AI Project Health** — analyzes only the selected agency/project data. If `OPENAI_API_KEY` is present it uses the configured OpenAI model; otherwise it uses a deterministic local fallback so the workflow remains usable without an API key.
- **Same-origin API** — the browser calls `/api/*` inside the same Next.js deployment. There is no separate frontend API URL and no CORS dependency.

## Stack

- Next.js 14 (frontend + Node.js route handlers)
- React 18
- MySQL 8+
- mysql2
- bcryptjs
- jose (signed JWT session cookie)
- Optional OpenAI API for the AI workflow

## Local setup

1. Install Node.js 20+.
2. Create a MySQL database and user.
3. Copy `.env.example` to `.env.local`.
4. Set `DATABASE_URL` and `AUTH_SECRET`.
5. Run the SQL schema:

```bash
mysql -u root -p < schema.sql
```

6. Install packages and seed demo data:

```bash
npm install
npm run seed
npm run dev
```

Open `http://localhost:3000`.

## Demo credentials

All demo accounts use password `Demo@1234`.

| Role | Email |
|---|---|
| Super Admin | `super@appzex.com` |
| Pixel Forge Admin | `admin@pixel.com` |
| Pixel Forge Team | `member@pixel.com` |
| Pixel / Nova Fitness Client | `client1@pixel.com` |
| Pixel / Greenleaf Client | `client2@pixel.com` |
| Northwind Admin | `admin@northwind.com` |
| Northwind Team | `member@northwind.com` |
| Northwind / Acme Client | `client1@northwind.com` |

## Architecture decisions

### Same-origin API
The previous split frontend/backend pattern was intentionally removed. The browser now calls Next.js route handlers on the same origin. This avoids a common source of deployment failures: stale API URLs, proxy configuration and credentialed CORS requests.

### Tenant isolation
Operational records carry `agency_id`. API handlers resolve the authenticated user from the signed session and derive the tenant from the database/session context. IDs supplied by the browser are never treated as proof of tenant ownership.

For example, a project lookup is effectively:

```sql
SELECT ... FROM projects WHERE id = ? AND agency_id = ?
```

Client portal queries additionally require both `agency_id` and the authenticated `client_id`.

### Support mode
Super Admin support mode uses a short-lived signed session context that targets exactly one agency. It is intentionally read-only for agency operational routes. Enter/exit events are written to the activity log.

### Project progress
Progress = completed tasks / total tasks × 100. A project with no tasks reports 0%, which makes the number meaningful rather than arbitrary.

### AI workflow
The AI feature is **Project Health**. Input is limited to the selected project's status, priority, deadline, tasks and recent feedback. Output is a summary, risk level, detected risks and recommended actions. OpenAI is used when configured; provider errors fall back to a local analysis so the application does not become unusable because an external AI service is unavailable.

## Deployment

Recommended simple setup:

1. **GitHub** — push this repository.
2. **Railway MySQL** — create a MySQL service and copy its `DATABASE_URL`.
3. Run `schema.sql` against the Railway database and run `npm run seed` once against that database.
4. **Vercel** — import the GitHub repository as a Next.js project.
5. Add these Vercel environment variables:
   - `DATABASE_URL`
   - `AUTH_SECRET`
   - `OPENAI_API_KEY` (optional but recommended for the external AI path)
   - `OPENAI_MODEL` (optional; default `gpt-4o-mini`)
6. Deploy. The live site uses the same-origin `/api` routes, so there is no frontend API URL to configure.

### Production smoke checks

- Open `/api/health` and confirm `{ "status": "ok", "database": "connected" }`.
- Test Super Admin login.
- Test Agency A login and confirm it cannot see Agency B data.
- Test Client 1 and change the project ID in the browser/API; it should receive access denied/not found.
- Suspend an agency from Super Admin, then verify its users are blocked.
- Enter support mode and verify the banner appears and operational write actions are rejected.
- Upload a small file, share it with the client, and verify the client can download only that file.
- Run AI Project Health on a project.

## Security notes

- Never commit `.env` or real API keys.
- Passwords are hashed with bcrypt.
- Authentication is stored in an HTTP-only, same-site cookie.
- Authorization is checked on the server, not only by hiding frontend pages.
- File downloads go through a permission-checked route.
- AI requests are tenant-scoped before data is sent to the provider.

## Known limitations / next steps

- The assignment MVP stores small uploaded files as MySQL BLOBs (maximum 4 MB). A production-scale version would move file bytes to S3/R2 with short-lived signed download URLs.
- The local AI fallback is deterministic; production deployments can enable the OpenAI path through `OPENAI_API_KEY`.
- Email invitations/notifications are represented by activity records rather than an email provider integration.
- With more time, I would add pagination, richer milestone editing, audit-log filters and automated end-to-end browser tests.
