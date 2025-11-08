
# Database Schema

This document details the second revision of the database schema, incorporating normalization recommendations to improve data integrity, reduce redundancy, and simplify querying.

---

## 1. Core Tables

### 1.1. Participants Table
Stores core user authentication and profile information.

| Column Name       | Data Type    | Key/Constraint                   | Notes                                            |
|:------------------|:-------------|:---------------------------------|:-------------------------------------------------|
| **ParticipantId** | INT          | **Primary Key** (Auto-Increment) | Unique user identifier.                          |
| FirstName         | VARCHAR(255) | NOT NULL                         | User's first name.                               |
| LastName          | VARCHAR(255) | NULLABLE                         | User's last name.                                |
| Nickname          | VARCHAR(100) | NULLABLE                         | Display name for the application.                |
| Role              | VARCHAR(50)  | NOT NULL                         | User role (e.g., 'Admin', 'Standard').           |
| Email             | VARCHAR(255) | **UNIQUE**, NOT NULL             | Login email address.                             |
| PasswordHash      | CHAR(60)     | NOT NULL                         | Stores the hashed password (e.g., using bcrypt). |

---

### 1.2. Categories Table
Stores the definitions of budgeting categories. This is the single source of truth for category metadata like color.

| Column Name    | Data Type    | Key/Constraint                   | Notes                                                               |
|:---------------|:-------------|:---------------------------------|:--------------------------------------------------------------------|
| **CategoryId** | INT          | **Primary Key** (Auto-Increment) | Unique identifier for the category (e.g., Groceries, Rent, Income). |
| CategoryName   | VARCHAR(100) | NOT NULL, UNIQUE                 | Human-readable name of the category.                                |
| ColorHex       | CHAR(7)      | NOT NULL                         | Hex code (e.g., `#FF5733`) for visual representation.               |

---

### 1.3. Accounts Table
Represents individual budget buckets tied to a category.

| Column Name              | Data Type      | Key/Constraint                               | Notes                                                                             |
|:-------------------------|:---------------|:---------------------------------------------|:----------------------------------------------------------------------------------|
| **AccountId**            | INT            | **Primary Key** (Auto-Increment)             | Unique budget account identifier.                                                 |
| CategoryId               | INT            | **Foreign Key** (Categories.CategoryId)      | Links the account to its parent category.                                         |
| TemplateId               | INT            | **Foreign Key** (Templates.TemplateId)       | Links the account to the template it belongs to                                   |
| ColorHex                 | VARCHAR        | NOT NULL                                     | Auto calculated. A hex color related to its category hex. used for colored charts |
| BudgetAmount             | DECIMAL(10, 2) | NOT NULL                                     | The total budget allocated to this account.                                       |
| ExpenditureTotal         | DECIMAL(10, 2) | NULLABLE, DEFAULT 0.00                       | The current running total of all transactions linked to this account.             |
| ResponsibleParticipantId | INT            | **Foreign Key** (Participants.ParticipantId) | The participant managing this specific account.                                   |
| DateCreated              | DATETIME       | NOT NULL                                     | Timestamp of account creation.                                                    |

**NOTE on Calculated Columns:**
* **Balance** (`BudgetAmount - ExpenditureTotal`) will be calculated in the application layer or via a database VIEW.

---

### 1.4. Transactions Table
Records all financial events (inflow and outflow).

| Column Name         | Data Type                         | Key/Constraint                               | Notes                                                                                       |
|:--------------------|:----------------------------------|:---------------------------------------------|:--------------------------------------------------------------------------------------------|
| **TransactionId**   | INT                               | **Primary Key** (Auto-Increment)             | Unique transaction identifier.                                                              |
| **SyncId**          | INT                               | **ForeignKey (SyncLog.SyncId)**              | Keep track of its sync status                                                               |
| AccountId           | INT                               | **Foreign Key** (Accounts.AccountId)         | The specific account this transaction affects.                                              |
| IsIgnored           | BOOL                              | NOT NULL                                     | Specifies whether the user chose to ignore the transaction                                  |
| Date                | DATETIME                          | NOT NULL                                     | Date and time the transaction occurred.                                                     |
| VendorId            | **Foreign key**(Vendors.VendorId) | NOT NULL                                     | if new, new vendor created, id stored                                                       |
| Amount              | DECIMAL(10, 2)                    | NOT NULL                                     | The monetary value of the transaction. (Always positive; direction defined by `IsMoneyIn`). |
| ParticipantId       | INT                               | **Foreign Key** (Participants.ParticipantId) | The participant who recorded/initiated the transaction.                                     |
| EditorParticipantId | INT                               | **Foreign Key** (Participants.ParticipantId) | The participant whose account was used to upload document.                                  |
| Reason              | TEXT                              | NULLABLE                                     | Detailed description of the transaction.                                                    |

### 1.4(b) TransactionEditHistory table
| Column Name           | Data Type    | Key/Constraint                               | Notes                                                      |
|:----------------------|:-------------|:---------------------------------------------|:-----------------------------------------------------------|
| **TransactionEditId** | INT          | **Primary key** (Auto Increment)             | Unique transaction edit identifier                         |
| EditorParticipantId   | INT          | **Foreign Key** (Participants.ParticipantId) | The participant whose account was used to upload document. |
| TransactionId         | INT          | **Foreign Key** (Transactions.TransactionId) | The transaction modified                                   |
| EditedField           | VarChar(100) | NOT NULL                                     | The field modified                                         |
| OriginalValue         | VarChar(250) | NOT NULL                                     | The value that existed in the field originally             |
| NewValue              | VarChar(250) | NOT NULL                                     | The value added by the user                                |
| TimeStamp             | TimeStamp    | NOT NULL                                     | The exact moment the change was saved                      |

