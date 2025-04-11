'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "2935c9c43cda2e99ca77eb38a98e708c",
"version.json": "66a36881553c58269af9bf5a634e44dc",
"favicon.ico": "309f576509c837d4a8f76015fa475d0c",
"index.html": "d5bc81743a11ac09ba649adec24d4153",
"/": "d5bc81743a11ac09ba649adec24d4153",
"main.dart.js": "e14dd0d97c7776a363c7c1e5795cfac2",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"main.dart.mjs": "315cb5f3bc24b34c9548a46930deb9dd",
"icons/Icon-192.png": "c91920a06ad14c7396a6367d468c18ec",
"icons/Icon-maskable-192.png": "c91920a06ad14c7396a6367d468c18ec",
"icons/Icon-maskable-512.png": "aaedc6da59302395764113d7148c663c",
"icons/Icon-512.png": "aaedc6da59302395764113d7148c663c",
"manifest.json": "b441e685616e7f8ba8995d57d7049e54",
"main.dart.wasm": "b4174db5a545074b46ed2240974dd9f4",
"assets/AssetManifest.json": "0cd0be9f76da6908a81c4eda4aa10463",
"assets/NOTICES": "a59f946f4588c2c8570407ea4c9d42d0",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/AssetManifest.bin.json": "7106c3c9830c38e1202acc5f15e8a1a4",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "5f7ed014c57bca8c3600c4709cf58c79",
"assets/fonts/MaterialIcons-Regular.otf": "919fab81bd83e2781d2919247ab022e0",
"assets/assets/image/page1.png": "faae95a87cc01ba2d260efeef3ae116a",
"assets/assets/image/page3.png": "a5c086367e6def6763e6b0afe54b817d",
"assets/assets/image/page2.png": "0858e1945b55d4503128f38f8a6e2e8a",
"assets/assets/icons/reaction_check.svg": "435082f2d7ac14fa1069cf30f427f76b",
"assets/assets/icons/reaction_thinking.svg": "9c1c3d794b6c3b04434bac693276167d",
"assets/assets/icons/reaction_handshake.svg": "1d0d98508d63b56ced318025bee8cbcc",
"assets/assets/icons/reaction_like.svg": "dab7b9ac2180978ee897a18b5ec4e1d2",
"assets/assets/icons/reaction_clap.svg": "604a683e876604c1346642fdac5234a1",
"assets/assets/bgimg/spring.svg": "39d85259eb1b20458999f5d64c470ee2",
"assets/assets/bgimg/wansui.svg": "15cb6c1cc2397811214b5ea881441c82",
"assets/assets/bgimg/happy.svg": "49a63bbf295fa6fa1298ddeb4fa6d560",
"assets/assets/bgimg/leaves.svg": "a68bceb9346779ba2ac07533e92f0b96",
"assets/assets/bgimg/new-year.svg": "4794e4279432af610833e173d8bbbfcc",
"assets/assets/bgimg/blue-sky.svg": "e56d78cd62c654a094b91a10485ad67b",
"assets/assets/bgimg/hot.svg": "5b01c6e708b51060ca7496ad4b6820a6",
"assets/assets/bgimg/cold.svg": "e205491be84e1de6ff347b89c9cfc76e",
"assets/assets/bgimg/done.svg": "fdfb468a42273b0ae6af16582dca25a2",
"assets/assets/bgimg/thinking.svg": "c17f2b8887852726ce3dc7e443ef9875",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206"};
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
