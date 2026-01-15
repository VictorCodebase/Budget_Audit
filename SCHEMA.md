# Database Schema

This document details the current revision of the database schema.

---

## 1. Core Tables

### 1.1. Participants Table

Stores core user authentication and profile information.

| Column Name       | Data Type    | Key/Constraint                   | Notes                                            |
| :---------------- | :----------- | :------------------------------- | :----------------------------------------------- |
| **ParticipantId** | INT          | **Primary Key** (Auto-Increment) | Unique user identifier.                          |
| FirstName         | VARCHAR(255) | NOT NULL                         | User's first name.                               |
| LastName          | VARCHAR(255) | NULLABLE                         | User's last name.                                |
| Nickname          | VARCHAR(100) | NULLABLE                         | Display name for the application.                |
| Role              | VARCHAR(255) | NOT NULL                         | User role (e.g., 'Admin', 'Standard').           |
| Email             | VARCHAR(255) | **UNIQUE**, NOT NULL             | Login email address.                             |
| PwdHash           | CHAR(60)     | NOT NULL                         | Stores the hashed password (e.g., using bcrypt). |

---

### 1.2. Categories Table

Stores the definitions of budgeting categories. Categories are now scoped per template.

| Column Name    | Data Type    | Key/Constraint                         | Notes                                                               |
| :------------- | :----------- | :------------------------------------- | :------------------------------------------------------------------ |
| **CategoryId** | INT          | **Primary Key** (Auto-Increment)       | Unique identifier for the category (e.g., Groceries, Rent, Income). |
| TemplateId     | INT          | **Foreign Key** (Templates.TemplateId) | Links the category to its parent template.                          |
| CategoryName   | VARCHAR(100) | NOT NULL                               | Human-readable name of the category.                                |
| ColorHex       | CHAR(7)      | NOT NULL                               | Hex code (e.g., `#FF5733`) for visual representation.               |

**Composite Unique Constraint:** (TemplateId, CategoryName) - ensures category names are unique within each template.

---

### 1.3. Accounts Table

Represents individual budget buckets tied to a category.

| Column Name              | Data Type      | Key/Constraint                                        | Notes                                                                              |
| :----------------------- | :------------- | :---------------------------------------------------- | :--------------------------------------------------------------------------------- |
| **AccountId**            | INT            | **Primary Key** (Auto-Increment)                      | Unique budget account identifier.                                                  |
| CategoryId               | INT            | **Foreign Key** (Categories.CategoryId)               | Links the account to its parent category.                                          |
| TemplateId               | INT            | **Foreign Key** (Templates.TemplateId)                | Links the account to the template it belongs to.                                   |
| AccountName              | VARCHAR(100)   | NOT NULL                                              | Human-readable name for the account.                                               |
| ColorHex                 | CHAR(7)        | NOT NULL                                              | Auto calculated. A hex color related to its category hex, used for colored charts. |
| BudgetAmount             | DECIMAL(10, 2) | NOT NULL                                              | The total budget allocated to this account.                                        |
| ExpenditureTotal         | DECIMAL(10, 2) | NULLABLE, DEFAULT 0.00                                | The current running total of all transactions linked to this account.              |
| ResponsibleParticipantId | INT            | **Foreign Key** (Participants.ParticipantId) NULLABLE | The participant managing this specific account (optional).                         |
| DateCreated              | DATETIME       | NOT NULL                                              | Timestamp of account creation.                                                     |

**NOTE on Calculated Columns:**

- **Balance** (`BudgetAmount - ExpenditureTotal`) will be calculated in the application layer or via a database VIEW.

---

### 1.4. Transactions Table

Records all financial events (inflow and outflow).

