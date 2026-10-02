import { query } from './db';
export async function logActivity({agencyId=null,actorId=null,eventType,entityType=null,entityId=null,visibility='internal',metadata={}}){await query('INSERT INTO activity_logs(agency_id,actor_id,event_type,entity_type,entity_id,visibility,metadata) VALUES(?,?,?,?,?,?,?)',[agencyId,actorId,eventType,entityType,entityId,visibility,JSON.stringify(metadata)]);}
