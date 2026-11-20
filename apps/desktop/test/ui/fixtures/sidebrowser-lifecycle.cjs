// Owns: the isolated Electron process for the side-tab lifecycle regression. Never starts the desktop app or runtime.
const { app, BrowserWindow, protocol, session } = require('electron');
protocol.registerSchemesAsPrivileged(['app','wf-sandbox'].map(scheme=>({scheme,privileges:{standard:true,secure:true}})));
const assert = require('node:assert/strict');
const root = process.env.SIDE_LIFECYCLE_PROFILE;
assert.ok(root, 'test-owned profile directory');
app.setPath('userData', root);
app.setPath('sessionData', root);
app.commandLine.appendSwitch('disable-background-networking');
const { WorkspaceBrowser, SideDriver } = require('./workspace-under-test.cjs');
const origin = 'https://fixture.invalid';
const agent = {id:'ag_fixture',name:'Fixture'};
const delay = ms => new Promise(r=>setTimeout(r,ms));
async function until(check,label='fixture') {
 for(let i=0;i<200;i++){ if(await check()) return; await delay(40); }
 throw Error(label+' deadline expired');
}
async function main() {
 const partition = session.fromPartition('persist:workspace-browser');
 partition.protocol.handle('https',request=>{
  const url=new URL(request.url);
  if(url.origin!==origin || !['/first','/second'].includes(url.pathname) || request.method!=='GET')
   return new Response('',{status:403});
  return new Response('<!doctype html><title>Fixture</title><body>'+url.pathname+'</body>',{
   headers:{'content-type':'text/html','content-security-policy':"default-src 'none'"}});
 });
 const win=new BrowserWindow({show:false,skipTaskbar:true,focusable:false});
 const registry=new Map();
 const driver=new SideDriver({browser:()=>browser});
 const browser=new WorkspaceBrowser(()=>win,{onTab:(id,wc)=>{
  if(wc) registry.set(id,wc); else registry.delete(id);
  driver.tab(id,wc);
 }});
 const call=(action, params={})=>driver.call({action,agent,space:'global',...params});
 async function open(url){
  const result=await call('open',{url:origin+url,newTab:true});
  assert.equal(result.ok,true,result.error);
  assert.equal(result.url,origin+url);
  assert.ok(result.text.includes(url),'fresh page snapshot marker');
  const id=result.tab;
  const wc=registry.get(id);
  assert.ok(wc);
  await until(async()=>!wc.isLoading() && wc.getURL()===origin+url && await wc.executeJavaScript('document.body.textContent')===url,'load '+url);
  return [id,wc];
 }
 try{
  const [a,first]=await open('/first');
  const [b,second]=await open('/second');
  await first.executeJavaScript('window.fixtureSentinel=123; void 0');
  let closed=false, destroyed=false;
  second.once('close',()=>closed=true);
  second.once('destroyed',()=>destroyed=true);
  void second.executeJavaScript('setTimeout(() => window.close(), 0); void 0').catch(()=>{});
  await until(()=>destroyed,'page self-close');
  assert.ok(closed,'native close event');
  assert.ok(!registry.has(b),'closed contents removed');
  assert.deepEqual(browser.sideTabs().pages.map(p=>p.id),[a]);
  assert.equal(registry.get(a),first);
  assert.equal(await first.executeJavaScript('window.fixtureSentinel'),123);
  const surviving=await call('snapshot',{tab:a,full:true});
  assert.equal(surviving.ok,true,surviving.error);
  assert.ok(surviving.text.includes('/first'));
  const stale=await call('snapshot',{tab:b,full:true});
  assert.equal(stale.ok,false);
  assert.match(stale.error,/no side-browser tab/i);
  browser.command({action:'reopen',space:'global'});
  await until(()=>browser.sideTabs().pages.some(p=>p.url===origin+'/second'),'reopen from self-close history');
  const reopened=browser.sideTabs().pages.filter(p=>p.url===origin+'/second');
  assert.equal(reopened.length,1);
  assert.notEqual(reopened[0].id,b);
  const afterReopen = browser.sideTabs().pages.length;
  browser.command({action:'reopen',space:'global'});
  assert.equal(browser.sideTabs().pages.length,afterReopen,'self-close adds exactly one history entry');
  assert.equal(registry.get(a),first);
  assert.equal(await first.executeJavaScript('window.fixtureSentinel'),123);
  const [fresh]=await open('/second');
  assert.notEqual(fresh,b);
  assert.equal(await first.executeJavaScript('window.fixtureSentinel'),123);
  console.log('fresh SideDriver.open after close: passed; Electron '+process.versions.electron);
  const closeResult=await call('close',{tab:fresh});
  assert.equal(closeResult.ok,true,closeResult.error);
  const existing=new Set(browser.sideTabs().pages.map(p=>p.id));
  browser.command({action:'reopen',space:'global'});
  await until(()=>browser.sideTabs().pages.some(p=>!existing.has(p.id)&&p.url===origin+'/second'),'manual close reopen control');
  const count=browser.sideTabs().pages.length;
  browser.command({action:'reopen',space:'global'});
  assert.equal(browser.sideTabs().pages.length,count,'no duplicate history entry');
  console.log('manual close/reopen: passed without duplicate');
 }finally{
  browser.dispose();
  if(!win.isDestroyed()) win.destroy();
 }
}
app.whenReady().then(main).then(()=>app.exit(0),error=>{console.error(error);app.exit(1)});
setTimeout(()=>{console.error('Global fixture timeout');app.exit(1)},30000).unref();
