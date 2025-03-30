
// Compiles a dart2wasm-generated main module from `source` which can then
// instantiatable via the `instantiate` method.
//
// `source` needs to be a `Response` object (or promise thereof) e.g. created
// via the `fetch()` JS API.
export async function compileStreaming(source) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(
      await WebAssembly.compileStreaming(source, builtins), builtins);
}

// Compiles a dart2wasm-generated wasm modules from `bytes` which is then
// instantiatable via the `instantiate` method.
export async function compile(bytes) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(await WebAssembly.compile(bytes, builtins), builtins);
}

// DEPRECATED: Please use `compile` or `compileStreaming` to get a compiled app,
// use `instantiate` method to get an instantiated app and then call
// `invokeMain` to invoke the main function.
export async function instantiate(modulePromise, importObjectPromise) {
  var moduleOrCompiledApp = await modulePromise;
  if (!(moduleOrCompiledApp instanceof CompiledApp)) {
    moduleOrCompiledApp = new CompiledApp(moduleOrCompiledApp);
  }
  const instantiatedApp = await moduleOrCompiledApp.instantiate(await importObjectPromise);
  return instantiatedApp.instantiatedModule;
}

// DEPRECATED: Please use `compile` or `compileStreaming` to get a compiled app,
// use `instantiate` method to get an instantiated app and then call
// `invokeMain` to invoke the main function.
export const invoke = (moduleInstance, ...args) => {
  moduleInstance.exports.$invokeMain(args);
}

class CompiledApp {
  constructor(module, builtins) {
    this.module = module;
    this.builtins = builtins;
  }

