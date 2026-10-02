export const dynamic = 'force-dynamic';
import { query } from '@/lib/db'; import { requireContext } from '@/lib/auth'; import { ok,fail,safe } from '@/lib/http';
export async function GET(){return safe(async()=>{const a=await requireContext(['client']);if(a.error)return fail(a.error,a.status);const [rows]=await query(`SELECT m.*,p.name project_name FROM meetings m JOIN projects p ON p.id=m.project_id AND p.agency_id=m.agency_id WHERE m.agency_id=? AND p.client_id=? AND m.client_visible=1 ORDER BY m.meeting_date DESC`,[a.ctx.agency_id,a.ctx.client_id]);return ok({rows});})}
