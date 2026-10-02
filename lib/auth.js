import { SignJWT, jwtVerify } from 'jose';
import bcrypt from 'bcryptjs';
import { cookies } from 'next/headers';
import { query } from './db';

const secret = () => new TextEncoder().encode(process.env.AUTH_SECRET || 'dev-only-change-me');
export async function hashPassword(password){ return bcrypt.hash(password, 12); }
export async function verifyPassword(password, hash){ return bcrypt.compare(password, hash); }
export async function createToken(payload){ return new SignJWT(payload).setProtectedHeader({alg:'HS256'}).setIssuedAt().setExpirationTime('8h').sign(secret()); }
export async function readToken(){ const token=cookies().get('appzex_session')?.value; if(!token) return null; try{return (await jwtVerify(token,secret())).payload}catch{return null} }
export async function setSession(payload){ cookies().set('appzex_session', await createToken(payload), {httpOnly:true, sameSite:'lax', secure:process.env.NODE_ENV==='production', path:'/', maxAge:60*60*8}); }
export function clearSession(){ cookies().set('appzex_session','',{httpOnly:true, sameSite:'lax', secure:process.env.NODE_ENV==='production', path:'/', maxAge:0}); }

export async function getContext(){
  const token=await readToken(); if(!token?.sub) return null;
  const [rows]=await query(`SELECT u.id,u.email,u.name,u.role,u.agency_id,u.client_id,u.is_active,a.status agency_status,a.name agency_name
    FROM users u LEFT JOIN agencies a ON a.id=u.agency_id WHERE u.id=? LIMIT 1`,[Number(token.sub)]);
  const u=rows[0]; if(!u || !u.is_active) return null;
  if(u.role!=='super_admin' && u.agency_status!=='active') return {...u, blocked:true};
  if(u.role==='super_admin' && token.supportAgencyId){ return {...u, support:true, supportAgencyId:Number(token.supportAgencyId), agency_id:Number(token.supportAgencyId), role:'agency_admin'}; }
  return u;
}
export async function requireContext(roles=[]){
  const ctx=await getContext(); if(!ctx) return {error:'Not authenticated',status:401};
  if(ctx.blocked) return {error:'This agency is suspended. Contact AppZex support.',status:403,code:'AGENCY_SUSPENDED'};
  if(roles.length && !roles.includes(ctx.role)) return {error:'Forbidden',status:403};
  return {ctx};
}
export function tenantId(ctx){ return ctx.support ? ctx.supportAgencyId : ctx.agency_id; }
