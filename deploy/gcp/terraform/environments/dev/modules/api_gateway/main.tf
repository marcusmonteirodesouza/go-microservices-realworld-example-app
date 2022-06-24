resource "google_project_service" "api_gateway" {
  service            = "apigateway.googleapis.com"
  disable_on_destroy = true
}

resource "google_project_service" "service_control" {
  service            = "servicecontrol.googleapis.com"
  disable_on_destroy = true
}

resource "google_project_service" "service_management" {
  service            = "servicemanagement.googleapis.com"
  disable_on_destroy = true
}

resource "google_api_gateway_api" "api" {
  provider = google-beta
  api_id = var.api_id

  depends_on = [
    google_project_service.api_gateway
  ]
}

resource "google_api_gateway_api_config" "api_gateway" {
  provider = google-beta
  api           = google_api_gateway_api.api.api_id
  api_config_id = "${google_api_gateway_api.api.api_id}-config"

  openapi_documents {
    document {
      path = "realworld-example-app-spec.yaml"
      contents = base64encode(<<-EOF
swagger: '2.0'
info:
  title: ${google_api_gateway_api.api.api_id}
  description: ${var.api_description}
  version: 1.0.0
basePath: /api
schemes:
  - https
produces:
  - application/json
paths:
  /users/login:
    post:
      x-google-backend:
        address: ${var.users_service_url}/users/login
      summary: Existing user login
      description: Login for existing user
      operationId: login
      consumes:
        - application/json
      parameters:
        - in: body
          name: user
          description: The User to login
          schema:
            type: object
            required:
              - email
              - password
            properties:
              email:
                type: string
              password: 
                type: string
                format: password
      responses: 
        200:
          description: OK
          schema:
            $ref: '#/definitions/User'
        401:
          description: Unauthorized
        422:
          description: Unexpected error
          schema:
            $ref: '#/definitions/ErrorResponse'
definitions:
  User:
    type: object
    properties:
      user: 
        type: object
        required:
          - email
          - token
          - username
          - bio
          - image
        properties:
          email:
            type: string
          token:
            type: string
          username:
            type: string
          bio:
            type: string
          image:
            type: string
  ErrorResponse:
    required:
      - errors
    type: object
    properties:
      errors:
        required:
          - body
        type: object
        properties:
          body:
            type: array
            items:
              type: string
EOF
      )
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_api_gateway_gateway" "api_gateway" {
  provider = google-beta
  api_config = google_api_gateway_api_config.api_gateway.id
  gateway_id = "${var.api_id}-api-gateway"
}