  // The second argument is an options object containing:
  // `loadDeferredWasm` is a JS function that takes a module name matching a
  //   wasm file produced by the dart2wasm compiler and returns the bytes to
  //   load the module. These bytes can be in either a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`.
  async instantiate(additionalImports, {loadDeferredWasm} = {}) {
    let dartInstance;

    // Prints to the console
    function printToConsole(value) {
      if (typeof dartPrint == "function") {
        dartPrint(value);
        return;
      }
      if (typeof console == "object" && typeof console.log != "undefined") {
        console.log(value);
        return;
      }
      if (typeof print == "function") {
        print(value);
        return;
      }

      throw "Unable to print message: " + js;
    }

    // Converts a Dart List to a JS array. Any Dart objects will be converted, but
    // this will be cheap for JSValues.
    function arrayFromDartList(constructor, list) {
      const exports = dartInstance.exports;
      const read = exports.$listRead;
      const length = exports.$listLength(list);
      const array = new constructor(length);
      for (let i = 0; i < length; i++) {
        array[i] = read(list, i);
      }
      return array;
    }

    // A special symbol attached to functions that wrap Dart functions.
    const jsWrappedDartFunctionSymbol = Symbol("JSWrappedDartFunction");

    function finalizeWrapper(dartFunction, wrapped) {
      wrapped.dartFunction = dartFunction;
      wrapped[jsWrappedDartFunctionSymbol] = true;
      return wrapped;
    }

    // Imports
    const dart2wasm = {

      _1: (x0,x1,x2) => x0.set(x1,x2),
      _2: (x0,x1,x2) => x0.set(x1,x2),
      _6: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._6(f,arguments.length,x0) }),
      _7: x0 => new window.FinalizationRegistry(x0),
      _8: (x0,x1,x2,x3) => x0.register(x1,x2,x3),
      _9: (x0,x1) => x0.unregister(x1),
      _10: (x0,x1,x2) => x0.slice(x1,x2),
      _11: (x0,x1) => x0.decode(x1),
      _12: (x0,x1) => x0.segment(x1),
      _13: () => new TextDecoder(),
      _14: x0 => x0.buffer,
      _15: x0 => x0.wasmMemory,
      _16: () => globalThis.window._flutter_skwasmInstance,
      _17: x0 => x0.rasterStartMilliseconds,
      _18: x0 => x0.rasterEndMilliseconds,
      _19: x0 => x0.imageBitmaps,
      _192: x0 => x0.select(),
      _193: (x0,x1) => x0.append(x1),
      _194: x0 => x0.remove(),
      _197: x0 => x0.unlock(),
      _202: x0 => x0.getReader(),
      _211: x0 => new MutationObserver(x0),
      _222: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _223: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      _226: x0 => new ResizeObserver(x0),
      _229: (x0,x1) => new Intl.Segmenter(x0,x1),
      _230: x0 => x0.next(),
      _231: (x0,x1) => new Intl.v8BreakIterator(x0,x1),
      _308: x0 => x0.close(),
      _309: (x0,x1,x2,x3,x4) => ({type: x0,data: x1,premultiplyAlpha: x2,colorSpaceConversion: x3,preferAnimation: x4}),
      _310: x0 => new window.ImageDecoder(x0),
      _311: x0 => x0.close(),
      _312: x0 => ({frameIndex: x0}),
      _313: (x0,x1) => x0.decode(x1),
      _316: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._316(f,arguments.length,x0) }),
      _317: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._317(f,arguments.length,x0) }),
      _318: (x0,x1) => ({addView: x0,removeView: x1}),
      _319: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._319(f,arguments.length,x0) }),
      _320: f => finalizeWrapper(f, function() { return dartInstance.exports._320(f,arguments.length) }),
      _321: (x0,x1) => ({initializeEngine: x0,autoStart: x1}),
      _322: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._322(f,arguments.length,x0) }),
      _323: x0 => ({runApp: x0}),
      _324: x0 => new Uint8Array(x0),
      _326: x0 => x0.preventDefault(),
      _327: x0 => x0.stopPropagation(),
      _328: (x0,x1) => x0.addListener(x1),
      _329: (x0,x1) => x0.removeListener(x1),
      _330: (x0,x1) => x0.prepend(x1),
      _331: x0 => x0.remove(),
      _332: x0 => x0.disconnect(),
      _333: (x0,x1) => x0.addListener(x1),
      _334: (x0,x1) => x0.removeListener(x1),
      _335: x0 => x0.blur(),
      _336: (x0,x1) => x0.append(x1),
      _337: x0 => x0.remove(),
      _338: x0 => x0.stopPropagation(),
      _342: x0 => x0.preventDefault(),
      _343: (x0,x1) => x0.append(x1),
      _344: x0 => x0.remove(),
      _345: x0 => x0.preventDefault(),
      _350: (x0,x1) => x0.removeChild(x1),
      _351: (x0,x1) => x0.appendChild(x1),
      _352: (x0,x1,x2) => x0.insertBefore(x1,x2),
      _353: (x0,x1) => x0.appendChild(x1),
      _354: (x0,x1) => x0.transferFromImageBitmap(x1),
      _356: (x0,x1) => x0.append(x1),
      _357: (x0,x1) => x0.append(x1),
      _358: (x0,x1) => x0.append(x1),
      _359: x0 => x0.remove(),
      _360: x0 => x0.remove(),
      _361: x0 => x0.remove(),
      _362: (x0,x1) => x0.appendChild(x1),
      _363: (x0,x1) => x0.appendChild(x1),
      _364: x0 => x0.remove(),
      _365: (x0,x1) => x0.append(x1),
      _366: (x0,x1) => x0.append(x1),
      _367: x0 => x0.remove(),
      _368: (x0,x1) => x0.append(x1),
      _369: (x0,x1) => x0.append(x1),
      _370: (x0,x1,x2) => x0.insertBefore(x1,x2),
      _371: (x0,x1) => x0.append(x1),
      _372: (x0,x1,x2) => x0.insertBefore(x1,x2),
      _373: x0 => x0.remove(),
      _374: (x0,x1) => x0.append(x1),
      _375: x0 => x0.remove(),
      _376: (x0,x1) => x0.append(x1),
      _377: x0 => x0.remove(),
      _378: x0 => x0.remove(),
      _379: x0 => x0.getBoundingClientRect(),
      _380: x0 => x0.remove(),
      _393: (x0,x1) => x0.append(x1),
      _394: x0 => x0.remove(),
      _395: (x0,x1) => x0.append(x1),
      _396: (x0,x1,x2) => x0.insertBefore(x1,x2),
      _397: x0 => x0.preventDefault(),
      _398: x0 => x0.preventDefault(),
      _399: x0 => x0.preventDefault(),
      _400: x0 => x0.preventDefault(),
      _401: (x0,x1) => x0.observe(x1),
      _402: x0 => x0.disconnect(),
      _403: (x0,x1) => x0.appendChild(x1),
      _404: (x0,x1) => x0.appendChild(x1),
      _405: (x0,x1) => x0.appendChild(x1),
      _406: (x0,x1) => x0.append(x1),
      _407: x0 => x0.remove(),
      _408: (x0,x1) => x0.append(x1),
      _410: (x0,x1) => x0.appendChild(x1),
      _411: (x0,x1) => x0.append(x1),
      _412: x0 => x0.remove(),
      _413: (x0,x1) => x0.append(x1),
      _414: x0 => x0.remove(),
      _418: (x0,x1) => x0.appendChild(x1),
      _419: x0 => x0.remove(),
      _978: () => globalThis.window.flutterConfiguration,
      _979: x0 => x0.assetBase,
      _984: x0 => x0.debugShowSemanticsNodes,
      _985: x0 => x0.hostElement,
      _986: x0 => x0.multiViewEnabled,
      _987: x0 => x0.nonce,
      _989: x0 => x0.fontFallbackBaseUrl,
      _995: x0 => x0.console,
      _996: x0 => x0.devicePixelRatio,
      _997: x0 => x0.document,
      _998: x0 => x0.history,
      _999: x0 => x0.innerHeight,
      _1000: x0 => x0.innerWidth,
      _1001: x0 => x0.location,
      _1002: x0 => x0.navigator,
      _1003: x0 => x0.visualViewport,
      _1004: x0 => x0.performance,
      _1007: (x0,x1) => x0.dispatchEvent(x1),
      _1008: (x0,x1) => x0.matchMedia(x1),
      _1010: (x0,x1) => x0.getComputedStyle(x1),
      _1011: x0 => x0.screen,
      _1012: (x0,x1) => x0.requestAnimationFrame(x1),
      _1013: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1013(f,arguments.length,x0) }),
      _1018: (x0,x1) => x0.warn(x1),
      _1021: () => globalThis.window,
      _1022: () => globalThis.Intl,
      _1023: () => globalThis.Symbol,
      _1026: x0 => x0.clipboard,
      _1027: x0 => x0.maxTouchPoints,
      _1028: x0 => x0.vendor,
      _1029: x0 => x0.language,
      _1030: x0 => x0.platform,
      _1031: x0 => x0.userAgent,
      _1032: x0 => x0.languages,
      _1033: x0 => x0.documentElement,
      _1034: (x0,x1) => x0.querySelector(x1),
      _1038: (x0,x1) => x0.createElement(x1),
      _1039: (x0,x1) => x0.execCommand(x1),
      _1042: (x0,x1) => x0.createTextNode(x1),
      _1043: (x0,x1) => x0.createEvent(x1),
      _1047: x0 => x0.head,
      _1048: x0 => x0.body,
      _1049: (x0,x1) => x0.title = x1,
      _1052: x0 => x0.activeElement,
      _1054: x0 => x0.visibilityState,
      _1056: x0 => x0.hasFocus(),
      _1057: () => globalThis.document,
      _1058: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _1059: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _1062: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1062(f,arguments.length,x0) }),
      _1063: x0 => x0.target,
      _1065: x0 => x0.timeStamp,
      _1066: x0 => x0.type,
      _1068: x0 => x0.preventDefault(),
      _1070: (x0,x1,x2,x3) => x0.initEvent(x1,x2,x3),
      _1077: x0 => x0.firstChild,
      _1082: x0 => x0.parentElement,
      _1084: x0 => x0.parentNode,
      _1088: (x0,x1) => x0.removeChild(x1),
      _1089: (x0,x1) => x0.removeChild(x1),
      _1090: x0 => x0.isConnected,
      _1091: (x0,x1) => x0.textContent = x1,
      _1095: (x0,x1) => x0.contains(x1),
      _1101: x0 => x0.firstElementChild,
      _1103: x0 => x0.nextElementSibling,
      _1104: x0 => x0.clientHeight,
      _1105: x0 => x0.clientWidth,
      _1106: x0 => x0.offsetHeight,
      _1107: x0 => x0.offsetWidth,
      _1108: x0 => x0.id,
      _1109: (x0,x1) => x0.id = x1,
      _1112: (x0,x1) => x0.spellcheck = x1,
      _1113: x0 => x0.tagName,
      _1114: x0 => x0.style,
      _1115: (x0,x1) => x0.append(x1),
      _1117: (x0,x1) => x0.getAttribute(x1),
      _1118: x0 => x0.getBoundingClientRect(),
      _1121: (x0,x1) => x0.closest(x1),
      _1124: (x0,x1) => x0.querySelectorAll(x1),
      _1126: x0 => x0.remove(),
      _1127: (x0,x1,x2) => x0.setAttribute(x1,x2),
      _1128: (x0,x1) => x0.removeAttribute(x1),
      _1129: (x0,x1) => x0.tabIndex = x1,
      _1132: (x0,x1) => x0.focus(x1),
      _1133: x0 => x0.scrollTop,
      _1134: (x0,x1) => x0.scrollTop = x1,
      _1135: x0 => x0.scrollLeft,
      _1136: (x0,x1) => x0.scrollLeft = x1,
      _1137: x0 => x0.classList,
      _1138: (x0,x1) => x0.className = x1,
      _1144: (x0,x1) => x0.getElementsByClassName(x1),
      _1146: x0 => x0.click(),
      _1147: (x0,x1) => x0.hasAttribute(x1),
      _1150: (x0,x1) => x0.attachShadow(x1),
      _1155: (x0,x1) => x0.getPropertyValue(x1),
      _1157: (x0,x1,x2,x3) => x0.setProperty(x1,x2,x3),
      _1159: (x0,x1) => x0.removeProperty(x1),
      _1161: x0 => x0.offsetLeft,
      _1162: x0 => x0.offsetTop,
      _1163: x0 => x0.offsetParent,
      _1165: (x0,x1) => x0.name = x1,
      _1166: x0 => x0.content,
      _1167: (x0,x1) => x0.content = x1,
      _1185: (x0,x1) => x0.nonce = x1,
      _1191: x0 => x0.now(),
      _1193: (x0,x1) => x0.width = x1,
      _1195: (x0,x1) => x0.height = x1,
      _1199: (x0,x1) => x0.getContext(x1),
      _1275: (x0,x1) => x0.fetch(x1),
      _1276: x0 => x0.status,
      _1278: x0 => x0.body,
      _1279: x0 => x0.arrayBuffer(),
      _1285: x0 => x0.read(),
      _1286: x0 => x0.value,
      _1287: x0 => x0.done,
      _1289: x0 => x0.name,
      _1290: x0 => x0.x,
      _1291: x0 => x0.y,
      _1294: x0 => x0.top,
      _1295: x0 => x0.right,
      _1296: x0 => x0.bottom,
      _1297: x0 => x0.left,
      _1306: x0 => x0.height,
      _1307: x0 => x0.width,
      _1308: (x0,x1) => x0.value = x1,
      _1310: (x0,x1) => x0.placeholder = x1,
      _1311: (x0,x1) => x0.name = x1,
      _1312: x0 => x0.selectionDirection,
      _1313: x0 => x0.selectionStart,
      _1314: x0 => x0.selectionEnd,
      _1317: x0 => x0.value,
      _1319: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      _1322: x0 => x0.readText(),
      _1323: (x0,x1) => x0.writeText(x1),
      _1324: x0 => x0.altKey,
      _1325: x0 => x0.code,
      _1326: x0 => x0.ctrlKey,
      _1327: x0 => x0.key,
      _1328: x0 => x0.keyCode,
      _1329: x0 => x0.location,
      _1330: x0 => x0.metaKey,
      _1331: x0 => x0.repeat,
      _1332: x0 => x0.shiftKey,
      _1333: x0 => x0.isComposing,
      _1334: (x0,x1) => x0.getModifierState(x1),
      _1336: x0 => x0.state,
      _1337: (x0,x1) => x0.go(x1),
      _1339: (x0,x1,x2,x3) => x0.pushState(x1,x2,x3),
      _1341: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      _1342: x0 => x0.pathname,
      _1343: x0 => x0.search,
      _1344: x0 => x0.hash,
      _1348: x0 => x0.state,
      _1356: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1356(f,arguments.length,x0,x1) }),
      _1358: (x0,x1,x2) => x0.observe(x1,x2),
      _1361: x0 => x0.attributeName,
      _1362: x0 => x0.type,
      _1363: x0 => x0.matches,
      _1366: x0 => x0.matches,
      _1368: x0 => x0.relatedTarget,
      _1369: x0 => x0.clientX,
      _1370: x0 => x0.clientY,
      _1371: x0 => x0.offsetX,
      _1372: x0 => x0.offsetY,
      _1375: x0 => x0.button,
      _1376: x0 => x0.buttons,
      _1377: x0 => x0.ctrlKey,
      _1378: (x0,x1) => x0.getModifierState(x1),
      _1381: x0 => x0.pointerId,
      _1382: x0 => x0.pointerType,
      _1383: x0 => x0.pressure,
      _1384: x0 => x0.tiltX,
      _1385: x0 => x0.tiltY,
      _1386: x0 => x0.getCoalescedEvents(),
      _1388: x0 => x0.deltaX,
      _1389: x0 => x0.deltaY,
      _1390: x0 => x0.wheelDeltaX,
      _1391: x0 => x0.wheelDeltaY,
      _1392: x0 => x0.deltaMode,
      _1398: x0 => x0.changedTouches,
      _1400: x0 => x0.clientX,
      _1401: x0 => x0.clientY,
      _1403: x0 => x0.data,
      _1406: (x0,x1) => x0.disabled = x1,
      _1407: (x0,x1) => x0.type = x1,
      _1408: (x0,x1) => x0.max = x1,
      _1409: (x0,x1) => x0.min = x1,
      _1410: (x0,x1) => x0.value = x1,
      _1411: x0 => x0.value,
      _1412: x0 => x0.disabled,
      _1413: (x0,x1) => x0.disabled = x1,
      _1414: (x0,x1) => x0.placeholder = x1,
      _1415: (x0,x1) => x0.name = x1,
      _1416: (x0,x1) => x0.autocomplete = x1,
      _1417: x0 => x0.selectionDirection,
      _1418: x0 => x0.selectionStart,
      _1419: x0 => x0.selectionEnd,
      _1423: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      _1428: (x0,x1) => x0.add(x1),
      _1432: (x0,x1) => x0.noValidate = x1,
      _1433: (x0,x1) => x0.method = x1,
      _1434: (x0,x1) => x0.action = x1,
      _1459: x0 => x0.orientation,
      _1460: x0 => x0.width,
      _1461: x0 => x0.height,
      _1462: (x0,x1) => x0.lock(x1),
      _1478: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1478(f,arguments.length,x0,x1) }),
      _1489: x0 => x0.length,
      _1491: (x0,x1) => x0.item(x1),
      _1492: x0 => x0.length,
      _1493: (x0,x1) => x0.item(x1),
      _1494: x0 => x0.iterator,
      _1495: x0 => x0.Segmenter,
      _1496: x0 => x0.v8BreakIterator,
      _1499: x0 => x0.done,
      _1500: x0 => x0.value,
      _1501: x0 => x0.index,
      _1505: (x0,x1) => x0.adoptText(x1),
      _1506: x0 => x0.first(),
      _1507: x0 => x0.next(),
      _1508: x0 => x0.current(),
      _1522: x0 => x0.hostElement,
      _1523: x0 => x0.viewConstraints,
      _1525: x0 => x0.maxHeight,
      _1526: x0 => x0.maxWidth,
      _1527: x0 => x0.minHeight,
      _1528: x0 => x0.minWidth,
      _1529: x0 => x0.loader,
      _1530: () => globalThis._flutter,
      _1531: (x0,x1) => x0.didCreateEngineInitializer(x1),
      _1532: (x0,x1,x2) => x0.call(x1,x2),
      _1533: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1533(f,arguments.length,x0,x1) }),
      _1534: x0 => new Promise(x0),
      _1537: x0 => x0.length,
      _1540: x0 => x0.tracks,
      _1544: x0 => x0.image,
      _1551: x0 => x0.displayWidth,
      _1552: x0 => x0.displayHeight,
      _1553: x0 => x0.duration,
      _1556: x0 => x0.ready,
      _1557: x0 => x0.selectedTrack,
      _1558: x0 => x0.repetitionCount,
      _1559: x0 => x0.frameCount,
      _1629: x0 => x0.toArray(),
      _1630: x0 => x0.toUint8Array(),
      _1631: x0 => ({serverTimestamps: x0}),
      _1632: x0 => ({source: x0}),
      _1635: x0 => new firebase_firestore.FieldPath(x0),
      _1636: (x0,x1) => new firebase_firestore.FieldPath(x0,x1),
      _1637: (x0,x1,x2) => new firebase_firestore.FieldPath(x0,x1,x2),
      _1638: (x0,x1,x2,x3) => new firebase_firestore.FieldPath(x0,x1,x2,x3),
      _1639: (x0,x1,x2,x3,x4) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4),
      _1640: (x0,x1,x2,x3,x4,x5) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5),
      _1641: (x0,x1,x2,x3,x4,x5,x6) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5,x6),
      _1642: (x0,x1,x2,x3,x4,x5,x6,x7) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5,x6,x7),
      _1643: (x0,x1,x2,x3,x4,x5,x6,x7,x8) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5,x6,x7,x8),
      _1644: (x0,x1,x2,x3,x4,x5,x6,x7,x8,x9) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5,x6,x7,x8,x9),
      _1645: () => globalThis.firebase_firestore.documentId(),
      _1646: (x0,x1) => new firebase_firestore.GeoPoint(x0,x1),
      _1647: x0 => globalThis.firebase_firestore.vector(x0),
      _1648: x0 => globalThis.firebase_firestore.Bytes.fromUint8Array(x0),
      _1650: (x0,x1) => globalThis.firebase_firestore.collection(x0,x1),
      _1652: (x0,x1) => globalThis.firebase_firestore.doc(x0,x1),
      _1657: x0 => x0.call(),
      _1687: x0 => globalThis.firebase_firestore.deleteDoc(x0),
      _1688: x0 => globalThis.firebase_firestore.getDoc(x0),
      _1689: x0 => globalThis.firebase_firestore.getDocFromServer(x0),
      _1690: x0 => globalThis.firebase_firestore.getDocFromCache(x0),
      _1697: (x0,x1) => globalThis.firebase_firestore.setDoc(x0,x1),
      _1698: (x0,x1) => globalThis.firebase_firestore.query(x0,x1),
      _1699: (x0,x1) => globalThis.firebase_firestore.query(x0,x1),
      _1700: x0 => globalThis.firebase_firestore.getDocs(x0),
      _1701: x0 => globalThis.firebase_firestore.getDocsFromServer(x0),
      _1702: x0 => globalThis.firebase_firestore.getDocsFromCache(x0),
      _1703: x0 => globalThis.firebase_firestore.limit(x0),
      _1704: (x0,x1) => globalThis.firebase_firestore.query(x0,x1),
      _1705: x0 => globalThis.firebase_firestore.limitToLast(x0),
      _1706: (x0,x1) => globalThis.firebase_firestore.query(x0,x1),
      _1709: (x0,x1) => globalThis.firebase_firestore.orderBy(x0,x1),
      _1711: (x0,x1) => globalThis.firebase_firestore.query(x0,x1),
      _1712: (x0,x1) => globalThis.firebase_firestore.query(x0,x1),
      _1713: (x0,x1) => globalThis.firebase_firestore.query(x0,x1),
      _1714: (x0,x1,x2) => globalThis.firebase_firestore.where(x0,x1,x2),
      _1715: (x0,x1) => globalThis.firebase_firestore.query(x0,x1),
      _1716: (x0,x1,x2) => globalThis.firebase_firestore.where(x0,x1,x2),
      _1717: (x0,x1) => globalThis.firebase_firestore.query(x0,x1),
      _1720: x0 => globalThis.firebase_firestore.doc(x0),
      _1723: (x0,x1) => x0.data(x1),
      _1727: x0 => x0.docChanges(),
      _1737: () => globalThis.firebase_firestore.serverTimestamp(),
      _1738: x0 => globalThis.firebase_firestore.increment(x0),
      _1745: (x0,x1) => globalThis.firebase_firestore.getFirestore(x0,x1),
      _1747: x0 => globalThis.firebase_firestore.Timestamp.fromMillis(x0),
      _1748: x0 => globalThis.firebase_firestore.Timestamp.fromMillis(x0),
      _1749: f => finalizeWrapper(f, function() { return dartInstance.exports._1749(f,arguments.length) }),
      _1806: () => globalThis.firebase_firestore.updateDoc,
      _1809: () => globalThis.firebase_firestore.or,
      _1810: () => globalThis.firebase_firestore.and,
      _1819: x0 => x0.path,
      _1823: () => globalThis.firebase_firestore.GeoPoint,
      _1824: x0 => x0.latitude,
      _1825: x0 => x0.longitude,
      _1827: () => globalThis.firebase_firestore.VectorValue,
      _1830: () => globalThis.firebase_firestore.Bytes,
      _1834: x0 => x0.type,
      _1836: x0 => x0.doc,
      _1838: x0 => x0.oldIndex,
      _1840: x0 => x0.newIndex,
      _1842: () => globalThis.firebase_firestore.DocumentReference,
      _1846: x0 => x0.path,
      _1856: x0 => x0.metadata,
      _1857: x0 => x0.ref,
      _1865: x0 => x0.docs,
      _1867: x0 => x0.metadata,
      _1875: () => globalThis.firebase_firestore.Timestamp,
      _1876: x0 => x0.seconds,
      _1877: x0 => x0.nanoseconds,
      _1914: x0 => x0.hasPendingWrites,
      _1916: x0 => x0.fromCache,
      _1923: x0 => x0.source,
      _1928: () => globalThis.firebase_firestore.startAfter,
      _1929: () => globalThis.firebase_firestore.startAt,
      _1930: () => globalThis.firebase_firestore.endBefore,
      _1931: () => globalThis.firebase_firestore.endAt,
      _1944: (x0,x1) => x0.createElement(x1),
      _1958: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      _1970: (x0,x1) => x0.querySelector(x1),
      _1971: (x0,x1) => x0.getAttribute(x1),
      _1972: (x0,x1,x2) => x0.setAttribute(x1,x2),
      _1974: (x0,x1) => x0.initialize(x1),
      _1975: (x0,x1) => x0.initTokenClient(x1),
      _1976: (x0,x1) => x0.initCodeClient(x1),
      _1979: x0 => x0.disableAutoSelect(),
      _1983: (x0,x1) => globalThis.firebase_database.ref(x0,x1),
      _1985: (x0,x1) => globalThis.firebase_database.child(x0,x1),
      _1989: (x0,x1) => globalThis.firebase_database.set(x0,x1),
      _1996: x0 => globalThis.firebase_database.get(x0),
      _2011: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._2011(f,arguments.length,x0,x1) }),
      _2012: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2012(f,arguments.length,x0) }),
      _2013: (x0,x1,x2) => globalThis.firebase_database.onChildAdded(x0,x1,x2),
      _2014: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._2014(f,arguments.length,x0,x1) }),
      _2015: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2015(f,arguments.length,x0) }),
      _2016: (x0,x1,x2) => globalThis.firebase_database.onValue(x0,x1,x2),
      _2017: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._2017(f,arguments.length,x0,x1) }),
      _2018: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2018(f,arguments.length,x0) }),
      _2019: (x0,x1,x2) => globalThis.firebase_database.onChildRemoved(x0,x1,x2),
      _2020: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._2020(f,arguments.length,x0,x1) }),
      _2021: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2021(f,arguments.length,x0) }),
      _2022: (x0,x1,x2) => globalThis.firebase_database.onChildChanged(x0,x1,x2),
      _2023: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._2023(f,arguments.length,x0,x1) }),
      _2024: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2024(f,arguments.length,x0) }),
      _2025: (x0,x1,x2) => globalThis.firebase_database.onChildMoved(x0,x1,x2),
      _2044: x0 => x0.toJSON(),
      _2053: x0 => x0.val(),
      _2054: x0 => x0.toJSON(),
      _2063: (x0,x1) => globalThis.firebase_database.getDatabase(x0,x1),
      _2085: x0 => x0.toJSON(),
      _2086: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2086(f,arguments.length,x0) }),
      _2087: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2087(f,arguments.length,x0) }),
      _2088: (x0,x1,x2) => x0.onAuthStateChanged(x1,x2),
      _2089: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2089(f,arguments.length,x0) }),
      _2090: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2090(f,arguments.length,x0) }),
      _2091: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2091(f,arguments.length,x0) }),
      _2092: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2092(f,arguments.length,x0) }),
      _2093: (x0,x1,x2) => x0.onIdTokenChanged(x1,x2),
      _2110: (x0,x1) => globalThis.firebase_auth.signInWithPopup(x0,x1),
      _2112: x0 => x0.signOut(),
      _2113: (x0,x1) => globalThis.firebase_auth.connectAuthEmulator(x0,x1),
      _2127: () => new firebase_auth.GoogleAuthProvider(),
      _2128: (x0,x1) => x0.addScope(x1),
      _2129: (x0,x1) => x0.setCustomParameters(x1),
      _2135: x0 => globalThis.firebase_auth.OAuthProvider.credentialFromResult(x0),
      _2150: x0 => globalThis.firebase_auth.getAdditionalUserInfo(x0),
      _2151: (x0,x1,x2) => ({errorMap: x0,persistence: x1,popupRedirectResolver: x2}),
      _2152: (x0,x1) => globalThis.firebase_auth.initializeAuth(x0,x1),
      _2168: x0 => globalThis.firebase_auth.OAuthProvider.credentialFromError(x0),
      _2190: () => globalThis.firebase_auth.debugErrorMap,
      _2194: () => globalThis.firebase_auth.browserSessionPersistence,
      _2196: () => globalThis.firebase_auth.browserLocalPersistence,
      _2198: () => globalThis.firebase_auth.indexedDBLocalPersistence,
      _2233: x0 => globalThis.firebase_auth.multiFactor(x0),
      _2234: (x0,x1) => globalThis.firebase_auth.getMultiFactorResolver(x0,x1),
      _2236: x0 => x0.currentUser,
      _2251: x0 => x0.displayName,
      _2252: x0 => x0.email,
      _2253: x0 => x0.phoneNumber,
      _2254: x0 => x0.photoURL,
      _2255: x0 => x0.providerId,
      _2256: x0 => x0.uid,
      _2257: x0 => x0.emailVerified,
      _2258: x0 => x0.isAnonymous,
      _2259: x0 => x0.providerData,
      _2260: x0 => x0.refreshToken,
      _2261: x0 => x0.tenantId,
      _2262: x0 => x0.metadata,
      _2267: x0 => x0.providerId,
      _2268: x0 => x0.signInMethod,
      _2269: x0 => x0.accessToken,
      _2270: x0 => x0.idToken,
      _2271: x0 => x0.secret,
      _2298: x0 => x0.creationTime,
      _2299: x0 => x0.lastSignInTime,
      _2304: x0 => x0.code,
      _2306: x0 => x0.message,
      _2318: x0 => x0.email,
      _2319: x0 => x0.phoneNumber,
      _2320: x0 => x0.tenantId,
      _2343: x0 => x0.user,
      _2346: x0 => x0.providerId,
      _2347: x0 => x0.profile,
      _2348: x0 => x0.username,
      _2349: x0 => x0.isNewUser,
      _2352: () => globalThis.firebase_auth.browserPopupRedirectResolver,
      _2358: x0 => x0.displayName,
      _2359: x0 => x0.enrollmentTime,
      _2360: x0 => x0.factorId,
      _2361: x0 => x0.uid,
      _2363: x0 => x0.hints,
      _2364: x0 => x0.session,
      _2366: x0 => x0.phoneNumber,
      _2378: (x0,x1) => x0.getItem(x1),
      _2390: (x0,x1) => x0.getItem(x1),
      _2392: (x0,x1,x2) => x0.setItem(x1,x2),
      _2397: (x0,x1,x2,x3,x4,x5,x6,x7) => ({apiKey: x0,authDomain: x1,databaseURL: x2,projectId: x3,storageBucket: x4,messagingSenderId: x5,measurementId: x6,appId: x7}),
      _2398: (x0,x1) => globalThis.firebase_core.initializeApp(x0,x1),
      _2399: x0 => globalThis.firebase_core.getApp(x0),
      _2400: () => globalThis.firebase_core.getApp(),
      _2405: x0 => x0.key,
      _2406: x0 => x0.priority,
      _2471: x0 => x0.ref,
      _2481: () => globalThis.firebase_core.SDK_VERSION,
      _2488: x0 => x0.apiKey,
      _2490: x0 => x0.authDomain,
      _2492: x0 => x0.databaseURL,
      _2494: x0 => x0.projectId,
      _2496: x0 => x0.storageBucket,
      _2498: x0 => x0.messagingSenderId,
      _2500: x0 => x0.measurementId,
      _2502: x0 => x0.appId,
      _2504: x0 => x0.name,
      _2505: x0 => x0.options,
      _2506: (x0,x1) => x0.debug(x1),
      _2507: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2507(f,arguments.length,x0) }),
      _2508: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._2508(f,arguments.length,x0,x1) }),
      _2509: (x0,x1) => ({createScript: x0,createScriptURL: x1}),
      _2510: (x0,x1,x2) => x0.createPolicy(x1,x2),
      _2511: (x0,x1) => x0.createScriptURL(x1),
      _2512: (x0,x1,x2) => x0.createScript(x1,x2),
      _2513: (x0,x1) => x0.appendChild(x1),
      _2514: (x0,x1) => x0.appendChild(x1),
      _2515: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2515(f,arguments.length,x0) }),
      _2528: x0 => new Array(x0),
      _2530: x0 => x0.length,
      _2532: (x0,x1) => x0[x1],
      _2533: (x0,x1,x2) => x0[x1] = x2,
      _2536: (x0,x1,x2) => new DataView(x0,x1,x2),
      _2538: x0 => new Int8Array(x0),
      _2539: (x0,x1,x2) => new Uint8Array(x0,x1,x2),
      _2540: x0 => new Uint8Array(x0),
      _2546: x0 => new Uint16Array(x0),
      _2548: x0 => new Int32Array(x0),
      _2550: x0 => new Uint32Array(x0),
      _2552: x0 => new Float32Array(x0),
      _2554: x0 => new Float64Array(x0),
      _2556: (o, c) => o instanceof c,
      _2560: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2560(f,arguments.length,x0) }),
      _2561: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2561(f,arguments.length,x0) }),
      _2586: (decoder, codeUnits) => decoder.decode(codeUnits),
      _2587: () => new TextDecoder("utf-8", {fatal: true}),
      _2588: () => new TextDecoder("utf-8", {fatal: false}),
      _2589: x0 => new WeakRef(x0),
      _2590: x0 => x0.deref(),
      _2596: Date.now,
      _2598: s => new Date(s * 1000).getTimezoneOffset() * 60,
      _2599: s => {
        if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
          return NaN;
        }
        return parseFloat(s);
      },
      _2600: () => {
        let stackString = new Error().stack.toString();
        let frames = stackString.split('\n');
        let drop = 2;
        if (frames[0] === 'Error') {
            drop += 1;
        }
        return frames.slice(drop).join('\n');
      },
      _2601: () => typeof dartUseDateNowForTicks !== "undefined",
      _2602: () => 1000 * performance.now(),
      _2603: () => Date.now(),
      _2606: () => new WeakMap(),
      _2607: (map, o) => map.get(o),
      _2608: (map, o, v) => map.set(o, v),
      _2609: () => globalThis.WeakRef,
      _2620: s => JSON.stringify(s),
      _2621: s => printToConsole(s),
      _2622: a => a.join(''),
      _2623: (o, a, b) => o.replace(a, b),
      _2625: (s, t) => s.split(t),
      _2626: s => s.toLowerCase(),
      _2627: s => s.toUpperCase(),
      _2628: s => s.trim(),
      _2629: s => s.trimLeft(),
      _2630: s => s.trimRight(),
      _2632: (s, p, i) => s.indexOf(p, i),
      _2633: (s, p, i) => s.lastIndexOf(p, i),
      _2634: (s) => s.replace(/\$/g, "$$$$"),
      _2635: Object.is,
      _2636: s => s.toUpperCase(),
      _2637: s => s.toLowerCase(),
      _2638: (a, i) => a.push(i),
      _2642: a => a.pop(),
      _2643: (a, i) => a.splice(i, 1),
      _2645: (a, s) => a.join(s),
      _2646: (a, s, e) => a.slice(s, e),
      _2649: a => a.length,
      _2651: (a, i) => a[i],
      _2652: (a, i, v) => a[i] = v,
      _2654: (o, offsetInBytes, lengthInBytes) => {
        var dst = new ArrayBuffer(lengthInBytes);
        new Uint8Array(dst).set(new Uint8Array(o, offsetInBytes, lengthInBytes));
        return new DataView(dst);
      },
      _2655: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
      _2656: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
      _2657: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
      _2658: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
      _2659: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
      _2660: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
      _2661: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
      _2663: (o, start, length) => new BigInt64Array(o.buffer, o.byteOffset + start, length),
      _2664: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
      _2665: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
      _2666: (t, s) => t.set(s),
      _2667: l => new DataView(new ArrayBuffer(l)),
      _2668: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      _2670: o => o.buffer,
      _2671: o => o.byteOffset,
      _2672: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      _2673: (b, o) => new DataView(b, o),
      _2674: (b, o, l) => new DataView(b, o, l),
      _2675: Function.prototype.call.bind(DataView.prototype.getUint8),
      _2676: Function.prototype.call.bind(DataView.prototype.setUint8),
      _2677: Function.prototype.call.bind(DataView.prototype.getInt8),
      _2678: Function.prototype.call.bind(DataView.prototype.setInt8),
      _2679: Function.prototype.call.bind(DataView.prototype.getUint16),
      _2680: Function.prototype.call.bind(DataView.prototype.setUint16),
      _2681: Function.prototype.call.bind(DataView.prototype.getInt16),
      _2682: Function.prototype.call.bind(DataView.prototype.setInt16),
      _2683: Function.prototype.call.bind(DataView.prototype.getUint32),
      _2684: Function.prototype.call.bind(DataView.prototype.setUint32),
      _2685: Function.prototype.call.bind(DataView.prototype.getInt32),
      _2686: Function.prototype.call.bind(DataView.prototype.setInt32),
      _2689: Function.prototype.call.bind(DataView.prototype.getBigInt64),
      _2690: Function.prototype.call.bind(DataView.prototype.setBigInt64),
      _2691: Function.prototype.call.bind(DataView.prototype.getFloat32),
      _2692: Function.prototype.call.bind(DataView.prototype.setFloat32),
      _2693: Function.prototype.call.bind(DataView.prototype.getFloat64),
      _2694: Function.prototype.call.bind(DataView.prototype.setFloat64),
      _2707: (o, t) => o instanceof t,
      _2709: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2709(f,arguments.length,x0) }),
      _2710: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2710(f,arguments.length,x0) }),
      _2711: o => Object.keys(o),
      _2712: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      _2713: (handle) => clearTimeout(handle),
      _2714: (ms, c) =>
      setInterval(() => dartInstance.exports.$invokeCallback(c), ms),
      _2715: (handle) => clearInterval(handle),
      _2716: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      _2717: () => Date.now(),
      _2718: (x0,x1,x2,x3,x4,x5) => ({method: x0,headers: x1,body: x2,credentials: x3,redirect: x4,signal: x5}),
      _2719: (x0,x1,x2) => x0.fetch(x1,x2),
      _2720: (x0,x1) => x0.get(x1),
      _2721: f => finalizeWrapper(f, function(x0,x1,x2) { return dartInstance.exports._2721(f,arguments.length,x0,x1,x2) }),
      _2722: (x0,x1) => x0.forEach(x1),
      _2724: () => new AbortController(),
      _2725: x0 => x0.getReader(),
      _2726: x0 => x0.read(),
      _2727: x0 => x0.cancel(),
      _2744: x0 => x0.trustedTypes,
      _2745: (x0,x1) => x0.src = x1,
      _2746: (x0,x1) => x0.createScriptURL(x1),
      _2747: x0 => x0.nonce,
      _2748: (x0,x1) => x0.debug(x1),
      _2749: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2749(f,arguments.length,x0) }),
      _2750: x0 => ({createScriptURL: x0}),
      _2751: (x0,x1) => x0.appendChild(x1),
      _2752: (x0,x1) => x0.querySelectorAll(x1),
      _2753: (x0,x1) => x0.item(x1),
      _2754: (x0,x1) => x0.getAttribute(x1),
      _2755: (x0,x1) => x0.key(x1),
      _2756: x0 => x0.trustedTypes,
      _2758: (x0,x1) => x0.text = x1,
      _2774: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      _2775: (x0,x1) => x0.exec(x1),
      _2776: (x0,x1) => x0.test(x1),
      _2777: (x0,x1) => x0.exec(x1),
      _2778: (x0,x1) => x0.exec(x1),
      _2779: x0 => x0.pop(),
      _2781: o => o === undefined,
      _2800: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      _2802: o => {
        const proto = Object.getPrototypeOf(o);
        return proto === Object.prototype || proto === null;
      },
      _2803: o => o instanceof RegExp,
      _2804: (l, r) => l === r,
      _2805: o => o,
      _2806: o => o,
      _2807: o => o,
      _2808: b => !!b,
      _2809: o => o.length,
      _2812: (o, i) => o[i],
      _2813: f => f.dartFunction,
      _2814: l => arrayFromDartList(Int8Array, l),
      _2815: l => arrayFromDartList(Uint8Array, l),
      _2816: l => arrayFromDartList(Uint8ClampedArray, l),
      _2817: l => arrayFromDartList(Int16Array, l),
      _2818: l => arrayFromDartList(Uint16Array, l),
      _2819: l => arrayFromDartList(Int32Array, l),
      _2820: l => arrayFromDartList(Uint32Array, l),
      _2821: l => arrayFromDartList(Float32Array, l),
      _2822: l => arrayFromDartList(Float64Array, l),
      _2823: x0 => new ArrayBuffer(x0),
      _2824: (data, length) => {
        const getValue = dartInstance.exports.$byteDataGetUint8;
        const view = new DataView(new ArrayBuffer(length));
        for (let i = 0; i < length; i++) {
          view.setUint8(i, getValue(data, i));
        }
        return view;
      },
      _2825: l => arrayFromDartList(Array, l),
      _2826: () => ({}),
      _2827: () => [],
      _2828: l => new Array(l),
      _2829: () => globalThis,
      _2830: (constructor, args) => {
        const factoryFunction = constructor.bind.apply(
            constructor, [null, ...args]);
        return new factoryFunction();
      },
      _2831: (o, p) => p in o,
      _2832: (o, p) => o[p],
      _2833: (o, p, v) => o[p] = v,
      _2834: (o, m, a) => o[m].apply(o, a),
      _2836: o => String(o),
      _2837: (p, s, f) => p.then(s, f),
      _2838: o => {
        if (o === undefined) return 1;
        var type = typeof o;
        if (type === 'boolean') return 2;
        if (type === 'number') return 3;
        if (type === 'string') return 4;
        if (o instanceof Array) return 5;
        if (ArrayBuffer.isView(o)) {
          if (o instanceof Int8Array) return 6;
          if (o instanceof Uint8Array) return 7;
          if (o instanceof Uint8ClampedArray) return 8;
          if (o instanceof Int16Array) return 9;
          if (o instanceof Uint16Array) return 10;
          if (o instanceof Int32Array) return 11;
          if (o instanceof Uint32Array) return 12;
          if (o instanceof Float32Array) return 13;
          if (o instanceof Float64Array) return 14;
          if (o instanceof DataView) return 15;
        }
        if (o instanceof ArrayBuffer) return 16;
        return 17;
      },
      _2839: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI8ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2840: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI8ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2841: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI16ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2842: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI16ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2843: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2844: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2845: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2846: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2847: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF64ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2848: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF64ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2849: s => {
        if (/[[\]{}()*+?.\\^$|]/.test(s)) {
            s = s.replace(/[[\]{}()*+?.\\^$|]/g, '\\$&');
        }
        return s;
      },
      _2852: x0 => x0.index,
      _2853: x0 => x0.groups,
      _2855: (x0,x1) => x0.exec(x1),
      _2857: x0 => x0.flags,
      _2858: x0 => x0.multiline,
      _2859: x0 => x0.ignoreCase,
      _2860: x0 => x0.unicode,
      _2861: x0 => x0.dotAll,
      _2862: (x0,x1) => x0.lastIndex = x1,
      _2864: (o, p) => o[p],
      _2865: (o, p, v) => o[p] = v,
      _2866: (o, p) => delete o[p],
      _2867: x0 => x0.random(),
      _2868: x0 => x0.random(),
      _2869: (x0,x1) => x0.getRandomValues(x1),
      _2870: () => globalThis.crypto,
      _2872: () => globalThis.Math,
      _2874: Function.prototype.call.bind(Number.prototype.toString),
      _2875: (d, digits) => d.toFixed(digits),
      _2935: () => globalThis.google.accounts.oauth2,
      _2939: (x0,x1) => x0.revoke(x1),
      _2944: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2944(f,arguments.length,x0) }),
      _2945: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2945(f,arguments.length,x0) }),
      _2946: (x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12) => ({client_id: x0,scope: x1,include_granted_scopes: x2,redirect_uri: x3,callback: x4,state: x5,enable_granular_consent: x6,enable_serial_consent: x7,login_hint: x8,hd: x9,ux_mode: x10,select_account: x11,error_callback: x12}),
      _2951: x0 => x0.error,
      _2954: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2954(f,arguments.length,x0) }),
      _2955: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2955(f,arguments.length,x0) }),
      _2956: (x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10) => ({client_id: x0,callback: x1,scope: x2,include_granted_scopes: x3,prompt: x4,enable_granular_consent: x5,enable_serial_consent: x6,login_hint: x7,hd: x8,state: x9,error_callback: x10}),
      _2962: x0 => x0.access_token,
      _2963: x0 => x0.expires_in,
      _2969: x0 => x0.error,
      _2972: x0 => x0.type,
      _2977: () => globalThis.google.accounts.id,
      _3004: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._3004(f,arguments.length,x0) }),
      _3007: (x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16) => ({client_id: x0,auto_select: x1,callback: x2,login_uri: x3,native_callback: x4,cancel_on_tap_outside: x5,prompt_parent_id: x6,nonce: x7,context: x8,state_cookie_domain: x9,ux_mode: x10,allowed_parent_origin: x11,intermediate_iframe_close_callback: x12,itp_support: x13,login_hint: x14,hd: x15,use_fedcm_for_prompt: x16}),
      _3028: x0 => x0.error,
      _3030: x0 => x0.credential,
      _3041: x0 => globalThis.onGoogleLibraryLoad = x0,
      _3042: f => finalizeWrapper(f, function() { return dartInstance.exports._3042(f,arguments.length) }),
      _3380: (x0,x1) => x0.nonce = x1,
      _4426: (x0,x1) => x0.src = x1,
      _4428: (x0,x1) => x0.type = x1,
      _4432: (x0,x1) => x0.async = x1,
      _4434: (x0,x1) => x0.defer = x1,
      _4436: (x0,x1) => x0.crossOrigin = x1,
      _4438: (x0,x1) => x0.text = x1,
      _4913: () => globalThis.window,
      _4955: x0 => x0.document,
      _4958: x0 => x0.location,
      _4977: x0 => x0.navigator,
      _5239: x0 => x0.trustedTypes,
      _5240: x0 => x0.sessionStorage,
      _5241: x0 => x0.localStorage,
      _5256: x0 => x0.hostname,
      _5368: x0 => x0.userAgent,
      _5588: x0 => x0.length,
      _7615: x0 => x0.signal,
      _7625: x0 => x0.length,
      _7693: () => globalThis.document,
      _7788: x0 => x0.head,
      _8137: (x0,x1) => x0.id = x1,
      _9518: x0 => x0.value,
      _9520: x0 => x0.done,
      _10243: x0 => x0.url,
      _10245: x0 => x0.status,
      _10247: x0 => x0.statusText,
      _10248: x0 => x0.headers,
      _10249: x0 => x0.body,
      _14642: () => globalThis.console,
      _14673: x0 => x0.name,
      _14674: x0 => x0.message,
      _14675: x0 => x0.code,
      _14677: x0 => x0.customData,

    };

    const baseImports = {
      dart2wasm: dart2wasm,


      Math: Math,
      Date: Date,
      Object: Object,
      Array: Array,
      Reflect: Reflect,
    };

    const jsStringPolyfill = {
      "charCodeAt": (s, i) => s.charCodeAt(i),
      "compare": (s1, s2) => {
        if (s1 < s2) return -1;
        if (s1 > s2) return 1;
        return 0;
      },
      "concat": (s1, s2) => s1 + s2,
      "equals": (s1, s2) => s1 === s2,
      "fromCharCode": (i) => String.fromCharCode(i),
      "length": (s) => s.length,
      "substring": (s, a, b) => s.substring(a, b),
      "fromCharCodeArray": (a, start, end) => {
        if (end <= start) return '';

        const read = dartInstance.exports.$wasmI16ArrayGet;
        let result = '';
        let index = start;
        const chunkLength = Math.min(end - index, 500);
        let array = new Array(chunkLength);
        while (index < end) {
          const newChunkLength = Math.min(end - index, 500);
          for (let i = 0; i < newChunkLength; i++) {
            array[i] = read(a, index++);
          }
          if (newChunkLength < chunkLength) {
            array = array.slice(0, newChunkLength);
          }
          result += String.fromCharCode(...array);
        }
        return result;
      },
    };

    const deferredLibraryHelper = {
      "loadModule": async (moduleName) => {
        if (!loadDeferredWasm) {
          throw "No implementation of loadDeferredWasm provided.";
        }
        const source = await Promise.resolve(loadDeferredWasm(moduleName));
        const module = await ((source instanceof Response)
            ? WebAssembly.compileStreaming(source, this.builtins)
            : WebAssembly.compile(source, this.builtins));
        return await WebAssembly.instantiate(module, {
          ...baseImports,
          ...additionalImports,
          "wasm:js-string": jsStringPolyfill,
          "module0": dartInstance.exports,
        });
      },
    };

    dartInstance = await WebAssembly.instantiate(this.module, {
      ...baseImports,
      ...additionalImports,
      "deferredLibraryHelper": deferredLibraryHelper,
      "wasm:js-string": jsStringPolyfill,
    });

    return new InstantiatedApp(this, dartInstance);
  }
}

class InstantiatedApp {
  constructor(compiledApp, instantiatedModule) {
    this.compiledApp = compiledApp;
    this.instantiatedModule = instantiatedModule;
  }

  // Call the main function with the given arguments.
  invokeMain(...args) {
    this.instantiatedModule.exports.$invokeMain(args);
  }
}

