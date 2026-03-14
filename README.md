# Queue - Task Queue Mobile Application

A Flutter mobile application for managing tasks in a queue-based system. Tasks are added to the end of the queue and completed from the top (FIFO - First In, First Out).

## Features

### Core Functionality
- **Queue Management**: Create multiple queues to organize your tasks
- **Task Management**: Add tasks to queues with importance and difficulty rankings
- **FIFO Processing**: Tasks are completed from the top of the queue (first element first)
- **Importance Ranking**: Rate tasks from 1 (low) to 10 (high) importance
- **Difficulty Ranking**: Rate tasks from 1 (easy) to 10 (very hard)
- **Queue Sorting**: Sort tasks by importance (low to high or high to low)
- **Points System**: Earn 10 × importance points when completing tasks
- **Points Display**: View your total queue points in the top right corner

### User Interface
- Modern Material Design 3 UI
- Clean and intuitive interface
- Task cards with importance and difficulty badges
- Queue cards showing pending and completed task counts
- Sort indicators on queues
- Points display in app bar

## Getting Started

### Prerequisites
- Flutter SDK (3.10.1 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)

### Installation

1. Clone or navigate to the project directory:
```bash
cd queue_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── task.dart            # Task model
│   └── queue.dart           # Queue model with sorting
├── providers/
│   └── queue_provider.dart  # State management with Provider
├── screens/
│   ├── home_screen.dart     # Main screen with queue list
│   ├── queue_detail_screen.dart  # Task list for a queue
│   └── add_task_screen.dart  # Add new task screen
└── widgets/
    ├── queue_card.dart      # Queue display card
    ├── task_card.dart       # Task display card
    └── points_display.dart  # Points counter widget
```

## Usage

### Creating a Queue
1. Tap the "New Queue" floating action button
2. Enter a queue name (required)
3. Optionally add a description
4. Tap "Create"

### Adding Tasks
1. Open a queue from the home screen
2. Tap "Add Task" floating action button
3. Enter task title (required)
4. Optionally add a description
5. Set importance (1-10 slider)
6. Set difficulty (1-10 slider)
7. Tap "Add Task"

### Completing Tasks
1. Open a queue to see pending tasks
2. Tap the checkmark icon on a task card
3. Earn points: 10 × importance value
4. Completed tasks move to the "Completed Tasks" section

### Sorting Tasks
1. Open a queue
2. Tap the sort icon in the app bar
3. Choose:
   - **No Sort**: Original order (FIFO)
   - **Low to High**: Sort by importance ascending
   - **High to Low**: Sort by importance descending

### Deleting
- **Delete Queue**: Long press or use delete icon on queue card
- **Delete Task**: Tap delete icon on task card

## Points System

- **Earning Points**: Complete a task to earn `10 × importance` points
- **Example**: 
  - Task with importance 5 = 50 points
  - Task with importance 10 = 100 points
- **Display**: Total points shown in top right corner of home screen

## Data Persistence

All data is stored locally using `shared_preferences`:
- Queues and tasks persist between app sessions
- Points are saved and restored
- No internet connection required

## Dependencies

- `provider`: State management
- `shared_preferences`: Local data storage
- `uuid`: Unique ID generation

## License

This project is created for personal/educational use.
