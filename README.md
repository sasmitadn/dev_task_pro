# project_manager

Offline project manager for personal developer. Main feature is add project, task and log timesheet.

## Feature Flow
1. Home screen show searchview (based on project name) and list of projects. On click of any project or search, it navigate to project detail screen. Floating button add task with + to add a new project. Horizontal scrollable chip for filtering category.
2. Project detail screen show project name, status, priority, category, project description, chip list of tech stack, url list, progress bar for tasks, open task button, due date, button edit project, system, brainstorming, log timesheet.
3. Open task show list of task folder with progressbar. On top there is rounded outline text input layout with + end icon for adding new task based on text entered in input.
4. Task folder details show subtask as list, display and UI/UX to add subtask is similar to task folder. On top there is rounded outline text input layout with + end icon for adding new subtask based on text entered in input.
5. Task detail have button to start timesheet log. It will show running timer and option to end and save it to database with note. Timer will show in entire app with detail building which project (can't back). it will be visible only when timesheet is running.

## Settings Menu
1. Add category.
2. Add priority.
3. Export and Import data as json file.
4. Transfer data between device by bluetooth or other method (across device type). The latest version of data should be kept (if there is any conflict). If user wants to transfer data to new device, it should be by pairing or entering id manually and choose which project's data should be imported and merged.
5. Change theme (dark / light)

## UI/UX
1. Make UI/UX as modern as possible.
2. Use material design 3.
3. Vibes like programmer (available in light and dark mode)
4. Every input text comes with + button in end icon to save it quickly, selection show as autocomplete text with + button or show item "save XXXX" at the end of the list. similar to that on click of item it should get selected and + button should be visible (if not already). Keyboard enter mode as done also save the data.
5. Progress bar show as linear progress like in terminal but every tick mark have nice rounded and percentage indicator (use font consolas)
6. Every item should have option to delete (swipe left or right or long press) and confirm dialog before deleting.
7. Every item should have option to edit and save.
8. Every list item can be dragable to reorder (save order in db).
9. Use animations where needed.
10. Make sure UI is clean and minimal in mobile or macOS.
11. Add icon in some places where needed.
12. Add title in all screens with app bar.
13. Make sure app is responsive to different screen sizes.

## Schema Code
- Use local db (choose latest and best practice for this).
- Use MVVM architecture.
- Build your own db schema and save it as a note in root project.
- Dont add too much comment in code.
