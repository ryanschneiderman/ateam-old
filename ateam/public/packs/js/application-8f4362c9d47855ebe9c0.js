/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, { enumerable: true, get: getter });
/******/ 		}
/******/ 	};
/******/
/******/ 	// define __esModule on exports
/******/ 	__webpack_require__.r = function(exports) {
/******/ 		if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 			Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 		}
/******/ 		Object.defineProperty(exports, '__esModule', { value: true });
/******/ 	};
/******/
/******/ 	// create a fake namespace object
/******/ 	// mode & 1: value is a module id, require it
/******/ 	// mode & 2: merge all properties of value into the ns
/******/ 	// mode & 4: return value when already ns object
/******/ 	// mode & 8|1: behave like require
/******/ 	__webpack_require__.t = function(value, mode) {
/******/ 		if(mode & 1) value = __webpack_require__(value);
/******/ 		if(mode & 8) return value;
/******/ 		if((mode & 4) && typeof value === 'object' && value && value.__esModule) return value;
/******/ 		var ns = Object.create(null);
/******/ 		__webpack_require__.r(ns);
/******/ 		Object.defineProperty(ns, 'default', { enumerable: true, value: value });
/******/ 		if(mode & 2 && typeof value != 'string') for(var key in value) __webpack_require__.d(ns, key, function(key) { return value[key]; }.bind(null, key));
/******/ 		return ns;
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "/packs/";
/******/
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = "./app/javascript/packs/application.js");
/******/ })
/************************************************************************/
/******/ ({

/***/ "./app/javascript/components sync recursive ^\\.\\/.*$":
/*!*************************************************!*\
  !*** ./app/javascript/components sync ^\.\/.*$ ***!
  \*************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

var map = {
	"./HelloWorld": "./app/javascript/components/HelloWorld.js",
	"./HelloWorld.js": "./app/javascript/components/HelloWorld.js"
};


function webpackContext(req) {
	var id = webpackContextResolve(req);
	return __webpack_require__(id);
}
function webpackContextResolve(req) {
	if(!__webpack_require__.o(map, req)) {
		var e = new Error("Cannot find module '" + req + "'");
		e.code = 'MODULE_NOT_FOUND';
		throw e;
	}
	return map[req];
}
webpackContext.keys = function webpackContextKeys() {
	return Object.keys(map);
};
webpackContext.resolve = webpackContextResolve;
module.exports = webpackContext;
webpackContext.id = "./app/javascript/components sync recursive ^\\.\\/.*$";

/***/ }),

/***/ "./app/javascript/components/HelloWorld.js":
/*!*************************************************!*\
  !*** ./app/javascript/components/HelloWorld.js ***!
  \*************************************************/
