// Офлайн-кэш приложения.
// Версию не меняйте вручную — используйте ./bump-version.sh <версия>, он обновит её здесь и в index.html.
const VERSION='0.0.2';
const CACHE='priemka-'+VERSION;
const ASSETS=['./','./index.html','./manifest.webmanifest','./icon-192.png','./icon-512.png'];

self.addEventListener('install',e=>{
  e.waitUntil((async()=>{
    const c=await caches.open(CACHE);
    // cache:'reload' — берём файлы с сервера, а не из HTTP-кэша браузера
    await c.addAll(ASSETS.map(u=>new Request(u,{cache:'reload'})));
    // Первая версия (priemka-v1) не умела показывать плашку — её обновляем сразу
    if(await caches.has('priemka-v1'))self.skipWaiting();
  })());
  // Иначе новая версия ждёт, пока пользователь нажмёт «Обновить»
});

self.addEventListener('activate',e=>{
  e.waitUntil((async()=>{
    for(const k of await caches.keys())if(k!==CACHE)await caches.delete(k);
    await self.clients.claim();
  })());
});

self.addEventListener('message',e=>{
  if(e.data==='SKIP_WAITING')self.skipWaiting();
  if(e.data==='GET_VERSION'&&e.source)e.source.postMessage({type:'VERSION',version:VERSION});
});

self.addEventListener('fetch',e=>{
  if(e.request.method!=='GET')return;
  e.respondWith((async()=>{
    const c=await caches.open(CACHE);
    const hit=await c.match(e.request,{ignoreSearch:true});
    if(hit)return hit;
    try{return await fetch(e.request)}
    catch(err){if(e.request.mode==='navigate')return c.match('./index.html');throw err}
  })());
});
