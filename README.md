# practice_cli

A practical TypeScript CLI tool distributed via curl and bash.

## Installation

### Quick Install

The easiest way to install `practice_cli` is to use the install script:

```bash
curl -fsSL https://raw.githubusercontent.com/Jangidyogesh12/practice_cli/main/install.sh | bash
```

This script will:
- Automatically detect your operating system (macOS, Linux, or Windows)
- Check if Node.js is installed
- Install Node.js if needed (with your system's package manager)
- Download the latest release from GitHub
- Install `practice_cli` to `/usr/local/bin/practice_cli`

### Manual Installation

1. Install Node.js from https://nodejs.org/ (if not already installed)

2. Clone the repository:
```bash
git clone https://github.com/Jangidyogesh12/practice_cli.git
cd practice_cli
```

3. Install dependencies and build:
```bash
npm install
npm run build
```

4. Make it executable and install:
```bash
chmod +x .dist/index.js
sudo cp .dist/index.js /usr/local/bin/practice_cli
```

## Usage

After installation, you can use `practice_cli` from anywhere:

```bash
practice_cli --help
```

### Available Commands

- `hello` - Say hello

Example:
```bash
practice_cli hello
```

## Supported Platforms

- **macOS** (Intel & Apple Silicon) - requires Homebrew for Node.js installation
- **Linux** (x86_64 & ARM64) - supports apt-get, yum, and pacman package managers
- **Windows** - requires Node.js to be pre-installed

## Requirements

- Node.js v18 or higher
- Bash shell

## Troubleshooting

### "command not found: practice_cli"

Make sure `/usr/local/bin` is in your PATH:
```bash
echo $PATH | grep -q "/usr/local/bin" && echo "OK" || echo "NOT FOUND"
```

If not, add it to your shell profile:
```bash
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### "Node.js not found"

The install script will attempt to install Node.js automatically. If installation fails:

**macOS:**
```bash
brew install node
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install nodejs npm
```

**Linux (Fedora/RedHat):**
```bash
sudo yum install nodejs npm
```

**Windows:**
Download from https://nodejs.org/

## Development

### Building from Source

```bash
# Install dependencies
npm install

# Build TypeScript
npm run build

# Test the CLI
node .dist/index.js --help
```

### Creating a Release

1. Ensure code is committed and pushed
2. Create a tarball:
```bash
tar -czf practice_cli-v1.0.0.tar.gz .dist/ package.json
```

3. Create a GitHub release:
   - Go to https://github.com/Jangidyogesh12/practice_cli/releases
   - Click "Create a new release"
   - Use tag: `v1.0.0`
   - Add the tarball as an attachment
   - Publish

## License

ISC

## Author

Yogesh Sharma
