export async function api(path, options={}){
  const {method='GET',body,formData=false}=options;
  try{
    const res=await fetch(`/api${path}`,{method,credentials:'same-origin',headers:formData?{}:{'Content-Type':'application/json'},body:body==null?undefined:(formData?body:JSON.stringify(body)),cache:'no-store'});
    const data=await res.json().catch(()=>({}));
    if(!res.ok) throw new Error(data.error||`Request failed (${res.status})`);
    return data;
  }catch(e){if(e instanceof TypeError) throw new Error('The app could not reach the server. Please check your connection and try again.'); throw e;}
}
export const roleHome={super_admin:'/admin',agency_admin:'/agency',agency_member:'/agency',client:'/portal'};
