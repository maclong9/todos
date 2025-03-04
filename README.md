# Todos

A simple full stack todo application, built with Swift, Hummingbird, HTML, CSS and JavaScript.

## Development

You can either open the project in Xcode, `open Package.swift` from your terminal; you can also run it from the terminal:

```sh
swift run App -p 8080 --migrate
```

> [!NOTE]
> `--migrate` is only required on the first run of the application.

## Deploy

There is a `Dockerfile` so clone this repository to any server with docker set up and run:

```sh
docker build -t todos .
docker run -d -p 8080:8080 -v todos-db:/app swift-todos
```
