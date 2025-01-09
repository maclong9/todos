## Swift Todos

This is an example application developed with Swift Hummingbird for educational and documentation purposes. It employs a straightforward templating mechanism integrated directly into the Swift code and a user-friendly CRUD web application for todo item management.

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
