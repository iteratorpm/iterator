// Import and register all your controllers
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

import { UltimateTurboModalController } from "ultimate_turbo_modal"
application.register("modal", UltimateTurboModalController)
