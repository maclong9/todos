## Swift Todos

This is an example application developed with Swift Hummingbird for educational and documentation purposes. It employs a straightforward templating mechanism integrated directly into the Swift code and a user-friendly CRUD web application todo item manaement.

The application is documented to ensure its maintainability and serve as a reference point for the processes I have acquired. Additionally, I provide specific details about the setup and architecture of the application within this `README.md` file.

## Locally Running the Application

To run the application locally, follow these steps:

1. Clone the repository using Git: `git clone https://github.com/maclong9/todos`
2. Navigate to the todos directory: `cd todos`
3. Execute the Swift command to run the application: `swift run App`

## Model-View-Controller (MVC) Pattern

The Model-View-Controller (MVC) pattern is a software design principle that organizes an application into three distinct components:

1. **Model**:
   - Represents data and business logic.
   - Manages data, logic, and rules of the application.
   - Notifies observers, typically views, about data changes.
   - Describes the storage of data.

2. **View**:
   - The user interface of the component.
   - Displays data to the user.
   - Handles user input.
   - Should be simple and minimal in terms of logic.

3. **Controller**:
   - Acts as a mediator between the Model and View.
   - Processes user input received from the View.
   - Implements business logic.
   - Updates the Model and View in response to changes.
   
> [!NOTE]
> This Application also contains a _ViewController_ written in JavaScript which interfaces with the `DashboardView` for altering the user interface according to user input and the `TodoController` and `UserController` for updating the `Model` data.

This architectural pattern facilitates the separation of concerns by compartmentalizing the storage, user interface, and data interaction aspects into distinct locations. This separation enhances maintainability and facilitates modular and testable code.

## Databases, Migrations, and Repositories

The application utilizes a SQLite database managed by Fluent ORM. SQLite is a file-based, fast, and effective database with full SQL functionality and ACID compliance.

Upon application startup, running the application with the `migrate` flag provisiones the database. This initialization step is only required once per environment. The actions performed by the migration can be viewed in the `Sources/App/Migrations` directory.

The `UserRepository` struct facilitates user retrieval based on either the currently logged-in session UUID or the user’s email address, which is passed as a string. This repository is utilized by the `SessionAuthenticator` to ensure proper user authentication.

## HTTP Requests, Responses, and Context

The application operates on HTTP requests and responses, with the application context passed between routes. A comprehensive list of available HTTP requests for each route is available at the top of the file, accompanied by documentation on the responses returned by the relevant methods.

## Middleware

Several middleware components are employed within the application, including:
- `LogRequestMiddleware`: This middleware logs server requests.
- `CompressionMiddleware`: Responsible for reducing the size of response bodies.
- `FilesMiddleware`: Handles public assets accessible by the application.
- `CorsMiddleware`: Sets the appropriate cross-origin request headers.
- `SessionMiddleware`: Redirects users attempting to access authenticated routes without proper login.

## Templating with Swift and the `HTML` Extension

To minimize dependencies while maintaining server-side rendering flexibility, templates are composed of multi-line Swift strings with interpolation capabilities for passing values.

## Server Management: `App.swift` and `Application+build.swift`

These two files are responsible for the primary application thread. Within `App.swift`, you will find the declaration of acceptable arguments for the application handled by `swift-argument-parser`. These flags can be toggled and extended to modify application behavior at runtime.

In `Application+build.swift`, the `buildApplication` function is invoked from `App.swift`. This function provisions the database, executes migrations if the `—migrate` flag is passed, defines the `userRepository` for use with the `SessionAuthenticator`, and checks the working directory to ensure the assets are loaded correctly.

Next, the `router` is initialized, and middlewares are added to it. A health check route is added for rapid server status verification. The `SessionAuthenticator` is subsequently defined to be passed to the controllers handling the `Todo`, `User`, and `View` routes.

Finally, the `app` is defined, passed the `router`, arguments, and the fluent as a service, and returned.

## Security

Passwords are hashed using `BCrypt`, the Bcrypt hashing function was designed by Niels Provos and David Mazières, based on the Blowfish cipher and presented at USENIX in 1999. Besides incorporating a salt to protect against rainbow table attacks, bcrypt is an adaptive function: over time, the iteration count can be increased to make it slower, so it remains resistant to brute-force search attacks even with increasing computation power.

## Design System with CSS

A simple design system is implemented using CSS custom properties, this includes some fonts; a basic typography scale; a selection of brand colours; semantic colours; container rounding and some effects such as dialog overlay and shadows.

All styles are written in the one CSS file however that file is split up into sections via the `@layout` pattern which helps with code organisation and scoping. 

> [!NOTE]
> I may create a second branch with this setup using Elementary, HTMX and TailwindCSS just to see how I enjoy workin with that trifecta of tools.

## Client-Side Updates with JavaScript

As mentioned earlier JavaScript provides a `ViewController` for interacting with the user interface and performing client side updates allowing the user to inreact with the application without having to refresh the page every single time they make a change.

## Application Testing in `Tests`

> [!NOTE]
> TODO

## Deployment of the Application

> [!NOTE]
> TODO

## Todo:

### Animation Concepts

The home page grid serves a purpose, although it is currently empty. At some point, I envision implementing a visually appealing animation on the right-hand side of the features grid.

#### Enhance Performance and Reach Goals More Efficiently

- A to-do list with tasks being swiftly added and marked as completed.
- A transition from a check mark to a rocket taking off.

#### Check Off On the Go

- An animation of a person checking off tasks on a mobile device as the background transitions from home to a park, a train, and an office.
- Use playful and energetic movements to capture the sense of rushing about.

#### Chill Out and Relax

- A transition from a busy and cluttered scene to a more peaceful and uncluttered one.
- Subtle and relaxing motions such as swaying plants and drifting clouds.
- Warm and muted color palettes and soft lighting to convey a sense of tranquility.
- The person could be shown meditating in nature.
