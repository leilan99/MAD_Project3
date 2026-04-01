# FoodieBFF
Using the Meal DB, this app is a one-stop shop for all foodies. 
A SwiftUI recipe app for discovering, creating, and sharing recipes with a community of home cooks.

## Features

### 🔍 Browse & Discover
- Browse recipes by cuisine or popular ingredients
- Search for recipes by name
- View detailed recipes with ingredients, instructions, and images

### 📖 My Cookbook
- Save your favorite recipes from the browse catalog
- Create custom recipes with ingredients, instructions, categories, and tags
- Add photos to your custom recipes
- Tag recipes as Dinner, Quick, or Healthy for easy filtering

### 🎲 Random Dinner
- Can't decide what to cook? Get a random dinner suggestion
- Save it to your cookbook if you like it

### 👥 Community Sharing
- Share your custom recipes with other users
- Browse community recipes shared by other cooks
- Save a copy of any community recipe to your own cookbook

### 🔐 User Accounts
- Email and password authentication
- Sign out any time from the cookbook menu

## Tech Stack

- **SwiftUI** with `@Observable` pattern
- **Swift Concurrency** (async/await)
- **Supabase** — authentication, PostgreSQL database, and file storage
- **TheMealDB API** — browse recipe catalog
- **Swift Testing** framework for unit tests

## Architecture

The app follows an MV (Model-View) architecture:

- **Models** — `UserRecipe`, `MealDTO`, `MealTag`, and related types
- **Services** — `MealService` (API), `SupabaseService` (database/auth/storage)
- **CookbookStore** — central state manager for recipes, bridging local state with cloud persistence
- **AuthViewModel** — handles authentication state and session management
- **Views** — SwiftUI views organized by feature
