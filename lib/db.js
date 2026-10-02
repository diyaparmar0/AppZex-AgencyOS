import mysql from 'mysql2/promise';
let pool;
export function getDb(){if(pool)return pool;if(!process.env.DATABASE_URL)throw new Error('DATABASE_URL is not configured');const u=new URL(process.env.DATABASE_URL);pool=mysql.createPool({host:u.hostname,port:Number(u.port||3306),user:decodeURIComponent(u.username),password:decodeURIComponent(u.password),database:u.pathname.replace(/^\//,''),waitForConnections:true,connectionLimit:10,queueLimit:0,enableKeepAlive:true,ssl:(process.env.DB_SSL==='true'||u.searchParams.get('ssl-mode'))?{rejectUnauthorized:false}:undefined});return pool}
export async function query(sql,params=[]){return getDb().execute(sql,params)}
