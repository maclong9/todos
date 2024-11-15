# Swift Todos

This is an example application built with Swift Hummingbird for learning and documentation purposes. It uses a simple templating system built directly into the Swift code and provides a simple CRUD web application for users to sign up and manage todo list tasks.

## Running Locally

1. Clone this repository `git clone https://github.com/maclong9/todos`
2. `cd todos; swift run App`

## Model View Controller

Model View Controller, MVC from here onwards, is a software design pattern which divides an application into three interconnected components:

1. Model
- Represents data and business logic.
- Manages data, logic and rules of the application.
- Notifies observers, usually views, about data changes.
- Describes how the data is stored.

2. View
- The user interface of the component.
- Displays data to the user.
- Receives user input.
- Should be simple/minimal in terms of logic.

3. Controller
- Acts as a connection between Model and View.
- Handles user input sent from the View.
- Processes business logic.
- Updates the Model and View accordingly.

This architecture pattern is useful for seperating the concerns of how something is stored, what the user sees and how the data is interacted with into seperate locations. This can improve maintainability and provide more modular and testable code.

## Todo:

### Write Documentation Here About

- [x] Introduction
- [x] Running Locally
- [x] MVC architecture
- [ ] Databases, Migrations & Repositries
- [ ] HTTP Requests, Repsonses and Context
- [ ] Templating Using Swift and the `HTML` Extension
- [ ] Running a Server `App` and `Application+build`
- [ ] Creting a Design System with CSS
- [ ] Client Side Updates with JS
- [ ] Testing Your Application `Tests`
- [ ] Deploying This Application

### Animation Ideas

#### Reach Goals Faster

- A to-do list with tasks being quickly added, and marked as complete. 
- Transition to a rocket taking off from the last check mark.

#### Check Off On the Go

- An animation of a person checking off tasks on a mobile device as the background changes from home to, a park, a train and an office. 
- Use Playful, energetic movements to capture the "rushing about" feeling.

#### Chill Out and Relax

- Transitioning from a busy, cluttered scene to a more peaceful, uncluttered one.
- Subtle, relaxing motions like swaying plants and drifting clouds.
- Warm, muted color palettes and soft lighting to convey a sense of tranquility.
- The person could be shown meditating in nature.
