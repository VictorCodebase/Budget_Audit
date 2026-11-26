CREATE TABLE categories (
  category_id INTEGER PRIMARY KEY,
  category_name TEXT,
  color_hex TEXT
);

CREATE TABLE accounts (
  account_id INTEGER PRIMARY KEY,
  category_id INTEGER,
  template_id INTEGER,
  account_name TEXT,
  color_hex TEXT,
  budget_amount REAL,
  date_created INTEGER
);

CREATE TABLE templates (
  template_id INTEGER PRIMARY KEY,
  template_name TEXT,
  period TEXT,
  date_created INTEGER
);

CREATE TABLE vendors (
  vendor_id INTEGER PRIMARY KEY,
  vendor_name TEXT
);

CREATE TABLE transactions (
  transaction_id INTEGER PRIMARY KEY,
  account_id INTEGER,
  vendor_id INTEGER,
  date INTEGER,
  amount REAL,
  participant_id INTEGER,
  is_ignored INTEGER DEFAULT 0
);

CREATE TABLE vendor_match_histories (
  vendor_match_id INTEGER PRIMARY KEY,
  vendor_id INTEGER,
  account_id INTEGER,
  participant_id INTEGER,
  use_count INTEGER,
  last_used INTEGER
);

CREATE TABLE participants (
  participant_id INTEGER PRIMARY KEY,
  role TEXT
);
