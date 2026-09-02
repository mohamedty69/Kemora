# Kemora Project Constitution

## 1. Guiding Principles
- **Cultural Identity**: Kemora's design and content must prioritize Egyptian identity, aesthetics, and user experience.
- **Technical Integrity**: Code must be stable, performant, and follow Clean Architecture principles.
- **User First**: Interfaces should be intuitive, premium-feeling, and visually stunning.

---

## 2. Architecture & Patterns

### 🏛️ Backend (.NET Core)
1. **Clean Architecture**: Separation of concerns into Domain, Application, Infrastructure, and API layers.
2. **Persistence**: Entity Framework Core with Repository/Service pattern.
3. **Validation**: Use `FluentValidation` to ensure data integrity before reaching the service layer.
4. **Error Handling**: Implement global exception handling middleware to return consistent error responses.
5. **Security**: JWT-based authentication with role-based authorization (User/Admin).

### 📱 Frontend (Flutter)
1. **Clean Architecture**: Feature-based separation (Data, Domain, Presentation).
2. **State Management**: Use `Provider` with `ChangeNotifier` (ViewModels) for predictable state flows.
3. **Dependency Injection**: Use `get_it` for service registration and decoupling.
4. **Error Handling**: Use the `dartz` package (Either) to handle failures functionally, avoiding uncontrolled exceptions.
5. **Widgets**: Favor atomic components and reusable themed widgets.

---

## 3. Coding Standards

### ✅ General
- **Naming**: 
  - Backend: PascalCase for Classes/Methods, camelCase for local variables.
  - Frontend: PascalCase for Classes, camelCase for methods/variables, snake_case/camelCase as per project convention.
- **Documentation**: Use XML/Markdown comments for complex business logic.
- **Stability**: Never commit code that breaks the build or contains critical warnings (e.g., deprecated `withOpacity`).

### 🛠️ Flutter Performance
- **Const Constructors**: Always use `const` where possible to optimize widget tree rebuilding.
- **Resources**: Use `withValues()` instead of `withOpacity()` for color adjustments (Flutter 3.x+).
- **Optimization**: Avoid deep widget nesting; extract complex widgets into separate classes.

---

## 4. UI/UX & Aesthetics
- **Typography**: Primary font is `GoogleFonts.outfit()`.
- **Palette**: Egyptians colors (Gold: `0xFFD4AF37`, Nile Blue: `0xFF0D253F`, Sand: `0xFFF4E4BC`).
- **Effect**: Use subtle micro-animations, glassmorphism, and smooth gradients for a premium feel.
- **Responsive**: Ensure layouts work across multiple screen sizes and orientations.

---

## 5. Review & Maintenance
- **Unit Testing**: Core business logic in `Kemora.Application` and `Domain` layers must have unit tests.
- **Peer Review**: Every major feature must undergo a review against this constitution.
- **Integration**: Maintain a `walkthrough.md` to document feature updates and verification status.
