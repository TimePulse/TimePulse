class AuthzController < ApplicationController
  needs_authorization
  admin_authorized
end
