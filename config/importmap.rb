pin "flatpickr", to: "https://ga.jspm.io/npm:flatpickr@4.6.13/dist/esm/index.js", preload: true
pin "lodash-es/debounce", to: "https://ga.jspm.io/npm:lodash-es@4.17.21/debounce.js", preload: true
pin "lodash-es/max", to: "https://ga.jspm.io/npm:lodash-es@4.17.21/max.js", preload: true
pin "sortablejs", to: "https://ga.jspm.io/npm:sortablejs@1.15.0/modular/sortable.esm.js", preload: true
pin "@hotwired/turbo-rails", to: "https://ga.jspm.io/npm:@hotwired/turbo-rails@7.3.0/app/javascript/turbo/index.js"
pin "@hotwired/turbo", to: "https://ga.jspm.io/npm:@hotwired/turbo@7.3.0/dist/turbo.es2017-esm.js"
pin "@rails/actioncable/src", to: "https://ga.jspm.io/npm:@rails/actioncable@7.0.7/src/index.js"

pin "alchemy_admin", to: "alchemy_admin.js", preload: true
pin_all_from File.expand_path("../app/javascript/alchemy_admin", __dir__), under: "alchemy_admin"
