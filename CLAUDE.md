# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

DM Assistant is a Flutter desktop application for Dungeons & Dragons campaign management. The app uses a desktop-first design with a sidebar navigation and multiple feature modules for managing campaigns, characters, sessions, maps, and other D&D tools.

## Development Commands

### Dependencies & Code Generation
- `flutter pub get` - Install dependencies
- `flutter packages pub run build_runner build` - Generate code (Isar schemas, JSON serialization)
- `flutter packages pub run build_runner build --delete-conflicting-outputs` - Force regenerate all generated files

### Testing & Quality
- `flutter test` - Run all tests
- `flutter analyze` - Run static analysis using flutter_lints
- `flutter test test/features/campaign/campaign_model_test.dart` - Run specific test file
- `flutter test test/features/character/` - Run all character tests

### Build & Run
- `flutter run -d windows` - Run on Windows
- `flutter run -d macos` - Run on macOS  
- `flutter run -d linux` - Run on Linux
- `flutter build windows` - Build Windows executable
- `flutter build macos` - Build macOS app
- `flutter build linux` - Build Linux executable

## Architecture

### State Management
- **Riverpod** for state management with providers
- **Isar** (v3.x) for local database storage with code generation
- Provider pattern: Repository → Provider → UI

### Navigation
- **GoRouter** v16.x for declarative routing with `NoTransitionPage` for desktop UX
- **ShellRoute** with DesktopShell layout for consistent UI structure
- All routes wrapped in DesktopShell with sidebar navigation
- Current routes: `/campaigns`, `/characters`, `/sessions`, `/maps`, `/dice`, `/compendium`, `/initiative`, `/settings`
- Initial route defaults to `/campaigns`

### Project Structure
```
lib/
├── core/                    # Core utilities and shared logic
│   ├── constants/          # App-wide constants (colors, strings, dimensions)
│   ├── router/             # GoRouter configuration
│   ├── theme/              # Theme and styling
│   ├── utils/              # Utilities (formatters, validators)
│   └── widgets/            # Core reusable widgets
├── features/               # Feature modules (campaign, characters, etc.)
│   ├── campaign/           # Campaign feature:
│   │   ├── models/         # Data models with Isar annotations
│   │   ├── providers/      # Riverpod providers and notifiers  
│   │   ├── repositories/   # Data access layer
│   │   └── presentation/   # UI (screens, widgets)
│   └── character/          # Character feature:
│       ├── models/         # Character model with D&D properties
│       ├── providers/      # Character providers and notifiers
│       ├── repositories/   # Character data access layer
│       └── presentation/   # Character UI (screens, widgets)
└── shared/                 # Shared UI components and layouts
    ├── components/         # Reusable UI components (buttons, cards, etc.)
    ├── layouts/            # Layout widgets (DesktopShell, SidebarNavigation)
    ├── models/             # Shared models (D&D enums, etc.)
    ├── providers/          # Shared providers (entity_provider)
    ├── repositories/       # Base repository pattern
    └── widgets/            # Shared widgets
```

### Key Components

**DesktopShell** (`lib/shared/layouts/desktop_shell.dart`):
- Main layout wrapper with sidebar + content area
- Provides consistent title bar and floating action button support
- Used by all routes via ShellRoute

**Campaign System** (implemented):
- Isar-based local storage with auto-increment IDs
- Repository pattern with async operations
- Riverpod providers for state management and caching
- Full CRUD operations with dialog-based forms
- List/Grid view toggle functionality

**Character System** (implemented):
- Isar-based storage with campaign relationship (required)
- D&D 5e properties: race, class, level, background, alignment
- Repository pattern with filtering and search capabilities
- Riverpod providers for state management
- Full CRUD operations with comprehensive test coverage

**Other Features** (placeholder routes):
- Sessions, Maps, Dice Roller, Compendium, Initiative Tracker, Settings
- All routes have placeholder screens with "coming soon" messages

### Database Models
- All models use Isar annotations (`@collection`, `part` files)
- Generated files (`.g.dart`) must be created via build_runner
- Models include factory constructors and copyWith methods
- Isar instance initialized in `main.dart` and provided via Riverpod (`isarProvider`)
- Database stored in application documents directory
- Current schemas: Campaign, Character
- Character model includes required campaign relationship (campaignId: int)
- D&D enums stored in `shared/models/dnd_enums.dart` for reusability

