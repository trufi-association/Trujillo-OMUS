'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/acerca_de_nosotros.pdf": "cc629ad367d181d8151e1102500a2d32",
"assets/AssetManifest.bin": "0b027ceeb942e76298eef81fd7ec4ee7",
"assets/AssetManifest.bin.json": "696b20f64f0ebf9ffb4db6553ad21586",
"assets/AssetManifest.json": "741b04534e75c97321cc6a975b0c7459",
"assets/assets/background.jpg": "40a068b70de690c979b31f5052395ada",
"assets/assets/gtfs/agency.txt": "334228bdab9aa3592094d38a526ffda0",
"assets/assets/gtfs/calendar.txt": "e00ced2c4df6c85c2083ec7826378d4a",
"assets/assets/gtfs/frequencies.txt": "bc5cf05bf60a2fe17621cf2be76bac1e",
"assets/assets/gtfs/routes.txt": "79496d0f850c55951065ee76320d8d06",
"assets/assets/gtfs/shapes.txt": "400ae01569043c96c59191444a60acca",
"assets/assets/gtfs/stops.txt": "85df5a403522bfb7c2f90a9dba4706f2",
"assets/assets/gtfs/stop_times.txt": "f4ef985c9b3a552056ce6a3519a3ff54",
"assets/assets/gtfs/trips.txt": "3f436b402564c32bccaaf0cbeaa1b865",
"assets/assets/logos.png": "978be133f1e77a672fb0a5e618ebc5b0",
"assets/assets/Logo_OMUS.png": "623379f0f4fb37078a73ab1073372a15",
"assets/assets/mapa_de_calor.geojson": "4b542421ad00c1f7ade74e8b8ffe4120",
"assets/assets/stops.geojson": "2ec7210456935b7f26253869306c4431",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "4543b411d749a7bb4dc97966471fe16c",
"assets/gtfs/agency.txt": "334228bdab9aa3592094d38a526ffda0",
"assets/gtfs/calendar.txt": "e00ced2c4df6c85c2083ec7826378d4a",
"assets/gtfs/fare_attributes.txt": "1b62437c88e45de848b198fe91950668",
"assets/gtfs/fare_rules.txt": "8715e817d44447b49753117e69df438b",
"assets/gtfs/feed_info.txt": "8e1716c46ede90ef9a4e3a7fc3fbe2ff",
"assets/gtfs/frequencies.txt": "bc5cf05bf60a2fe17621cf2be76bac1e",
"assets/gtfs/routes.txt": "79496d0f850c55951065ee76320d8d06",
"assets/gtfs/shapes.txt": "400ae01569043c96c59191444a60acca",
"assets/gtfs/stops.txt": "85df5a403522bfb7c2f90a9dba4706f2",
"assets/gtfs/stop_times.txt": "f4ef985c9b3a552056ce6a3519a3ff54",
"assets/gtfs/trips.txt": "3f436b402564c32bccaaf0cbeaa1b865",
"assets/mapa_de_calor.geojson": "4b542421ad00c1f7ade74e8b8ffe4120",
"assets/NOTICES": "eff0b7e374a659e7faec7e9bc5757f45",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "8521152765ac463fb43cc71bb7a89163",
"assets/packages/flutter_map/lib/assets/flutter_map_logo.png": "208d63cc917af9713fc9572bd5c09362",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/stops.geojson": "b5e0e87de9c6a7566efecdac445added",
"canvaskit/canvaskit.js": "66177750aff65a66cb07bb44b8c6422b",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/chromium/canvaskit.js": "671c6b4f8fcc199dcc551c7bb125f239",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/skwasm.js": "694fda5704053957c2594de355805228",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"favicon.png": "2db05ca6e351b5bc40042e46fc55aba2",
"flutter.js": "f393d3c16b631f36852323de8e583132",
"flutter_bootstrap.js": "968932801320263e9911a4c47f5ed069",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "dd7f3dbe6961d853b6bab9cab59cb0b8",
"/": "dd7f3dbe6961d853b6bab9cab59cb0b8",
"main.dart.js": "fd9dfc1ac59b8642c0bfffb123e316d2",
"main.dart.mjs": "9971ae30ad3f2ce596efde36aac8aaf7",
"main.dart.wasm": "62c16c30a2ee4f46300dab366b22bc19",
"manifest.json": "2f8325d5dcc2cd3f77a6d361d43d9192",
"version.json": "5d6dca45e63540b9a7b88b9e0a2b2060"};
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
