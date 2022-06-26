locals {
  api_config_spec = <<-EOF
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
  /users:
    post:
      x-google-backend:
        address: ${var.users_service_url}/users
      summary: Register a new user
      description: Register a new user
      operationId: registerUser
      consumes:
        - application/json
      parameters:
        - in: body
          name: user
          description: The User to register
          schema:
            type: object
            required:
              - email
              - username
              - password
            properties:
              email:
                type: string
              username:
                type: string
              password: 
                type: string
                format: password
      responses: 
        201:
          description: Created
          schema:
            $ref: '#/definitions/User'
        401:
          description: Unauthorized
        422:
          description: Unexpected error
          schema:
            $ref: '#/definitions/ErrorResponse'
  /user:
    get:
      x-google-backend:
        address: ${var.users_service_url}/user
      summary: Get current user
      description: Get current user
      operationId: getCurrentUser
      responses: 
        200:
          description: Created
          schema:
            $ref: '#/definitions/User'
        422:
          description: Unexpected error
          schema:
            $ref: '#/definitions/ErrorResponse'
EOF
}