### UI Patterns & Shared Components
- Feature-based organization with presentation/screens and presentation/widgets
- **CRITICAL: Always maximize reuse of existing shared components before creating new ones**
- Extensive shared component library in `/shared/components/` with these available components:

#### Actions (`actions/`)
- `ActionSheet` - Modal bottom sheets with customizable actions, titles, and styles (material/cupertino/custom)

#### Buttons (`buttons/`)
- `BaseButton` - Foundation button component with consistent styling and behavior

#### Cards (`cards/`)
- `BaseCard` - Basic card container with consistent styling
- `EntityCard` - Advanced card for entities with image, title, subtitle, details, actions, and list/grid layouts
- `EntityDetailRow` - Row component for displaying entity details with label/value pairs

#### Dialogs (`dialogs/`)
- `BaseDialog` - Foundation dialog component with consistent styling and behavior
- `EntityFormDialog` - Form dialog for entity creation/editing with validation and actions

#### Forms (`forms/`)
- `FormBuilder` - Form construction utility with validation and field management

#### Grids (`grids/`)
- `BaseGridView` - Grid view component with consistent spacing and responsive behavior

#### Headers (`headers/`)
- `SectionHeader` - Section titles and headers with consistent typography

#### Inputs (`inputs/`)
- `BaseTextField` - Foundation text input with consistent styling and validation
- `EntityImagePicker` - Image picker component for entity avatars with local/network image support
- `SearchBar` - Search input component with filtering capabilities

#### Lists (`lists/`)
- `BaseListView` - List view component with consistent spacing and behavior

#### Menus (`menus/`)
- `ContextMenu` - Context menu component for right-click and long-press actions

#### Navigation (`navigation/`)
- `TabNavigation` - Tab navigation component for switching between views

#### States (`states/`)
- `EmptyState` - Empty state component with customizable message and icon

#### Tiles (`tiles/`)
- `EntityListTile` - List tile component for entities with image, title, subtitle, and actions

- Desktop-optimized with consistent spacing and sizing
- FlexColorScheme for theming with light/dark mode support

### Dependencies Notes
- Requires Flutter SDK >=3.8.0
- Uses Isar v3.x (stable) instead of v4.x (beta)
- Multi-platform desktop support (Windows, macOS, Linux)
- Image handling with `image_picker` and `cached_network_image`
- UI theming with `flex_color_scheme` v8.x for light/dark mode

## Development Workflow

### Code Reuse Policy (CRITICAL)
**ALWAYS maximize reuse of existing components and code before creating new implementations:**

1. **Before creating new UI components**: Check `/shared/components/` for existing components that can be reused or extended
2. **Before creating new widgets**: Look for similar patterns in existing features and shared widgets
3. **Before implementing new functionality**: Search for existing utilities, providers, and repositories that can be leveraged
4. **When extending components**: Prefer adding parameters/props to existing components over creating new ones

### Feature Development Guidelines
1. When adding new features, follow the established feature structure under `lib/features/`
2. For data models, always add Isar annotations and run code generation
3. Use the Repository → Provider → UI pattern for data flow
4. All routes should use DesktopShell for consistency
5. Test business logic, especially model operations and providers
6. Every entity MUST belong to a campaign (required campaignId relationship)
7. D&D-related enums should be added to `shared/models/dnd_enums.dart`
8. **Prioritize component reuse**: Always check shared components before creating feature-specific widgets

## Testing Guidelines

### Repository Tests
- Use `repository.save(entity)` for create/update operations
- Use `repository.deleteById(id)` for deletion
- Use `repository.getById(id)` for retrieval
- Test with in-memory Isar instances for isolation

### Provider Tests  
- Use `entityProvider.create(entity)` for creating entities
- Use `entity.copyWith()` + `entityProvider.update()` for updates
- Use `entityProvider.deleteById(id)` for deletion
- Read state directly: `container.read(provider).value!`
- DO NOT use `.future` on StateNotifier providers