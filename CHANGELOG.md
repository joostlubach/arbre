## 2.0.0.rc1

* Removal of `:for`-feature in tags
* Rails: added content-layout structure
* Rails: optimized template output handling, removed need for String masquerading
* Increased RSpec coverage to 100%

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
