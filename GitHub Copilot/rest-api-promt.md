You are assisting with a Java-based REST API project following a layered architecture inspired by Domain-Driven Design (DDD). The goal is to generate or review code that adheres to a standard structure and specific constraints, ensuring consistency across a team. Use the following guidelines:

### Project Structure
- **Layers**:
  - `controller`: Thin REST controllers (e.g., `UserController`) that handle HTTP requests and delegate to Application Services.
  - `application`: Application Services (e.g., `UserAppService`) that orchestrate use cases, manage transactions, and call Domain Services.
  - `domain/entity`: Domain entities (e.g., `User`) with core data and basic behavior.
  - `domain/service`: Domain Services (e.g., `RegisterUserService`) for specific business operations.
  - `repository`: Data access interfaces (e.g., `UserRepository`) for persistence.
  - `dto`: Data Transfer Objects (e.g., `UserDTO`) for request/response shaping.

- **Naming Convention**:
  - Application Services: `<Resource>AppService` (e.g., `UserAppService`).
  - Domain Services: `<Operation><Resource>Service` (e.g., `RegisterUserService`).
  - Controllers: `<Resource>Controller` (e.g., `UserController`).

### Rules for Domain Services
1.  **Pure Business Logic**: Only business rules; no database, HTTP, or external system calls.
2.  **No App Layer Dependency**: Must not depend on Application Services or controllers.
3.  **Stateless**: No instance-level state; rely on method parameters and return values.
4.  **Single Responsibility**: One service per operation (e.g., `RegisterUserService`, `UpdateUserProfileService`).
5.  **No External Access**: Use repositories for persistence, not direct database calls.
6.  **Limited Dependencies**: Only inject repositories, other Domain Services, or entities.
7.  **No Transactions**: Transaction management belongs in Application Services (e.g., `@Transactional`).
8.  **No DTOs**: Return domain entities, not DTOs; shaping happens in Application Services.
9.  **Idempotency**: Ensure operations like updates are idempotent where applicable.
10. **No Logging**: Logging/auditing is handled outside Domain Services.

### Code Generation Task
When generating code:
- Follow the structure above.
- Use dependency injection (constructor-based) with Spring annotations where applicable (e.g., `@Autowired`).
- Place business logic in Domain Services, orchestration in Application Services, and HTTP handling in controllers.
- Example:
  ```java
  // domain/service/RegisterUserService.java
  public class RegisterUserService {
      private final UserRepository userRepository;

      public RegisterUserService(UserRepository userRepository) {
          this.userRepository = userRepository;
      }

      public User register(String email, String password) {
          User user = new User(email, password);
          return userRepository.save(user);
      }
  }

  // application/UserAppService.java
  @Service
  public class UserAppService {
      private final RegisterUserService registerUserService;

      @Autowired
      public UserAppService(RegisterUserService registerUserService) {
          this.registerUserService = registerUserService;
      }

      @Transactional
      public UserDTO registerUser(String email, String password) {
          User user = registerUserService.register(email, password);
          return new UserDTO(user.getId(), user.getEmail());
      }
  }

  // controller/UserController.java
  @RestController
  @RequestMapping("/users")
  public class UserController {
      private final UserAppService userAppService;

      @Autowired
      public UserController(UserAppService userAppService) {
          this.userAppService = userAppService;
      }

      @PostMapping
      public ResponseEntity<UserDTO> register(@RequestBody UserDTO request) {
          UserDTO user = userAppService.registerUser(request.getEmail(), request.getPassword());
          return ResponseEntity.status(201).body(user);
      }
  }
  
### Code Review Task
When reviewing code:

Flag violations of Domain Service constraints (e.g., direct database calls, DTO usage, logging).
Ensure proper layer separation (e.g., no business logic in controllers).
Check for single responsibility in Domain Services.
Verify dependency injection and statelessness.
Example comment: "Move @Transactional from RegisterUserService to UserAppService as transactions are an application concern."  


### How to Use This Prompt
1. **For Code Generation**:
   - Paste this prompt into a comment or a `.md` file in your project (e.g., `copilot-guidelines.md`).
   - When writing new code, reference it with a comment like:
     ```java
     // See copilot-guidelines.md: Create a Domain Service for updating user email


For Code Review:
During a pull request, add a comment like

```java
// Copilot: Review this Domain Service for compliance with guidelines
public class RegisterUserService { ... } 