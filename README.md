# srplib

A collection of lightweight and highly specialized libraries for lua.
Lua port of Java libraries https://github.com/apechinsky/srplib.

## Modules

* srplib.path - General purpose path library
* srplib.name - Converts name between different naming schemas.
* srplib.strings

### srplib.path

General purpose path library (classpath, filesystem path, URL, etc.)
Provides common operations on paths, such as joining, normalizing, extracting components, etc.
Provides predictable behavior independent of trailing slashes or other edge cases.

```
local path = Path.parse('ab/cd/hello', '/')
path:parent() --> 'ab/cd'
path:child('world') --> 'ab/cd/hello/world'
path:sibling('bye') --> 'ab/cd/bye'
path:relative('ab/cd') --> 'hello'
path:relative('ab/cd/hello', 'ef') -> 'ef/../ab/cd/hello'
```


### srplib.name

Converts name between different naming schemas:
* camelCase
* PascalCase
* snake_case
* kebab-case
* etc.

```
local Name = require("srplib.name")
local myvar = Name.parse("some_variable_name")
myvar:kebab() --> "some-variable-name"
myvar:camel() --> "someVariableName"
```

### srplib.strings

## Publishing

```bash
$ git tag v0.1.0
$ git push --tags
```

