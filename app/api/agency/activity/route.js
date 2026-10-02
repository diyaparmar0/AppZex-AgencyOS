export const dynamic = 'force-dynamic';
import { query } from '@/lib/db'; import { requireContext,tenantId } from '@/lib/auth'; import { ok,fail,safe } from '@/lib/http';
export async function GET(){return safe(async()=>{const a=await requireContext(['agency_admin','agency_member']);if(a.error)return fail(a.error,a.status);const [rows]=await query(`SELECT l.*,u.name actor FROM activity_logs l LEFT JOIN users u ON u.id=l.actor_id WHERE l.agency_id=? ORDER BY l.created_at DESC LIMIT 50`,[tenantId(a.ctx)]);return ok({rows});})}