### 1.5 Vendors Table
| Column Name  | Data Type    | Key/Constraint                  | Notes                                      |
|:-------------|:-------------|:--------------------------------|:-------------------------------------------|
| **VendorId** | INT          | **Primary key**(Auto-Increment) | Unique vendor identifier                   |
| VendorName   | VarChar(250) | NOT NULL                        | Shall be used to enable vendor recognition |


### 1.5(b) VendorPreferences Table
| Column Name               | Data Type | Key/Constraint                              | Notes                                          |
|:--------------------------|:----------|:--------------------------------------------|:-----------------------------------------------|
| **VendorPreferenceId**    | INT       | **Primary key**(Auto-Increment)             | Unique preference identifier                   |
| **VendorId**              | INT       | **Foreign key**(Vendors.VendorId)           | Unique vendor identifier                       |
| **ParticipantId**         | INT       | **Foreign Key**(Participants.ParticipantId) | Participant's with the preference              |
| (VendorId, ParticipantId) |           | **Composite UNIQUE key**                    | Only one account (ie y's transport) per vendor |


---

### 1.6. ParticipantIncome Table
Separates income history from the main user table for better normalization (1NF).

| Column Name   | Data Type      | Key/Constraint                               | Notes                                                                   |
|:--------------|:---------------|:---------------------------------------------|:------------------------------------------------------------------------|
| **IncomeId**  | INT            | **Primary Key** (Auto-Increment)             | Unique income record identifier.                                        |
| ParticipantId | INT            | **Foreign Key** (Participants.ParticipantId) | Links the income record to the owner.                                   |
| IncomeAmount  | DECIMAL(10, 2) | NOT NULL                                     | The amount of this income event.                                        |
| IncomeName    | VarChar(100)   | NULLABLE                                     | User's labeling ie, overtime, Locums                                    |
| IncomeType    | VARCHAR(100)   | NOT NULL                                     | Classification (e.g., 'Standard Salary', 'Freelance Payment', 'Bonus'). |
| DateReceived  | DATE           | NOT NULL                                     | The date the income was received.                                       |

---

### 1.7. Templates Table
Records all budget templates

| Column Name          | Data Type    | Key/Constraint                               | Notes                                                                 |
|:---------------------|:-------------|:---------------------------------------------|:----------------------------------------------------------------------|
| **TemplateId**       | INT          | **Primary Key** (Auto-Increment)             | Unique income record identifier.                                      |
| **SyncId**           | INT          | **ForeignKey**                               | Keep track of its sync status                                         |
| SpreadSheetId        | VarChar(250) | NULLABLE                                     | The template's google sheets url for retrieval.                       |
| TemplateName         | VarChar(100) | NOT NULL                                     | Friendly name chosen by creator.                                      |
| CreatorParticipantId | INT          | **Foreign Key** (participants.ParticipantId) | participant who created the template                                  |
| DateCreated          | Date         | NOT NULL                                     | Date of creation                                                      |
| TimesUsed            | INT          | NOT NULL                                     | Updated every time the user creates a budget sheet using the template |


### 1.7 (b) TemplateParticipants Junction table
Keeps track of the `template - associated participants` many to many relationship

| Column Name                 | Data Type   | Key/Constraint                               | Notes                                                           |
|:----------------------------|:------------|:---------------------------------------------|:----------------------------------------------------------------|
| TemplateId                  | INT         | **ForeignKey** (Templates.TemplateId)        | Identifies the template                                         |
| ParticipantId               | INT         | **Foreign Key** (Participants.ParticipantId) | Identifies the participant                                      |
| (TemplateId, ParticipantId) |             | Composite primary Key                        | Ensures that a participant is only associated once per template |
| PermissionRole              | VARCHAR(50) | NOT NULL                                     | The participant's role in the template                          |

### 1.8 ChartSnapshots
Keep track of chart snapshots by users

| Column Name        | Data Type     | Key/Constraint                        | Notes                                                   |
|:-------------------|:--------------|:--------------------------------------|:--------------------------------------------------------|
| SnapshotId         | INT           | **PrimaryKey**                        | Identifies the snapshot                                 |
| Name               | VAR CHAR(100) | NULLABLE                              | Human friendly name optionally added to the snapshot    |
| Configuration      | VAR CHAR      | NOT NULL                              | JSON describing all the data on the graph at the moment |
| CreatedAt          | TIMESTAMP     | NOT NULL                              | When the snapshot was taken                             |
| PermissionRole     | VARCHAR(50)   | NOT NULL                              | The participant's role in the template                  |
| AssociatedTemplate | INT           | **ForeignKey (Templates.TemplateId)** | The template whose data was used to create the graph    |


### 1.9 SyncLog
Keep Synchronizations with google cloud

| Column Name        | Data Type     | Key/Constraint                             | Notes                                                            |
|:-------------------|:--------------|:-------------------------------------------|:-----------------------------------------------------------------|
| SyncId             | INT           | **PrimaryKey**                             | Identifies the sync                                              |
| TransactionId      | INT           | **ForeignKey(Transactions.transactionId)** | The exact transaction affected                                   |
| SyncDirection      | VAR CHAR(100) | NOT NULL                                   | To remote or from remote                                         |
| Synced             | BOOL          | NOT  NULL                                  | False if only done locally                                       |
| Success            | BOOL          | NOT NULL                                   | If an error was critical, sync fails obviously                   |
| ErrorMessage       | VAR CHAR      | NULLABLE                                   | Should an error occur, it gets logged here                       |
| SheetUrl           | VAR CHAR      | NOT NULL                                   | The exact sheet in the excel responsible/ affected by the change |
| AssociatedTemplate | INT           | **ForeignKey (Templates.TemplateId)**      | The template which had its data synced                           |



---
