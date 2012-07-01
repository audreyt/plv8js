# Modules

Modules are an implementation of CommonJS modules as defined by http://wiki.commonjs.org/wiki/Modules/1.0.

## Usage

There are two types of modules: built-in and user-installed.  Built in modules are core modules that are distributed with PLV8.

Built-in modules are stored in `/usr/local/plv8/lib`.

User-installed modules are stored in `/usr/local/plv8/plv8_modules`.

Modules can accessed via `require()` and should contain a CommonJS `exports` object.

hello.js:

    exports.hello = function (who) {
      return "Hello " + who + "!";
    };

hello.sql

    CREATE OR REPLACE FUNCTION hello(who VARCHAR) RETURNS
    VARCHAR AS $$
      var hello = require('hello');
      
      return hello.hello(who);
    $$ LANGUAGE plv8 IMMUTABLE STRICT;

running:

    work=# SELECT hello('World');

## Modules

There are a couple of built-in modules to get things going.

### Assert

Assertion modules (useful for testing).

    var assert = require('assert');


#### assert.ok(guard, message)

Asserts whether a value is truthy.  This is a synonym of `assert.equal(true, !!guard, message)`.

#### assert.equal(actual, expected, message)

Asserts whether two values are equal.

#### assert.notEqual(actual, expected, message)

Asserts whether two values are not equal to each other.

#### assert.deepEqual(actual, expected, message)

Asserts whether two objects are deeply equal.

#### assert.notDeepEqual(actual, expected, message)

Asserts whether two objects are not deeply equal.

#### assert.strictEqual(actual, expected, message)

Asserts whether two values are strictly equal (===).

#### assert.notStrictEqual(actual, expected, message)

Asserts whether two values are not strictly equal (!==)

### Util

    var util = require('util');

## Caveats

- Currently there is no support for relative paths in `require()`, but that should change in a couple of revisions.
- Modules are not cached, and currently will be executed on every reload.


