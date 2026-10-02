# AppZex submission note

Thank you for the opportunity to complete the Full Stack Developer assignment.

I built AppZex AgencyOS as a same-origin Next.js + Node.js + MySQL SaaS. The core focus was secure tenant isolation, working role-based workflows, a separate Super Admin portal, a focused client portal, derived project progress, secure file access, activity tracking and a meaningful AI Project Health workflow.

I intentionally kept the application as one Next.js deployment rather than a separate frontend/API deployment. This removes a common source of browser fetch/CORS failures while keeping the backend authorization in server-side route handlers.

The README contains setup instructions, demo credentials, architecture decisions, AI behavior, deployment configuration and known limitations.
