import { NextResponse } from 'next/server';
export function ok(data,status=200){ return NextResponse.json(data,{status}); }
export function fail(message,status=400,extra={}){ return NextResponse.json({error:message,...extra},{status}); }
export async function safe(handler){ try{return await handler()}catch(err){ console.error(err); return fail('Something went wrong on the server. Please try again.',500); } }
