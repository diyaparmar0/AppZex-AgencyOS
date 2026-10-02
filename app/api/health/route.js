export const dynamic = 'force-dynamic';
import { query } from '@/lib/db'; import { ok,fail } from '@/lib/http'; export async function GET(){try{await query('SELECT 1');return ok({status:'ok',database:'connected'})}catch(e){return fail('Database unavailable',503,{database:'disconnected'})}}
