# Board Game Library System

A simple SQL database for managing a board game rental service. Tracks games, members, physical copies, and loans.

## Schema Overview

- **Members**: Library members and their contact info.
- **Publishers**: Companies that publish the games.
- **Games**: Details about each game title (min/max players, playtime).
- **Copies**: Physical copies of games and their condition.
- **Loans**: Tracks which member borrowed which copy and when.

## Features

- Enforces data integrity with primary keys, foreign keys, and unique constraints
- Tracks multiple copies of the same game
- Manages current and historical loan records
- Uses ENUM types for specific value constraints

## How to Use

1. Run the `BoardGameLibrary.sql` script in your MySQL server.
2. The database will be created and populated with sample data.
3. Start querying the tables to manage your game library!
