'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "82c74e41de4af0ec896396240e58eac5",
"version.json": "5d6dca45e63540b9a7b88b9e0a2b2060",
"index.html": "10a748cb6b771cd64e253a928835a817",
"/": "10a748cb6b771cd64e253a928835a817",
"main.dart.js": "207fd3fbe120ca2addf825d864278625",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"favicon.png": "2db05ca6e351b5bc40042e46fc55aba2",
"main.dart.mjs": "16e9ae45f76bc660d05d53ff6822ab87",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "b8ce5acf1586ba37388809bf327449e3",
"main.dart.wasm": "fc26564532e0bd49f8c6abb524ee21a4",
"assets/acerca_de_nosotros.pdf": "cc629ad367d181d8151e1102500a2d32",
"assets/AssetManifest.json": "e62f828d3b76f9beee30de092b61fce5",
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
"assets/gtfs/routes.txt": "af117c641d7c5502d601d339e4bc8d70",
"assets/NOTICES": "e7e3023348aa25cd7e94ba69902459bf",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "5470bb9dd11c041bc3a52c938a5fdd07",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/flutter_map/lib/assets/flutter_map_logo.png": "208d63cc917af9713fc9572bd5c09362",
"assets/packages/flutter_inappwebview_web/assets/web/web_support.js": "509ae636cfdd93e49b5a6eaf0f06d79f",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.css": "5a8d0222407e388155d7d1395a75d5b9",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.html": "16911fcc170c8af1c5457940bd0bf055",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"assets/mapa_de_calor.geojson": "e740de74e510a188785e0ccf5b4a63e4",
"assets/AssetManifest.bin": "7ec0d740ccadd60f89f8c1c1ea18f15b",
"assets/fonts/MaterialIcons-Regular.otf": "d830e555604a6919bdc6433565487c63",
"assets/AsistenteVirtual.png": "63fd5da4f192779d8092c2ae7be3932a",
"assets/assets/Logo_OMUS.png": "623379f0f4fb37078a73ab1073372a15",
"assets/assets/pnft_latlon_01156_2023.geojson": "7ee2cbae48e94a193b1b7f6c2915429e",
"assets/assets/stops.geojson": "27a744681cb80988bc8abd9ee3c02b94",
"assets/assets/gtfs/agency.txt": "9f06beaf439675837ec9da511328b11d",
"assets/assets/gtfs/stop_times.txt": "8db0a070e08b0dab335a6c470079ed6f",
"assets/assets/gtfs/frequencies.txt": "1cb8e67a0c2b57c0621320fe155fa461",
"assets/assets/gtfs/shapes.txt": "0fefe454c1af573a415bb35283870892",
"assets/assets/gtfs/trips.txt": "72a3cdd60fc3f374214f1f47dfca14f3",
"assets/assets/gtfs/stops.txt": "9a3cb676e4c8f239dc29e7acbe5d1740",
"assets/assets/gtfs/calendar.txt": "60f429487c3ed5803bd34c52819791dd",
"assets/assets/gtfs/routes.txt": "af117c641d7c5502d601d339e4bc8d70",
"assets/assets/background.jpg": "40a068b70de690c979b31f5052395ada",
"assets/assets/logos.png": "978be133f1e77a672fb0a5e618ebc5b0",
"assets/assets/mapa_de_calor.geojson": "e740de74e510a188785e0ccf5b4a63e4",
"assets/assets/AsistenteVirtual.png": "63fd5da4f192779d8092c2ae7be3932a",
"assets/assets/RutasDelSITT.json": "dcde7c9dd587ee49fc04db80da13441d",
"assets/assets/merged_stations.json": "84540c625614ecb8ff0d938520dfba43",
"assets/assets/PlanReguladorDeRutas.json": "aa7ede64416cf98e7e6091bdc640a5be",
"assets/RutasDelSITT.json": "dcde7c9dd587ee49fc04db80da13441d",
"assets/merged_stations.json": "84540c625614ecb8ff0d938520dfba43",
"assets/PlanReguladorDeRutas.json": "aa7ede64416cf98e7e6091bdc640a5be",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
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
