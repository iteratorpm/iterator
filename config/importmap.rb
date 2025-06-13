# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js" # @3.2.2
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "ultimate_turbo_modal" # @2.0.3
pin "chartkick" # @5.0.1
pin "Chart.bundle", to: "Chart.bundle.js"
pin "hotkeys-js" # @3.13.9
pin "sortablejs" # @1.15.6
pin "stimulus-use" # @0.52.3
pin "@rails/request.js", to: "@rails--request.js.js" # @0.0.11
pin "autosize" # @6.0.1
pin "js-cookie" # @3.0.5
pin "tributejs" # @5.1.3
pin "cocoon-js-vanilla" # @1.5.1
pin "taggle" # @1.15.0
pin "autocompleter" # @9.3.2
pin "lodash.debounce" # @4.0.8
