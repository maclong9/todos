```mermaid
---
title: High-Level System Architecture
---
graph TB
    subgraph "Client Layer"
        W[Web App<br/>Mustache, HTMX, Alpine and Three]
        I[iOS/iPadOS App<br/>SwiftUI]
        M[macOS App<br/>SwiftUI]
        V[visionOS App<br/>SwiftUI]
        Watch[watchOS App<br/>SwiftUI]
    end

    subgraph "API Layer"
        API[Hummingbird API Server]
        Auth[Authentication Service]
        Sync[Sync Service]
        Push[Push Notification Service]
    end

    subgraph "Data Layer"
        DB[(PostgreSQL)]
        Cache[(Redis)]
        APNs[Apple Push<br/>Notification Service]
        WebPush[Web Push Service]
    end

    W --> API
    I --> API
    M --> API
    V --> API
    Watch --> API
    
    API --> Auth
    API --> Sync
    API --> Push
    
    Auth --> DB
    Sync --> DB
    Push --> APNs
    Push --> WebPush
    
    API --> Cache
    Sync --> Cache
```

```mermaid
---
title: Authentication Flow
---
sequenceDiagram
    participant U as User
    participant C as Client
    participant A as Auth Service
    participant D as Database
    participant R as Redis Cache

    U->>C: Login Request
    C->>A: Forward Credentials
    A->>D: Validate User
    D-->>A: User Valid
    A->>R: Store Session
    A-->>C: Return JWT + Refresh Token
    C-->>U: Login Success
```

```mermaid
---
title: Data Sync Architecture
---
graph LR
    subgraph "Client"
        LC[Local Cache]
        SQ[Sync Queue]
    end

    subgraph "Server"
        API[API Endpoint]
        SS[Sync Service]
        VV[Version Vector]
    end

    subgraph "Storage"
        PG[(PostgreSQL)]
        RC[(Redis Cache)]
    end

    LC -->|Push Changes| SQ
    SQ -->|Sync| API
    API -->|Process| SS
    SS -->|Check| VV
    SS -->|Store| PG
    SS -->|Cache| RC
    VV -->|Update| RC
```

```mermaid
---
title: Todo Item State Machine
---
stateDiagram-v2
    [*] --> Created
    Created --> InProgress
    InProgress --> Completed
    InProgress --> OnHold
    OnHold --> InProgress
    Completed --> [*]
    
    note right of Created
        Contains:
        - Title
        - Due Date
        - Priority
        - Tags
    end note
    
    note right of InProgress
        Can have:
        - Subtasks
        - Notes
        - Attachments
    end note
```

```mermaid
erDiagram
    User ||--o{ TodoList : "owns"
    User {
        uuid id
        string email
        string hashedPassword
        string name
        bool emailVerified
        bool twoFactorEnabled
        jsonb preferences
        timestamp createdAt
        timestamp updatedAt
    }
    
    TodoList ||--o{ Todo : "contains"
    TodoList {
        uuid id
        uuid userId
        string name
        string color
        bool isDefault
        timestamp createdAt
        timestamp updatedAt
    }
    
    Todo ||--o{ SubTask : "has"
    Todo ||--o{ Tag : "tagged_with"
    Todo {
        uuid id
        uuid listId
        string title
        text notes
        datetime dueDate
        enum priority
        bool completed
        enum repeatType
        jsonb repeatConfig
        version syncVersion
        timestamp createdAt
        timestamp updatedAt
    }
    
    SubTask {
        uuid id
        uuid todoId
        string title
        bool completed
        int order
        timestamp createdAt
        timestamp updatedAt
    }
    
    Tag {
        uuid id
        string name
        string color
        timestamp createdAt
        timestamp updatedAt
    }

    Session {
        uuid id
        uuid userId
        string token
        timestamp expiresAt
        timestamp createdAt
    }
  ```
