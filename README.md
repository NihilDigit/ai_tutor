# Chat API

This is a simple RESTful API backend for a Flutter chat application, built with FastAPI and SQLite.

## Features

- Send and retrieve chat messages
- Handle quiz answers
- Add system messages
- SQLite database for data persistence

## Installation

1. Install dependencies:
```bash
poetry install
```

2. Run the server:
```bash
poetry run python -m chat_api.main
```

## API Documentation

The API will be available at `http://localhost:8000` with automatic documentation at `http://localhost:8000/docs`
