'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "0eec4cf4a0a1eab653ce4612a0c26c29",
"version.json": "5d6dca45e63540b9a7b88b9e0a2b2060",
"index.html": "10a748cb6b771cd64e253a928835a817",
"/": "10a748cb6b771cd64e253a928835a817",
"main.dart.js": "2d7edf34789950e0ceab72e008947681",
"flutter.js": "f393d3c16b631f36852323de8e583132",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"main.dart.mjs": "01f045d5e4e65ef820e198a892faac04",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "b8ce5acf1586ba37388809bf327449e3",
"main.dart.wasm": "03e62b24d5be24581433e4cc7dc664d9",
"assets/AssetManifest.json": "b1bee653e85d37f8eac634a0f7790cc0",
"assets/stops.geojson": "e123fc6d81d481a77e552b97f163b3cf",
"assets/gtfs/fare_attributes.txt": "d667ff1dce055c7606590c65591e5889",
"assets/gtfs/agency.txt": "9f06beaf439675837ec9da511328b11d",
"assets/gtfs/fare_rules.txt": "f1890aed01e1728f5aa342c9f804b65f",
"assets/gtfs/stop_times.txt": "8db0a070e08b0dab335a6c470079ed6f",
"assets/gtfs/frequencies.txt": "1cb8e67a0c2b57c0621320fe155fa461",
"assets/gtfs/shapes.txt": "0fefe454c1af573a415bb35283870892",
"assets/gtfs/trips.txt": "72a3cdd60fc3f374214f1f47dfca14f3",
"assets/gtfs/feed_info.txt": "eee3f982cd7677bc5b46298d227b33fd",
"assets/gtfs/stops.txt": "9a3cb676e4c8f239dc29e7acbe5d1740",
"assets/gtfs/calendar.txt": "60f429487c3ed5803bd34c52819791dd",
"assets/gtfs/routes.txt": "ac31b98eaf3cf14ab1f4bafda9ab1e1f",
"assets/NOTICES": "653eb46502eab825732b5ffc1c67c3dd",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "e0b8a69993328c8f387aa6ef06d78cc1",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "8521152765ac463fb43cc71bb7a89163",
"assets/packages/flutter_map/lib/assets/flutter_map_logo.png": "208d63cc917af9713fc9572bd5c09362",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/mapa_de_calor.geojson": "e740de74e510a188785e0ccf5b4a63e4",
"assets/AssetManifest.bin": "fa2634b1ec617a7416f8511adde000eb",
"assets/fonts/MaterialIcons-Regular.otf": "f9edbedf972fb40cb865269509ec435f",
"assets/assets/stops.geojson": "27a744681cb80988bc8abd9ee3c02b94",
"assets/assets/gtfs/agency.txt": "9f06beaf439675837ec9da511328b11d",
"assets/assets/gtfs/stop_times.txt": "8db0a070e08b0dab335a6c470079ed6f",
"assets/assets/gtfs/frequencies.txt": "1cb8e67a0c2b57c0621320fe155fa461",
"assets/assets/gtfs/shapes.txt": "0fefe454c1af573a415bb35283870892",
"assets/assets/gtfs/trips.txt": "72a3cdd60fc3f374214f1f47dfca14f3",
"assets/assets/gtfs/stops.txt": "9a3cb676e4c8f239dc29e7acbe5d1740",
"assets/assets/gtfs/calendar.txt": "60f429487c3ed5803bd34c52819791dd",
"assets/assets/gtfs/routes.txt": "ac31b98eaf3cf14ab1f4bafda9ab1e1f",
"assets/assets/mapa_de_calor.geojson": "e740de74e510a188785e0ccf5b4a63e4",
"canvaskit/skwasm.js": "694fda5704053957c2594de355805228",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"canvaskit/chromium/canvaskit.js": "671c6b4f8fcc199dcc551c7bb125f239",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/canvaskit.js": "66177750aff65a66cb07bb44b8c6422b",
"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"main.dart.wasm",
"main.dart.mjs",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