| Column Name         | Data Type      | Key/Constraint                               | Notes                                                       |
| :------------------ | :------------- | :------------------------------------------- | :---------------------------------------------------------- |
| **TransactionId**   | INT            | **Primary Key** (Auto-Increment)             | Unique transaction identifier.                              |
| **SyncId**          | INT            | **Foreign Key** (SyncLog.SyncId)             | Keep track of its sync status.                              |
| AccountId           | INT            | **Foreign Key** (Accounts.AccountId)         | The specific account this transaction affects.              |
| IsIgnored           | BOOL           | NOT NULL, DEFAULT FALSE                      | Specifies whether the user chose to ignore the transaction. |
| Date                | DATETIME       | NOT NULL                                     | Date and time the transaction occurred.                     |
| VendorId            | INT            | **Foreign Key** (Vendors.VendorId)           | If new, new vendor created, ID stored.                      |
| Amount              | DECIMAL(10, 2) | NOT NULL                                     | The monetary value of the transaction (always positive).    |
| ParticipantId       | INT            | **Foreign Key** (Participants.ParticipantId) | The participant who recorded/initiated the transaction.     |
| EditorParticipantId | INT            | **Foreign Key** (Participants.ParticipantId) | The participant whose account was used to upload document.  |
| Reason              | TEXT           | NULLABLE                                     | Detailed description of the transaction.                    |

**Note:** Money-in transactions flagged as ignored don't get committed to DB because they are never presented to the user during transaction labeling with accounts.

---

### 1.5. VendorMatchHistories Table


Tracks vendor-account-participant associations and their usage frequency.

| Column Name       | Data Type | Key/Constraint                               | Notes                                           |
| :---------------- | :-------- | :------------------------------------------- | :---------------------------------------------- |
| **VendorMatchId** | INT       | **Primary Key** (Auto-Increment)             | Unique identifier.                              |
| VendorId          | INT       | **Foreign Key** (Vendors.VendorId)           | The vendor.                                     |
| AccountId         | INT       | **Foreign Key** (Accounts.AccountId)         | The account associated with the vendor.         |
| ParticipantId     | INT       | **Foreign Key** (Participants.ParticipantId) | The participant who made this association.      |
| UseCount          | INT       | DEFAULT 1                                    | Number of times this association has been used. |
| LastUsed          | DATETIME  | NOT NULL                                     | Most recent usage timestamp.                    |

**Composite Unique Constraint:** (VendorId, AccountId, ParticipantId) - ensures unique stats per vendor-account-participant combination.

---

### 1.6. Vendors Table

Stores vendor information for transaction categorization.

| Column Name  | Data Type    | Key/Constraint                   | Notes                                       |
| :----------- | :----------- | :------------------------------- | :------------------------------------------ |
| **VendorId** | INT          | **Primary Key** (Auto-Increment) | Unique vendor identifier.                   |
| VendorName   | VARCHAR(250) | NOT NULL                         | Shall be used to enable vendor recognition. |

---

### 1.7. VendorPreferences Table

Stores user preferences for vendor-account associations.

| Column Name            | Data Type | Key/Constraint                               | Notes                            |
| :--------------------- | :-------- | :------------------------------------------- | :------------------------------- |
| **VendorPreferenceId** | INT       | **Primary Key** (Auto-Increment)             | Unique preference identifier.    |
| **VendorId**           | INT       | **Foreign Key** (Vendors.VendorId)           | Unique vendor identifier.        |
| **ParticipantId**      | INT       | **Foreign Key** (Participants.ParticipantId) | Participant with the preference. |

**Composite Unique Constraint:** (VendorId, ParticipantId) - only one account preference per vendor per participant.

---

### 1.8. ParticipantIncomes Table

Separates income history from the main user table for better normalization (1NF).

| Column Name   | Data Type      | Key/Constraint                               | Notes                                                                   |
| :------------ | :------------- | :------------------------------------------- | :---------------------------------------------------------------------- |
| **IncomeId**  | INT            | **Primary Key** (Auto-Increment)             | Unique income record identifier.                                        |
| ParticipantId | INT            | **Foreign Key** (Participants.ParticipantId) | Links the income record to the owner.                                   |
| IncomeAmount  | DECIMAL(10, 2) | NOT NULL                                     | The amount of this income event.                                        |
| IncomeName    | VARCHAR(100)   | NULLABLE                                     | User's labeling (e.g., overtime, locums).                               |
| IncomeType    | VARCHAR(100)   | NOT NULL                                     | Classification (e.g., 'Standard Salary', 'Freelance Payment', 'Bonus'). |
| DateReceived  | DATETIME       | NOT NULL, DEFAULT NOW()                      | The date the income was received.                                       |