/*! no static exports found */
/***/ (function(module, exports) {

throw new Error("Module build failed (from ./node_modules/babel-loader/lib/index.js):\nSyntaxError: /Users/ryan/src/ateam/ateam/app/javascript/components/HelloWorld.js: Support for the experimental syntax 'jsx' isn't currently enabled (6:7):\n\n  4 |   render () {\n  5 |     return (\n> 6 |       <React.Fragment>\n    |       ^\n  7 |         Greeting: {this.props.greeting}\n  8 |       </React.Fragment>\n  9 |     );\n\nAdd @babel/preset-react (https://github.com/babel/babel/tree/main/packages/babel-preset-react) to the 'presets' section of your Babel config to enable transformation.\nIf you want to leave it as-is, add @babel/plugin-syntax-jsx (https://github.com/babel/babel/tree/main/packages/babel-plugin-syntax-jsx) to the 'plugins' section to enable parsing.\n    at instantiate (/Users/ryan/src/ateam/ateam/node_modules/@babel/parser/lib/index.js:72:32)\n    at constructor (/Users/ryan/src/ateam/ateam/node_modules/@babel/parser/lib/index.js:359:12)\n    at Parser.raise (/Users/ryan/src/ateam/ateam/node_modules/@babel/parser/lib/index.js:3339:19)\n    at Parser.expectOnePlugin (/Users/ryan/src/ateam/ateam/node_modules/@babel/parser/lib/index.js:3396:18)\n    at Parser.parseExprAtom (/Users/ryan/src/ateam/ateam/node_modules/@babel/parser/lib/index.js:13078:18)\n    at Parser.parseExprSubscripts (/Users/ryan/src/ateam/ateam/node_modules/@babel/parser/lib/index.js:12648:23)\n    at Parser.parseUpdate (/Users/ryan/src/ateam/ateam/node_modules/@babel/parser/lib/index.js:12627:21)\n    at Parser.parseMaybeUnary (/Users/ryan/src/ateam/ateam/node_modules/@babel/parser/lib/index.js:12598:23)\n    at Parser.parseMaybeUnaryOrPrivate (/Users/ryan/src/ateam/ateam/node_modules/@babel/parser/lib/index.js:12392:61)\n    at Parser.parseExprOps (/Users/ryan/src/ateam/ateam/node_modules/@babel/parser/lib/index.js:12399:23)\n    at Parser.parseMaybeConditional (/Users/ryan/src/ateam/ateam/node_modules/@babel/parser/lib/index.js:12369:23)\n    at Parser.parseMaybeAssign (/Users/ryan/src/ateam/ateam/node_modules/@babel/parser/lib/index.js:12321:21)\n    at /Users/ryan/src/ateam/ateam/node_modules/@babel/parser/lib/index.js:12279:39\n    at Parser.allowInAnd (/Users/ryan/src/ateam/ateam/node_modules/@babel/parser/lib/index.js:14352:12)\n    at Parser.parseMaybeAssignAllowIn (/Users/ryan/src/ateam/ateam/node_modules/@babel/parser/lib/index.js:12279:17)\n    at Parser.parseParenAndDistinguishExpression (/Users/ryan/src/ateam/ateam/node_modules/@babel/parser/lib/index.js:13405:28)\n    at Parser.parseExprAtom (/Users/ryan/src/ateam/ateam/node_modules/@babel/parser/lib/index.js:12976:23)\n    at Parser.parseExprSubscripts (/Users/ryan/src/ateam/ateam/node_modules/@babel/parser/lib/index.js:12648:23)\n    at Parser.parseUpdate (/Users/ryan/src/ateam/ateam/node_modules/@babel/parser/lib/index.js:12627:21)\n    at Parser.parseMaybeUnary (/Users/ryan/src/ateam/ateam/node_modules/@babel/parser/lib/index.js:12598:23)\n    at Parser.parseMaybeUnaryOrPrivate (/Users/ryan/src/ateam/ateam/node_modules/@babel/parser/lib/index.js:12392:61)\n    at Parser.parseExprOps (/Users/ryan/src/ateam/ateam/node_modules/@babel/parser/lib/index.js:12399:23)\n    at Parser.parseMaybeConditional (/Users/ryan/src/ateam/ateam/node_modules/@babel/parser/lib/index.js:12369:23)\n    at Parser.parseMaybeAssign (/Users/ryan/src/ateam/ateam/node_modules/@babel/parser/lib/index.js:12321:21)\n    at Parser.parseExpressionBase (/Users/ryan/src/ateam/ateam/node_modules/@babel/parser/lib/index.js:12257:23)\n    at /Users/ryan/src/ateam/ateam/node_modules/@babel/parser/lib/index.js:12251:39\n    at Parser.allowInAnd (/Users/ryan/src/ateam/ateam/node_modules/@babel/parser/lib/index.js:14346:16)\n    at Parser.parseExpression (/Users/ryan/src/ateam/ateam/node_modules/@babel/parser/lib/index.js:12251:17)\n    at Parser.parseReturnStatement (/Users/ryan/src/ateam/ateam/node_modules/@babel/parser/lib/index.js:15058:28)\n    at Parser.parseStatementContent (/Users/ryan/src/ateam/ateam/node_modules/@babel/parser/lib/index.js:14697:21)");

/***/ }),

/***/ "./app/javascript/packs/application.js":
/*!*********************************************!*\
  !*** ./app/javascript/packs/application.js ***!
  \*********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb
// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
console.log('Hello World from Webpacker');
console.log("test"); // Support component names relative to this directory:

var componentRequireContext = __webpack_require__("./app/javascript/components sync recursive ^\\.\\/.*$"); // var ReactRailsUJS = require("react_ujs");
// ReactRailsUJS.useContext(componentRequireContext);

/***/ })

/******/ });
//# sourceMappingURL=application-8f4362c9d47855ebe9c0.js.map