function init(){var require=(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var app, appData;

appData = {};

app = {
  api: null,
  exapi: {},
  init: function(api) {
    return app.api = api;
  }
};

module.exports = app;

},{}],2:[function(require,module,exports){
var DOMObserver;

DOMObserver = (function() {
  DOMObserver.prototype.bodyObserver = null;

  DOMObserver.prototype.isActive = false;

  DOMObserver.prototype.observers = {};

  DOMObserver.prototype.processedOnce = [];

  DOMObserver.prototype.checkForAction = function(selector, observer, container) {
    var matchedElems, nodesList;
    nodesList = container.querySelectorAll(selector);
    matchedElems = Array.prototype.slice.call(nodesList);
    return matchedElems.forEach((function(_this) {
      return function(elem) {
        if (elem && _this.processedOnce.indexOf(elem) < 0) {
          _this.processedOnce.push(elem);
          return observer.action(elem);
        }
      };
    })(this));
  };

  function DOMObserver() {
    this.bodyObserver = new MutationObserver((function(_this) {
      return function(mutations) {
        return mutations.forEach(function(mutation) {
          var observer, ref, results, selector;
          ref = _this.observers;
          results = [];
          for (selector in ref) {
            observer = ref[selector];
            results.push(_this.checkForAction(selector, observer, mutation.target));
          }
          return results;
        });
      };
    })(this));
  }

  DOMObserver.prototype.activateMainObserver = function() {
    var config, target;
    if (!this.isActive) {
      this.isActive = true;
      target = document.querySelector('body');
      config = {
        subtree: true,
        childList: true
      };
      return this.bodyObserver.observe(target, config);
    }
  };

  DOMObserver.prototype.waitElement = function(selector, action) {
    var observer;
    this.activateMainObserver();
    observer = {
      selector: selector,
      action: action
    };
    this.observers[selector] = observer;
    return this.checkForAction(selector, observer, document.querySelector('body'));
  };

  return DOMObserver;

})();

module.exports = DOMObserver;

},{}],"addon":[function(require,module,exports){
var DOMObserver, addonEntry, app;

app = require('./app');

DOMObserver = require('./helpers/domObserver');

addonEntry = {
  start: function(_taistApi, entryPoint) {
    window._app = app;
    app.init(_taistApi);
    return console.log("STARTED ON " + location.host);
  }
};

module.exports = addonEntry;

},{"./app":1,"./helpers/domObserver":2}]},{},[]);
;return require("addon")}