---

### 1.9. Templates Table

Records all budget templates.

| Column Name          | Data Type    | Key/Constraint                               | Notes                                                                  |
| :------------------- | :----------- | :------------------------------------------- | :--------------------------------------------------------------------- |
| **TemplateId**       | INT          | **Primary Key** (Auto-Increment)             | Unique template identifier.                                            |
| **SyncId**           | INT          | **Foreign Key** (SyncLog.SyncId) NULLABLE    | Keep track of its sync status.                                         |
| SpreadSheetId        | VARCHAR(250) | NULLABLE                                     | The template's Google Sheets URL for retrieval.                        |
| TemplateName         | VARCHAR(100) | NOT NULL                                     | Friendly name chosen by creator.                                       |
| CreatorParticipantId | INT          | **Foreign Key** (Participants.ParticipantId) | Participant who created the template.                                  |
| Period               | VARCHAR(100) | NOT NULL                                     | Budget period (e.g., 'Monthly', 'Quarterly').                          |
| DateCreated          | DATETIME     | NOT NULL                                     | Date of creation.                                                      |
| TimesUsed            | INT          | NULLABLE                                     | Updated every time the user creates a budget sheet using the template. |

---

### 1.10. TemplateParticipants Junction Table

Keeps track of the template-participant many-to-many relationship.

| Column Name    | Data Type   | Key/Constraint                               | Notes                                   |
| :------------- | :---------- | :------------------------------------------- | :-------------------------------------- |
| TemplateId     | INT         | **Foreign Key** (Templates.TemplateId)       | Identifies the template.                |
| ParticipantId  | INT         | **Foreign Key** (Participants.ParticipantId) | Identifies the participant.             |
| PermissionRole | VARCHAR(50) | NOT NULL                                     | The participant's role in the template. |

**Composite Primary Key:** (TemplateId, ParticipantId) - ensures that a participant is only associated once per template.

---

### 1.11. ChartSnapshots Table

Keep track of chart snapshots by users.

| Column Name        | Data Type    | Key/Constraint                         | Notes                                                 |
| :----------------- | :----------- | :------------------------------------- | :---------------------------------------------------- |
| **SnapshotId**     | INT          | **Primary Key** (Auto-Increment)       | Identifies the snapshot.                              |
| Name               | VARCHAR(100) | NULLABLE                               | Human-friendly name optionally added to the snapshot. |
| Configuration      | TEXT         | NOT NULL                               | JSON describing all the data on the graph.            |
| CreatedAt          | DATETIME     | NOT NULL                               | When the snapshot was taken.                          |
| PermissionRole     | VARCHAR(50)  | NOT NULL                               | The participant's role in the template.               |
| AssociatedTemplate | INT          | **Foreign Key** (Templates.TemplateId) | The template whose data was used to create the graph. |

---

### 1.12. SyncLog Table

Keep synchronizations with Google Cloud.

| Column Name   | Data Type    | Key/Constraint                   | Notes                                               |
| :------------ | :----------- | :------------------------------- | :-------------------------------------------------- |
| **SyncId**    | INT          | **Primary Key** (Auto-Increment) | Identifies the sync.                                |
| SyncDirection | VARCHAR(100) | NOT NULL                         | To remote or from remote.                           |
| Synced        | BOOL         | NOT NULL                         | False if only done locally.                         |
| Success       | BOOL         | NOT NULL                         | If an error was critical, sync fails.               |
| ErrorMessage  | TEXT         | NULLABLE                         | Should an error occur, it gets logged here.         |
| SheetUrl      | TEXT         | NOT NULL                         | The exact sheet responsible/affected by the change. |
| DateSynced    | DATETIME     | NOT NULL                         | Timestamp of when the sync occurred.                |

**Note:** The TransactionId and AssociatedTemplate foreign keys from the original schema are not present in the current implementation. SyncLog can be referenced by both Transactions and Templates tables via their respective syncId columns.
