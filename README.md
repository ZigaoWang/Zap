# Zap App

Zap is a versatile note-taking application that allows users to quickly record their thoughts, ideas, and tasks using text, voice, and photos. With future plans for AI-powered smart categorization and management, Zap aims to provide a more convenient and efficient recording experience.

## Current Features

- Multi-modal input: Text, voice, and photo capture
- Audio recording and playback
- Image and video capture and viewing
- Note management (add, edit, delete, mark as complete)
- Customizable appearance settings

## Planned Features

- AI-powered smart categorization and management
- Cross-platform synchronization
- Multi-platform support

## Project Structure

The project is organized into several key components:

- `ContentView.swift`: The main entry point of the app
- `HomeView.swift`: The primary view for displaying and managing notes
- `NoteRowView.swift`: Individual note display component
- `AudioNoteView.swift`: Audio recording functionality
- `ImagePicker.swift`: Photo and video capture functionality
- `FullScreenMediaView.swift`: Full-screen media viewing
- `AppearanceSettingsView.swift`: Customizable appearance settings

## For AI or Contributors

This project is currently in the prototype stage. The main focus areas for future development include:

1. Implementing AI-powered categorization and management of notes
2. Developing cross-platform synchronization capabilities
3. Expanding to support multiple platforms (iOS, macOS, web)

When contributing to this project, please follow the commit message guidelines provided below to maintain a clean and organized project history.

## Commit Message Guidelines

To maintain a clean and organized project history, please follow these commit message guidelines:

### Format:
```
type: subject
```

### General Rules:
- Separate different types of changes into different commits.
- Keep the subject concise, no more than 50 characters.
- Use English consistently.
- For detailed explanations, add a blank line after the subject.

### Commit Types:
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code refactoring
- `docs`: Documentation changes
- `style`: Code style changes (not CSS)
- `test`: Test case modifications
- `chore`: Other changes (e.g., build process, dependencies)

### Examples:
```
feat: add user login functionality
fix: resolve slow loading issue on homepage
docs: update project description in README.md
style: standardize code indentation
refactor: restructure data processing module
test: add unit tests for user registration
chore: update dependency versions in package.json
```

### Detailed Example:
```
feat: add user login functionality

- Implement JWT authentication
- Create login form component
- Add login state management

Related issue: #123
```

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## Contact

Contact Zigao Wang at a@zigao.wang, or open an issue: https://github.com/ZigaoWang/Zap/issues