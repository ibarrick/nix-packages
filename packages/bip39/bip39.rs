use std::fs;
use std::io::{Read, Write};
use std::path::Path;
use bip39::{Mnemonic, Language};
use sha2::{Sha256, Digest};
use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Generate BIP39 mnemonic from a file
    Generate {
        /// Input file path
        #[arg(short, long)]
        input: String,
    },
    /// Convert BIP39 mnemonic back to a file
    Convert {
        /// BIP39 mnemonic phrase
        #[arg(short, long)]
        mnemonic: String,
        /// Output file path
        #[arg(short, long)]
        output: String,
    },
}

fn file_to_bip39<P: AsRef<Path>>(file_path: P) -> Result<String, Box<dyn std::error::Error>> {
    let mut file = fs::File::open(file_path)?;
    let mut buffer = Vec::new();
    file.read_to_end(&mut buffer)?;

    let mut hasher = Sha256::new();
    hasher.update(&buffer);
    let result = hasher.finalize();

    let mnemonic = Mnemonic::from_entropy(&result, Language::English)?;
    Ok(mnemonic.phrase().to_string())
}

fn bip39_to_file<P: AsRef<Path>>(mnemonic: &str, output_path: P) -> Result<(), Box<dyn std::error::Error>> {
    let mnemonic = Mnemonic::from_phrase(mnemonic, Language::English)?;
    let entropy = mnemonic.entropy();

    let mut file = fs::File::create(output_path)?;
    file.write_all(entropy)?;

    Ok(())
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let cli = Cli::parse();

    match &cli.command {
        Commands::Generate { input } => {
            let mnemonic = file_to_bip39(input)?;
            println!("Generated BIP39 mnemonic: {}", mnemonic);
        }
        Commands::Convert { mnemonic, output } => {
            bip39_to_file(mnemonic, output)?;
            println!("BIP39 mnemonic converted to file: {}", output);
        }
    }

    Ok(())
}
