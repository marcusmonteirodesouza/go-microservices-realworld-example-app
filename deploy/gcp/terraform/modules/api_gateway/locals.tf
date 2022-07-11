locals {
  api_config_spec = <<-EOF
swagger: '2.0'
info:
  title: ${google_api_gateway_api.api.api_id}
  description: ${var.api_description}
  version: 1.0.0
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
            format: email
          token:
            type: string
          username:
            type: string
          bio:
            type: string
          image:
            type: string
            format: uri
  UserWithoutToken:
    type: object
    properties:
      user: 
        type: object
        required:
          - email
          - username
          - bio
          - image
        properties:
          email:
            type: string
            format: email
          username:
            type: string
          bio:
            type: string
          image:
            type: string
            format: uri
  Profile:
    type: object
    properties:
      profile: 
        type: object
        required:
          - username
          - bio
          - image
          - following
        properties:
          username:
            type: string
          bio:
            type: string
          image:
            type: string
            format: uri
          following:
            type: boolean
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
        address: ${var.users_service_url}
        path_translation: APPEND_PATH_TO_ADDRESS
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
                format: email
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
        address: ${var.users_service_url}
        path_translation: APPEND_PATH_TO_ADDRESS
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
                format: email
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
        address: ${var.users_service_url}
        path_translation: APPEND_PATH_TO_ADDRESS
      summary: Get current user
      description: Get current user
      operationId: getCurrentUser
      responses: 
        200:
          description: OK
          schema:
            $ref: '#/definitions/User'
        422:
          description: Unexpected error
          schema:
            $ref: '#/definitions/ErrorResponse'
    put:
      x-google-backend:
        address: ${var.users_service_url}
        path_translation: APPEND_PATH_TO_ADDRESS
      summary: Update current user
      description: Updated user information for current user
      operationId: updateCurrentUser
      consumes:
        - application/json
      parameters:
        - in: body
          name: user
          description: User details to update. At least **one** field is required.
          schema:
            type: object
            properties:
              email:
                type: string
                format: email
              username:
                type: string
              password: 
                type: string
                format: password
              bio:
                type: string
              image: 
                type: string
                format: uri
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
  /users/{username}:
    get:
      x-google-backend:
        address: ${var.users_service_url}
        path_translation: APPEND_PATH_TO_ADDRESS
      summary: Get user by username
      description: Get user by username
      operationId: getUserByUsername
      parameters:
        - name: username
          in: path
          description: Username of the user to get
          type: string
          required: true
      responses: 
        200:
          description: OK
          schema:
            $ref: '#/definitions/UserWithoutToken'
        404:
          description: Not Found
  /profiles/{username}:
    get:
      x-google-backend:
        address: ${var.profiles_service_url}
        path_translation: APPEND_PATH_TO_ADDRESS
      summary: Get a profile
      description: Get a profile of a user of the system. Auth is optional
      operationId: getProfileByUsername
      parameters:
        - name: username
          in: path
          description: Username of the profile to get
          type: string
          required: true
      responses: 
        200:
          description: OK
          schema:
            $ref: '#/definitions/Profile'
        401:
          description: Unauthorized    
        422:
          description: Unexpected error
          schema:
            $ref: '#/definitions/ErrorResponse'
  /profiles/{username}/follow:
    post:
      x-google-backend:
        address: ${var.profiles_service_url}
        path_translation: APPEND_PATH_TO_ADDRESS
      summary: Follow a user
      description: Follow a user by username
      operationId: followUserByUsername
      parameters:
        - name: username
          in: path
          description: Username of the profile to get
          type: string
          required: true
      responses: 
        201:
          description: Created
          schema:
            $ref: '#/definitions/Profile'
        401:
          description: Unauthorized    
        422:
          description: Unexpected error
          schema:
            $ref: '#/definitions/ErrorResponse'
    delete:
      x-google-backend:
        address: ${var.profiles_service_url}
        path_translation: APPEND_PATH_TO_ADDRESS
      summary: Unfollow a user
      description: Unfollow a user by username
      operationId: unfollowUserByUsername
      parameters:
        - name: username
          in: path
          description: Username of the profile to get
          type: string
          required: true
      responses: 
        201:
          description: Created
          schema:
            $ref: '#/definitions/Profile'
        401:
          description: Unauthorized    
        422:
          description: Unexpected error
          schema:
            $ref: '#/definitions/ErrorResponse'
EOF
}
