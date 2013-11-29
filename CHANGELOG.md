## 2.0.1.rc2

* Added AJAX-rendering to `Arbre::Rails::LegacyDocument`
* Bug fix: classes specified in the class definition are not overwritten anymore by those passed to the
  `build!` method.
* When using the `build!` method, any attributes that have a corresponding `<attribute>=` method on the
  element class will cause this method to be invoked rather than the attributes array being updated.

## 2.0.1.rc1

* Added `app/views/arbre` as autoload path when using Rails
* Added DSL methods `Arbre::Html::Tag.tag`, `Arbre::Html::Tag.tag_id` and `Arbre::Html::Tag.tag_classes` 

## 2.0.0

* Increased RSpec coverage to 100%
* Clear of specs failing when integrating into Flux framework

## 2.0.0.rc2

* Support for symbolic classes
* Various fixes & spec upgrades after integration into Flux framework

### Breaking changes

* Renaming `build` to `build!`
* Renaming `build_tag`/`build_element` to `build`
* Renaming `insert_tag`/`insert_element` to `insert`

## 2.0.0.rc1

* Rails: added content-layout structure
* Rails: optimized template output handling, removed need for String masquerading
* Added querying
* Increased RSpec coverage to near 100%

### Breaking changes

* Removal of `:for`-feature in tags
* Renamed `current_arbre_element` to `current_element`
* Renamed `Arbre::HTML` into `Arbre::Html`

  *Joost Lubach*

## 1.0.1

* Template handler converts to string to satisfy Rack::Lint (@jpmckinney, #6)
* Fix to `Tag#add_class` when passing a string of classes to Tag build method
  (@gregbell, #7)
* Not longer uses the default separator (@LTe, #4)

## 1.0.0

* Added support for the use of `:for` with non Active Model objects

## 1.0.0.rc4

* Fix issue where user could call `symbolize_keys!` on a
  HashWithIndifferentAccess which doesn't implement the method

## 1.0.0.rc3

* Implemented `Arbre::Html::Tag#default_id_for_prefix`

## 1.0.0.rc2

* Fixed bug where Component's build methods were being rendered within the
  parent context.

## 1.0.0.rc1

Initial release and extraction from Active Admin
