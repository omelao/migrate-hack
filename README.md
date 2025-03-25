# migrate-hack

**migrate-hack** is a tool designed to run Rails migrations in a deterministic, commit-by-commit manner. It’s especially useful in CI/CD pipelines or containerized environments where migrations must be applied sequentially and reproducibly.

## Features

- **Ordered Migrations:**  
  Automatically detects and orders pending Rails migrations based on commit timestamps.

- **Environment Injection (`--env`):**  
  Load a specified `.env` file to provide the necessary environment variables during the migration process.

- **File Copying (`--copy`):**  
  Copy files from a designated directory into the project before running migrations. This is especially useful for overriding credentials or configuration files that are not stored in the repository.

- **Automated Git Handling:**  
  For each pending migration, the tool:
  - Checks out the commit where the migration was introduced,
  - Installs necessary dependencies,
  - Runs the migration,
  - And then returns to the main branch.

## Dependencies

- **Git:**  
  migrate-hack relies on Git to retrieve commit information and perform checkouts. **Ensure that Git is installed** and available in your system’s PATH.

- **Ruby and Bundler:**  
  Ruby (and Bundler) are required for installing the gem and running Rails commands.

- **Bash:**  
  The tool uses a shell script as part of its logic, so a compatible Bash interpreter is required.

## Repository State

For migrate-hack to work correctly, the repository must be in a clean state (with no uncommitted changes). This ensures that Git operations (such as stashing, checking out commits, and reverting to the main branch) function as expected. Before running the tool, commit or stash any changes in your repository.

## Installation

You can install migrate-hack via RubyGems:

```bash
gem install migrate-hack
```

Alternatively, add it to your Gemfile:

```ruby
gem 'migrate-hack'
```

Then run:

```bash
bundle install
```

## Usage

Once installed, the executable `migrate-hack` will be available in your PATH. Use it with the following options:

### Command-Line Arguments

- **`--env [FILE]`**  
  Specifies the path to a `.env` file that will be sourced to load environment variables. This is useful when your migration process depends on specific configuration settings.

  **Example:**
  ```bash
  migrate-hack --env tmp/.env
  ```

- **`--copy [DIR]`**  
  Specifies a directory whose contents will be copied into the project’s directory structure before running migrations. **Important:**  
  - The files within the folder defined by `--copy` must follow the same folder structure as they belong in your project. For example, if you need to override credential files located in `config/credentials/`, the `--copy` directory should contain a `config/credentials/` folder with the appropriate files.
  - This option is particularly useful for updating credentials or other configuration files that are not synchronized with your repository.

  **Example:**
  ```bash
  migrate-hack --copy tmp/untracked/
  ```

### Combined Example

To run migrations while loading environment variables from `tmp/.env` and copying necessary files (ensuring the correct folder structure) from `tmp/untracked/`, execute:

```bash
migrate-hack --env tmp/.env --copy tmp/untracked/
```

## How It Works

1. **Parameter Parsing:**  
   The tool accepts command-line arguments either with an equal sign (e.g., `--env=tmp/.env`) or separated by a space (e.g., `--env tmp/.env`). It processes these to determine the paths for the environment file and the directory for file copying.

2. **Environment Loading:**  
   If the `--env` option is provided, the tool sources the specified `.env` file so that its environment variables are available throughout the migration process.

3. **File Copying:**  
   When the `--copy` option is used, the tool verifies that the specified directory exists. It then copies the contents into the current working directory, preserving the folder structure. This allows you to override or supply files (like credentials or configuration files) that are not committed to your repository.

4. **Migration Execution:**  
   The tool identifies pending Rails migrations and, for each migration:
   - Retrieves the commit in which the migration was introduced.
   - Checks out that specific commit.
   - Installs dependencies using `bundle install`.
   - Executes the migration with `rails db:migrate:up VERSION=<migration_version>`.
   - Returns to the main branch after cleaning up any local changes.
   
   This ensures that each migration is run in the context of the commit where it was originally created, preserving consistency and reproducibility.

## Contributing

Contributions are welcome! Please open issues or submit pull requests on our [GitHub repository](https://github.com/your-repository).

## License

migrate-hack is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

